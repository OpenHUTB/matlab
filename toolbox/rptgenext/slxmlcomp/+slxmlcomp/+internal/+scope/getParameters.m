function params=getParameters(expression)



    params=java.util.HashMap;

    if strncmp(expression,'C++SS(',6)
        timeScope=Simulink.scopes.TimeScopeBlockCfg;

        converted=timeScope.getScopeConfigurationParameters(expression);
    else
        [~,timeScope]=evalc(expression);
        converted=timeScope.getScopeConfigurationParameters();
    end

    vals=fields(converted);

    for ii=1:numel(vals)
        val=vals{ii};
        value=converted.(val);
        if isnumeric(value)
            value=num2str(value);
        end
        value=java.lang.String.valueOf(value);
        params.put(val,value);
    end
end
