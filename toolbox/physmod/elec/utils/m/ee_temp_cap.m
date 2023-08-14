function[CJO_mult_t,VJ_t]=ee_temp_cap(VJ,MG_a,DevTemp,MeasTemp)







    SpiConst=ee_spiceconstants();
    CJO_Cnst=SpiConst.CJO_Cnst;
    EG_ZeroK=SpiConst.EG_ZeroK;
    EG_Alpha=SpiConst.EG_Alpha;
    EG_Beta=SpiConst.EG_Beta;
    KoverQ=SpiConst.KoverQ;

    DTtoMT=DevTemp/MeasTemp;

    EG_Tmeas=EG_ZeroK-(EG_Alpha*MeasTemp^2)/(MeasTemp+EG_Beta);
    EG_Tckt=EG_ZeroK-(EG_Alpha*DevTemp^2)/(DevTemp+EG_Beta);

    VJ_t=VJ*DTtoMT-2*DevTemp*KoverQ*1.5*log(DTtoMT)-...
    DTtoMT*EG_Tmeas+EG_Tckt;
    CJO_mult_t=1+MG_a*(CJO_Cnst*(DevTemp-MeasTemp)-(VJ_t-VJ)/VJ);

end

