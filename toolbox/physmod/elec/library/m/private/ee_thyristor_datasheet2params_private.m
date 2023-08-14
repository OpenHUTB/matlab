function[BF_NPN,BF_PNP,IS_NPN,IS_PNP,R_on,Vt]=ee_thyristor_datasheet2params_private(V_T,I_T,T,I_GT,V_GT,V_D,R_L,Rs,Gain,BR_NPN,BR_PNP,n,Rg)























    if Rs>0
        i_GT=I_GT-V_GT/Rs;
    else
        i_GT=I_GT;
    end
    if V_GT-Rg*I_GT<0
        pm_error('physmod:simscape:compiler:patterns:checks:LessThan',getString(message('physmod:ee:library:comments:private:ee_thyristor_datasheet2params_private:error_InternalSeriesGateResistorRg')),'V_GT/I_GT')
    end
    v_GT=V_GT-Rg*I_GT;

    iL=(V_D-V_T)/R_L;
    q=1.602176487e-19;
    k=1.3806504e-23;
    Vt=n*k*T/q;
    vTol=0.001;


    IS_ratio=100;
    BF_PNP=1;
    BF=Gain/BF_PNP;
    BR=BR_NPN;


    IS=(BF*BR*iL+BF*BR*i_GT+BF*BF_PNP*BR*iL+BF*BR*BR_PNP*iL+BF*BF_PNP*BR*i_GT+BF*BR*BR_PNP*i_GT+...
    BF*BR_PNP*IS_ratio*iL+BF*BR_PNP*IS_ratio*i_GT+BF*BF_PNP*BR_PNP*IS_ratio*iL+BF*BF_PNP*BR_PNP*IS_ratio*i_GT+...
    BF*BR*BR_PNP*IS_ratio*i_GT+BF*BF_PNP*BR*BR_PNP*IS_ratio*iL+BF*BF_PNP*BR*BR_PNP*IS_ratio*i_GT)/((exp(v_GT/Vt)-1)*...
    (BR+BF*BR+BF_PNP*BR+BR*BR_PNP+BR_PNP*IS_ratio+BF*BF_PNP*BR+BF*BR*BR_PNP+BF*BR_PNP*IS_ratio+...
    BF_PNP*BR_PNP*IS_ratio+BR*BR_PNP*IS_ratio+BF*BF_PNP*BR_PNP*IS_ratio+BF_PNP*BR*BR_PNP*IS_ratio));
    if IS<1e-20
        pm_error('physmod:ee:library:RelatedMaskParameters',getString(message('physmod:ee:library:comments:private:ee_thyristor_datasheet2params_private:error_CalculatedNPNDeviceSaturationCurrentIsUnrealisticallySmal')))
    end
    IS_PNP=IS/IS_ratio;



    V_GTsat=Vt*log(I_T/(IS*(1+1/BF)));
    Vc_max=V_D;
    Vc_min=0;
    iL=I_T;
    not_converged=true;max_iter=100;iter=0;
    while not_converged
        iter=iter+1;
        if iter>max_iter
            pm_error('physmod:ee:library:InitializationFailedToConverge',getString(message('physmod:ee:library:comments:private:ee_thyristor_datasheet2params_private:error_ThyristorSubcomponentParameters')))
        end
        Vc=(Vc_max+Vc_min)/2;
        V=Vc+Vt*log((BF_PNP*IS_PNP+BR_PNP*IS_PNP+...
        BF_PNP*BR_PNP*(iL-(BF*iL+BR*iL+BF*i_GT-...
        (BF*iL)/exp((Vc-V_GTsat)/Vt)-(BF*i_GT)/exp((Vc-...
        V_GTsat)/Vt)-BR*iL*exp(V_GTsat/Vt)+...
        BF*BR*i_GT*exp(V_GTsat/Vt)-(BF*BR*i_GT)/exp((Vc-...
        V_GTsat)/Vt))/(BR-BR*exp(V_GTsat/Vt)-...
        BF*BR*exp(V_GTsat/Vt)+(BF*BR)/exp((Vc-V_GTsat)/Vt)))-...
        (BF_PNP*IS_PNP)/exp((Vc-V_GTsat)/Vt))/(BR_PNP*IS_PNP));
        vbe1=Vc-V;
        vbc1=Vc-V_GTsat;
        ic1_constraint=-IS_PNP*((exp(-vbe1/Vt)-exp(-vbc1/Vt))-(1/BR_PNP)*(exp(-vbc1/Vt)-1));
        ic1_calc=-(BF*iL+BR*iL+BF*i_GT-(BF*iL)/exp((Vc-...
        V_GTsat)/Vt)-(BF*i_GT)/exp((Vc-V_GTsat)/Vt)-...
        BR*iL*exp(V_GTsat/Vt)+BF*BR*i_GT*exp(V_GTsat/Vt)-...
        (BF*BR*i_GT)/exp((Vc-V_GTsat)/Vt))/(BR-BR*exp(V_GTsat/Vt)-...
        BF*BR*exp(V_GTsat/Vt)+(BF*BR)/exp((Vc-V_GTsat)/Vt));
        if ic1_calc>ic1_constraint
            Vc_max=Vc;
        else
            Vc_min=Vc;
        end
        if abs(Vc_max-Vc_min)<vTol
            not_converged=false;
        end



        if(V_D-Vc<vTol)||(Vc<vTol)
            pm_error('physmod:ee:library:RelatedMaskParameters',getString(message('physmod:ee:library:comments:private:ee_thyristor_datasheet2params_private:error_UnableToSolveForThyristorSubcomponentParametersCheckYourV')))
        end
    end
    V=Vc+Vt*log((BF_PNP*IS_PNP+BR_PNP*IS_PNP+BF_PNP*BR_PNP*(iL-...
    (BF*iL+BR*iL+BF*i_GT-(BF*iL)/exp((Vc-V_GTsat)/Vt)-...
    (BF*i_GT)/exp((Vc-V_GTsat)/Vt)-BR*iL*exp(V_GTsat/Vt)+...
    BF*BR*i_GT*exp(V_GTsat/Vt)-(BF*BR*i_GT)/exp((Vc-...
    V_GTsat)/Vt))/(BR-BR*exp(V_GTsat/Vt)-BF*BR*exp(V_GTsat/Vt)+...
    (BF*BR)/exp((Vc-V_GTsat)/Vt)))-(BF_PNP*IS_PNP)/exp((Vc-...
    V_GTsat)/Vt))/(BR_PNP*IS_PNP));
    if V>=V_T
        pm_error('physmod:simscape:compiler:patterns:checks:GreaterThan',getString(message('physmod:ee:library:comments:private:ee_thyristor_datasheet2params_private:error_OnstateVoltageV_TForOnstateCurrentI_T')),getString(message('physmod:ee:library:comments:private:ee_thyristor_datasheet2params_private:error_TheCalculatedPnJunctionVoltageDrop')))
    end
    R_on=(V_T-V)/I_T;
    BF_NPN=BF;
    IS_NPN=IS;

end



