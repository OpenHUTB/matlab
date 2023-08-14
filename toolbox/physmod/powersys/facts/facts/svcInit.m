function[j,Vnom,Fnom,Qc_nom,Ql_nom,Bmax,Bmin,Vbase,Ibase,Kp,Ki]=svcInit(SystemNominal,Pbase,Qnom,Kp_Ki,gcbh)


    j=sqrt(-1);
    Vnom=SystemNominal(1);
    Fnom=SystemNominal(2);
    Qc_nom=Qnom(1);
    Ql_nom=Qnom(2);
    Bmax=Qc_nom/Pbase;
    Bmin=Ql_nom/Pbase;
    Vbase=Vnom/sqrt(3)*sqrt(2);
    Ibase=Pbase/Vnom/sqrt(3)*sqrt(2);
    Kp=Kp_Ki(1);
    Ki=Kp_Ki(2);


    SvcCback(gcbh,1);
    power_initmask();

end

