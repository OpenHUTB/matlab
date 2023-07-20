function out=transformR2022aTLOrifice(in)




    out=in;



    orifice_spec=getValue(out,'orifice_spec');
    open_orientation=eval(getValue(out,'open_orientation'));

    area_leak=stripComments(getValue(out,'area_leak'));
    area_leak_unit=getUnit(out,'area_leak');
    area_leak_conf=getRTConfig(out,'area_leak');
    area_max=stripComments(getValue(out,'area_max'));
    area_max_unit=getUnit(out,'area_max');
    area_max_conf=getRTConfig(out,'area_max');
    opening_max=stripComments(getValue(out,'opening_max'));
    opening_max_unit=getUnit(out,'opening_max');
    opening_max_conf=getRTConfig(out,'opening_max');
    x0=stripComments(getValue(out,'x0'));
    x0_unit=getUnit(out,'x0');
    x0_conf=getRTConfig(out,'x0');
    opening_TLU=stripComments(getValue(out,'opening_TLU'));
    opening_TLU_unit=getUnit(out,'opening_TLU');
    opening_TLU_conf=getRTConfig(out,'opening_TLU_');
    opening_mdot_TLU=stripComments(getValue(out,'opening_mdot_TLU'));
    opening_mdot_TLU_unit=getUnit(out,'opening_mdot_TLU');
    opening_mdot_TLU_conf=getRTConfig(out,'opening_mdot_TLU');


    orifice_spec_val=eval(orifice_spec);
    if orifice_spec_val==1||orifice_spec_val==2

        out=setValue(out,'variable_orifice_spec',orifice_spec);
    else

        out=setValue(out,'variable_orifice_spec','fluids.thermal_liquid.valves.enum.orifice_spec.table2D_massflow_opening_pressure');
    end


    expr1=['(',opening_max,')*(',area_leak,')/(',area_max,')'];
    unit1=[opening_max_unit,'*',area_leak_unit,'/(',area_max_unit,')'];
    expr1_converted=convertUnits(expr1,unit1,x0_unit);
    if open_orientation==1
        S_min=[expr1_converted,' - (',x0,')'];
    else
        S_min=['-(',expr1_converted,') + (',x0,')'];
    end

    S_min_eval=protectedNumericConversion(S_min);
    if~isempty(S_min_eval)
        S_min=num2str(double(S_min_eval),16);
    end
    S_min_unit=x0_unit;
    S_min_conf=getExprConf({opening_max_conf,area_leak_conf,area_max_conf,x0_conf});

    out=setValue(out,'S_min',S_min);
    out=setUnit(out,'S_min',S_min_unit);
    out=setRTConfig(out,'S_min',S_min_conf);



    expr1_converted=convertUnits(expr1,unit1,opening_max_unit);
    del_S=[opening_max,'-',expr1_converted];

    del_S_eval=protectedNumericConversion(del_S);
    if~isempty(del_S_eval)
        del_S=num2str(double(del_S_eval),16);
    end
    del_S_unit=opening_max_unit;
    del_S_conf=getExprConf({opening_max_conf,area_leak_conf,area_max_conf,opening_max_conf});

    out=setValue(out,'del_S',del_S);
    out=setUnit(out,'del_S',del_S_unit);
    out=setRTConfig(out,'del_S',del_S_conf);



    opening_TLU_converted=convertUnits(opening_TLU,opening_TLU_unit,x0_unit);
    if open_orientation==1
        S_TLU=[opening_TLU_converted,' - (',x0,')'];
    else
        S_TLU=['-(',opening_TLU_converted,') + (',x0,')'];
    end

    S_TLU_eval=protectedNumericConversion(S_TLU);
    if~isempty(S_TLU_eval)
        S_TLU=mat2str(double(S_TLU_eval),16);
    end
    S_TLU_unit=x0_unit;
    S_TLU_conf=getExprConf({opening_TLU_conf,x0_conf});

    out=setValue(out,'S_TLU',S_TLU);
    out=setUnit(out,'S_TLU',S_TLU_unit);
    out=setRTConfig(out,'S_TLU',S_TLU_conf);



    if~isempty(opening_mdot_TLU)
        opening_mdot_TLU_converted=convertUnits(opening_mdot_TLU,opening_mdot_TLU_unit,x0_unit);
        if open_orientation==1
            S_flow_TLU=[opening_mdot_TLU_converted,' - (',x0,')'];
        else
            S_flow_TLU=['-(',opening_mdot_TLU_converted,') + (',x0,')'];
        end

        S_flow_TLU_eval=protectedNumericConversion(S_flow_TLU);
        if~isempty(S_flow_TLU_eval)
            S_flow_TLU=mat2str(double(S_flow_TLU_eval),16);
        end
        S_flow_TLU_unit=x0_unit;
        S_flow_TLU_conf=getExprConf({opening_mdot_TLU_conf,x0_conf});

        out=setValue(out,'S_flow_TLU',S_flow_TLU);
        out=setUnit(out,'S_flow_TLU',S_flow_TLU_unit);
        out=setRTConfig(out,'S_flow_TLU',S_flow_TLU_conf);
    end

end

function conf=getExprConf(s2)



    if all(strcmp('runtime',s2))
        conf='runtime';
    else
        conf='compiletime';
    end

end