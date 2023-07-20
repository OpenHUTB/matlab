function[tau,TM,failedToConverge]=getDiodeTau(iRM,iF,idot,trr)%#codegen




    coder.allowpcode('plain');

    failedToConverge=0;


    ts=(iRM-iF)/idot;
    tau_rr=(trr-iRM/idot)/log(10);


    tau=(tau_rr+ts)/2;
    l10=log(10);
    a=idot;
    not_converged=1;iter=0;max_iter=100;
    while not_converged
        tau_last=tau;iter=iter+1;
        ex=exp(ts/tau);
        tau=(a*trr-iRM+iF*l10+a*ts*l10)/(2*a*l10)-(iF*l10-(iRM^2-2*ex*iRM^2+ex^2*iRM^2...
        +a^2*trr^2-2*a^2*ex*trr^2-4*ex^2*iRM^2*l10-2*a*iRM*trr+a^2*ex^2*trr^2+ex^2*iF^2*l10^2...
        +4*ex*iRM^2*l10+4*a*ex*iRM*trr-2*ex*iF*iRM*l10-2*a*ex^2*iRM*trr...
        +2*ex^2*iF*iRM*l10+a^2*ex^2*ts^2*l10^2+2*a*ex^2*iF*ts*l10^2-2*a^2*ex^2*trr*ts*l10...
        +2*a*ex*iF*trr*l10-4*a*ex*iRM*trr*l10-2*a*ex*iRM*ts*l10-2*a*ex^2*iF*trr*l10...
        +4*a*ex^2*iRM*trr*l10+2*a*ex^2*iRM*ts*l10+2*a^2*ex*trr*ts*l10)^(1/2)...
        +a*ts*l10)/(2*a*l10-2*a*ex*l10);
        if abs(tau-tau_last)<0.001*tau_rr,not_converged=0;end
        if iter>max_iter

            failedToConverge=1;
            not_converged=0;
        end
    end
    TM=-(iF*tau+a*tau^2*(1/ex-1)+a*tau*ts)/iRM;
