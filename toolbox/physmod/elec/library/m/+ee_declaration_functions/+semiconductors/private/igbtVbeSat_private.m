function[Vbe_sat,failedToConverge]=igbtVbeSat_private(Vce_sat,Ice_sat,IS,BF,ec,VAF,Vt,Vbe_sat_min,Vbe_sat_max,max_iter)%#codegen




    coder.allowpcode('plain');

    failedToConverge=0;
    not_converged=1;
    iter=0;
    while not_converged
        Vbe_sat=(Vbe_sat_min+Vbe_sat_max)/2;
        Vbc=Vbe_sat+Vce_sat;
        i=IS*(1/BF*(exp(-Vbe_sat/(ec*Vt))-1));
        Ice_sat_calculated=i+IS*((exp(-Vbe_sat/(ec*Vt)))*(1+Vbc/VAF));
        err=Ice_sat-Ice_sat_calculated;
        if err>0
            Vbe_sat_min=Vbe_sat;
        else
            Vbe_sat_max=Vbe_sat;
        end
        if abs(err)<0.0002*Ice_sat,not_converged=0;end
        iter=iter+1;
        if iter>max_iter
            failedToConverge=1;
            not_converged=0;
        end
    end

end