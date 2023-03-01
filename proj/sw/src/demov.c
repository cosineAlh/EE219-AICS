#include "trap.h"

#define ADDR_A      0x80800000
#define ADDR_B      0x80800000 + 0x396c0 //235200
#define ADDR_OS     0x80800000 + 0x39A44
#define ADDR_C      0x80840000
#define ADDR_B_v    0x80800000 + 0x1CB600 //235200*8
#define STEP        64
#define ADDR_temp   0x80900000

void vadd_vv(register int* vd,register int* vs1,register int* vs2){
    asm volatile( ".insn r 0x57, 0x0, 0x01, %0, %1, %2": :"r"(vd), "r"(vs1), "r"(vs2) );
}

void vmul_vv(register int* vd,register int* vs1,register int* vs2){
    asm volatile( ".insn r 0x57, 0x0, 0x25, %0, %1, %2": :"r"(vd), "r"(vs1), "r"(vs2) );
}

void vle64_v(register int* vd,int64_t rs1){
    asm volatile( ".insn r 0x7, 0x6, 0x01, %0, %1, x0": :"r"(vd), "r"(rs1));
}

void vse64_v(register int* vd,int64_t rs1){
    asm volatile( ".insn r 0x27, 0x6, 0x01, %0, %1, x0": :"r"(vd), "r"(rs1));
}

void vmac_en(register int* vs1,register int* vs2){
    asm volatile( ".insn r 0x57, 0x0, 0x68, x0, %0,%1": : "r"(vs1), "r"(vs2));
}

void vmac_sw(register int* vd){
    asm volatile( ".insn r 0x57, 0x0, 0x10, %0, x0, x0": :"r"(vd));
}

void vshift_vv(register int* vd,register int* vs1,register int* vs2){
    asm volatile( ".insn r 0x57, 0x0, 0x4b, %0, %1, %2": :"r"(vd), "r"(vs1) ,"r"(vs2) );
}

void vrelu_vv(register int* vd,register int* vs1,register int* vs2){
    asm volatile( ".insn r 0x57, 0x0, 0x01, %0, %1, %2": :"r"(vd), "r"(vs1) ,"r"(vs2) );
}

void vpool_vv(register int* vs1,register int* vs2){
    asm volatile( ".insn r 0x57, 0x0, 0x02, x0, %0, %1 ": :"r"(vs1) ,"r"(vs2) );
}


int main(){
    // //register int *reg_vx0 asm ("x0");
    register int *reg_vx1 asm ("x1");
    register int *reg_vx2 asm ("x2");
    int i,j,h,n,k;
    int64_t *p_A = (int64_t *)ADDR_A ;
    int64_t *p_B = (int64_t *)ADDR_B ;
    int64_t *p_C = (int64_t *)ADDR_C ;
    int64_t *p_t = (int64_t *)ADDR_temp ;
    int64_t *p_OS = (int64_t *)ADDR_OS;
    int64_t output_scale = *p_OS;
    
    int64_t data_A,data_B,data_C;

    for (n = 0; n < 4; n++)
    {
        for ( h = 0; h < 12; h++)
        {
            for (j = 0; j < 784; j++)
            {
                for (i = 0; i < 9; i++)
                {
                    vle64_v(reg_vx1,ADDR_A + STEP*i + j*75*8 + n*784*75*8);
                    vle64_v(reg_vx2,ADDR_B_v + STEP*i + h*75*8);
                    vmac_en(reg_vx1,reg_vx2);
                    vmac_sw(reg_vx1);
                    vse64_v(reg_vx1,ADDR_temp + 8*i + j*75*8 + n*784*75*8);
                }

                data_C = 0;
                for ( i = 72; i < 75; i++)
                {
                        data_A = p_A[i + j*75 + n*784*75];
                        data_B = p_B[i + h*75];
                        data_C += data_A * data_B;
                }
                for (i = 0; i < 9; i++)
                {
                    data_A = p_t[i + j*75 + n*784*75];
                    data_C += data_A;
                }

                p_C[n*784*12 + h*784 +j] = data_C >> output_scale;
            }
        
        }

        int64_t data_C1,data_C2;
        for ( i = 0; i < 28; i = i + 2)
        {
            for (k = 0; k < 28; k = k + 2)
            {
                data_C1 = p_C[((n*12+h)*28+i)*28+k];
                data_C2 = p_C[((n*12+h)*28+i)*28+k+1];
                if(data_C1 < data_C2){
                    data_C1 = data_C2;
                }
                data_C2 = p_C[((n*12+h)*28+i+1)*28+k];

                if (data_C1 < data_C2)
                {
                    data_C1 = data_C2;
                }
                data_C2 = p_C[((n*12+h)*28+i+1)*28+k+1];
                if (data_C1 < data_C2)
                {
                    data_C1 = data_C2;
                }
                if(data_C1 < 0){
                    data_C1 = 0;
                }
                p_A[n*2352 + h*196 + i*7 + k/2] = data_C1;

            }
            
        }


    }
    


    



    return 0 ;
}
