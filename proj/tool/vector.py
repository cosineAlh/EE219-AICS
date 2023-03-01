import torch 
import torchvision
import torchvision.transforms as transforms
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

DATA_PATH = "../data/bin/data.bin"
RESULTS_PATH = "../data/bin/vector.bin"
C_PATH = "../data/bin/correctC.bin"
IMA_PATH = "../data/bin/imA.bin"
IMB_PATH = "../data/bin/imB.bin"


if __name__=='__main__':
    with open(DATA_PATH, "rb") as f:
        data = f.read()
    
    data = np.frombuffer(data,dtype=np.int64)

    with open(RESULTS_PATH, "rb") as f:
        result_data = f.read()

    result_data = np.frombuffer(result_data,dtype=np.int64)

    # with open(IMA_PATH, "rb") as f:
    #     A_data = f.read()

    # A_data = np.frombuffer(A_data,dtype=np.int64)

    # with open(IMB_PATH, "rb") as f:
    #     B_data = f.read()

    # B_data = np.frombuffer(B_data,dtype=np.int64)

    with open(C_PATH, "rb") as f:
       C_data = f.read()

    C_data = np.frombuffer(C_data,dtype=np.int8)
    print(C_data.shape)

    result_data  = result_data[32768:32768+37632]
    for i in range(len(C_data)):
        if (result_data[i]==C_data[i]):
            print("True")

    # print(C_data[2567:2587])
    # print(result_data[32768+2567:32788+2567])

    

    
   
    # for j in range(9):
    #     C = 0
    #     for i in range(8):
    #         C = C + A_data[i+j*8]*B_data[i+j*8]
    #     print(C)
    

    # # print(correct_data[98:112])
    #print(result_data[436:443])






    #262144 40000 32768
    #327680 addr_c 40960
    #393216 addr_d 49152
    #print(correct_data[236101:236111])
    #print(result_data[40960:40970])

    #np.savetxt("fc1.txt",correct_data,fmt='%d')
    #np.savetxt("demo1.txt",result_data,fmt='%d')

    
 