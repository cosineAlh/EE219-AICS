`timescale 1ns / 1ps

module systolic_array#(
    parameter M = 5,
    parameter N = 3,
    parameter K = 4,
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,
    input [DATA_WIDTH*N-1:0] X,
    input [DATA_WIDTH*N*K-1:0] W,
    output reg [DATA_WIDTH*K-1:0] Y,
    output valid,
    output done
);

reg [DATA_WIDTH-1:0] X_reg_pipe [N-1:0];
reg [DATA_WIDTH-1:0] Y_reg_pipe [K-1:0];
reg [DATA_WIDTH-1:0] X_reg [K:0][N-1:0];
reg [DATA_WIDTH-1:0] W_reg [K-1:0][N-1:0];
reg [DATA_WIDTH-1:0] Y_reg [K-1:0][N:0];

integer m_cntr;

// Initialization
always@(posedge clk) begin
    if (rst) begin
        valid <= 0;
        done <= 0;
    end
end

// Read inputs
genvar i, j;
generate
    for (i = 0; i < N; i = i + 1) begin
        always@(*) X_reg[0][i] = X_reg_pipe[i];
    end
endgenerate

generate
    for (i = 0; i < K; i = i + 1) begin
        for (j = 0; j < N; j = j + 1) begin
            always@(*) W_reg[i][j] = W[(i*N+j+1)*DATA_WIDTH-1:(i*N+j)*DATA_WIDTH];
        end
    end
endgenerate

// Pipeline
genvar idx, idy;
generate
    for (idx = 0; idx < N; idx = idx + 1) begin
        pipe #(
            .DATA_WIDTH(DATA_WIDTH),
            .pipes(idx+1)
        )
        pipe
        (
            .clk(clk),
            .rst(rst),
            .D(X[(idx+1)*DATA_WIDTH-1:idx*DATA_WIDTH]),
            .Q(X_reg_pipe[idx])
        );
    end

    for (idy = 1; idy <= K; idy = idy + 1) begin
        pipe #(
            .DATA_WIDTH(DATA_WIDTH),
            .pipes(idy)
        )
        pipe
        (
            .clk(clk),
            .rst(rst),
            .D(Y_reg_pipe[K-idy]),
            .Q(Y[((K-idy)+1)*DATA_WIDTH-1:(K-idy)*DATA_WIDTH])
        );
    end
endgenerate      

// PE
genvar r, c;
generate
    for (r = 0; r < K; r = r + 1) begin
        for (c = 0; c < N; c = c + 1) begin
            pe #(
                .DATA_WIDTH(DATA_WIDTH)
            )
            pe
            (
                .clk(clk),
                .rst(rst),
                .w(W_reg[r][c]),
                .x_in(X_reg[r][c]),
                .y_in(Y_reg[r][c]),
                .x_out(X_reg[r+1][c]),
                .y_out(Y_reg[r][c+1])
            );
        end
    end
endgenerate

// Outputs
genvar o;
generate
    for (o = 0; o < K; o = o + 1)
        always@(*) Y_reg_pipe[o] = Y_reg[o][N];
endgenerate

// Counter
always@(posedge clk) begin
    if (rst) m_cntr <= 0;
    else begin
        m_cntr <= m_cntr + 1;

        if (m_cntr==M+N+K+1) done <= 1;
        if (m_cntr==N+K+1) valid <= 1;
    end
end

endmodule


///////////////////////////////////////
module pipe #(
    parameter integer DATA_WIDTH = 32,
    parameter integer pipes = 10
)
(
    input clk,
    input rst,
    input wire [DATA_WIDTH-1:0]  D,
    output wire [DATA_WIDTH-1:0]  Q
);

reg [DATA_WIDTH-1:0] regs [pipes-1:0];

always@(posedge clk) begin
    if (rst) begin
        regs[0] <= 0;
    end
    else begin
        regs[0] <= D;
    end
end

assign Q = regs[pipes-1]; 

genvar i;
for (i = 1; i < pipes; i = i + 1) begin
    always@(posedge clk) begin
        if(rst) regs[i] <= 0;
        else regs[i] <= regs[i-1];
    end
end

endmodule