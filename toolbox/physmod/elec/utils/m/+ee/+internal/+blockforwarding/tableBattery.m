function out=tableBattery(in)










    out=in;




    prm_age=in.getValue('prm_age');
    if~isempty(prm_age)


        if contains(prm_age,'ee.enum.battery.prm_age')
            switch prm_age
            case 'ee.enum.battery.prm_age.enabledEquation'
                agingIdx=2;
            case 'ee.enum.battery.prm_age.enabledTableT'
                agingIdx=3;
            case 'ee.enum.battery.prm_age.enabledTableTandTime'
                agingIdx=4;
            otherwise
                agingIdx=1;
            end
        else
            agingIdx=eval(prm_age);
        end

        if agingIdx==2
            out=out.setValue('prm_age_resistance','ee.enum.battery.prm_age.enabled');
            out=out.setValue('prm_age_modeling','ee.enum.battery.prm_age_modeling.equation');
        elseif agingIdx==3
            out=out.setValue('prm_age_resistance','ee.enum.battery.prm_age.enabled');
            out=out.setValue('prm_age_modeling','ee.enum.battery.prm_age_modeling.tableT');
        elseif agingIdx==4
            out=out.setValue('prm_age_resistance','ee.enum.battery.prm_age.enabled');
            out=out.setValue('prm_age_modeling','ee.enum.battery.prm_age_modeling.tableTandTime');
        else
            out=out.setValue('prm_age_resistance','ee.enum.battery.prm_age.disabled');
        end
    end




    movedParameterEnumerations={'prm_age_resistance','prm_age_capacity','prm_age_modeling','prm_age_OCV',...
    'prm_dir','prm_dyn','prm_fade','prm_leak','T_dependence'};
    for parameterIdx=1:length(movedParameterEnumerations)
        parameterValue=out.getValue(movedParameterEnumerations{parameterIdx});
        if~isempty(parameterValue)
            enumValue=strrep(parameterValue,'ee.enum.battery','simscape.enum.tablebattery');
            out=out.setValue(movedParameterEnumerations{parameterIdx},enumValue);
        end
    end

    socPort=in.getValue('SOC_port');
    if~isempty(socPort)
        socPortValue=strrep(socPort,'ee.enum.enable','simscape.enum.tablebattery.enable');
        out=out.setValue('SOC_port',socPortValue);
    end

    tDependence=in.getValue('T_dependence');
    if~isempty(tDependence)
        tDependenceValue=strrep(enumValue,'ee.enum.temperature_dependence','simscape.enum.tablebattery.temperature_dependence');
        out=out.setValue('T_dependence',tDependenceValue);
    end


    if~isempty(in.getValue('extrapolation_option'))
        extrapolation_option=in.getValue('extrapolation_option');
        extrapolation_option=strrep(extrapolation_option,'ee.enum.extrapolation','simscape.enum.extrapolation');
        out=out.setValue('extrapolation_option',extrapolation_option);
    end

    tDependence=out.getValue('T_dependence');
    if~isempty(in.getValue('AH_vec'))...
        &&(isempty(tDependence)||isequal(int32(eval(tDependence)),int32(simscape.enum.tablebattery.temperature_dependence.yes)))




        AH_vec=in.getValue('AH_vec');
        out=out.setValue('AH',AH_vec);
    end


    prmFade=out.getValue('prm_fade');
    if~isempty(prmFade)&&~contains(prmFade,'simscape.enum.tablebattery.prm_fade')


        prmFadeIndex=eval(prmFade);
        out=out.setValue('prm_fade',string(prmFadeIndex+1));
    end


