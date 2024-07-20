%初始值
x1=1;
x2=2;
y=3.5;
% 使用遗传算法进行最优值求解
% 2^8=256 是有8bit进行编码



calvar(1,2,3.5)
r=enco(2.5);
d=deco(r);



%变量S 201*251*10
%     东西 南北 分层

%编码十进制 海里->二进制
function r=enco(in)
    t=in/0.02+1;
    bin=dec2bin(t);%二进制生编码
    r=zeros(1,8);
    [~,s]=size(bin);%bin长度，按需补0
    w=8-s; %bin与8相差的，需要在开头补的0的个数
    for i=1:w
        r(i)=0;
    end
    for i=w+1:8
        r(i)=str2num(bin(i-w));
    end
end
%解码二进制->十进制 海里
function d=deco(in)
    de=0;
    for i=1:8
        de=de+2^(8-i)*in(i);
    end
    d=0.02*(de-1);

end

function [result]=calAarea(xmin,xmax,ymin,ymax)
%通过传入的范围索引，求解出在这个区域上的目标值 
    %将四个坐标进行转换，求解出方差
    Xmin=xmin/0.02+1;
    Xmax=xmax/0.02+1;
    Ymin=ymin/0.02+1;
    Ymax=ymax/0.02+1;
    global S;
    D=[];
    for i=1:10%测试，加一层
        middle=[];
        layer=S(Xmin:Xmax,Ymin:Ymax,i);%提取一层
        %计算平均值
        for y=1:Ymax-Ymin%沿着y方向进行遍历
            line=layer(:,y);
            t=find(line==1);
            b=max(t)+Xmin;
            s=min(t)+Xmin;
            m=(b+s)/2;
            if size(m)~=0
                middle=[middle m];
            end
        end
        if ~isnan(var(middle))
            D=[D var(middle)];
        end
    end
    result=sum(D);
    
end



function [output]=calvar(x1,x2,y)
%x1 x2 y 单位是海里，需要转换为坐标的索引   
    output=0;
    output=output+calAarea(0,x2,y,5);
    output=output+calAarea(x2,4,y,5);
    output=output+calAarea(0,x1,0,y);
    output=output+calAarea(x1,4,0,y);

end

