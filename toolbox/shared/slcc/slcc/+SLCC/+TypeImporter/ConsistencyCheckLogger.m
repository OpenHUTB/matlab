classdef ConsistencyCheckLogger<handle


    properties(Constant,Hidden)

        NEWLY_IMPORTED_BUS_TYPE=1;
        EXISTING_BUS_TYPE=2;
        INCONSISTENT_BUS_TYPE_NOT_A_VALID_BUS_TYPE=3;
        INCONSISTENT_BUS_TYPE_BUSELEMENT_MISMATCH=4;
        NONIMPORTABLE_BUS_TYPE=5;
        NEWLY_IMPORTED_ENUM_TYPE=6;
        EXISTING_ENUM_TYPE=7;
        INCONSISTENT_ENUM_TYPE_ENUM_NAME_MISMATCH=8;
        INCONSISTENT_ENUM_TYPE_ENUM_VALUE_MISMATCH=9;
        FAILED_TO_PARSE_TYPE=10;
        NEWLY_IMPORTED_ALIAS_TYPE=11;
        EXISTING_ALIAS_TYPE=12;
        INCONSISTENT_ALIAS_TYPE_NOT_A_VALID_ALIAS_TYPE=13;
        INCONSISTENT_ALIAS_TYPE_BASETYPE_MISMATCH=14;
        INVALID_MATLAB_VARIABLE_NAME=15;
        INVALID_FIELD_NAME=16;
    end

    properties
        checkConsistencyInfo=[];
        importedTypes=[];
        params=[];
        isStaticEnum=0;
    end

    methods(Access=private)

        function existingBusObject=getExistingBusObject(obj,BusName,extVarsNames,DataSectObj)
            existingBusObject=[];
            if ismember(BusName,extVarsNames)
                if~isempty(obj.params.DataDictionary)

                    if~isempty(DataSectObj)
                        tempObj=getEntry(DataSectObj,BusName);
                        existingBusObject=tempObj.getValue;
                    end
                else

                    existingBusObject=evalin('base',BusName);
                end
            end
        end

        function ImportedBusInfo=checkConsistencyForImportedBusTypes(obj)

            BusObjectList=obj.importedTypes.BusObjectList;
            ImportedBusInfo=[];

            if isempty(BusObjectList)
                return;
            end

            busCheckLogArray(numel(BusObjectList))=...
            SLCC.TypeImporter.InconsistencyCheckLogEntry;

            dDataSectObj=[];
            dictionaryObj=[];
            if~isempty(obj.params.DataDictionary)

                if ischar(obj.params.DataDictionary)
                    if~isempty(regexp(obj.params.DataDictionary,'.+\.sldd$','ONCE'))
                        dictionaryName=obj.params.DataDictionary;
                    else
                        dictionaryName=sprintf('%s.sldd',obj.params.DataDictionary);
                    end
                    dictionaryName=fullfile(obj.params.OutputDir,dictionaryName);

                    if exist(dictionaryName,'file')
                        dictionaryObj=Simulink.data.dictionary.open(dictionaryName);
                        dDataSectObj=getSection(dictionaryObj,'Design Data');
                        allEntries=find(dDataSectObj);
                        extVarsNames={allEntries.Name};
                    else
                        return;
                    end
                else
                    return;
                end

            else

                extVarsNames=evalin('base','who');
            end

            for i=1:numel(BusObjectList)
                if~BusObjectList(i).isImportable
                    busCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(BusObjectList(i).BusName,'Simulink.Bus',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.NONIMPORTABLE_BUS_TYPE,i,BusObjectList(i).HeaderFilePath);
                    continue;
                end
                existingBus=obj.getExistingBusObject(BusObjectList(i).BusName,extVarsNames,dDataSectObj);
                if~isempty(existingBus)
                    importedBus=BusObjectList(i).BusObject;
                    if isa(existingBus,'Simulink.Bus')

                        if isequal(importedBus.Elements,existingBus.Elements)
                            busCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(BusObjectList(i).BusName,'Simulink.Bus',...
                            SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_BUS_TYPE,i,BusObjectList(i).HeaderFilePath);
                        else
                            busDiff=SLCC.TypeImporter.ConsistencyCheckLogger.compareSimulinkBus(importedBus,existingBus);
                            if isempty([busDiff.FieldName])
                                busCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(BusObjectList(i).BusName,'Simulink.Bus',...
                                SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_BUS_TYPE,i,BusObjectList(i).HeaderFilePath);
                            else
                                busCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(BusObjectList(i).BusName,'Simulink.Bus',...
                                SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_BUS_TYPE_BUSELEMENT_MISMATCH,i,BusObjectList(i).HeaderFilePath,busDiff);
                            end
                        end
                    else

                        busCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(BusObjectList(i).BusName,'Simulink.Bus',...
                        SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_BUS_TYPE_NOT_A_VALID_BUS_TYPE,i,BusObjectList(i).HeaderFilePath);
                    end
                else

                    busCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(BusObjectList(i).BusName,'Simulink.Bus',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_BUS_TYPE,i,BusObjectList(i).HeaderFilePath);
                end

            end

            ImportedBusInfo=busCheckLogArray;

            if~isempty(dictionaryObj)
                close(dictionaryObj);
            end

        end

        function ImportedEnumInfo=checkConsistencyForImportedEnumTypes(obj)

            EnumObjectList=obj.importedTypes.EnumObjectList;
            ImportedEnumInfo=[];

            if isempty(EnumObjectList)
                return;
            end

            enumCheckLogArray(numel(EnumObjectList))=...
            SLCC.TypeImporter.InconsistencyCheckLogEntry;

            enumOption=0;
            dataDictionaryVarsNames=[];
            dDataSectObj=[];
            dictionaryObj=[];
            if~isempty(obj.params.DataDictionary)

                if ischar(obj.params.DataDictionary)
                    if~isempty(regexp(obj.params.DataDictionary,'.+\.sldd$','ONCE'))
                        dictionaryName=obj.params.DataDictionary;
                    else
                        dictionaryName=sprintf('%s.sldd',obj.params.DataDictionary);
                    end
                    dictionaryName=fullfile(obj.params.OutputDir,dictionaryName);

                    if exist(dictionaryName,'file')
                        dictionaryObj=Simulink.data.dictionary.open(dictionaryName);
                        dDataSectObj=getSection(dictionaryObj,'Design Data');
                        allEntries=find(dDataSectObj);
                        dataDictionaryVarsNames={allEntries.Name};
                        enumOption=1;
                    else
                        return;
                    end
                else
                    return;
                end
            end

            for i=1:numel(EnumObjectList)
                if~SLCC.TypeImporter.ConsistencyCheckLogger.isEnumFieldNameValid(cellstr(EnumObjectList(i).LabelStrings),obj.isStaticEnum)
                    enumCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(EnumObjectList(i).Name,'Enum',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.INVALID_FIELD_NAME,i,EnumObjectList(i).HeaderFilePath);
                    continue;
                end

                if enumOption==0
                    [members,names]=enumeration(EnumObjectList(i).Name);
                else
                    [members,names]=SLCC.TypeImporter.ConsistencyCheckLogger.getEnumfromDataDictionary(EnumObjectList(i).Name,dataDictionaryVarsNames,dDataSectObj);
                end

                if isempty(members)||isempty(names)
                    enumCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(EnumObjectList(i).Name,'Enum',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ENUM_TYPE,i,EnumObjectList(i).HeaderFilePath);
                    continue;
                end
                if isequal(names,cellstr(EnumObjectList(i).LabelStrings))
                    if isequal(members,EnumObjectList(i).Values)
                        enumCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(EnumObjectList(i).Name,'Enum',...
                        SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_ENUM_TYPE,i,EnumObjectList(i).HeaderFilePath);
                    else
                        enumCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(EnumObjectList(i).Name,'Enum',...
                        SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_ENUM_TYPE_ENUM_VALUE_MISMATCH,i,EnumObjectList(i).HeaderFilePath);
                    end
                else
                    enumCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(EnumObjectList(i).Name,'Enum',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_ENUM_TYPE_ENUM_NAME_MISMATCH,i,EnumObjectList(i).HeaderFilePath);
                end

            end

            ImportedEnumInfo=enumCheckLogArray;

            if~isempty(dictionaryObj)
                close(dictionaryObj);
            end

        end

        function ImportedAliasInfo=checkConsistencyForImportedAliasTypes(obj)

            AliasObjectList=obj.importedTypes.AliasObjectList;
            ImportedAliasInfo=[];

            if isempty(AliasObjectList)
                return;
            end

            aliasCheckLogArray(numel(AliasObjectList))=...
            SLCC.TypeImporter.InconsistencyCheckLogEntry;

            dDataSectObj=[];
            dictionaryObj=[];
            if~isempty(obj.params.DataDictionary)

                if ischar(obj.params.DataDictionary)
                    if~isempty(regexp(obj.params.DataDictionary,'.+\.sldd$','ONCE'))
                        dictionaryName=obj.params.DataDictionary;
                    else
                        dictionaryName=sprintf('%s.sldd',obj.params.DataDictionary);
                    end
                    dictionaryName=fullfile(obj.params.OutputDir,dictionaryName);

                    if exist(dictionaryName,'file')
                        dictionaryObj=Simulink.data.dictionary.open(dictionaryName);
                        dDataSectObj=getSection(dictionaryObj,'Design Data');
                        allEntries=find(dDataSectObj);
                        extVarsNames={allEntries.Name};
                    else
                        return;
                    end
                else
                    return;
                end

            else

                extVarsNames=evalin('base','who');
            end

            for i=1:numel(AliasObjectList)
                existingAlias=obj.getExistingBusObject(AliasObjectList(i).Name,extVarsNames,dDataSectObj);
                if~isempty(existingAlias)
                    if isa(existingAlias,'Simulink.AliasType')
                        if strcmp(existingAlias.BaseType,AliasObjectList(i).BaseType)

                            aliasCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(AliasObjectList(i).Name,'Simulink.AliasType',...
                            SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_ALIAS_TYPE,i,AliasObjectList(i).HeaderFilePath);
                        else
                            if SLCC.TypeImporter.ConsistencyCheckLogger.isDataTypeCompatible(existingAlias.BaseType,AliasObjectList(i).BaseType)==1
                                aliasCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(AliasObjectList(i).Name,'Simulink.AliasType',...
                                SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_ALIAS_TYPE,i,AliasObjectList(i).HeaderFilePath);
                            else
                                aliasCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(AliasObjectList(i).Name,'Simulink.AliasType',...
                                SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_ALIAS_TYPE_BASETYPE_MISMATCH,i,AliasObjectList(i).HeaderFilePath);
                            end
                        end
                    else
                        aliasCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(AliasObjectList(i).Name,'Simulink.AliasType',...
                        SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_ALIAS_TYPE_NOT_A_VALID_ALIAS_TYPE,i,AliasObjectList(i).HeaderFilePath);
                    end
                else
                    aliasCheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(AliasObjectList(i).Name,'Simulink.AliasType',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ALIAS_TYPE,i,AliasObjectList(i).HeaderFilePath);
                end

            end

            ImportedAliasInfo=aliasCheckLogArray;

            if~isempty(dictionaryObj)
                close(dictionaryObj);
            end

        end

        function allImportedTypesInfo=getAllTypesImported(obj)
            num=numel(obj.importedTypes.EnumObjectList)+numel(obj.importedTypes.BusObjectList)+numel(obj.importedTypes.AliasObjectList);
            if num==0
                allImportedTypesInfo=[];
                return;
            end
            n=0;
            CheckLogArray(num)=...
            SLCC.TypeImporter.InconsistencyCheckLogEntry;
            for i=1:numel(obj.importedTypes.EnumObjectList)
                n=n+1;
                if~SLCC.TypeImporter.ConsistencyCheckLogger.isEnumFieldNameValid(cellstr(obj.importedTypes.EnumObjectList(i).LabelStrings),obj.isStaticEnum)
                    CheckLogArray(n)=SLCC.TypeImporter.InconsistencyCheckLogEntry(obj.importedTypes.EnumObjectList(i).Name,'Enum',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.INVALID_FIELD_NAME,i,obj.importedTypes.EnumObjectList(i).HeaderFilePath);
                    continue;
                end
                CheckLogArray(n)=SLCC.TypeImporter.InconsistencyCheckLogEntry(obj.importedTypes.EnumObjectList(i).Name,'Enum',...
                SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ENUM_TYPE,i,obj.importedTypes.EnumObjectList(i).HeaderFilePath);
            end
            for i=1:numel(obj.importedTypes.BusObjectList)
                n=n+1;
                if~obj.importedTypes.BusObjectList(i).isImportable
                    CheckLogArray(n)=SLCC.TypeImporter.InconsistencyCheckLogEntry(obj.importedTypes.BusObjectList(i).BusName,'Simulink.Bus',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.NONIMPORTABLE_BUS_TYPE,i,obj.importedTypes.BusObjectList(i).HeaderFilePath);
                    continue;
                end
                CheckLogArray(n)=SLCC.TypeImporter.InconsistencyCheckLogEntry(obj.importedTypes.BusObjectList(i).BusName,'Simulink.Bus',...
                SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_BUS_TYPE,i,obj.importedTypes.BusObjectList(i).HeaderFilePath);
            end
            for i=1:numel(obj.importedTypes.AliasObjectList)
                n=n+1;
                CheckLogArray(n)=SLCC.TypeImporter.InconsistencyCheckLogEntry(obj.importedTypes.AliasObjectList(i).Name,'Simulink.AliasType',...
                SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ALIAS_TYPE,i,obj.importedTypes.AliasObjectList(i).HeaderFilePath);
            end
            allImportedTypesInfo=CheckLogArray;
        end

        function addFailedToParseInfo(obj)
            if~isempty(obj.importedTypes.FailedToParseList)
                CheckLogArray(numel(obj.importedTypes.FailedToParseList))=...
                SLCC.TypeImporter.InconsistencyCheckLogEntry;
                for i=1:numel(obj.importedTypes.FailedToParseList)
                    CheckLogArray(i)=SLCC.TypeImporter.InconsistencyCheckLogEntry(obj.importedTypes.FailedToParseList(i).Name,'Simulink.Bus',...
                    SLCC.TypeImporter.ConsistencyCheckLogger.FAILED_TO_PARSE_TYPE,-1,obj.importedTypes.FailedToParseList(i).HeaderFilePath);
                end
                obj.checkConsistencyInfo=[obj.checkConsistencyInfo,CheckLogArray];
            end
        end

        function validNameCheck(obj)
            if~isempty(obj.checkConsistencyInfo)
                for i=1:numel(obj.checkConsistencyInfo)
                    if~isvarname(obj.checkConsistencyInfo(i).Name)
                        obj.checkConsistencyInfo(i).checkId=SLCC.TypeImporter.ConsistencyCheckLogger.INVALID_MATLAB_VARIABLE_NAME;
                    end
                end
            end
        end

    end

    methods(Static,Access=private)

        function busDiff=compareSimulinkBus(importedBus,existedBus)
            busDiff(max(numel(existedBus.Elements),numel(importedBus.Elements))*4)=...
            SLCC.TypeImporter.BusElementsCheckLogEntry;
            minNum=min(numel(existedBus.Elements),numel(importedBus.Elements));
            n=0;
            for i=1:minNum
                if~isequal(existedBus.Elements(i),importedBus.Elements(i))
                    if~isequal(existedBus.Elements(i).Name,importedBus.Elements(i).Name)
                        n=n+1;
                        busDiff(n)=SLCC.TypeImporter.BusElementsCheckLogEntry('Name',...
                        existedBus.Elements(i).Name,importedBus.Elements(i).Name,i,0);
                    end
                    if~isequal(existedBus.Elements(i).Complexity,importedBus.Elements(i).Complexity)
                        n=n+1;
                        busDiff(n)=SLCC.TypeImporter.BusElementsCheckLogEntry('Complexity',...
                        existedBus.Elements(i).Complexity,importedBus.Elements(i).Complexity,i,0);
                    end
                    if~isequal(existedBus.Elements(i).Dimensions,importedBus.Elements(i).Dimensions)
                        n=n+1;
                        busDiff(n)=SLCC.TypeImporter.BusElementsCheckLogEntry('Dimensions',...
                        existedBus.Elements(i).Dimensions,importedBus.Elements(i).Dimensions,i,0);
                    end
                    if~isequal(existedBus.Elements(i).DataType,importedBus.Elements(i).DataType)

                        if SLCC.TypeImporter.ConsistencyCheckLogger.isDataTypeCompatible(existedBus.Elements(i).DataType,importedBus.Elements(i).DataType)==0
                            n=n+1;
                            busDiff(n)=SLCC.TypeImporter.BusElementsCheckLogEntry('DataType',...
                            existedBus.Elements(i).DataType,importedBus.Elements(i).DataType,i,0);
                        end
                    end
                end
            end
            if numel(existedBus.Elements)<numel(importedBus.Elements)
                for i=(numel(existedBus.Elements)+1):numel(importedBus.Elements)
                    n=n+1;
                    busDiff(n)=SLCC.TypeImporter.BusElementsCheckLogEntry('All',...
                    '',importedBus.Elements(i),i,1);
                end
            end
            busDiff=busDiff(1:n);
        end

        function[members,names]=getEnumfromDataDictionary(EnumName,dataDictionaryVarsNames,DataSectObj)
            members=[];
            names=[];
            if isempty(dataDictionaryVarsNames)
                return;
            end
            if ismember(EnumName,dataDictionaryVarsNames)
                tempObj=getEntry(DataSectObj,EnumName);
                tempEnumObj=tempObj.getValue;
                if isa(tempEnumObj,'Simulink.data.dictionary.EnumTypeDefinition')
                    names={tempEnumObj.Enumerals.Name}';
                    members=cellfun(@str2num,{tempEnumObj.Enumerals.Value})';
                end
            end

        end

        function isCompatible=isDataTypeCompatible(existedDataType,importedDataType)
            isCompatible=0;

            slIntTypeSet={'int8','int16','int32','uint8','uint16','uint32'};
            if any(strcmp(existedDataType,slIntTypeSet))
                return;
            end
            dtInfoExisted=SimulinkFixedPoint.DTContainerInfo(existedDataType,[]);
            dtInfoimported=SimulinkFixedPoint.DTContainerInfo(importedDataType,[]);
            if dtInfoExisted.isFixed&&dtInfoimported.isFixed
                if isequal(dtInfoExisted.evaluatedNumericType.Signedness,dtInfoimported.evaluatedNumericType.Signedness)&&...
                    (dtInfoExisted.evaluatedNumericType.WordLength<=dtInfoimported.evaluatedNumericType.WordLength)
                    isCompatible=1;
                    return;
                end
            end

            if~isempty(regexp(importedDataType,'^Bus:\s*','once'))&&...
                strcmp(SLCC.TypeImporter.ConsistencyCheckLogger.stripBusOrEnumPrefix(importedDataType,'Bus'),...
                SLCC.TypeImporter.ConsistencyCheckLogger.stripBusOrEnumPrefix(existedDataType,'Bus'))
                isCompatible=1;
                return;
            end

            if~isempty(regexp(importedDataType,'^Enum:\s*','once'))&&...
                strcmp(SLCC.TypeImporter.ConsistencyCheckLogger.stripBusOrEnumPrefix(importedDataType,'Enum'),...
                SLCC.TypeImporter.ConsistencyCheckLogger.stripBusOrEnumPrefix(existedDataType,'Enum'))
                isCompatible=1;
                return;
            end
        end

        function striped=stripBusOrEnumPrefix(orginalName,prefix)
            expression=['^\s*',prefix,'\s*:\s*'];
            striped=regexprep(strtrim(orginalName),expression,'');
        end

        function isFieldNameValid=isEnumFieldNameValid(aEnumCellOfNames,isStaticEnum)
            isFieldNameValid=1;
            for i=1:numel(aEnumCellOfNames)
                if~isvarname(aEnumCellOfNames{i})
                    if isStaticEnum
                        isFieldNameValid=0;
                        return;
                    elseif~iskeyword(aEnumCellOfNames{i})
                        isFieldNameValid=0;
                        return;
                    end
                end
            end
        end

    end

    methods

        function obj=ConsistencyCheckLogger(importedTypes,params)
            obj.importedTypes=importedTypes;
            obj.params=params;
            obj.checkConsistencyInfo=[];
            obj.isStaticEnum=strcmpi(params.EnumClass,'MATLAB file');
            obj.consistencyChecking();
        end


        function consistencyChecking(obj)
            if~isempty(obj.params.MATFile)||strcmp(obj.params.Overwrite,'on')

                obj.checkConsistencyInfo=obj.getAllTypesImported();
            else
                if~isempty(obj.importedTypes.EnumObjectList)
                    obj.checkConsistencyInfo=...
                    [obj.checkConsistencyInfo,obj.checkConsistencyForImportedEnumTypes()];
                end
                if~isempty(obj.importedTypes.BusObjectList)
                    obj.checkConsistencyInfo=...
                    [obj.checkConsistencyInfo,obj.checkConsistencyForImportedBusTypes()];
                end
                if~isempty(obj.importedTypes.AliasObjectList)
                    obj.checkConsistencyInfo=...
                    [obj.checkConsistencyInfo,obj.checkConsistencyForImportedAliasTypes()];
                end
            end
            obj.validNameCheck();
            obj.addFailedToParseInfo();
        end


        function reportStrBuffer=createConsistencyReport(obj)
            if strcmpi(obj.params.Verbose,'on')
                verbose=1;
            else
                verbose=0;
            end
            reportObj=SLCC.TypeImporter.ConsistencyCheckReport(obj,verbose);
            reportStrBuffer=reportObj.getReport();
        end


        function importedTypes=getTypeListImported(obj)
            if~isempty(obj.checkConsistencyInfo)
                templist=[obj.checkConsistencyInfo.checkId]==SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_BUS_TYPE;
                importedBusList=[obj.checkConsistencyInfo(templist).TypeIndex];
                importedTypes.BusObjectList=obj.importedTypes.BusObjectList(importedBusList);

                templist=[obj.checkConsistencyInfo.checkId]==SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ENUM_TYPE;
                importedEnumList=[obj.checkConsistencyInfo(templist).TypeIndex];
                importedTypes.EnumObjectList=obj.importedTypes.EnumObjectList(importedEnumList);

                templist=[obj.checkConsistencyInfo.checkId]==SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ALIAS_TYPE;
                importedAliasList=[obj.checkConsistencyInfo(templist).TypeIndex];
                importedTypes.AliasObjectList=obj.importedTypes.AliasObjectList(importedAliasList);
            else
                importedTypes=obj.importedTypes;
            end

        end


        function typesNotImported=getTypeListNotImported(obj)
            if~isempty(obj.checkConsistencyInfo)
                templist=([obj.checkConsistencyInfo.checkId]~=SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_BUS_TYPE)&...
                ([obj.checkConsistencyInfo.checkId]~=SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_BUS_TYPE)&...
                cellfun(@(x)strcmp(x,'Simulink.Bus'),{obj.checkConsistencyInfo.TypeName});
                typesNotImported.Bus={obj.checkConsistencyInfo(templist).Name};

                templist=([obj.checkConsistencyInfo.checkId]~=SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ENUM_TYPE)&...
                ([obj.checkConsistencyInfo.checkId]~=SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_ENUM_TYPE)&...
                cellfun(@(x)strcmp(x,'Enum'),{obj.checkConsistencyInfo.TypeName});
                typesNotImported.Enum={obj.checkConsistencyInfo(templist).Name};

                templist=([obj.checkConsistencyInfo.checkId]~=SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ALIAS_TYPE)&...
                ([obj.checkConsistencyInfo.checkId]~=SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_ALIAS_TYPE)&...
                cellfun(@(x)strcmp(x,'Simulink.AliasType'),{obj.checkConsistencyInfo.TypeName});
                typesNotImported.AliasType={obj.checkConsistencyInfo(templist).Name};
            else
                typesNotImported.Bus={};
                typesNotImported.Enum={};
                typesNotImported.AliasType={};
            end

        end
    end

end

