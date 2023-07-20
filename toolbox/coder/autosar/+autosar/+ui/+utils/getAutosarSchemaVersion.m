function schemaVersion=getAutosarSchemaVersion(m3iModelOrModelName)





    modelName='';
    m3iModel=[];
    isInterfaceDictionary=false;
    if isa(m3iModelOrModelName,'Simulink.metamodel.foundation.Domain')
        m3iModel=m3iModelOrModelName;
        [~,dictName]=autosar.dictionary.Utils.isSharedM3IModel(m3iModel);
        isInterfaceDictionary=sl.interface.dict.api.isInterfaceDictionary(dictName);
    else

        assert(~isempty(m3iModelOrModelName),'modelName cannot be empty');
        modelName=m3iModelOrModelName;
    end

    if isInterfaceDictionary

        schemaVersion=getSchemaVersionFromMetamodel(m3iModel);
    elseif strcmp(get_param(modelName,'AutosarCompliant'),'on')
        schemaVersion=get_param(model,'AutosarSchemaVersion');
    else
        m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
        if isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')
            schemaVersion=arxml.getAdaptiveDefaultSchema();
        else
            schemaVersion=arxml.getDefaultSchemaVersion();
        end
    end
end

function schemaVersion=getSchemaVersionFromMetamodel(sharedM3iModel)
    assert(autosar.dictionary.Utils.isSharedM3IModel(sharedM3iModel),...
    'Should only get here from the Interface Editor StudioApp');


    m3iRoot=sharedM3iModel.RootPackage.front();
    propName='SchemaVersion';
    toolId=['ARXML_',propName];
    m3iSchemaVerExternalToolInfo=autosar.mm.Model.getExtraExternalToolInfo(...
    m3iRoot,toolId,{'Value','Type'},{'%s','%s'});
    schemaVersion=m3iSchemaVerExternalToolInfo.Value;

    if isempty(schemaVersion)


        t=M3I.Transaction(sharedM3iModel);
        schemaVersion=arxml.getDefaultSchemaVersion();
        propName='SchemaVersion';
        toolId=['ARXML_',propName];
        autosar.mm.Model.setExtraExternalToolInfo(...
        m3iRoot,toolId,{'%s','%s'},{schemaVersion,'Enumeration'});
        t.commit();
    end
end


