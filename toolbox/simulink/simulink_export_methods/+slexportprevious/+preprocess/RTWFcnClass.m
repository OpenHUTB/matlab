function RTWFcnClass(obj)










    saveAsVersionObj=obj.ver;
    modelNameNoPath=obj.modelName;

    if isR2007bOrEarlier(saveAsVersionObj)
        allCs=getConfigSets(modelNameNoPath);
        for idx=1:length(allCs)
            thisCs=getConfigSet(modelNameNoPath,allCs{idx});
            if strcmp(get_param(thisCs,'SystemTargetFile'),'autosar.tlc');
                set_param(thisCs,'SystemTargetFile','ert.tlc');
            end
        end
    end

    if isR2006bOrEarlier(saveAsVersionObj)
        try
            obj=get_param(modelNameNoPath,'RTWFcnClass');
            if~isempty(obj)
                set_param(modelNameNoPath,'RTWFcnClass',[]);
            end
        catch %#ok<CTCH>
            return;
        end
    elseif isR2007bOrEarlier(saveAsVersionObj)
        try
            obj=get_param(modelNameNoPath,'RTWFcnClass');
            if~isempty(obj)&&isa(obj,'RTW.AutosarInterface')
                set_param(modelNameNoPath,'RTWFcnClass',[]);
            end
        catch %#ok<CTCH>
            return;
        end
    end
