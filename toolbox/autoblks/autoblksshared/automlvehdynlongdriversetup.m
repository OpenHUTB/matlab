function[F,G,a_star,b_star]=automlvehdynlongdriversetup(aRes,bRes,cRes,m,Kpt,L,U,tau)%#codegen
    coder.allowpcode('plain')



    tol=1e-3;
    [Up,Uabs]=div0prot(U,tol);



    if Uabs>5
        T_star=max(min(tau,L./Uabs),tol);
    else
        T_star=tau;
    end

    Res=-(tanh(U)*(aRes/Up+cRes*U)+bRes)/m;


    F=[0,1;
    Res,0];
    G=[0;Kpt./m];


    m_T=[1,1];
    sigmaA=zeros(2);
    sigmaB=zeros(2);
    for idx=1:15
        sigmaA=sigmaA+(F^idx)*(T_star^idx)/factorial(idx+1);
        sigmaB=sigmaB+(F^idx)*(T_star^idx)/factorial(idx);
    end
    a_star=T_star*m_T*(eye(2)+sigmaA)*G;
    b_star=m_T*(eye(2)+sigmaB);

end
function[y,yabs]=div0prot(u,tol)%#codegen
    coder.allowpcode('plain')
    yabs=abs(u);
    ytolinds=yabs<tol;
    yabs(ytolinds)=2.*tol(ytolinds)./(3-(yabs(ytolinds)./tol(ytolinds)).^2);
    yneginds=u<0;
    y=yabs;
    y(yneginds)=-yabs(yneginds);
end