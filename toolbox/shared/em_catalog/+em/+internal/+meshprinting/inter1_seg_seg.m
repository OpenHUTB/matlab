function[x0,y0,indicator]=inter1_seg_seg(x1,y1,x2,y2)































    A=[x1(2)-x1(1),0,-1,0;...
    0,x2(2)-x2(1),-1,0;...
    y1(2)-y1(1),0,0,-1;...
    0,y2(2)-y2(1),0,-1];
    c=[-x1(1);...
    -x2(1);...
    -y1(1);...
    -y2(1)];

    if rank(A)<4
        x0=NaN;
        y0=NaN;
        indicator=0;
        return;
    end

    X=A\c;
    t1=X(1);
    t2=X(2);
    x0=X(3);
    y0=X(4);
    indicator=(t1>=0&&t1<=1)&&(t2>=0&&t2<=1);
end



