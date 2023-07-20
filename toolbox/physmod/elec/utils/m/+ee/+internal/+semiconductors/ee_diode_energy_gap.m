function[EG1,XTI1]=ee_diode_energy_gap(N1,IS1,tmeas,XTI_param,XTI,t_param,IS_t2,i1_t2,v1_t2,tmeas2,EG_param,EG)



    q=1.602176487e-19;
    k=1.3806504e-23;

    switch XTI_param
    case 'ee.enum.diode.xtiParam.schottky'
        XTI1=2;
    case 'ee.enum.diode.xtiParam.custom'
        XTI1=XTI;
    otherwise
        XTI1=3;
    end

    switch t_param
    case 'ee.enum.diode.temperatureParam.iv'
        Vt2=k*tmeas2/q;
        IS_T2_tmp=i1_t2/(exp(v1_t2/N1/Vt2)-1);
        EG1=(tmeas2*k*N1*log(IS_T2_tmp/(IS1*(tmeas2/tmeas)^(XTI1/N1))))/(tmeas2/tmeas-1);
    case 'ee.enum.diode.temperatureParam.saturation'
        EG1=(tmeas2*k*N1*log(IS_t2/(IS1*(tmeas2/tmeas)^(XTI1/N1))))/(tmeas2/tmeas-1);
    case 'ee.enum.diode.temperatureParam.egap'
        switch EG_param
        case 'ee.enum.diode.egapParam.material_si'
            EG1=1.11;
        case 'ee.enum.diode.egapParam.material_4h_sic'
            EG1=3.23;
        case 'ee.enum.diode.egapParam.material_6h_sic'
            EG1=3.00;
        case 'ee.enum.diode.egapParam.material_ge'
            EG1=0.67;
        case 'ee.enum.diode.egapParam.material_gaas'
            EG1=1.43;
        case 'ee.enum.diode.egapParam.material_se'
            EG1=1.74;
        case 'ee.enum.diode.egapParam.material_schottky'
            EG1=0.69;
        otherwise
            EG1=EG;
        end
    otherwise
        EG1=1.11;
    end

    assert(EG1>0);
