function IS_mult_t=ee_temp_satcur(XTI,ND,EG_a,DevTemp,MeasTemp,vt)





    DTtoMT=DevTemp/MeasTemp;
    IS_mult_t=(DTtoMT)^(XTI/ND)*exp((DTtoMT-{1,'1'})*{value(EG_a,'eV'),'J/c'}/vt);


