function out=resolveSection(dict,sectionID)




    parts=split(sectionID,'.');

    if length(parts)>2
        DAStudio.error('SimulinkCoderApp:data:InvalidSectionName',sectionID);
    end


    if length(parts)==1
        lang='CDefinitions';
        type=parts{1};
    else
        if~strcmp(parts{1},'C_Definitions')
            DAStudio.error('SimulinkCoderApp:data:InvalidSectionName',sectionID);
        end
        lang='CDefinitions';
        type=parts{2};
    end



    if~(strcmp(type,'StorageClasses')||...
        strcmp(type,'FunctionCustomizationTemplates')||...
        strcmp(type,'MemorySections')||...
        strcmp(type,'TimerServices'))
        DAStudio.error('SimulinkCoderApp:data:InvalidSectionName',sectionID);
    end

    datamodelType=type;
    if strcmp(type,'FunctionCustomizationTemplates')
        datamodelType='FunctionClasses';
    end


    if strcmp(type,'TimerServices')
        if isempty(dict.RTEDefinition)
            coder.internal.CoderDataStaticAPI.create(dict,'RuntimeEnvironment');
        end
        out=coder.dictionary.Section(dict,dict.RTEDefinition.timerServices,type);
    else
        out=coder.dictionary.Section(dict,dict.(lang).(datamodelType),type);
    end
end


