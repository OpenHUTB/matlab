function dataDictionary(obj)




    if~isR2013bOrEarlier(obj.ver)

        return;
    end

    ddName=get_param(obj.modelName,'DataDictionary');
    if isempty(ddName)

        return;
    end


    obj.reportWarning('Simulink:ExportPrevious:DataDictionaryRemoved',...
    obj.modelName,ddName,obj.ver.release,obj.ver.release);

    if slfeature('SLModelAllowedBaseWorkspaceAccess')>0
        set_param(obj.modelName,'EnableAccessToBaseWorkspace','on')
    end
    set_param(obj.modelName,'DataDictionary','');

end

