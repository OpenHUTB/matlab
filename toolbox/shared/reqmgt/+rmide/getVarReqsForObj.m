function[ddReqs,ddNames,ddSources]=getVarReqsForObj(objH)




    try
        vars=Simulink.findVars(getfullname(objH),'SearchMethod','cached');
    catch ex
        if strcmp(ex.identifier,'Simulink:Data:CannotRetrieveCachedInformationBeforeUpdate')
            vars=Simulink.findVars(getfullname(objH));
        else
            vars=[];
        end
    end
    if isempty(vars)

        ddReqs=[];
        ddNames={};
        ddSources={};
    else

        [ddReqs,ddNames,ddSources]=rmide.getReqsFromDD(vars);
    end
end
