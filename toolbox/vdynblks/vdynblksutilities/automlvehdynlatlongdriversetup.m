function[F,G,a_star,b_star]=automlvehdynlatlongdriversetup(a,b,Cy_f,Cy_r,m,I,U,V,L,Kpt,tau,aR,bR,cR)%#codegen
    coder.allowpcode('plain')

    tol=1e-3;
    [Up,Uabs]=automltirediv0prot(U,tol);
    if Uabs>1
        T_starLong=min(max(tau,L./Uabs),tau);
    else
        T_starLong=(sin(pi/2*abs(U)/1)+1)*tau/2;
    end

    Res=-(tanh(U)*(aR/Up+cR*U)+bR)/m;


    lowSpdFactorLat=autoblkssmoothstep(abs(U),0,10);
    Cy_f=Cy_f.*lowSpdFactorLat;
    Cy_r=Cy_r.*lowSpdFactorLat;
    T_starLat=L./Uabs.*lowSpdFactorLat;


    A1=-2*(Cy_f+Cy_r)/(m*Up);
    B1=2*(b*Cy_r-a*Cy_f)/(m*Up)-U;
    C1=2*Cy_f/m;
    A2=2*(b*Cy_r-a*Cy_f)/(I*Up);
    B2=-2*(a^2*Cy_f+b^2*Cy_r)/(I*Up);
    C2=2*a*Cy_f/I;


    F=[0,1,0,0,0,0;
    Res,0,0,0,V,0;
    0,0,0,1,0,U;
    0,0,0,A1,B1,0;
    0,0,0,A2,B2,0;
    0,0,0,0,1,0];
    G=[0,0;Kpt/m,0;0,0;0,C1;0,C2;0,0];
    m_T=[1,1,1,0,0,0];
    sigmaA=zeros(6);
    sigmaB=zeros(6);
    T_star=[T_starLong,T_starLong,T_starLat,T_starLat,T_starLat,T_starLat;...
    T_starLong,T_starLong,T_starLat,T_starLat,T_starLat,T_starLat;...
    T_starLong,T_starLong,T_starLat,T_starLat,T_starLat,T_starLat;...
    T_starLong,T_starLong,T_starLat,T_starLat,T_starLat,T_starLat;...
    T_starLong,T_starLong,T_starLat,T_starLat,T_starLat,T_starLat;...
    T_starLong,T_starLong,T_starLat,T_starLat,T_starLat,T_starLat];

    for idx=1:15
        sigmaA=sigmaA+(F^idx).*(T_star.^idx)./factorial(idx+1);
        sigmaB=sigmaB+(F^idx).*(T_star.^idx)./factorial(idx);
    end
    a_star=m_T*(T_star.*(eye(6)+sigmaA))*G;
    b_star=m_T*(eye(6)+sigmaB);
    a_starMax=1e3;
    a_starLongMin=.01;
    if abs(U)<1
        a_starLatMin=1;
    else
        a_starLatMin=.05;
    end
    b_starMax=1e3;
    b_starMin=1e-2;
    if a_star(1)>a_starMax
        a_star(1)=a_starMax;
    elseif a_star(1)<a_starLongMin
        a_star(1)=a_starLongMin;
    end
    if a_star(2)>a_starMax
        a_star(2)=a_starMax;
    elseif a_star(2)<a_starLatMin
        a_star(2)=a_starLatMin;
    end
    tempBInds=b_star>b_starMax;
    b_star(tempBInds)=b_starMax;
    tempBInds=b_star<b_starMin;
    b_star(tempBInds)=b_starMin;
end
