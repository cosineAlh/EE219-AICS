import torch 
import torchvision
import torchvision.transforms as transforms
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

DATA_PATH = "../data/bin/correctC.bin"
RESULTS_PATH = "../data/bin/saveA2.bin"
IMA_PATH = "../data/bin/imA.bin"
IMB_PATH = "../data/bin/imB.bin"


if __name__=='__main__':
    with open(DATA_PATH, "rb") as f:
        correct_data = f.read()
    
    correct_data = np.frombuffer(correct_data,dtype=np.int8)

    with open(RESULTS_PATH, "rb") as f:
        result_data = f.read()

    result_data = np.frombuffer(result_data,dtype=np.int64)

    with open(IMA_PATH, "rb") as f:
        A_data = f.read()

    A_data = np.frombuffer(A_data,dtype=np.int64)

    with open(IMB_PATH, "rb") as f:
        B_data = f.read()

    B_data = np.frombuffer(B_data,dtype=np.int64)

    result_data = result_data[32768:32768+37632]
    # r1 = np.array([],dtype=np.int8)

    # for i in range(0,1344,2):
    #    r1 = np.append(r1,result_data[i*14:(i+1)*14])
    
    print(result_data.shape)
    print(correct_data.shape)
    print(correct_data[0:8])

    # for i in range(440,443):
    #     if(result_data[i] != correct_data [i]):
    #         print("第",i,"个数据出错\t","correct:",correct_data[i],"\tresult:",result_data[i])

    # print(A_data[33204])
    # A_S = A_data[33150:33225]
    # B_S = B_data[0:75]
    # C_s = 0
    # for i in range(75):
    #     C_s += A_S[i]*B_S[i]
    # print(C_s)
    # # print(correct_data[98:112])
    #print(result_data[436:443])






    #262144 40000 32768
    #327680 addr_c 40960
    #393216 addr_d 49152
    #print(correct_data[236101:236111])
    #print(result_data[40960:40970])

    #np.savetxt("fc1.txt",correct_data,fmt='%d')
    #np.savetxt("demo1.txt",result_data,fmt='%d')

    
 