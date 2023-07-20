function inActiveConfigsetsHaveMemSecMappings=inActiveCSHasMappings(modelName)





    activeCS=getActiveConfigSet(modelName);
    allCS=getConfigSets(modelName);
    inActiveConfigsetsHaveMemSecMappings=false;
    for i=1:length(allCS)
        if strcmp(allCS{i},activeCS.Name)
            continue;
        end
        currCS=getConfigSet(modelName,allCS{i});
        if currCS.isValidParam('MemSecPackage')&&...
            ~isequal(get_param(currCS,'MemSecPackage'),'--- None ---')
            inActiveConfigsetsHaveMemSecMappings=true;
            break;
        end
    end
end
