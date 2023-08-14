classdef MappingUtils<handle




    methods(Static,Access='public')
        function modelMapping=getModelMapping(modelName,mappingType,internalMappingType)
            slRoot=slroot;
            if~slRoot.isValidSlObject(modelName)
                DAStudio.error('coderdictionary:api:invalidMappingSimulinkObject',...
                mappingType,'model',modelName);
            end

            modelMapping=Simulink.CodeMapping.get(modelName,internalMappingType);
            if isempty(modelMapping)
                DAStudio.error('coderdictionary:api:NoCodeMapping',modelName);
            end
        end
        function[blockMapping,SLBlockPath]=getInport(modelName,mappingType,...
            modelMapping,modelIdentifierType,block,apiName)
            slRoot=slroot;
            if~(slRoot.isValidSlObject(block)&&...
                strcmp(get_param(block,'Type'),'block')&&...
                strcmp(get_param(block,'BlockType'),'Inport'))
                hasError=false;
                if ischar(block)||(isstring(block)&&isscalar(block))
                    blockName=coder.mapping.internal.Utils.escapeSimulinkName(block);
                    SLBlockPath=[char(modelName),'/',char(blockName)];
                    if~(slRoot.isValidSlObject(SLBlockPath)&&...
                        strcmp(get_param(SLBlockPath,'Type'),'block')&&...
                        strcmp(get_param(SLBlockPath,'BlockType'),'Inport'))
                        id=block;
                        hasError=true;
                    else
                        blockH=get_param(SLBlockPath,'Handle');
                    end
                elseif ishandle(block)
                    id=num2str(block);
                    hasError=true;
                else
                    DAStudio.error('coderdictionary:api:invalidSimulinkObject',...
                    'BLOCK',apiName,'inport block name or inport block path or inport block handle');
                end
                if hasError
                    DAStudio.error('coderdictionary:api:invalidMappingSimulinkObject',...
                    mappingType,modelIdentifierType,id);
                end
            else
                blockH=get_param(block,'Handle');
                SLBlockPath=getfullname(blockH);
            end


            if strcmp(get_param(blockH,'IsBusElementPort'),'on')
                if~(codermapping.internal.bep.isMappableBEP(blockH))
                    DAStudio.error('coderdictionary:api:InvalidBlockForBEMapping',...
                    getfullname(blockH));
                end
            end




            try
                modelMapping.addInportToMapping(blockH);
            catch


            end



            mapIdx=find(arrayfun(@(x)isequal(get_param(x.Block,'Handle'),blockH),...
            modelMapping.Inports));
            if length(mapIdx)~=1
                DAStudio.error('coderdictionary:api:invalidMappingIOBlock',...
                'inport',SLBlockPath);
            end
            blockMapping=modelMapping.Inports(mapIdx);
            if length(blockMapping)~=1
                DAStudio.error('coderdictionary:api:invalidMappingIOBlock',...
                'inport',SLBlockPath);
            end
        end

        function[blockMapping,SLBlockPath]=getOutport(modelName,mappingType,...
            modelMapping,modelIdentifierType,block,apiName)
            slRoot=slroot;
            if~(slRoot.isValidSlObject(block)&&...
                strcmp(get_param(block,'Type'),'block')&&...
                strcmp(get_param(block,'BlockType'),'Outport'))
                hasError=false;
                if ischar(block)||(isstring(block)&&isscalar(block))
                    blockName=coder.mapping.internal.Utils.escapeSimulinkName(block);
                    SLBlockPath=[char(modelName),'/',char(blockName)];
                    if~(slRoot.isValidSlObject(SLBlockPath)&&...
                        strcmp(get_param(SLBlockPath,'Type'),'block')&&...
                        strcmp(get_param(SLBlockPath,'BlockType'),'Outport'))
                        id=block;
                        hasError=true;
                    else
                        blockH=get_param(SLBlockPath,'Handle');
                    end
                elseif ishandle(block)
                    id=num2str(block);
                    hasError=true;
                else
                    DAStudio.error('coderdictionary:api:invalidSimulinkObject',...
                    'BLOCK',apiName,'outport block name or outport block path or outport block handle');
                end
                if hasError
                    DAStudio.error('coderdictionary:api:invalidMappingSimulinkObject',...
                    mappingType,modelIdentifierType,id);
                end
            else
                blockH=get_param(block,'Handle');
                SLBlockPath=getfullname(blockH);
            end


            if strcmp(get_param(blockH,'IsBusElementPort'),'on')
                if~(codermapping.internal.bep.isMappableBEP(blockH))
                    DAStudio.error('coderdictionary:api:InvalidBlockForBEMapping',...
                    getfullname(blockH));
                end
            end




            try
                modelMapping.addOutportToMapping(blockH);
            catch


            end



            mapIdx=find(arrayfun(@(x)isequal(get_param(x.Block,'Handle'),blockH),...
            modelMapping.Outports));
            if length(mapIdx)~=1
                DAStudio.error('coderdictionary:api:invalidMappingIOBlock',...
                'inport',SLBlockPath);
            end
            blockMapping=modelMapping.Outports(mapIdx);
            if length(blockMapping)~=1
                DAStudio.error('coderdictionary:api:invalidMappingIOBlock',...
                'outport',SLBlockPath);
            end
        end

        function[SLSignals,PortHandleStr]=getSignal(mappingType,...
            modelMapping,modelIdentifierType,PortHandle,apiName)
            slRoot=slroot;
            if~(slRoot.isValidSlObject(PortHandle)&&strcmp(get_param(PortHandle,'Type'),'port'))

                if ischar(PortHandle)||isstring(PortHandle)
                    id=PortHandle;
                elseif ishandle(PortHandle)
                    id=num2str(PortHandle);
                else
                    DAStudio.error('coderdictionary:api:invalidSimulinkObject',...
                    'PORTHANDLE',apiName,'output port handle');
                end
                DAStudio.error('coderdictionary:api:invalidMappingSimulinkObject',...
                mappingType,modelIdentifierType,id);
            end



            drawnow;

            PortHandleStr=num2str(PortHandle);

            if isequal(mappingType,'data transfer mapping')

                SLSignals=modelMapping.SignalDataTransfers.findobj('PortHandle',PortHandle);
                if length(SLSignals)<1
                    DAStudio.error('coderdictionary:api:invalidMappingDataTransferSignalPort',...
                    PortHandleStr);
                end
            else

                SLSignals=modelMapping.Signals.findobj('PortHandle',PortHandle);
                if length(SLSignals)<1
                    DAStudio.error('coderdictionary:api:invalidMappingERTSignalPort',...
                    PortHandleStr);
                end
            end
        end

        function[SLStates,SLBlockPath]=getState(mappingType,...
            modelMapping,modelIdentifierType,block,apiName)
            slRoot=slroot;
            if~(slRoot.isValidSlObject(block)&&strcmp(get_param(block,'Type'),'block'))

                if ischar(block)||isstring(block)
                    id=block;
                elseif ishandle(block)
                    id=num2str(block);
                else
                    DAStudio.error('coderdictionary:api:invalidSimulinkObject',...
                    'BLOCK',apiName,'block path or block handle');
                end
                DAStudio.error('coderdictionary:api:invalidMappingSimulinkObject',...
                mappingType,modelIdentifierType,id);
            end

            blockH=get_param(block,'Handle');



            modelMapping.addStateToMapping(blockH);

            SLBlockPath=getfullname(block);

            SLStates=modelMapping.States.findobj('OwnerBlockHandle',blockH);
            if length(SLStates)~=1
                DAStudio.error('coderdictionary:api:invalidERTMappingStateBlock',...
                SLBlockPath);
            end

        end

        function SLDataStores=getDataStore(modelMapping,dataStoreName,apiName)
            validateattributes(dataStoreName,{'string','char','double'},{'nonempty'},...
            apiName,'DATASTORENAME',2);
            slRoot=slroot;
            if isnumeric(dataStoreName)
                id=num2str(dataStoreName);
            else
                id=dataStoreName;
            end
            if(slRoot.isValidSlObject(dataStoreName)&&strcmp(get_param(dataStoreName,'Type'),'block'))
                blockH=get_param(dataStoreName,'Handle');



                modelMapping.addDataStoreToMapping(blockH);

                SLDataStores=modelMapping.DataStores.findobj('OwnerBlockHandle',blockH);
                if length(SLDataStores)~=1
                    DAStudio.error('coderdictionary:api:invalidMappingDataStoreName',...
                    id);
                end
            else



                drawnow;

                SLDataStores=modelMapping.DataStores.findobj('Name',dataStoreName);
                if isempty(SLDataStores)
                    DAStudio.error('coderdictionary:api:invalidMappingDataStoreName',...
                    id);
                elseif length(SLDataStores)~=1
                    DAStudio.error('coderdictionary:api:nonUniqueMappingDataStoreName',...
                    id);
                end
            end

        end

        function mappedDSM=getSynthesizedDataStore(modelMapping,SLDataStore,apiName)
            validateattributes(SLDataStore,{'string','char'},{'nonempty'},...
            apiName,'SLDATASTORE',2);

            mappedDSM=modelMapping.SynthesizedLocalDataStores.findobj('Name',SLDataStore);
            if length(mappedDSM)<1
                DAStudio.error('coderdictionary:api:invalidMappingSynthesizedLocalDataStoreName',...
                SLDataStore);
            end
        end

        function mappedParam=getModelParameter(modelMapping,SLParam,apiName)
            validateattributes(SLParam,{'string','char'},{'nonempty'},...
            apiName,'SLPARAM',2);

            mappedParam=modelMapping.ModelScopedParameters.findobj('Parameter',SLParam);
            if length(mappedParam)~=1
                DAStudio.error('coderdictionary:api:invalidMappingParameterName',...
                SLParam);
            end
        end

        function[blockH,paramField]=parseAndValidateBlockParameter(slRoot,parameter,apiName)

            lastSlashPos=find(char(parameter)=='/',1,'last');
            blkPath=extractBefore(parameter,lastSlashPos);
            paramField=extractAfter(parameter,lastSlashPos);


            if~(slRoot.isValidSlObject(blkPath)&&strcmp(get_param(blkPath,'Type'),'block'))

                if ischar(blkPath)||isstring(blkPath)
                    id=blkPath;
                else
                    DAStudio.error('coderdictionary:api:invalidSimulinkObject',...
                    'PARAMETER',apiName,'block parameter');
                end
                DAStudio.error('coderdictionary:api:invalidMappingSimulinkObject',...
                'block parameter mapping','Simulink block',id);
            end

            blockH=get_param(blkPath,'Handle');
        end

        function mappedParam=getBlockParameter(modelMapping,parameter,apiName)
            validateattributes(parameter,{'string','char'},{'nonempty'},...
            apiName,'PARAMETER',3);
            [~,~]=coder.mapping.internal.MappingUtils.parseAndValidateBlockParameter(slroot,parameter,apiName);

            mappedParam=modelMapping.ModelScopedParameters.findobj('BlockParameterPath',parameter);

            if length(mappedParam)~=1
                DAStudio.error('coderdictionary:api:invalidMappingBlockParameterName',...
                parameter);
            end
        end

        function mappedParam=getBaseWorkspaceVariable(modelMapping,MLVar,apiName)
            validateattributes(MLVar,{'string','char'},{'nonempty'},...
            apiName,'MLVAR',2);

            mappedParam=modelMapping.BaseWorkspaceVariables.findobj('Name',MLVar);
            if length(mappedParam)~=1
                DAStudio.error('coderdictionary:api:invalidMappingParameterName',...
                MLVar);
            end
        end
    end
end


