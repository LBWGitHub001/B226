xmin=3;
xmax=4;
ymin=0;
ymax=4;
Xmin=xmin/0.02+1
Xmax=xmax/0.02+1
Ymin=ymin/0.02+1
Ymax=ymax/0.02+1
    %%根据范围中的点进行平面拟合，并且进行划线
    % 提取 x、y、z 坐标
    len=(Xmax-Xmax+1)*(Ymax-Ymin+1);
    block=submarine(Xmin:Xmax,Ymin:Ymax);
    x=zeros(1,len);
    y=zeros(1,len);
    z=zeros(1,len);
    for i=1:Xmax-Xmin+1
        for j=1:Ymax-Ymin+1
            index=(i-1)*(Ymax-Ymin+1)+j;
            x(index)=(j-1)*0.02;
            y(index)=(i-1)*0.02;
            z(index)=block(i,j);
        end
    end
    
    [r ~]=FitPlane(x,y,z);
    r
    c=r.p00;
    a=r.p10;
    b=r.p01;
    
    
    
    figure('Name','海底测线绘制')
















