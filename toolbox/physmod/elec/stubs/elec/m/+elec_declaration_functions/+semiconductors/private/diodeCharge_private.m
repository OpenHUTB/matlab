function[TT,tau,failedToConverge]=diodeCharge_private(Irrm,iF,didt,trr)




    coder.allowpcode('plain');


    failedToConverge=0;


    a=didt;
    ts=(Irrm-iF)/a;
    tau_rr=(trr-Irrm/a)/log(10);


    tau=(tau_rr+ts)/2;
    not_converged=1;iter=0;max_iter=100;ex=0;
    while not_converged
        tau_last=tau;iter=iter+1;
        ex=exp(ts/tau);l10=log(10);
        tau=(a*trr-Irrm+iF*l10+a*ts*l10)/(2*a*l10)-(iF*l10-(Irrm^2-2*ex*Irrm^2+ex^2*Irrm^2...
        +a^2*trr^2-2*a^2*ex*trr^2-4*ex^2*Irrm^2*l10-2*a*Irrm*trr+a^2*ex^2*trr^2+ex^2*iF^2*l10^2...
        +4*ex*Irrm^2*l10+4*a*ex*Irrm*trr-2*ex*iF*Irrm*l10-2*a*ex^2*Irrm*trr...
        +2*ex^2*iF*Irrm*l10+a^2*ex^2*ts^2*l10^2+2*a*ex^2*iF*ts*l10^2-2*a^2*ex^2*trr*ts*l10...
        +2*a*ex*iF*trr*l10-4*a*ex*Irrm*trr*l10-2*a*ex*Irrm*ts*l10-2*a*ex^2*iF*trr*l10...
        +4*a*ex^2*Irrm*trr*l10+2*a*ex^2*Irrm*ts*l10+2*a^2*ex*trr*ts*l10)^(1/2)...
        +a*ts*l10)/(2*a*l10-2*a*ex*l10);
        if abs(tau-tau_last)<0.001*tau_rr,not_converged=0;end
        if iter>max_iter

            failedToConverge=1;
            not_converged=0;
        end
    end
    TT=-(iF*tau+a*tau^2*(1/ex-1)+a*tau*ts)/Irrm;

end