%%随机生成无线传感网络分布。
N=200;%（传感器节点个数）
SensorDiameter=100;%传感器节点分布半径 100M,从50,50开始
X=SensorDiameter*rand(2,N);%
save('TestData.mat','X');