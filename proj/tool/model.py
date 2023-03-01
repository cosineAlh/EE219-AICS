import torch 
import torchvision
import torchvision.transforms as transforms
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

CIFAR10_PATH = "../data/cifar10"
MODLE_PATH = "../data/model/model_lab1.pth"
SAVE_PATH = "../data/bin/data.bin"
CORRECT_PATH = "../data/bin/correct.bin"
CORRECTC_PATH = "../data/bin/correctC.bin"
IMA_PATH = "../data/bin/imA.bin"
IMB_PATH = "../data/bin/imB.bin"

class Network(nn.Module):
    def __init__(self):
        super(Network, self).__init__()
        self.conv1 = nn.Conv2d(3, 12, 5, bias=False)
        self.pool = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(12, 32, 3, bias=False)
        self.fc1 = nn.Linear(32 * 6 * 6, 256, bias=False)
        self.fc2 = nn.Linear(256, 64, bias=False)
        self.fc3 = nn.Linear(64, 10, bias=True)

def load_model( path ):
    model = torch.load(path)
    return model

def get_testloader():
    transform = transforms.Compose(
        [transforms.ToTensor(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))])
    testset = torchvision.datasets.CIFAR10(root=CIFAR10_PATH, train=False,
                                        download=True, transform=transform)
    testloader = torch.utils.data.DataLoader(testset, batch_size=4,
                                            shuffle=False, num_workers=2)
    return testloader 

def gen_testcase(testloader, batch=1):
    cnt = 0 
    images_set = []
    labels_set = []
    for data in testloader:
        images, labels = data
        images_set.append(images)
        labels_set.append(labels)
        cnt += 1 
        if cnt>=batch:
            break 
    return images_set, labels_set

def export_bin(filename, data_bytes):
    with open(filename, "wb") as f:
        f.write(data_bytes)

def im2col_fun(input_data, filter_h, filter_w, stride=1, pad=0):

    N, C, H, W = input_data.shape
    out_h = (H + 2*pad - filter_h)//stride + 1
    out_w = (W + 2*pad - filter_w)//stride + 1

    img = np.pad(input_data, [(0,0), (0,0), (pad, pad), (pad, pad)], 'constant')
    col = np.zeros((N, C, filter_h, filter_w, out_h, out_w), dtype='int')

    for y in range(filter_h):
        y_max = y + stride*out_h
        for x in range(filter_w):
            x_max = x + stride*out_w
            col[:, :, y, x, :, :] = img[:, :, y:y_max:stride, x:x_max:stride]

    col = col.transpose(0, 4, 5, 1, 2, 3).reshape(N*out_h*out_w, -1)
    return col.T

if __name__=='__main__':
    model = load_model(MODLE_PATH)
    test_loader = get_testloader()
    images_set, labels_set = gen_testcase(test_loader, batch=1)
    input_img = images_set[0]

    input_scale = torch.clamp(torch.round(input_img/(2**model.input_scale)), min=-128, max=127)
    print(input_scale.shape)
    conv1_output_scale = model.conv1.output_scale
    print(conv1_output_scale)
    conv1_output = torch.clamp(torch.floor(model.conv1(input_scale)/(2**conv1_output_scale )), min=-128, max=127)
    print(conv1_output.shape)
    Relu1_output = F.relu(conv1_output)
    #print(Relu1_output.shape)
    pool1_output = model.pool(F.relu(Relu1_output))
    print(pool1_output.shape)

    conv1_weight = model.conv1.weight
    conv1_w_size=conv1_weight.shape
    

    # select the data to be saved
    # save input
    total_data = np.array([],dtype=np.int8)
    the_data = im2col_fun(input_scale,conv1_w_size[2],conv1_w_size[3])
    # the_data1 = np.append(the_data[0:25][:],the_data[25:50][:],axis=1)
    # the_data1 = np.append(the_data1,the_data[50:75][:],axis=1)
    the_data1 = the_data.T
    total_data = np.append(total_data, the_data1)
    the_bin = bytes(total_data)
    export_bin( IMA_PATH, the_bin )
    # print(total_data.shape)
    #235200

    #save conv1_weight
    the_data = conv1_weight.data
    the_data = np.array(the_data,dtype=np.int8)
    total_data = np.append(total_data, the_data)
    the_bin = bytes(total_data[235200:])
    export_bin( IMB_PATH, the_bin )
    #print(total_data[235200:235210])
    #236100

    #save conv1 output scale
    the_data = conv1_output_scale
    total_data = np.append(total_data, the_data)
    #236101

    the_bin = bytes(total_data)
    export_bin( SAVE_PATH, the_bin )

    #save conv1 output
    the_data = conv1_output.data
    print(the_data.shape)
    the_data = np.array(the_data,dtype=np.int8)
    the_bin = bytes(the_data)
    export_bin( CORRECTC_PATH, the_bin )
    # print(total_data.shape)
    #273733

    #save pool1 output
    the_data = pool1_output.data
    the_data = np.array(the_data,dtype=np.int8)
    the_bin = bytes(the_data)
    export_bin( CORRECT_PATH, the_bin )
    #283141



    