function globalWksName=getGlobalWorkspaceName_R2020b(dataDictionary)








    if isempty(dataDictionary)
        globalWksName='Base workspace';
    else
        globalWksName=dataDictionary;
    end

end
