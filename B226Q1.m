clear;clc
%角度转弧度
rad=@(x) x*pi/180;
degree=@(x) x*180/pi;
%初始化参数
aphla=rad(-1.5);%海底倾斜角
D0=70;%海底中心处水深
theta=rad(120);%换能器开角
d=200;%测线间距

D=@(x) D0+tan(aphla)*x;%距离海面中心x处的海深
%覆盖宽度
W=@(x) D(x)/sin(pi/2-theta/2-aphla)*sin(theta/2)+D(x)/sin(pi/2-theta/2+aphla)*sin(theta/2);
%覆盖率
eta=@(x) (D(x)/sin(pi/2-theta/2-aphla)*sin(theta/2)+...
    D(x-d)/sin(pi/2-theta/2+aphla)*sin(theta/2)-d/cos(aphla))/W(x);

result=struct;
result.W=zeros(5,9);%覆盖宽度
result.D=zeros(5,9);
result.D=zeros(5,9);
for j=100:10:140%开角theta
    theta=rad(j);
    D=@(x) D0+tan(aphla)*x;%距离海面中心x处的海深

    W=@(x) D(x)/sin(pi/2+theta/2-aphla)*sin(theta/2)+D(x)/sin(pi/2-theta/2+aphla)*sin(theta/2);

    eta=@(x) (D(x)/sin(pi/2-theta/2-aphla)*sin(theta/2)+...
    D(x-d)/sin(pi/2-theta/2+aphla)*sin(theta/2)-d/cos(aphla))/W(x);
    for i=-800:200:800%测线范围
        result.W(j/10-9,i/200+5)=W(i);
        result.D(j/10-9,i/200+5)=D(i);
        result.eta(j/10-9,i/200+5)=eta(i);
    end
end

%画图
%距离海面中心距离
D=-800:200:800;
for i=1:5
    figure(1)
    plot(D,result.W(i,:))
    xlabel('测线中心处的距离/m')
    ylabel('覆盖宽度/m')
    len_str1{i}=['多波束换能器的开角为 ',num2str(i*10+90)];
    hold on;
    
end
legend(len_str1)

for i=1:5
    figure(2)
    plot(D(2:end),result.eta(i,2:end)*100)
    xlabel('测线中心处的距离/m')
    ylabel('与前一条测线的重叠率/%')
    len_str2{i}=['多波束换能器的开角为 ',num2str(i*10+90)];
    ytickformat('percentage')
    hold on;
end
figure(2)
plot(-600:200:800,20*ones(8),'k--')
plot(-600:200:800,10*ones(8),'k--')
legend(len_str2,'Location','southwest')

%计算不同划分情况下的重叠率
for i=6:10
    b=-800;
    d=round(1600/i);
    theta=rad(120);
    D=@(x) D0+tan(aphla)*x;%距离海面中心x处的海深

    W=@(x) D(x)/sin(pi/2+theta/2-aphla)*sin(theta/2)+D(x)/sin(pi/2-theta/2+aphla)*sin(theta/2);

    eta=@(x) (D(x)/sin(pi/2-theta/2-aphla)*sin(theta/2)+...
    D(x-d)/sin(pi/2-theta/2+aphla)*sin(theta/2)-d/cos(aphla))/W(x);
    c=0;
    x=[];
    result_eta=[];
    while b<=900
        c=c+1;
        result_eta=[result_eta,eta(b)];
        x=[x,b];
        b=b+d;
    end
    figure(3)
    len_str3{i-5}=['将海面划分为 ',num2str(i),'份'];
    plot(x,result_eta*100);
    xlabel('测线中心处的距离/m')
    ylabel('与前一条测线的重叠率/%')
    ytickformat('percentage')
    hold on;
end
plot(-800:200:800,20*ones(9),'k--')
plot(-800:200:800,10*ones(9),'k--')
xlim([-800,800])
legend(len_str3,'Location','southwest')
hold on
