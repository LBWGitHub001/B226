%使用 智能优化算法 求解第三问，寻找最优的测线分布
%由于前面已经证明了沿着登高线测量就可以达到最大的测量效率，因此我们保证算法所找的测线都是南北走向的
%西深东浅，南北等深

%角度转弧度
rad=@(x) x*pi/180;
degree=@(x) x*180/pi;
%初始化参数
alpha=rad(1.5);%海底倾斜角
D0=110;%海底中心处水深
theta=rad(120);%换能器开角

%海里转换为米
mile=@(x) 1852*x;
haili=@(x) x/1852;
D=@(x) tan(alpha)*x+D0;%计算当前位置的深度
%覆盖宽度
W11=@(x) D(x)/sin(pi/2-theta/2-alpha)*sin(theta/2);%深水侧
W22=@(x) D(x)/sin(pi/2-theta/2+alpha)*sin(theta/2);%浅水侧
W=@(x) W11(x)+W22(x);
%覆盖率 x当前位置 d上一条测线的位置
eta=@(x,d) (D(x)/sin(pi/2-theta/2-alpha)*sin(theta/2)+...
    D(x-d)/sin(pi/2-theta/2+alpha)*sin(theta/2)-d/cos(alpha))/W(x);

%东西边界      %%2海里=3704m
west=-mile(2);
east=mile(2);

W1=@(x) W11(x)*cos(alpha);
W2=@(x) W22(x)*cos(alpha);
%以下采用m作为运算的单位
%搜索步长
step=1;
%搜索初始点
for i=west:east
    if W2(i)<i-west
        break
    end
    X=i;
end

while true
    %if W2(i)>i-W1(X(end))+X(end)
        temp=eta(i,i-X(end));
        if temp>0.1 && temp <0.13
            X=[X i]
            flag=W1(i)+i
            if flag>east
                break
            end
        end
    %end
    i=i+1;
end

X=X+3704;

