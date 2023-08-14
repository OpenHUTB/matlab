function[x,y]=ellipseToPolygon(a,b,xc,yc,delta)















    M=128;
    [nu,t]=parametricSamplingDensity(a,b,delta,M);




    S=(t(2)-t(1))*(2*cumsum(nu)-nu-nu(1))/2;




    N=1+ceil(S(end));
    S=N*(S/S(end));





    [S,indx]=unique(S);
    t=t(indx);
    ts=interp1q(S(:),t(:),(1:(N-1))')';


    tsflip=ts((N-1):-1:1);
    ts=[0,ts,pi/2,(pi-tsflip),pi,(pi+ts),3*pi/2,(2*pi-tsflip),0];


    x=xc+a*cos(ts);
    y=yc+b*sin(ts);

end

function[nu,t]=parametricSamplingDensity(a,b,delta,M)








    dt=(pi/2)/M;



    t=(1:(M-1))*dt;







    nu=sqrt(1/(8*delta))*((sin(t)/b).^2+(cos(t)/a).^2).^(-1/4);



    t=[0,t,pi/2];
    nu=[sqrt((a)/(8*delta)),nu,sqrt((b)/(8*delta))];

end