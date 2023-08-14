function[X,Y,Z,TH,PHI,Ntot]=sphereRegular(N,R)





    if nargin==1
        R=1;
    end
    Ntot=0;
    a=(4*pi*R^2)/N;
    d=sqrt(a);
    Mtheta=round(pi/d);
    dtheta=pi/Mtheta;
    dphi=a/dtheta;
    X=[];
    Y=[];
    Z=[];
    TH=[];
    PHI=[];
    for m=0:Mtheta-1
        theta=pi*(m+0.5)/Mtheta;
        Mphi=round(2*pi*sin(theta)/dphi);
        for n=0:Mphi-1
            phi=2*pi*n/Mphi;
            x=R*sin(theta)*cos(phi);
            y=R*sin(theta)*sin(phi);
            z=R*cos(theta);
            Ntot=Ntot+1;
            X=[X;x];
            Y=[Y;y];
            Z=[Z;z];
            TH=[TH,theta];
            PHI=[PHI,phi];
        end
    end


