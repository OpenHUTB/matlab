function errorCodes=mapSLDataTypes(modelName,m3iObject,...
    slTypeNames,choiceOK,append,ignoreError)









    import autosar.mm.util.ExternalToolInfoAdapter;
    if nargin==5
        ignoreError=false;
    end

    errorCodes={};


    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        errorCodes=[errorCodes,'RTW:autosar:mdlNotLoaded'];
        errorCodes=[errorCodes,modelName];
        return;
    end
    m3iModel=m3iObject.rootModel;
    toolId=autosar.ui.metamodel.PackageString.SlDataTypesToolID;

    if numel(slTypeNames)==0||isempty(slTypeNames)...
        ||(numel(slTypeNames)==1&&isempty(slTypeNames{1}))
        tranaction=M3I.Transaction(m3iModel);
        m3iObject.setExternalToolInfo(M3I.ExternalToolInfo(toolId,''));
        tranaction.commit();
        return;
    end
    if ischar(slTypeNames)||isStringScalar(slTypeNames)
        slTypeNames={slTypeNames};
    end

    externalId=m3iObject.getExternalToolInfo(toolId).externalId;
    if~isempty(externalId)
        tokens=strsplit(externalId,'#');
        if append

            u=union(tokens,slTypeNames);
            if isempty(setxor(u,tokens))

                for ii=1:numel(slTypeNames)
                    autosar.mm.util.mapSLDataType(modelName,m3iObject,...
                    slTypeNames{ii},choiceOK,ignoreError);
                end
                return;
            end
        else

            if isempty(setxor(slTypeNames,tokens))

                for ii=1:numel(slTypeNames)
                    autosar.mm.util.mapSLDataType(modelName,m3iObject,...
                    slTypeNames{ii},choiceOK,ignoreError);
                end
                return;
            end
        end
    end
    arRoot=m3iModel.RootPackage.front();
    m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(arRoot,...
    m3iObject.MetaClass,true);
    for ii=1:m3iSeq.size()
        if m3iSeq.at(ii)==m3iObject
            continue;
        end
        slTypeNamesAlreadySet=ExternalToolInfoAdapter.get(m3iSeq.at(ii),...
        autosar.ui.metamodel.PackageString.SlDataTypes);
        [common,~,indeces2]=intersect(slTypeNamesAlreadySet,slTypeNames);
        if~isempty(common)
            errorCodes=[errorCodes,'autosarstandard:common:slDataTypeForMultipleCompuMethods'];%#ok<AGROW>
            errorCodes=[errorCodes,slTypeNames{indeces2(1)},m3iObject.Name,m3iSeq.at(ii).Name];%#ok<AGROW>
            return;
        end
    end
    for ii=1:numel(slTypeNames)
        if isempty(slTypeNames{ii})
            continue;
        end
        if isa(m3iObject,autosar.ui.metamodel.PackageString.CompuMethodClass)
            errorCodes=autosar.mm.util.checkDataTypeCompuMethodCompatibility(...
            modelName,slTypeNames{ii},m3iObject,false);
            if numel(errorCodes)>0
                return;
            end
        end
    end
    slTypeNamesOK={};
    for ii=1:numel(slTypeNames)
        slTypeName=slTypeNames{ii};
        if isempty(slTypeName)
            continue;
        end
        success=autosar.mm.util.mapSLDataType(modelName,...
        m3iObject,slTypeName,choiceOK,ignoreError);
        switch success
        case 0
            continue;
        case 1
            slTypeNamesOK=[slTypeNamesOK,slTypeName];%#ok<AGROW>
        case 2
            return;
        end
    end
    if numel(slTypeNamesOK)>0
        autosar.mm.util.setCompuMethodSlDataType(m3iModel,...
        m3iObject,slTypeNamesOK,append);
    end
end



