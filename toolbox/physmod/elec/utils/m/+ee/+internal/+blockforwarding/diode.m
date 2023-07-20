function out=diode(in)










    out=in;


    mt=in.getValue('ModelType');
    switch mt
    case '1'
        out=out.setValue('ModelType','ee.enum.diode.modelType.pwl');
        out=out.setValue('BV','inf');
        out=out.setValue('BV_unit','V');
        out=out.setValue('CJ',in.getValue('C_PWL'));
        out=out.setValue('CJ_unit',in.getValue('C_PWL_unit'));
    case '2'
        out=out.setValue('ModelType','ee.enum.diode.modelType.pwl');
        out=out.setValue('CJ',in.getValue('C_PWL'));
        out=out.setValue('CJ_unit',in.getValue('C_PWL_unit'));
        out=out.setValue('BV',in.getValue('Vz'));
        out=out.setValue('BV_unit',in.getValue('Vz_unit'));
    case '3'
        out=out.setValue('ModelType','ee.enum.diode.modelType.exponential');
        out=out.setValue('CJ',in.getValue('CJ0'));
        out=out.setValue('CJ_unit',in.getValue('CJ0_unit'));
    otherwise
        out=out.setValue('ModelType','ee.enum.diode.modelType.pwl');
        out=out.setValue('BV','inf');
        out=out.setValue('BV_unit','V');
        out=out.setValue('CJ',in.getValue('C_PWL'));
        out=out.setValue('CJ_unit',in.getValue('C_PWL_unit'));
    end

    rr=in.getValue('Q_param');
    switch rr
    case '1'
        out=out.setValue('Q_param','ee.enum.diode.recoveryParam.off');
    case '2'
        out=out.setValue('Q_param','ee.enum.diode.recoveryParam.peaktime');
    case '3'
        out=out.setValue('Q_param','ee.enum.diode.recoveryParam.transittime');
    otherwise
        out=out.setValue('Q_param','ee.enum.diode.recoveryParam.off');
    end

    out=out.setValue('iRM',in.getValue('Irrm'));
    out=out.setValue('iRM_unit',in.getValue('Irrm_unit'));
