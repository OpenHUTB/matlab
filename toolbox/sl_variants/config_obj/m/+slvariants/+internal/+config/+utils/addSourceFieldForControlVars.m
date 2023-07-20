function controlVars=addSourceFieldForControlVars(controlVars)




    if~any(strcmp(fieldnames(controlVars),'Source'))
        for i=1:numel(controlVars)
            controlVars(i).Source=[];
        end
        return;
    end
    for i=1:numel(controlVars)
        if strcmp(controlVars(i).Source,getGlobalWorkspaceName_R2020b(''))

            controlVars(i).Source=getGlobalWorkspaceName('');
        end
    end
end




function globalWksName=getGlobalWorkspaceName(dataDictionary)
    if isempty(dataDictionary)
        globalWksName='base workspace';
    else
        globalWksName=dataDictionary;
    end
end




function globalWksName=getGlobalWorkspaceName_R2020b(dataDictionary)
    if isempty(dataDictionary)
        globalWksName='Base workspace';
    else
        globalWksName=dataDictionary;
    end
end
