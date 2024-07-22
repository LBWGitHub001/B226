clc;clear

%%%%%%%%%%%%%%%%%%%%%算法调参区%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%评价标准
% eval=@(x1,x2,y) calvar(x1,x2,y);
ex=0.9; %交换率
va=0.5; %变异率
iter=300; %迭代次数
best=[1 2 3.5 5]; %最优情况
%    x1 x2 y  var
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

submarine = readmatrix("附件.xlsx");
submarine = submarine(2:end,3:end);
%按照海域深度进行划分
split=zeros(251,201);
for i=1:251
    for j=1:201
        split(i,j)=round(submarine(i,j)/20);
    end
end
global S;
S=zeros(201,251,10);
for k=1:10
    for i=1:201
        for j=1:251
            if split(j,i)==k
                S(i,j,k)=1;
            end
        end
    end
end

%初始值
x1=1;
x2=2;
y=3.5;
% 使用遗传算法进行最优值求解
% 2^8=256 是有8bit进行编码
% calvar(1,2,3.5)
% r=enco(2.5);
% d=deco(r);

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



for it =1:iter
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
    newX1=X1(sortIndex(1:10),:);
    newX2=X2(sortIndex(1:10),:);
    newY=Y(sortIndex(1:10),:);
    Ten=sortedV(1:10);
    percent=Ten./sum(Ten);
    %选取best
    if sortedV(1)>best(end,4)
        index=sortIndex(1);%最大的那个ev对应的索引
        best=[best;De(index,:),sortedV(1)]
        
    end

    %开始加和，求取10个区间
    whlseed=zeros(1,10);
    for i=1:10
        whlseed(i)=sum(percent(1:i));
    end
    %随机轮选取新子代
    for i=1:50
        r=wheel(whlseed);
        X1(i,:)=newX1(r);
        X2(i,:)=newX2(r);
        Y(i,:)=newY(r);
    end


    %交换和变异
    %交换
    A=1:50;
    exchIndex=A(rand(50,1)<ex);
    for i=exchIndex
        [obj,val]=randomGen(i);
        %对x1进行操作
        temp=X1(i,val(1):val(2));
        X1(i,val(1):val(2))=X1(obj,val(1):val(2));
        X1(obj,val(1):val(2))=temp;
        %对x2进行操作
        temp=X2(i,val(1):val(2));
        X2(i,val(1):val(2))=X2(obj,val(1):val(2));
        X2(obj,val(1):val(2))=temp;
        %对x1进行操作
        temp=Y(i,val(1):val(2));
        Y(i,val(1):val(2))=Y(obj,val(1):val(2));
        Y(obj,val(1):val(2))=temp;
    end
    
    %变异
    B=1:8;
    vaIndex=A(rand(50,1)<va);
    for i=vaIndex
        index=B(rand(8,1)<va);
        for j=index
            X1(i,j)=(rand()<0.5);
            X2(i,j)=(rand()<0.5);
            Y(i,j)=(rand()<0.5);
        end
    end
    clc;
    it
    best
end

% 画图展示划分情况

x=0:0.02:4;
y=0:0.02:5;
[x,y]=meshgrid(x,y);
contour(x,y,submarine,'levels',2)
hold on
plot([best(end,1) best(end,1)],[0 best(end,3)],'LineWidth',2,'Color','r')
plot([0 4],[best(end,3) best(end,3)],'LineWidth',2,'Color','r')
plot([best(end,2) best(end,2)],[best(end,3) 5],'LineWidth',2,'Color','r')

text(0.5,4.3,"矩形 1","FontSize",30)
text(2.6,4.3,"矩形 2","FontSize",30)
text(0.1,2,"矩形","FontSize",30)
text(0.4,1.5,"3","FontSize",30)
text(2,2,"矩形 4","FontSize",30)

%%展示海域情况 
rect=best(end,:);
point2line(0,best(1),0,best(3));
point2line(best(1),4,0,best(3));
point2line(0,best(2),best(3),5);
point2line(best(2),4,best(3),5);

% 画图展示划分情况

x=0:0.02:4;
y=0:0.02:5;
[x,y]=meshgrid(x,y);
contour(x,y,submarine,'levels',2)
hold on
plot([best(end,1) best(end,1)],[0 best(end,3)],'LineWidth',2,'Color','r')
plot([0 4],[best(end,3) best(end,3)],'LineWidth',2,'Color','r')
plot([best(end,2) best(end,2)],[best(end,3) 5],'LineWidth',2,'Color','r')

text(0.5,4.3,"矩形 1","FontSize",30)
text(2.6,4.3,"矩形 2","FontSize",30)
text(0.1,2,"矩形","FontSize",30)
text(0.4,1.5,"3","FontSize",30)
text(2,2,"矩形 4","FontSize",30)

%%展示海域情况 
submarine=submarine';
% best=[1 2 3.5 11];
mile=@(x) 1852*x;
figure('Name','海底测线绘制')
%%边框
plot([0,0],[0,mile(4)],'LineWidth',1,'Color','b')
hold on;
plot([mile(0),mile(4)],[mile(5),mile(5)],'LineWidth',1,'Color','b')
plot([mile(4),mile(4)],[0,mile(5)],'LineWidth',1,'Color','b')
plot([mile(0),mile(4)],[0,0],'LineWidth',1,'Color','b')
%%分割
plot([mile(best(end,1)) mile(best(end,1))],[0 mile(best(end,3))],'LineWidth',2,'Color','r')
plot([0 mile(4)],[mile(best(end,3)) mile(best(end,3))],'LineWidth',2,'Color','r')
plot([mile(best(end,2)) mile(best(end,2))],[mile(best(end,3)) mile(5)],'LineWidth',2,'Color','r')
% %画测线
rect=best(end,:);
point2line(0,best(end,1),0,best(end,3));
point2line(best(end,1),4,0,best(end,3));
point2line(0,best(end,2),best(end,3),5);
point2line(best(end,2),4,best(end,3),5);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%函数区%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%变量S 201*251*10
%     东西 南北 分层
function [obj,val]=randomGen(self)%选择一个染色体，选择一个区间
    obj=ceil(rand()*50);
    while obj==0 || obj==self
        obj=ceil(rand()*50);
    end

    val=ceil(rand(1,2)*8);
    while val(1)==0 || val(2)==0
        obj=ceil(rand()*50);
    end
    val(1)=min(val(1),val(2));
    val(2)=max(val(1),val(2));

end



%轮盘选择法
function [result]=wheel(seed)
    r=rand();
    for i=1:10
        if seed(i)>r
            break
        end
    end
    result=i;
end

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

