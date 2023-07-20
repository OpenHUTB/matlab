function importResults=createCustomCodeTypeObjects(importedTypes,params)
    importResults=[];

    ConsistencyCheckLoggerObj=SLCC.TypeImporter.ConsistencyCheckLogger(importedTypes,params);

    importResults.report=ConsistencyCheckLoggerObj.createConsistencyReport();
    importResults.failedToImport=ConsistencyCheckLoggerObj.getTypeListNotImported();

    importedTypes=ConsistencyCheckLoggerObj.getTypeListImported();


    EnumNameList=createIntEnumTypes(importedTypes.EnumObjectList,params);
    importedTypes.AliasObjectList=createAliasTypes(importedTypes.AliasObjectList);

    importResults.importedTypes.Bus={importedTypes.BusObjectList.BusName};
    importResults.importedTypes.Enum=EnumNameList;
    importResults.importedTypes.AliasType={importedTypes.AliasObjectList.AliasTypeName};

    if isempty(importedTypes.BusObjectList)&&isempty(importedTypes.AliasObjectList)
        return;
    end



    if isempty(params.DataDictionary)&&isempty(params.MATFile)
        for n=1:numel(importedTypes.BusObjectList)
            assignin('base',importedTypes.BusObjectList(n).BusName,importedTypes.BusObjectList(n).BusObject);
        end
        for n=1:numel(importedTypes.AliasObjectList)
            assignin('base',importedTypes.AliasObjectList(n).AliasTypeName,importedTypes.AliasObjectList(n).AliasTypeObject);
        end
        return;
    end

    if~isempty(params.MATFile)
        matFilePath=fullfile(params.OutputDir,params.MATFile);
        saveToMATFile(matFilePath,importedTypes.BusObjectList,'BusName','BusObject',0);
        saveToMATFile(matFilePath,importedTypes.AliasObjectList,'AliasTypeName','AliasTypeObject',1);
    elseif~isempty(params.DataDictionary)
        saveDDChanges=true;
        if ischar(params.DataDictionary)
            slddFilePath=fullfile(params.OutputDir,params.DataDictionary);
            if isempty(regexp(params.DataDictionary,'.+\.sldd$','ONCE'))
                slddFilePath=sprintf('%s.sldd',slddFilePath);
            end
            if exist(slddFilePath,'file')
                dictionaryObj=Simulink.data.dictionary.open(slddFilePath);
            else

                dictionaryObj=Simulink.data.dictionary.create(slddFilePath);
            end
        elseif isa(params.DataDictionary,'Simulink.data.DataDictionary')
            dictionaryPath=params.DataDictionary.DataSource.filespec;
            dictionaryObj=Simulink.data.dictionary.open(dictionaryPath);

            saveDDChanges=false;
        end
        dDataSectObj=getSection(dictionaryObj,'Design Data');
        for n=1:numel(importedTypes.BusObjectList)
            assignin(dDataSectObj,importedTypes.BusObjectList(n).BusName,...
            importedTypes.BusObjectList(n).BusObject);
        end
        for n=1:numel(importedTypes.AliasObjectList)
            assignin(dDataSectObj,importedTypes.AliasObjectList(n).AliasTypeName,...
            importedTypes.AliasObjectList(n).AliasTypeObject);
        end

        if saveDDChanges
            saveChanges(dictionaryObj);
        end
        close(dictionaryObj);
    else
        return;
    end

    function saveToMATFile(matFileName,busObjectList,Name,Object,isAppend)

        fieldNames=fieldnames(busObjectList);





        saveVarCell=reshape(struct2cell(busObjectList),...
        [numel(fieldNames),numel(busObjectList)]);








        busNameIdx=[];
        busObjIdx=[];
        for n=1:numel(fieldNames)
            switch fieldNames{n}
            case Name
                busNameIdx=n;
            case Object
                busObjIdx=n;
            end
            if~isempty(busNameIdx)&&~isempty(busObjIdx)
                break;
            end
        end

        saveVarStruct=cell2struct(saveVarCell(busObjIdx,:),...
        saveVarCell(busNameIdx,:),2);%#ok<NASGU>


        if isAppend
            save(matFileName,'-struct','saveVarStruct','-append');
        else
            save(matFileName,'-struct','saveVarStruct');
        end
