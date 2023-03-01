module mc_cpu (
    input clk, input reset, output reg flag
);

parameter reg_width=32, num_reg=32;
parameter width=32, addr_width = 16, depth = 2**addr_width;
parameter pc_width = 16;

reg [reg_width-1:0] reg_file[0:num_reg-1];          
reg [width-1:0] data_memory[0:depth-1]; 
reg [width-1:0] instru_memory[0:2**pc_width-1];         

initial $readmemh("instru_mem.txt", instru_memory);    
initial $readmemh("data.txt", data_memory); 
initial $readmemh("rf.txt",reg_file);

localparam RST = 4'd0;
localparam IF  = 4'd1;
localparam DEC = 4'd2;
localparam RF_RD = 4'd3;
localparam EXE = 4'd4;
localparam WB  = 4'd5;
localparam MEM_R = 4'd6;
localparam MEM_W = 4'd7;

reg [3:0] state, next_state;
reg [31:0] instru, imm, addr, result;
reg [15:0] pc_count;
reg zero;
reg [4:0] rs1, rs2, rd;

always @(posedge clk)
begin
    if(reset)
    begin
        state <= RST;
    end
    else begin
        state <= next_state;
    end 
end

always @(state, reset)
begin
    case(state)
    RST: begin
         if (reset==1)
         begin
             next_state = RST;
             flag <= 0;
             pc_count <= 0;
         end
         else
         next_state = IF;
         flag = 0;
    end
    IF: begin
        if (reset==1) begin
        next_state = RST;
        flag <= 0;
        end
        else begin
            instru <= instru_memory[pc_count];
            next_state = DEC;
            flag <= 0;
        end
    end
    DEC: begin
        if (reset==1) begin
            next_state = RST;
            flag <= 0;
        end
        else begin
            casex(instru)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx0110011://R-type
            begin
                next_state = EXE;
                rs1 <= instru[19:15];
                rs2 <= instru[24:20];
                rd  <= instru[11:7];
            end
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011://beq
            begin
                next_state = EXE;
                rs1 <= instru[19:15];
                rs2 <= instru[24:20];
                imm[31:12] <= {20{instru[31]}};
                imm[11:0] <= {instru[31:25],instru[11:7]};
            end
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011://sw
            begin
                next_state = EXE;
                rs1 <= instru[19:15];
                rs2 <= instru[24:20];
                imm[11:0] <= {instru[31:25],instru[11:7]};
                imm[31:12] <= {20{instru[31]}};
            end
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011://lw
            begin
                next_state = EXE;
                rs1 <= instru[19:15];
                rd <= instru[11:7];
                imm[11:0] <= instru[31:20];
                imm[31:12] <= {20{instru[31]}};
            end
            default: begin next_state = RST; flag <= 0; end
            endcase
            flag = 0;
        end
    end
    EXE: begin
        if (reset==1) begin
            next_state = RST;
            flag = 0;
        end
        else begin
            casex(instru)
            32'b0000000xxxxxxxxxx000xxxxx0110011://ADD
            begin
                result <= reg_file[rs1] + reg_file[rs2];
                next_state = WB;
                flag <= 0;
            end
            32'b0100000xxxxxxxxxx000xxxxx0110011://SUB
            begin
                result <= reg_file[rs1] - reg_file[rs2];
                next_state = WB;
                flag <= 0;
            end
            32'b0000000xxxxxxxxxx111xxxxx0110011://AND
            begin
                result <= reg_file[rs1] & reg_file[rs2];
                next_state = WB;
                flag <= 0;
            end
            32'b0000000xxxxxxxxxx110xxxxx0110011://OR
            begin
                result <= reg_file[rs1] | reg_file[rs2];
                next_state = WB;
                flag <= 0;
            end
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011://LW
            begin
                addr <= reg_file[rs1] + imm;
                next_state = MEM_R;
                flag <= 0;
            end
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011://SW
            begin
                addr <= reg_file[rs1] + imm;
                next_state = MEM_W;
                flag <= 0;
            end
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011://BEQ
            begin
                next_state = IF;
                pc_count <= (reg_file[rs1]==reg_file[rs2])?(pc_count+imm[15:0]):(pc_count+1);
                flag <= 1;
            end
            default:
            next_state = RST;
            endcase
        end
        end
    WB: begin
        if (reset==1) begin
            next_state = RST;
            flag <= 0;
        end
        else begin
            next_state = IF;
            pc_count <= pc_count + 1;
            reg_file[rd] <= result;
            flag <= 1;
        end
        end
    MEM_R: begin
        if (reset==1) begin
            next_state = RST;
            flag <= 0;
        end
        else begin
            next_state = WB;
            result <= data_memory[addr];
            flag <= 0;
        end        
    end
    MEM_W: begin
        if (reset==1) begin
            next_state = RST;
            flag <= 0;
        end
        else begin
            next_state = IF;
            data_memory[addr] <= reg_file[rs2];
            pc_count <= pc_count+1;
            flag <= 1;
        end
    end
    default: begin next_state = RST; flag <= 0; end
    endcase
end

generate
  genvar idx_d_mem;
  for(idx_d_mem = 0; idx_d_mem < 10; idx_d_mem = idx_d_mem+1) begin: register_d_mem
    wire [31:0] tmp_data_memory;
    assign tmp_data_memory = data_memory[idx_d_mem];
  end
endgenerate

generate
  genvar idx_rf;
  for(idx_rf = 0; idx_rf < 32; idx_rf = idx_rf+1) begin: register_rf
    wire [31:0] tmp_regfile;
    assign tmp_regfile = reg_file[idx_rf];
  end
endgenerate

endmodule

