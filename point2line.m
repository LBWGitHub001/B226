% xmin=3;
% xmax=4;
% ymin=0;
% ymax=4;
% Xmin=xmin/0.02+1;
% Xmax=xmax/0.02+1;
% Ymin=ymin/0.02+1;
% Ymax=ymax/0.02+1;
function [totalLen]=point2line(xmin,xmax,ymin,ymax)
    %%根据范围中的点进行平面拟合，并且进行划线
    % 提取 x、y、z 坐标
    Xmin=xmin/0.02+1;
    Xmax=xmax/0.02+1;
    Ymin=ymin/0.02+1;
    Ymax=ymax/0.02+1;
    len=round((Xmax-Xmax+1)*(Ymax-Ymin+1));
    global submarine;
    block=submarine(Xmin:Xmax,Ymin:Ymax);
    x=zeros(1,len);
    y=zeros(1,len);
    z=zeros(1,len);
    for i=1:Xmax-Xmin+1
        for j=1:Ymax-Ymin+1
            index=round((i-1)*(Ymax-Ymin+1)+j);
            x(index)=(j-1)*0.02;
            y(index)=(i-1)*0.02;
            z(index)=block(i,j);
        end
    end
    if size(block)==[0 0]
        return
    end
    [r,~]=FitPlane(x,y,z);
    c=r.p00;
    a=r.p10
    b=r.p01
    AmoreB=0;
    if a<b  %说明y方向更平，互换x,y
        [xmin,ymin]=swap(xmin,ymin);
        [Xmin,Ymin]=swap(Xmin,Ymin);
        [xmax,ymax]=swap(xmax,ymax);
        [Xmax,Ymax]=swap(Xmax,Ymax);
        [a,b]=swap(a,b);
        AmoreB=1;
    end


    
    %海里转换为米
    mile=@(x) 1852*x;
    haili=@(x) x/1852;
    %角度转弧度
    rad=@(x) x*pi/180;
    degree=@(x) x*180/pi;
    f=@(x,y) a*x+b*y+c;
    y_s=(ymax+ymin)/2;
    %求解海底倾角
    alpha=rad(atan((f(1,y_s)-f(0,y_s))));
    %初始化参数
    %alpha=rad(1.5);%海底倾斜角
    D=@(x) a*haili(x)+b*y_s+c;
    theta=rad(120);%换能器开角

    
    %覆盖宽度
    W11=@(x) D(x)/sin(pi/2-theta/2-alpha)*sin(theta/2);%深水侧
    W22=@(x) D(x)/sin(pi/2-theta/2+alpha)*sin(theta/2);%浅水侧
    W=@(x) W11(x)+W22(x);
    %覆盖率 x当前位置 d上一条测线的位置
    eta=@(x,d) (D(x)/sin(pi/2-theta/2-alpha)*sin(theta/2)+...
        D(x-d)/sin(pi/2-theta/2+alpha)*sin(theta/2)-d/cos(alpha))/W(x);

    %东西边界      %%2海里=3704m
        west=mile(ymin);
        east=mile(ymax);
    W1=@(x) W11(x)*cos(alpha);
    W2=@(x) W22(x)*cos(alpha);
    %以下采用m作为运算的单位
    %搜索初始点 粗糙判定在10-30
    high=east;
    low=west;
    mid=(high+low)/2.0;
    iteration=0;
    while west+W2(mid)-mid<0
        mid=(high+low)/2.0;
        if west+W2(mid)-mid>0
            low=mid;
        elseif west+W2(mid)-mid<0
            high=mid;
        end  
        iteration=iteration+1;
        if iteration>500
            disp("[W]二分法初始边未收敛与最优处")
            break
        end
    end
    X=mid;
    %使用二分法进行求解，使覆盖率尽可能接近10%
    error=0.011;
    i=mid;
    while true
        temp=eta(i,i-X(end));
        if temp>0.1 && temp <0.12
            high=i;low=i;
            while temp>=0.1
                temp=eta(high,high-X(end));
                high=high+1;
            end
            %进入二分法
            mid=(high+low)/2.0;
            iteration=0;
            while temp-0.1>error || temp<=0.1
                    mid=(high+low)/2.0;
                    temp=eta(high,high-X(end));
                    if temp<0
                        low=mid;
                    elseif temp>0
                        high=mid;
                    end
                    iteration=iteration+1;
                    if iteration>500
                        disp("[W]二分法中间边未收敛与最优处")
                        break;
                    end
            end
            X=[X mid];
        end
        
        i=i+1;
        flag=W1(i)+i;
        if flag>east
           break
        end
    end
  
    loc=[xmin xmax ymin ymax];
    if AmoreB==0
        disp("横向划线")
        [~,len]=size(X);
        for i=1:len
        plot([mile(xmin) mile(xmax)],[X(i),X(i)],'Color',[0 0.5 0.5])
        hold on
        end
    else
        [~,len]=size(X);
        disp("竖向划线")
        for i=1:len
        plot([X(i) X(i)],[mile(xmin),mile(xmax)],'Color',[0 0.5 0.5]);
        hold on
        end
    end
    [s,~]=size(X);
    totalLen=s*(mile(xmax)-mile(xmin));
end



function [x,y]=swap(x1,y1)
    y=x1;
    x=y1;
end




