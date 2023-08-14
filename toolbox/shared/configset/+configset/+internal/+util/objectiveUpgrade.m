function isEfficiencyGeneralSelected=objectiveUpgrade(hSrc)





    isEfficiencyGeneralSelected=false;
    if isa(hSrc,'Simulink.ConfigSetRef')
        op=[];
    else
        op=hSrc.get_param('ObjectivePriorities');
    end

    found=strcmp(op,'Efficiency');
    if any(found)
        isEfficiencyGeneralSelected=true;

        idx=find(found);
        op=[op(1:idx-1),...
        {'Execution efficiency',...
        'ROM efficiency',...
        'RAM efficiency'},...
        op(idx+1:end)];

        waringtext=getString(message('RTW:configSet:EfficiencyObjAutoConversionMsg'));
        warning('Simulink:ConfigSetEfficiencyGen',waringtext);

        hSrc.set_param('ObjectivePriorities',op);
    end

