function pVal=getResolvedParamValue(blkName,pName)










    try
        pString=get_param(blkName,pName);
        pVal=slResolve(pString,blkName,'expression');
    catch ME
        if(strcmp(ME.identifier,"Simulink:Data:SlResolveNotResolved"))
            str=getString(message("slreportgen:report:error:UnresolvableSimulinkData",...
            pString,pName,mlreportgen.utils.normalizeString(get_param(blkName,'Name'))));
            error('slreportgen:UnResolvableExpression',...
            str);
        else
            rethrow(ME);
        end
    end

    if isa(pVal,'Simulink.Data')
        pVal=pVal.Value;
    end
end