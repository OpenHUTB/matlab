classdef(Hidden)CodeMapping





    methods(Static)


        [modelMapping,mappingType]=getOrCreateCMapping(modelName);
        [modelMapping,mappingType]=getCurrentMapping(sourceModel);
        modelMapping=get(modelName,mappingType);
        out=create(modelName,creationMode,mappingType);

        bm=getBlockMapping(modelMapping,modelElementCategory,model,blockH);
        isValid=isCodeIdentifierValidProperty(indMapping);


        resolvedName=getResolvedFunctionName(mapObj,model,modelElementCategory);
        preview=getFunctionPreview(mapObj,model,modelElementCategory);
        [functionType,functionId]=getFunctionId(mapping,functionCategory);
        id=getValidIdentifierForDialogId(mapping,functionType,functionId);


        value=getPerInstancePropertyForOutport(modelH,blockH,...
        propertyName);
        propUpdated=setPerInstancePropertyForOutport(modelH,blockH,...
        propertyName,propertyValue);
        value=getPerInstancePropertyForPort(modelH,portH,...
        propertyName);
        propUpdated=setPerInstancePropertyForPort(modelH,portH,...
        propertyName,propertyValue);
        value=getPerInstancePropertyForStateOrDSM(modelH,blockH,...
        propertyName);
        propUpdated=setPerInstancePropertyForStateOrDSM(modelH,blockH,...
        propertyName,propertyValue);
        value=getPerInstancePropertyForModelWorkspaceObject(modelH,uuid,...
        propertyName);
        propUpdated=setPerInstancePropertyForModelWorkspaceObject(modelH,uuid,...
        propertyName,propertyValue);
        ret=isPerInstanceProperty(modelH,mappingObj,member,propName);
        isReadOnly=isPerInstancePropertyReadOnly(modelH,mappingObj,member,propName);
        newPropValue=massageAndValidatePerInstancePropertyValue(...
        modelH,mappingObj,propName,propValue);
        val=getPerInstancePropertyValue(modelH,mappedTo,propName);
        propUpdated=setPerInstancePropertyValue(model,mappingObj,member,propName,propValue);
        val=getPerInstancePropertyDataType(modelH,mappedTo,propName);
        values=getPerInstancePropertyAllowedValues(modelH,mappedTo,propName);


        [rowSpan,tabItems]=getSchema(sourceModel,sourceBlock,...
        enable,rowSpan,tabItems);
        UI_Launch(modelName);
        out=getIconPath(relativePath,isErrorIcon);
        [title,expectedTabSuffix]=getTitle(modelHandle);
        match=tabSuffixMatchesApp(studio);
        mappingType=getMappingType(appName,appLang,codeInterfacePackaging);
        openCodeMappingsEditor(model,tabIndex);
        openPIFromMappingInspector(ss,~,~);
        handleCQuickEditorOutput(ss,proxyObjects,valuesJSON);
        handleCppQuickEditorOutput(ss,proxyObjects,valuesJSON);
        handleARQuickEditorOutput(ss,proxyObjects,valuesJSON);
        [props,isMapped]=getAllProperties(modelH,mappingObj);
        [needsUpdate,allowedValues]=getAllowedValuesForDataElement(ss,portTag,portValue);
        TestHarnessActivated(model);
        TestHarnessDeactivated(model);

        [show,enable]=isCompatible(sourceModel,sourceBlock);
        [show,enable]=isRootIOCompatible(sourceModel,sourceBlock,propertyName);
        enable=enableCodeMappings(sourceModel);

        RTWInfoBackup=backup(sourceModel,sourceBlock);
        restore(sourceModel,sourceBlock,RTWInfoBackup);


        doPostModelLoadMigration(modelName);
        doMigrationFromGUI(modelName,migrateDictionaryOnly,varargin);
        inActiveConfigsetsHaveMemSecMappings=inActiveCSHasMappings(modelName);
        migrateDictionary(mdlH,activeCS,guiEntry,varargin);
        migrateToSharedDictionary(ddName,activeCS,guiEntry);
        migrateFromShared(modelName,bMigrateSharedMapping);
        createAndMigrate(modelName,activeCS,isShared,isCSInBaseWS,migrateDictionaryOnly,varargin);
        migrateCPPCS(modelName,activeCS);
        migrate(modelName);
        createSharedUtilsMappingAndDataIfNecessary(activeCS,source,isShared,mapping);
        setSharedMappingMSFromCS(source,cs,csparam,mappingParam);
        setModelMappingMSFromCS(modelMapping,cs,csparam,mappingParam);
        setCppMappingClassConfigFromCS(modelMapping,cs,csparam);


        out=setGetListeners(listeners);
        out=findBlockMapping(mappings,eventName);
        onModelClose(~,~);
        add_mapping_listener(sourceModel,sourceBlock,dialog,portObj);
        handle_mapping_updated_event(~,~,portObj);
        remove_mapping_listener(portObj,dialog);
        ertMappingChanged(dlg,mapObj,mapping);
        PerInstancePropertyChanged(dlg,controlTag,modelH,mappingObj,propName);
        autosarMappingChanged(dlg,sourceModel,SLPortName,prop);


        createDict(dictFileName,packageName);
        addCoderGroups(modelName,creationMode);
        uuid=getGroupUuidFromName(modelName,name);
        out=doesModelHaveCoderGroups(modelH);
        ret=isMemorySectionInstanceSpecific(mdlH,scName);
        resetCoderInterface(mdlName);


        [objExists,storageClass,isModelWSObject]=evalObject(modelName,objName);
        [isNonAutoStorageCls,propValue]=isSignalObjectSpecified(modelName,blk,isInport);


        res=escapeSimulinkName(pathStr);
        taskName=getMDSAperiodicTaskName(model,blockH);

        [res,isCpp]=isErtCompliant(model);
        [res,isCpp]=isGrtCompliant(model);
        res=isAutosarCompliant(model);
        res=isAutosarSTF(model);
        res=isAutosarAdaptiveSTF(model);
        res=isCppClassInterface(model);
        res=isSLRealTimeCompliant(model);

        [isMapped,modelMapping]=isMappedToAutosarComponent(modelName);
        [isMapped,modelMapping]=isMappedToAutosarComposition(modelName);
        [isMapped,modelMapping]=isMappedToAutosarSubComponent(modelName);
        [isMapped,modelMapping]=isMappedToAdaptiveApplication(modelName);
        [isMapped,modelMapping]=isMappedToCppERTSwComponent(modelName);
        [isMapped,modelMapping]=isMappedToERTSwComponent(modelName);
        [isMapped,modelMapping]=isMappedToGRTSwComponent(modelName);
    end

    methods(Static,Access=private)

        [namingRule,useSimulinkDefault]=getNamingRuleFromFunctionClass(mapObj,mdlH,defaultsCategory);
        cdType=getCoderDataTypeForFunctionCategory(modelMapping,defaultsCategory);


        storageClass=getStorageClass(sourceModel,sigName);


        out=createNameValuePairsForMappingAPI(valuesJSON);
        setCommunicationAttributesFromJSON(modelH,mappingCategory,blockPath,valuesJSON);


        title=getTitleForEmbeddedCoderC(modelHandle,readOnlyText);
        title=getTitleForEmbeddedCoderCPP(modelHandle,readOnlyText);


        islicensed=codersLicensed();
        islicensed=ddsLicensed();
    end

    properties(Constant)
        DefaultCoderGroup={DAStudio.message('coderdictionary:mapping:NoMapping')};
        DefaultCoderGroupModelLevel={DAStudio.message('coderdictionary:mapping:SimulinkGlobal')};
        CalPrmCoderGroups={'DataFast','DataSlow','DataNoPTA'};
        VariablesCoderGroups={'FastNoReIni','MediumNoReIni','SlowNoReIni','FastReIni','MediumReIni',...
        'SlowReIni','Protected','NonVolatile'};
    end

end
