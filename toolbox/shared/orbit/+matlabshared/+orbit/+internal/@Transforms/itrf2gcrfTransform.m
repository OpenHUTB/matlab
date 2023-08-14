function transformationMatrix=itrf2gcrfTransform(times)%#codegen












    coder.allowpcode('plain');


    times=reshape(times,1,[]);
    numTimes=numel(times);


    eop=[0;0];
    polarMotion=[0;0];


    cipData=matlabshared.orbit.internal.Transforms.PrecessionNutation;
    Ax=cipData.Ax;
    Ay=cipData.Ay;
    As=cipData.As;




    yy=times.Year;
    mm=times.Month;
    dd=times.Day;
    hh=times.Hour;
    mins=times.Minute;
    ss=times.Second;
    JD_UT1=(367*yy)-floor(7*(yy+floor((mm+9)/12))/4)+...
    floor(275*mm/9)+dd+1721013.5+(((((ss/60)+mins)/60)+hh)/24);





    JD_TT=JD_UT1+(32.184/86400);


    tTT=(JD_TT-2451545.0)./36525;
    tTT2=tTT.*tTT;
    tTT3=tTT2.*tTT;
    tTT4=tTT3.*tTT;
    tTT5=tTT4.*tTT;


    M_moon=485868.249036+1717915923.2178*tTT+31.8792*tTT2+...
    0.051635*tTT3-0.00024470*tTT4;
    M_sun=1287104.79305+129596581.0481*tTT-0.5532*tTT2+...
    0.000136*tTT3-0.00001149*tTT4;
    u_M_moon=335779.526232+1739527262.8478*tTT-12.7512*tTT2-...
    0.001037*tTT3+0.00000417*tTT4;
    D_sun=1072260.70369+1602961601.2090*tTT-6.3706*tTT2+...
    0.006593*tTT3-0.00003169*tTT4;
    OMEGA_moon=450160.398036-6962890.5431*tTT+7.4722*tTT2+...
    0.007702*tTT3-0.00005939*tTT4;




    lambda_M_mercury=4.402608842+2608.7903141574*tTT;
    lambda_M_venus=3.176146697+1021.3285546211*tTT;
    lambda_M_earth=1.753470314+628.3075849991*tTT;
    lambda_M_mars=6.203480913+334.0612426700*tTT;
    lambda_M_jupiter=0.599546497+52.9690962641*tTT;
    lambda_M_saturn=0.874016757+21.3299104960*tTT;
    lambda_M_uranus=5.481293872+7.4781598567*tTT;
    lambda_M_neptune=5.311886287+3.8133035638*tTT;
    p_lambda=0.02438175*tTT+0.00000538691*tTT2;

    nutationV=mod([mod([M_moon;M_sun;u_M_moon;D_sun;OMEGA_moon]/3600,360)*pi/180;...
    [lambda_M_mercury;lambda_M_venus;lambda_M_earth;lambda_M_mars;...
    lambda_M_jupiter;lambda_M_saturn;lambda_M_uranus;lambda_M_neptune;p_lambda]],2*pi);




    X0=-16617+2004191898*tTT-429782.9*tTT2-198618.34*tTT3+7.578*tTT4+5.9285*tTT5;
    Y0=-6951-25896*tTT-22407274.7*tTT2+1900.59*tTT3+1112.526*tTT4+0.1358*tTT5;
    S0=94+3808.65*tTT-122.68*tTT2-72574.11*tTT3+27.98*tTT4+15.62*tTT5;



    FX=ones(length(Ax),numTimes);

    FX(1307:1559,:)=repmat(tTT,[253,1]);
    FX(1560:1595,:)=repmat(tTT2,[36,1]);
    FX(1596:1599,:)=repmat(tTT3,[4,1]);
    FX(1600,:)=tTT4;

    a_p_x=Ax(:,4:17)*nutationV;
    if isempty(coder.target)
        X=sum((Ax(:,2).*sin(a_p_x)+Ax(:,3).*cos(a_p_x)).*FX);
    else
        X=sum((repmat(Ax(:,2),1,numTimes).*sin(a_p_x)+repmat(Ax(:,3),1,numTimes).*cos(a_p_x)).*FX);
    end


    FY=ones(length(Ay),numTimes);

    FY(963:1239,:)=repmat(tTT,[277,1]);
    FY(1240:1269,:)=repmat(tTT2,[30,1]);
    FY(1270:1274,:)=repmat(tTT3,[5,1]);
    FY(1275,:)=tTT4;

    a_p_y=Ay(:,4:17)*nutationV;
    if isempty(coder.target)
        Y=sum((Ay(:,2).*sin(a_p_y)+Ay(:,3).*cos(a_p_y)).*FY);
    else
        Y=sum((repmat(Ay(:,2),1,numTimes).*sin(a_p_y)+repmat(Ay(:,3),1,numTimes).*cos(a_p_y)).*FY);
    end


    FS=ones(length(As),numTimes);

    FS(34:36,:)=repmat(tTT,[3,1]);
    FS(37:61,:)=repmat(tTT2,[25,1]);
    FS(62:65,:)=repmat(tTT3,[4,1]);
    FS(66,:)=tTT4;

    a_p_s=As(:,4:17)*nutationV;
    if isempty(coder.target)
        s=sum((As(:,2).*sin(a_p_s)+As(:,3).*cos(a_p_s)).*FS);
    else
        s=sum((repmat(As(:,2),1,numTimes).*sin(a_p_s)+repmat(As(:,3),1,numTimes).*cos(a_p_s)).*FS);
    end

    X=X+X0;
    Y=Y+Y0;
    s=s+S0;


    dX=eop(1);
    dY=eop(2);
    X=mod(X*1e-6/3600+dX,360)*pi/180;
    X(X>pi)=X(X>pi)-2*pi;
    Y=mod(Y*1e-6/3600+dY,360)*pi/180;
    Y(Y>pi)=Y(Y>pi)-2*pi;
    s=mod(s*1e-6/3600,360)*pi/180;
    s=s-(X.*Y/2);
    s(s>pi)=s(s>pi)-2*pi;


    theta_ERA=mod(2*pi*(mod(JD_UT1,1)+0.7790572732640+...
    0.00273781191135448*(JD_UT1-2451545.0)),2*pi);


    xp=mod(polarMotion(1),360)*pi/180;
    yp=mod(polarMotion(2),360)*pi/180;



    d=atan(sqrt(((X.^2)+(Y.^2))./(1-(X.^2)-(Y.^2))));
    a=1./(1+cos(d));
    ac=0.26;
    aa=0.12;
    s_dash=mod(-0.0015*(((ac^2)/1.2)+(aa^2))*tTT/3600,360)*pi/180;

    initZeros=zeros(1,numTimes);
    initOnes=ones(1,numTimes);

    PN=pagemtimes(...
    permute(cat(3,...
    cat(1,1-a.*X.^2,-a.*X.*Y,X),...
    cat(1,-a.*X.*Y,1-a.*Y.^2,Y),...
    cat(1,-X,-Y,1-a.*(X.^2+Y.^2))),...
    [3,1,2]),...
    permute(cat(3,...
    cat(1,cos(s),sin(s),initZeros),...
    cat(1,-sin(s),cos(s),initZeros),...
    cat(1,initZeros,initZeros,initOnes)),...
    [3,1,2]));

    R=permute(cat(3,...
    cat(1,cos(-theta_ERA),sin(-theta_ERA),initZeros),...
    cat(1,-sin(-theta_ERA),cos(-theta_ERA),initZeros),...
    cat(1,initZeros,initZeros,initOnes)),...
    [3,1,2]);


    W_xp=[cos(xp),0,sin(xp);...
    0,1,0;...
    -sin(xp),0,cos(xp)]';
    W_yp=[1,0,0;...
    0,cos(yp),-sin(yp);...
    0,sin(yp),cos(yp)]';

    W=pagemtimes(...
    pagemtimes(permute(cat(3,...
    cat(1,cos(-s_dash),sin(-s_dash),initZeros),...
    cat(1,-sin(-s_dash),cos(-s_dash),initZeros),...
    cat(1,initZeros,initZeros,initOnes)),[3,1,2]),...
    W_xp),...
    W_yp);

    transformationMatrix=pagemtimes(pagemtimes(PN,R),W);

end


