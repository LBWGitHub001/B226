%在第一问的基础上，测线与坡面会产生一个夹角0-315
%开角120度 坡度1.5度 中心水深120m
%本题所需要做的事将第二问转化为第一问，然后利用第一问的模型进行求解

%角度转弧度
rad=@(x) x*pi/180;
degree=@(x) x*180/pi;
%初始化参数
aphla=rad(-1.5);%海底倾斜角
D0=70;%海底中心处水深
stheta=rad(120);%换能器开角
d=200;%测线间距
bate=rad(120);%题中β,偏角
H0=120;%中心海域的深度

D=@(x) D0+tan(aphla)*x;%距离海面中心x处的海深
%覆盖宽度
W=@(x) D(x)/sin(pi/2+theta/2-aphla)*sin(theta/2)+D(x)/sin(pi/2-theta/2+aphla)*sin(theta/2);
%覆盖率
eta=@(x) (D(x)/sin(pi/2-theta/2-aphla)*sin(theta/2)+...
    D(x-d)/sin(pi/2-theta/2+aphla)*sin(theta/2)-d/cos(aphla))/W(x);

%计算新的倾角
l_dir=[sin(bate),-cos(bate),0];%测线水平投影的单位方向向量
n1=[cos(bate),sin(bate),0]; %水平投影的法向量
n2=[0,cos(aphla),sin(aphla)];%平面的法向量
%化归成第一问
delta=abs(asin(sin(bate)*sin(aphla)/sqrt(cos(bate)^2*cos(aphla)^2+sin(bate)^2)));

%深度
D=@(x) H0+x*tan(aphla)*cos(bate);
%覆盖宽度
W=@(x) D(x)/sin(pi/2-theta/2-delta)*sin(theta/2)+D(x)/sin(pi/2-theta/2+delta)*sin(theta/2);
%海里转换为米
mile=@(x) 1852*x;

batearray=rad([0 45 90 135 180 225 270 315]);
result_W=zeros(8,6);
c=1;
for bate=batearray
    %深度
    D=@(x) H0+x*tan(aphla)*cos(bate);
    %覆盖宽度
    W=@(x) D(x)/sin(pi/2-theta/2-delta)*sin(theta/2)+D(x)/sin(pi/2-theta/2+delta)*sin(theta/2);
    %海里转换为米
    mile=@(x) 1852*x;
    for i=0:0.3:2.1 %8个数
        result_W(c,i/0.3+1)=W(mile(i));
    end
    c=c+1;
end 

for i=1:6
    x=0:0.3:2.1;
    plot(x,result_W(i,:));
    hold on;
    len_str{i}=['夹角为',num2str(batearray(i)),'°'];
end
legend(len_str,'Location','southwest');
xlabel('测量船距海域中心的距离/海里')
ylabel('覆盖宽度/m')














