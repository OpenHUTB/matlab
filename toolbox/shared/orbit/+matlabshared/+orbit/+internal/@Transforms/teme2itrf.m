function rItrf=teme2itrf(rTeme,time)%#codegen











    coder.allowpcode('plain');





    if coder.target('MATLAB')
        JD_UT1=juliandate(time);
    else
        yy=time.Year;
        mm=time.Month;
        dd=time.Day;
        hh=time.Hour;
        mins=time.Minute;
        ss=time.Second;
        JD_UT1=(367*yy)-floor(7*(yy+floor((mm+9)/12))/4)+...
        floor(275*mm/9)+dd+1721013.5+(((((ss/60)+mins)/60)+hh)/24);
    end



    T_UT1=(JD_UT1-2451545.0)./36525;


    xp=0;
    yp=0;



    theta_GMST=mod(((67310.54841)+(((876600*3600)+...
    (8640184.812866))*T_UT1)+(0.093104*(T_UT1.^2))-...
    ((6.2e-6)*(T_UT1.^3)))/240,360)*pi/180;


    R=permute(cat(3,...
    cat(1,cos(theta_GMST),-sin(theta_GMST),zeros(size(theta_GMST))),...
    cat(1,sin(theta_GMST),cos(theta_GMST),zeros(size(theta_GMST))),...
    cat(1,zeros(size(theta_GMST)),zeros(size(theta_GMST)),ones(size(theta_GMST)))),...
    [1,3,2]);

    W=[1,0,0;...
    0,cos(yp),-sin(yp);...
    0,sin(yp),cos(yp)]*...
    [cos(xp),0,sin(xp);...
    0,1,0;...
    -sin(xp),0,cos(xp)];


    rItrf=squeeze(pagemtimes(pagemtimes(W',R),reshape(rTeme,3,1,[])));

end


