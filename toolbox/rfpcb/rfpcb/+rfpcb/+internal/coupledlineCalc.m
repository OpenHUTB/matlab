function[Zeven,Zodd,EpsilonR_eff,epsilonRe,EpsilonRo]=coupledlineCalc(w,s,t,h,er,eta0)






    u=w/h;
    g=s/h;
    u1=(u*(20+g^2))/(10+g^2)+g*exp(-g);
    m=0.2175+(4.113+(20.36/g)^6)^-0.251+(1/323)*log(g^10/(1+(g/13.8)^10));
    alp=0.5*exp(-g);
    phi1=1+g/1.45+(g^2.09)/3.95;
    phi2=0.8645*u^0.172;
    b=0.564*((er-0.9)/(er+3))^0.053;
    a=1+(1/49)*log((u^4+(u/52)^2)/(u^4+0.432))+(1/18.7)*log(1+(u/18.1)^3);
    Fe=(1+10/u1)^(-a*b);
    epsilonRe=(er+1)/2+(er-1)*Fe/2;
    phie=phi2/(phi1*(alp*u^m+(1-alp)*u^-m));
    F1=6+(2*pi-6)*exp(-(30.666*h/w)^0.7528);
    Z01=60*log(F1*h/w+sqrt(1+(2*h/w)^2));
    Z01e=Z01/(1-Z01*phie/eta0);
    Zeven=Z01e/sqrt(epsilonRe);

    EpsilonR_eff=((er+1)/2)+((er-1)/2)*((1/(sqrt(1+12*(h/w))))+0.04*(1-(w/h))^2);
    q=exp(-1.3766-g);
    r=1+0.15*(1-(exp(1-((er-1)^2)/8.2))/(1+g^-6));
    fo1=1-exp(-0.179*g^0.15-(0.328*g^r)/(log(exp(1)+(g/7)^2.8)));
    p=exp(-0.745*g^0.295)/cosh(g^0.68);
    fo=fo1*exp(p*log(u)+q*sin(pi*log(u)/log(10)));
    n=(1/17.7+exp(-6.424-0.76*log(g)-(g/0.23)^5))*log((10+68.3*g^2)/(1+32.5*g^3.093));
    B=0.2306+(1/301.8)*log((g^10)/(1+(g/3.73)^10))+(1/5.3)*log(1+0.646*g^1.175);
    thet=1.729+1.175*log(1+0.627/(g+0.327*g^2.17));
    phio=phie-(thet/phi1)*exp((B*u^n)*log(u));
    Fo=fo*(1+10/u)^(-a*b);
    EpsilonRo=(er+1)/2+((er-1)/2)*Fo;
    Z01o=Z01/(1-Z01*phio/eta0);
    Zodd=Z01o/sqrt(EpsilonRo);
end