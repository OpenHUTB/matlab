function[X1,X1m,X2,X2m,X3,X4,Y1,Y1m,Y2,Y2m,Y3,Y4,color1,color2]=spsdrivelogo
















    R=0.15;
    a=0.5;
    b=0.6;
    c1=[200,255,180];
    c2=[120,220,255];
    d=0.01;

    X0=-R:d:R;
    Y0=-R:d:R;

    for i=1:size(X0,2)
        Y0(i)=sqrt((R^2)-X0(i)^2);
    end

    X1=X0+a;
    Y1=Y0+b;
    X1m=X1;
    Y1m=-Y0+b;

    X2=X0/2+a;
    Y2=Y0/2+b;
    X2m=X2;
    Y2m=-Y0/2+b;

    X3=[a,a-R,a-R,a];
    Y3=[b,b+R,b-R,b];

    X4=[a-R,a+R,a,a,a,a,a+R];
    Y4=[b,b,b,b+R,b-R,b,b-R];

    color1=[c1(1)/255,c1(2)/255,c1(3)/255];
    color2=[c2(1)/255,c2(2)/255,c2(3)/255];