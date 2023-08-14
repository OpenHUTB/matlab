function dialog_param=HtoIL_gauge_to_abs(dialog_param_name,collected_param)








    dialog_param=collected_param;
    dialog_param.name=dialog_param_name;

    pressure_unit=collected_param.unit;

    P_atm=simscape.Value(0.101325,'MPa');
    P_atm_str=num2str(value(P_atm,pressure_unit),6);


    dialog_param.base=[dialog_param.base,' + ',P_atm_str];

end