%使用 智能优化算法 求解第三问，寻找最优的测线分布
%由于前面已经证明了沿着登高线测量就可以达到最大的测量效率，因此我们保证算法所找的测线都是南北走向的
%西深东浅，南北等深
clear;clc;
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
X=[22.5195312500000	66.5820312500000	113.769531250000	164.894531250000	220.769531250000	280.894531250000	346.269531250000	416.894531250000	493.894531250000	577.269531250000	667.519531250000	765.519531250000	871.519531250000	986.519531250000	1111.51953125000	1246.51953125000	1392.76953125000	1551.76953125000	1723.76953125000	1910.01953125000	2112.01953125000	2331.01953125000	2568.26953125000	2825.26953125000	3103.51953125000	3404.76953125000	3731.76953125000	4085.76953125000	4469.26953125000	4885.26953125000	5335.51953125000	5823.76953125000	6352.76953125000	6925.26953125000];
X=X-3704;
len=34;
T=100;
k=0.99;
sum=0;
for i=2:34
    sum=sum+eta(X(i),X(i)-X(i-1));
end
avg=sum/33;
while T>70
    %生成随机偏移量
    delta=2*rand()-1;
    %选择一个点偏移
    point=ceil(34*rand());
    X(point)=X(point)+delta;
    %对首进行特殊处理
    if point==1
        bool1=eta(X(2),X(2)-X(1))>0.1 && eta(X(2),X(2)-X(1))<0.2;
        bool2=X(1)-W2(X(1))<west;
        bool3=X(1)<X(2);
        b=bool1&&bool2&&bool3;
    end
    if point==34
        bool1=eta(X(34),X(34)-X(33))>0.1 && eta(X(34),X(34)-X(33))<0.2;
        bool2=X(34)+W1(X(34))>east;
        bool3=X(33)<X(34);
        b=bool1&&bool2&&bool3;
    end
    if point>1 && point <34
        bool1=eta(X(point),X(point)-X(point-1))>0.1 && eta(X(point),X(point)-X(point-1))<0.2;
        bool2=eta(X(point+1),X(point+1)-X(point))>0.1 && eta(X(point+1),X(point+1)-X(point))<0.2;
        bool3=X(point-1)<X(point);
        bool4=X(point)<X(point+1);
        b=bool1 && bool2 && bool3 && bool4;
    end

    %b==true意思是移动之后保证合法
    if b
        sum=0;
        for i=2:34
            sum=sum+eta(X(i),X(i)-X(i-1));
        end
        if avg>sum/33
            avg=sum/33;
        else
            if rand()*100 > exp(-(sum/33-avg)/T)%不符合概率，不移动
                X(point)=X(point)-delta;
            end
        end
        T=T*k
    end

end
X=X+3704;


%%导入mat文件之后调用画图功能就可以画图
%%画图
for i=1:34
    plot([0,3704],[X(i) X(i)],'Color',[0 0.5 0.5])
    hold on
end
plot([0,3704],[7408 7408],'Color',[1 0 0])
hold on
%这里还可以表示一下覆盖范围
%rectangle('Position',[,0,40,20],'edgecolor','k','facecolor','y','linewidth',2)
xlabel('南-----------------------------北')
ylabel('西-----------------------------东')
text(3400,7700,'西海岸边界') 