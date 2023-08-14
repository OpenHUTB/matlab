classdef StrongDataTypeEngineImpl<Simulink.inputmap.util.FauxEngineImpl&Simulink.inputmap.util.SlInportEngineImpl





    properties
DatasetID
        supportedCast={'double','single','int8','uint8','int16','uint16','int32','uint32','boolean','half','int64','uint64'};
CompileStatus
    end

    methods


        function[status,diagnosticstruct]=isExternalInputCompatible(obj,model,SignalsStruct,mappingStruct)

            if~isempty(obj.DatasetID)
                eng=Simulink.sdi.Instance.engine;
                SignalIds=eng.getSignalChildren(obj.DatasetID);





                for id=1:length(SignalIds)
                    castToDt=eng.getMetaDataV2(SignalIds(id),'CastToDataType');
                    if~isempty(castToDt)


                        eng.setMetaDataV2(SignalIds(id),'CastToDataType','double');
                    end
                end
            end

            if obj.CompileStatus
                [status,diagnosticstruct]=isExternalInputCompatible@Simulink.inputmap.util.SlInportEngineImpl(obj,model,SignalsStruct,mappingStruct);

                status=logical(status);
            else
                [status,diagnosticstruct]=isExternalInputCompatible@Simulink.inputmap.util.FauxEngineImpl(obj,model,SignalsStruct,mappingStruct);
            end

        end


        function[status,diagnosticstruct]=determineCompatibility(obj,model,externalInputPlugin,mappingStruct)
            fastRestartIsOn=strcmp(get_param(model,'SimulationStatus'),'compiled');


            nMap=length(mappingStruct.mapping);

            castedIDs=zeros(nMap,1);


            for kInput=1:nMap

                inMapping=mappingStruct.mapping(kInput);

                blockH=find_system(get_param(model,'Handle'),'SearchDepth'...
                ,1,'BlockType',inMapping.Type,'Name',...
                inMapping.Destination.BlockName);




                if ismethod(externalInputPlugin,'getInputVariablePluginFromIndex')
                    inputVariablePlugin=getInputVariablePluginFromIndex(externalInputPlugin,kInput);
                else

                    inputVariablePlugin=getInputVariablePluginFromMapping(externalInputPlugin,inMapping);
                end


                inportFactory=Simulink.iospecification.InportFactory.getInstance();
                inportPlugin=inportFactory.getInportType(blockH);
                inportPlugin.USE_COMPILED_PARAMS=fastRestartIsOn;


                diagnosticstruct(kInput)=inportPlugin.areCompatible(inputVariablePlugin);

                [diagnosticstruct(kInput),castedIDs]=overrideDiagnostics(obj,diagnosticstruct(kInput),mappingStruct,...
                inportPlugin,inputVariablePlugin,kInput,externalInputPlugin.InputVariables,castedIDs);


                status(kInput)=double(diagnosticstruct(kInput).status);

            end

            if~any(status>1)
                status=logical(status);
            end
        end

    end


    methods(Hidden)



        function consStructResults=decorateResults(obj,model,consStructResults,inputStr)




            inputStrSplit=strsplit(inputStr,',');
            eng=Simulink.sdi.Instance.engine;
            SignalIds=[];
            if~isempty(obj.DatasetID)
                SignalIds=eng.getSignalChildren(obj.DatasetID);
            end

            signalNamesAlreadyCasted=zeros(size(consStructResults.Diagnostics,1),1);


            for id=1:size(consStructResults.Diagnostics,1)

                if~strcmp(consStructResults.Status,'External Input Error')&&...
                    ~strcmp(consStructResults.Diagnostics{id,2},'No Errors')&&...
                    strcmp(consStructResults.Diagnostics{id,2}.MessageID,...
                    'Simulink:SimInput:LoadingDataTypeMismatch')

                    expectedDataType=consStructResults.Diagnostics{id,2}.Arguments{end};

                    if any(strcmp(expectedDataType,obj.supportedCast))

                        dsEleStr=inputStrSplit{id};
                        dsVarName=strsplit(dsEleStr,'.');
                        dsVarName=dsVarName{1};
                        dsInBase=evalin('base',dsVarName);

                        start_id=strfind(dsEleStr,'(')+1;
                        end_id=strfind(dsEleStr,')')-1;
                        dsEleId=sscanf(dsEleStr(start_id:end_id),'%d');
                        if isempty(dsEleId)




                            dsEleName=sscanf(dsEleStr(start_id+1:end_id-1),'%s');
                            [~,dsEleId]=find(dsInBase,dsEleName);
                        end

                        if any(ismember(dsEleId,signalNamesAlreadyCasted))






                            continue;
                        else
                            signalNamesAlreadyCasted(id)=dsEleId;
                        end

                        if any(strcmp(expectedDataType,{'boolean'}))
                            expectedDataType='logical';
                        end
                        if~isempty(SignalIds)&&length(SignalIds)>=dsEleId
                            eng.setMetaDataV2(SignalIds(dsEleId),'CastToDataType',expectedDataType);
                        end

                        dsEleToChange=dsInBase.get(dsEleId);
                        newDsEle=timeseries(starepository.slCastData(dsEleToChange.Data,expectedDataType),dsEleToChange.Time);
                        newDsEle.Name=dsEleToChange.Name;
                        dsInBase=dsInBase.setElement(dsEleId,newDsEle);
                        Signals{1}=dsInBase;
                        assignin('base',char(dsVarName),dsInBase);
                    end

                end
            end

            if obj.FORCE_MODEL_TERMINATION
                UNITS_WARN_STATE_PREV=warning('OFF','Simulink:Unit:UndefinedUnitUsage');
                eval([model,'([],[],[],''term'')']);
                warning(UNITS_WARN_STATE_PREV.state,'Simulink:Unit:UndefinedUnitUsage');
            end


            consStructResults=eval([model,'(''compileForExtInputMappingCheck'')']);
            obj.COMPILE_COUNT=obj.COMPILE_COUNT+1;

        end


        function[diagnosticstruct,castedIDs]=overrideDiagnostics(obj,diagnosticstruct,...
            mappingStruct,inportPlugin,inputVariablePlugin,inportNumber,dsVariable,castedIDs)

            if~isfield(diagnosticstruct.datatype,'diagnosticstext')||...
                isempty(diagnosticstruct.datatype.diagnosticstext)
                return;
            end

            inputStr=mappingStruct.inputStr;
            inputStrSplit=strsplit(inputStr,',');

            dsEleStr=inputStrSplit{inportNumber};

            start_id=strfind(dsEleStr,'(')+1;
            end_id=strfind(dsEleStr,')')-1;
            dsEleId=sscanf(dsEleStr(start_id:end_id),'%d');

            if isempty(dsEleId)




                dsEleName=sscanf(dsEleStr(start_id+1:end_id-1),'%s');
                [~,dsEleId]=find(dsVariable,dsEleName);
            end



            SignalIds=[];
            eng=Simulink.sdi.Instance.engine;
            if~isempty(obj.DatasetID)
                SignalIds=eng.getSignalChildren(obj.DatasetID);
            end

            if any(ismember(dsEleId,castedIDs))







                return;
            else
                castedIDs(inportNumber)=dsEleId;
            end


            expectedDataType=inportPlugin.getDataType();

            if any(strcmp(expectedDataType,obj.supportedCast))
                if any(strcmp(expectedDataType,{'boolean'}))
                    expectedDataType='logical';
                end
                dsEleToChange=dsVariable.get(dsEleId);
                if~isempty(SignalIds)&&length(SignalIds)>=dsEleId
                    eng.setMetaDataV2(SignalIds(dsEleId),'CastToDataType',expectedDataType);


                end
                diagnosticstruct.datatype.diagnosticstext='';
                diagnosticstruct.datatype.status=1;

                ANY_ZEROS=any([diagnosticstruct.signaltype.status,diagnosticstruct.dimension.status]==0);
                ANY_TWOS=any([diagnosticstruct.signaltype.status,diagnosticstruct.dimension.status]==2);
                if ANY_ZEROS
                    diagnosticstruct.status=0;
                elseif ANY_TWOS
                    diagnosticstruct.status=2;
                else
                    diagnosticstruct.status=1;
                end


            end
        end

    end
end
