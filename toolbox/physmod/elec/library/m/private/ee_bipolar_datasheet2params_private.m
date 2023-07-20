function[BF,IS,VAF,VBE]=ee_bipolar_datasheet2params_private(hfe,hoe,Ic,Vce,BR,T,Vbe2,Ib2,Ic2,Vce2,VAF1)






































    if nargin==11
        solve_for_VAF=false;
        VAF=VAF1;
    else
        solve_for_VAF=true;
    end


    q=simscape.Value(1.602176487e-19,'c');
    k=simscape.Value(1.3806504e-23,'J/K');


    VBE=simscape.Value(0.5,'V');
    not_converged=1;
    max_iter=10;iter=1;
    while not_converged

        if solve_for_VAF
            VAF=(BR*exp((VBE*q)/(T*k))*(Ic+VBE*hoe-Vce*hoe))/(hoe*(BR*exp((VBE*q)/(T*k))+1));
            BF=-(VAF*hfe*q)/(T*k-VAF*q+VBE*q-Vce*q);
        else
            BF=-(VAF*hfe*q)/(T*k-VAF*q+VBE*q-Vce*q);
        end

        if~isempty(Ib2)
            IS=-(BF*BR*Ib2)/(BF+BR-BR*exp((Vbe2*q)/(T*k)));
        else
            IS=-Ic2/(exp((Vbe2*q)/(T*k))*((Vbe2-Vce2)/VAF-1)-1/BR);
        end

        VBE_last=VBE;
        VBE=(T*k*log(-(IS*VAF-BR*Ic*VAF)/(BR*IS*VAF-BR*IS*VBE_last+BR*IS*Vce)))/q;
        if abs(VBE-VBE_last)<simscape.Value(1e-3,'V'),not_converged=0;end
        if iter>max_iter,not_converged=0;pm_warning('physmod:ee:library:InitializationFailedToConverge','VBE');end
        iter=iter+1;
    end


    err1=value((BF*(1-k*T/q/VAF*(1+q/k/T*(VBE-Vce)))-hfe)/hfe,'1');
    if solve_for_VAF
        err2=value(((IS/VAF)*exp(q*VBE/(k*T))-hoe)/hoe,'1');
    else
        err2=0;
    end
    err3=value((IS*(exp(q*VBE/(k*T))*(1-(VBE-Vce)/VAF)+1/BR)-Ic)/Ic,'1');
    if~isempty(Ib2)
        err4=value((IS*((1/BF)*(exp(q*Vbe2/(k*T))-1)-1/BR)-Ib2)/Ib2,'1');
    else
        err4=value((IS*(exp(q*Vbe2/(k*T))*(1-(Vbe2-Vce2)/VAF)+1/BR)-Ic2)/Ic2,'1');
    end
    if sum(abs([err1,err2,err3,err4]))>0.001
        pm_error('physmod:ee:library:InitializationFailedToConverge','BF, IS, VAF');
    end
    if VAF<0
        pm_error('physmod:simscape:compiler:patterns:checks:GreaterThanZero',getString(message('physmod:ee:library:comments:private:ee_bipolar_datasheet2params_private:error_DerivedValueForTheForwardEarlyVoltageVAFdependentOnOutput')));
    end

end




