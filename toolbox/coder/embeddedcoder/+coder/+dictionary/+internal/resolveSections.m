function sectionList=resolveSections(dict)



    switch dict.getConfigurationType
    case{'DataInterface'}
        sectionList=loc_getDataInterfaceSections(dict);
    case{'ServiceInterface'}
        sectionList=coder.dictionary.Section.empty;
    otherwise
        sectionList=loc_getDataInterfaceSections(dict);
    end

end

function sectionList=loc_getDataInterfaceSections(dict)
    lang='CDefinitions';
    langDef=dict.(lang);


    attribs=langDef.StaticMetaClass.ownedAttributes.toArray;
    attribs=attribs';
    exclusionList={'SoftwareComponentTemplates','owner','packageChecksums','Name'};
    sectionList=[];
    for i=1:length(attribs)
        if isempty(intersect(exclusionList,attribs(i).name))
            currentSection=attribs(i).name;


            if~(strcmp(currentSection,'StorageClasses')||...
                strcmp(currentSection,'FunctionCustomizationTemplates')||...
                strcmp(currentSection,'FunctionClasses')||...
                strcmp(currentSection,'MemorySections'))
                DAStudio.error('SimulinkCoderApp:data:InvalidSection',currentSection);
            end

            datamodelType=currentSection;
            if strcmp(currentSection,'FunctionCustomizationTemplates')
                datamodelType='FunctionClasses';
            end
            sectionList=[sectionList,coder.dictionary.Section(dict,dict.(lang).(datamodelType),currentSection)];%#ok<AGROW>
        end
    end
end

