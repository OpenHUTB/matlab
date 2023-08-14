function usageProxies=getUsageProxy(context,variableName,varargin)











    usages=Simulink.findVars(context,'Name',variableName,varargin{:});



    if isempty(usages)
        usageProxies=SimulinkFixedPoint.SimulinkVariableUsageParser.VariableUsageProxy(usages);
    else
        for ii=1:numel(usages)
            usageProxies(ii)=SimulinkFixedPoint.SimulinkVariableUsageParser.VariableUsageProxy(usages(ii));%#ok<AGROW>
        end
    end
end
