#include "trap.h"

#define ADDR_A      0x80800000
#define ADDR_B      0x80800000 + 0x396c0
#define ADDR_OS     0x80800000 + 0x39A44
#define ADDR_C      0x80840000

int main() {
    int i,k,h,n;
    int64_t *p_A = (int64_t *)ADDR_A ;
    int64_t *p_B = (int64_t *)ADDR_B ;
    int64_t *p_C = (int64_t *)ADDR_C ; 
    int64_t *p_OS = (int64_t *)ADDR_OS;
    int64_t output_scale = *p_OS;
    
    int64_t data_A,data_B,data_C;

    for ( n = 0; n < 4; n++)
    {
        for (h = 0; h < 12; h++)
        {
            
            for( i=0; i<784; i++ ){
                printf("I:%d\n:",i);
                data_C = 0;
                for ( k = 0; k < 75; k++ )
                {
                    data_A = p_A[(n*784+i)*75+k];
                    data_B = p_B[h*75+k];
                    data_C += data_A * data_B;
                }
                printf("C%d:%d\t",i,data_C);
                printf("\n");
                data_C = data_C >> output_scale ;
                p_C[(n*12+h)*784+i] = data_C ;
            
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

    }
    
    
}
