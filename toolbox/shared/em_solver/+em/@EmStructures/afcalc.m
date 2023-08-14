function af=afcalc(obj,f,phi,theta)


    N=size(obj.FeedLocation,1);
    if isscalar(obj.PhaseShift)
        ps=obj.PhaseShift.*ones(1,N).*(pi/180);
    else
        ps=obj.PhaseShift.*(pi/180);
    end
    if isscalar(obj.AmplitudeTaper)
        Am=obj.AmplitudeTaper.*(ones(1,N));
    else
        Am=obj.AmplitudeTaper;
    end
    [a,b]=pol2cart(ps,Am);
    Vmn=a+1i*b;


    vp=physconst('lightspeed');
    lambda=vp/f;
    k0=2*pi/lambda;





    kx=k0.*sind(theta).*cosd(phi);
    ky=k0.*sind(theta).*sind(phi);
    kz=k0.*cosd(theta);
    element_position=obj.FeedLocation;
    N=size(element_position,1);
    xn=element_position(:,1);
    yn=element_position(:,2);
    zn=element_position(:,3);


    af=0;
    for i=1:N
        af=af+Vmn(i)*exp(1i*(kx*xn(i)+ky*yn(i)+kz*zn(i)));
    end





















end