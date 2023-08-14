function globalWksName=getGlobalWorkspaceName(dataDictionary)






    if isempty(dataDictionary)
        globalWksName='base workspace';
    else
        globalWksName=dataDictionary;
    end

end
