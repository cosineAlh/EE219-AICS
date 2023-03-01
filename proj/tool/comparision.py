import torch 
import torchvision
import torchvision.transforms as transforms
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

DATA_PATH = "../data/bin/correct.bin"
RESULTS_PATH = "../data/bin/saveA.bin"



if __name__=='__main__':
    with open(DATA_PATH, "rb") as f:
        correct_data = f.read()
    
    correct_data = np.frombuffer(correct_data,dtype=np.int8)

    with open(RESULTS_PATH, "rb") as f:
        result_data = f.read()

    result_data = np.frombuffer(result_data,dtype=np.int64)

    result_data = result_data[0:12*14*14*4]
    
    print("result",result_data)
    print("correct",correct_data)
    for i in range(len(correct_data)):
        if (result_data[i]==correct_data[i]):
            print("True")

    # # print(correct_data[98:112])
    # print(result_data[0:14])

    #262144 40000 32768
    #327680 addr_c 40960
    #393216 addr_d 49152

 