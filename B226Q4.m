% clc;clear
% submarine = readmatrix("附件.xlsx");
% submarine = submarine(2:end,3:end);
% 画图展示划分情况

x=0:0.02:4;
y=0:0.02:5;
[x,y]=meshgrid(x,y);
contour(x,y,submarine,'levels',2)
hold on
plot([1 1],[0 3.5],'LineWidth',2,'Color','r')
plot([0 4],[3.5 3.5],'LineWidth',2,'Color','r')
plot([2 2],[3.5 5],'LineWidth',2,'Color','r')

text(0.5,4.3,"矩形 1","FontSize",30)
text(2.6,4.3,"矩形 2","FontSize",30)
text(0.1,2,"矩形","FontSize",30)
text(0.4,1.5,"3","FontSize",30)
text(2,2,"矩形 4","FontSize",30)

% % 海域划分情况
area=struct();
area.a1=[0,3.5,2,5];
area.a2=[2,3.5,4,5];
area.a3=[0,0,1,3.5];
area.a4=[1,0,4,3.5];

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

T=100;
k=0.99;
x=[1 2 3.5];%x1 x2 y
output=cal(x(1),x(2),x(3))


function [output]=calArea(xmin,xmax,ymin,ymax)
    global S;
    output=0;
    %数据初始化，调整为正确的数组下标
    xmin=xmin/0.02+1;
    xmax=xmax/0.02+1;
    ymin=ymin/0.02+1;
    ymax=ymax/0.02+1;
    for i=1:10
        layer=S(i,ymin:ymax,xmin:xmax);
        layer=reshape(layer,[ymax-ymin+1,xmax-xmin+1])
        sum=0;
        for j=1:251
            t=find(layer(:,j)==1);
            big=max(t);
            small=min(t);
            if size(t)==[0 0]
                big=0;
                small=0;
            end
            sum=big+small;
        end
        %横向求解均值，划线
        mean=sum/502;
        sum=0;
        for j=1:251
            t=find(layer(:,j)==1);
            big=max(t);
            small=min(t);
            if size(t)==[0 0]
                big=0;
                small=0;
            end
            sum=(big-mean)^2+(small-mean)^2;
        end
        var=sum/502;
        output=output+var;
    end
    output=output/9;

end


%根据传入的两个点，计算指标
function [output]=cal(x1,x2,y)%point 1:x1 2:x2 3:y
    output=zeros(1,4);
    output(1)=calArea(0,x2,y,5);
    output(2)=calArea(x2,4,y,5);
    output(3)=calArea(0,x1,0,y);
    output(4)=calArea(x1,4,0,y); 
end