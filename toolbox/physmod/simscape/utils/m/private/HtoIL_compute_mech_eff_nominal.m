function mech_eff_nominal=HtoIL_compute_mech_eff_nominal(params,type)











    dialog_unit_expression='1';
    evaluate=1;


    if contains(type,'fixed')
        params.displacement=params.D;
    else
        params.displacement=params.D_max;
    end

    term1=HtoIL_derive_params('term1','torque_pressure_coeff/displacement',params,dialog_unit_expression,evaluate);
    term2=HtoIL_derive_params('term2','no_load_torque/displacement/pr_nominal',params,dialog_unit_expression,evaluate);

    if contains(type,'pump')
        term3=['1/(1 + ',term1.base,' + ',term2.base,')'];
    else
        term3=['1 - (',term1.base,') - (',term2.base,')'];
    end

    eval3=protectedNumericConversion(term3);

    if~isempty(eval3)&&isfinite(eval3)
        mech_eff_nominal.base=num2str(double(eval3),16);
    else
        mech_eff_nominal.base=term3;
    end
    if all(strcmp('runtime',{params.torque_pressure_coeff.conf,params.displacement.conf,params.no_load_torque,params.pr_nominal}))
        mech_eff_nominal.conf='runtime';
    else
        mech_eff_nominal.conf='compiletime';
    end

    mech_eff_nominal.unit=dialog_unit_expression;

end





function PrOtEcTeD_EvAlUaTeD_VaLuE=protectedNumericConversion(PrOtEcTeD_ExPrEsSiOn_To_EvAlUaTe)


    try
        PrOtEcTeD_EvAlUaTeD_VaLuE=eval(PrOtEcTeD_ExPrEsSiOn_To_EvAlUaTe);
    catch
        PrOtEcTeD_EvAlUaTeD_VaLuE=[];
    end


    if numel(PrOtEcTeD_EvAlUaTeD_VaLuE)>1
        PrOtEcTeD_EvAlUaTeD_VaLuE=[];
    end

end