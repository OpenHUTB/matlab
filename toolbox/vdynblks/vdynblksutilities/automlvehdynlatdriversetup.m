function[F,g,a_star,b_star]=automlvehdynlatdriversetup(a,b,Cy_f,Cy_r,m,I,U,L)%#codegen
    coder.allowpcode('plain')



    tol=0.01;
    [U,Uabs]=automltirediv0prot(U,tol);


    lowSpdFactorLat=autoblkssmoothstep(abs(U),0,10);
    Cy_f=Cy_f.*lowSpdFactorLat;
    Cy_r=Cy_r.*lowSpdFactorLat;
    T_star=L./Uabs.*lowSpdFactorLat;


    A1=-2*(Cy_f+Cy_r)/(m*U);
    B1=2*(b*Cy_r-a*Cy_f)/(m*U)-U;
    C1=2*Cy_f/m;
    A2=2*(b*Cy_r-a*Cy_f)/(I*U);
    B2=-2*(a^2*Cy_f+b^2*Cy_r)/(I*U);
    C2=2*a*Cy_f/I;
    F=[0,1,0,U;
    0,A1,B1,0;
    0,A2,B2,0;
    0,0,1,0];
    g=[0;C1;C2;0];


    m_T=[1,0,0,0];
    sigmaA=zeros(4);
    sigmaB=zeros(4);
    for idx=1:15
        sigmaA=sigmaA+(F^idx)*(T_star^idx)/factorial(idx+1);
        sigmaB=sigmaB+(F^idx)*(T_star^idx)/factorial(idx);
    end
    a_star=T_star*m_T*(eye(4)+sigmaA)*g;
    b_star=m_T*(eye(4)+sigmaB);

end