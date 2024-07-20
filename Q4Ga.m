clc
%初始值
x1=1;
x2=2;
y=3.5;
% 使用遗传算法进行最优值求解
% 2^8=256 是有8bit进行编码
calvar(1,2,3.5)
r=enco(2.5);
d=deco(r);

%生成初始群落 个体数50
X1=enco(1);
for i=2:50
    X1=[X1;rand(1,8)<0.5];
end
X2=enco(2);
for i=2:50
    X2=[X2;rand(1,8)<0.5];
end
Y=enco(3.5);
for i=2:50
    Y=[Y;rand(1,8)<0.5];
end

%评价标准
eval=@(x1,x2,y) calvar(x1,x2,y);
ex=0.6; %交换率
va=0.1; %变异率
iter=1000; %迭代次数
best=[1 2 3.5 1546.56061362170]; %最优情况
%    x1 x2 y  var


for it =1:1
    % 进行解码
    De=Deco(X1,X2,Y);
    %合法性检验
    % X1
    for i=1:50
        if De(i,1)>4%如果横向大于4海里
            De(i,1)=De(i,1)/2;
            X1(i,:)=moveR(X1(i,:));
        end
    end
    % X2
    for i=1:50
        if De(i,2)>4%如果横向大于4海里
            De(i,2)=De(i,2)/2;
            X2(i,:)=moveR(X2(i,:));
        end
    end
    % Y
    for i=1:50
        if De(i,3)>5%如果横向大于4海里
            De(i,3)=De(i,3)/2;
            Y(i,:)=moveR(Y(i,:));
        end
    end

    % 计算方差
    VAR=CalVAR(De);
    %评价指标越小越好
    ev=1./VAR*10000;
    %选取排名前10的进行轮盘法抽取样本
    [sortedV, sortIndex] = sort(ev, 'descend');
    newX1=X1(sortIndex(1:10));
    newX2=X2(sortIndex(1:10));
    newY=Y(sortIndex(1:10));
    Ten=sortedV(1:10);
    percent=Ten./sum(Ten);
    %开始加和，求取10个区间
    






    
end




%变量S 201*251*10
%     东西 南北 分层

% 按位右移>>
function result=moveR(input)
    result=0;
    result=[result input(2:end)];
end

% 对一个种群的编码计算方差
function VAR=CalVAR(De)
    VAR=inf*ones(50,1);
    for i=1:50
        VAR(i)=calvar(De(i,1),De(i,2),De(i,3));
    end
    
end

% 对一个种群进行解码
function D=Deco(X1,X2,Y)
    x1Set=zeros(50,1);
    x2Set=zeros(50,1);
    ySet=zeros(50,1);
    for i=1:50
        x1=X1(i,:);
        x2=X2(i,:);
        y=Y(i,:);
        x1Set(i)=deco(x1);
        x2Set(i)=deco(x2);
        ySet(i)=deco(y);
    end
    D=[x1Set,x2Set,ySet];
end

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
    d=0.02*(de);

end

function [result]=calAarea(xmin,xmax,ymin,ymax)
%通过传入的范围索引，求解出在这个区域上的目标值 
    %将四个坐标进行转换，求解出方差
    Xmin=round(xmin/0.02+1);
    Xmax=round(xmax/0.02+1);
    Ymin=round(ymin/0.02+1);
    Ymax=round(ymax/0.02+1);
    global S;

    %横向切片，衡量直线的竖直程度
    D=[];
    for i=1:10%测试，加一层
        middle=[];
        % [DeBug]
        % if Xmin<=0 || Xmax <=0 || Ymin <=0 || Ymax <=0
        %     [xmin,xmax,ymin,ymax]
        %     Xmin
        %     Xmax
        %     Ymin
        %     Ymax
        % end
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
    num1=sum(D);
    
    %纵向切片，衡量直线的水平程度
    D=[];
    for i=1:10%测试，加一层
        middle=[];
        layer=S(Xmin:Xmax,Ymin:Ymax,i);%提取一层
        %计算平均值
        for x=1:Xmax-Xmin%沿着y方向进行遍历
            line=layer(x,:);
            t=find(line==1);
            b=max(t)+Ymin;
            s=min(t)+Ymin;
            m=(b+s)/2;
            if size(m)~=0
                middle=[middle m];
            end
        end
        if ~isnan(var(middle))
            D=[D var(middle)];
        end
    end
    num2=sum(D);
    
    
    result=min(num1,num2);
    
end



function [output]=calvar(x1,x2,y)
%x1 x2 y 单位是海里，需要转换为坐标的索引   
    output=0;
    output=output+calAarea(0,x2,y,5);
    output=output+calAarea(x2,4,y,5);
    output=output+calAarea(0,x1,0,y);
    output=output+calAarea(x1,4,0,y);

end

