
























classdef ModelMapping<handle

    properties(Access=private)

        fModelMappingInfo=[];

        fSignalNameToStorageClassMap;

        fStateNameToStorageClassMap;

        fDataStoreNameToStorageClassMap;

        fModelParameterNameToStorageClassMap;

        fInportNameToStorageClassMap;

        fOutportNameToStorageClassMap;

        fSignalNametoBlockNameMap;

    end


    methods

        function aObj=ModelMapping(aModelName)

            aObj.allocateMapContainers();


aModelMapping...
            =Simulink.CodeMapping.getCurrentMapping(aModelName);
            if~isempty(aModelMapping)...
                &&isa(aModelMapping,'Simulink.CoderDictionary.ModelMapping')

                aObj.fModelMappingInfo...
                =coder.mapping.api.get(aModelName);




                aObj.createSignalStorageClassMapping();


                aObj.createStateStorageClassMapping();


                aObj.createDataStoreStorageClassMapping();


                aObj.createModelParameterStorageClassMapping();


                aObj.createInportStorageClassMapping();


                aObj.createOutportStorageClassMapping();

            end
        end


        function delete(aObj)
            aObj.fModelMappingInfo=[];
        end
    end


    methods

        function out=getSignalInfo(aObj,aKey)
            assert(aObj.hasSignal(aKey),'Unable to find signal in model mapping');
            out=aObj.fSignalNameToStorageClassMap(aKey);
        end


        function out=getStateInfo(aObj,aKey)
            assert(aObj.hasState(aKey),'Unable to find state in model mapping');
            out=aObj.fStateNameToStorageClassMap(aKey);
        end


        function out=getDataStoreInfo(aObj,aKey)
            assert(aObj.hasDataStore(aKey),'Unable to find data store in model mapping');
            out=aObj.fDataStoreNameToStorageClassMap(aKey);
        end


        function out=getModelParameterInfo(aObj,aKey)
            assert(aObj.hasModelParameter(aKey),'Unable to find model parameter in model mapping');
            out=aObj.fModelParameterNameToStorageClassMap(aKey);
        end


        function out=getInportInfo(aObj,aKey)
            assert(aObj.hasInport(aKey),'Unable to find inport in model mapping');
            out=aObj.fInportNameToStorageClassMap(aKey);
        end


        function out=getOutportInfo(aObj,aKey)
            assert(aObj.hasOutport(aKey),'Unable to find outport in model mapping');
            out=aObj.fOutportNameToStorageClassMap(aKey);
        end


        function out=getBlockNameInfo(aObj,aKey)
            assert(aObj.hasSignal(aKey),'Unable to find signal in model mapping');
            out=aObj.fSignalNametoBlockNameMap(aKey);
        end

    end


    methods

        function tf=hasModelMapping(aObj)
            tf=~isempty(aObj.fModelMappingInfo)...
            &&(~isempty(aObj.fSignalNameToStorageClassMap.keys())...
            ||~isempty(aObj.fStateNameToStorageClassMap.keys())...
            ||~isempty(aObj.fDataStoreNameToStorageClassMap.keys())...
            ||~isempty(aObj.fModelParameterNameToStorageClassMap.keys())...
            ||~isempty(aObj.fInportNameToStorageClassMap.keys())...
            ||~isempty(aObj.fOutportNameToStorageClassMap.keys()));
        end


        function tf=hasSignal(aObj,aKey)
            tf=aObj.fSignalNameToStorageClassMap.isKey(aKey);
        end


        function tf=hasState(aObj,aKey)
            tf=aObj.fStateNameToStorageClassMap.isKey(aKey);
        end


        function tf=hasDataStore(aObj,aKey)
            tf=aObj.fDataStoreNameToStorageClassMap.isKey(aKey);
        end


        function tf=hasModelParameter(aObj,aKey)
            tf=aObj.fModelParameterNameToStorageClassMap.isKey(aKey);
        end


        function tf=hasInport(aObj,aKey)
            tf=aObj.fInportNameToStorageClassMap.isKey(aKey);
        end


        function tf=hasOutport(aObj,aKey)
            tf=aObj.fOutportNameToStorageClassMap.isKey(aKey);
        end

    end


    methods(Access=private)

        function createSignalStorageClassMapping(aObj)
            aSignalInfo=find(aObj.fModelMappingInfo,'Signals');
            for aSignal=aSignalInfo
                signalName=get_param(aSignal,...
                'Name');
                scName=aObj.fModelMappingInfo.getSignal(aSignal,...
                'StorageClass');

                value=slci.WSVarInfo;
                value.StorageClass=scName;
                value.DataType=get_param(aSignal,...
                'CompiledPortDataType');


                blockName=get_param(aSignal,'Parent');


                aObj.addSignalNameBlockNameMapping(signalName,blockName);
                aObj.mapConnectedBlocks(signalName,aSignal);


                aObj.fSignalNameToStorageClassMap(signalName)=value;
            end
        end


        function createStateStorageClassMapping(aObj)
            aStateInfo=find(aObj.fModelMappingInfo,'States');
            for aState=aStateInfo
                try
                    stateName=get_param(aState,...
                    'StateName');
                    scName=aObj.fModelMappingInfo.getState(aState,...
                    'StorageClass');
                catch ME %#ok
                    continue;
                end


                if isempty(stateName)
                    continue;
                end


                value=slci.WSVarInfo;
                value.StorageClass=scName;
                value.DataType='double';


                aObj.fStateNameToStorageClassMap(stateName)=value;
            end
        end


        function createDataStoreStorageClassMapping(aObj)
            aDataStoreInfo=find(aObj.fModelMappingInfo,'DataStores');
            for dsmH=aDataStoreInfo
                dataStoreName=get_param(dsmH,'DataStoreName');
                scName=aObj.fModelMappingInfo.getDataStore(dsmH,...
                'StorageClass');

                value=slci.WSVarInfo;
                value.StorageClass=scName;
                runtimeObject=get_param(dsmH,'RuntimeObject');

                value.DataType=runtimeObject.RuntimePrm(1).Datatype;


                aObj.fDataStoreNameToStorageClassMap(dataStoreName)=value;
            end
        end


        function createModelParameterStorageClassMapping(aObj)
            aModelParameterInfo=find(aObj.fModelMappingInfo,'ModelParameters');
            for modelParameterName=aModelParameterInfo
                scName=aObj.fModelMappingInfo.getModelParameter(modelParameterName,...
                'StorageClass');

                value=slci.WSVarInfo;
                value.StorageClass=scName;
                value.DataType='auto';


                aObj.fModelParameterNameToStorageClassMap(modelParameterName)=value;
            end

        end


        function createInportStorageClassMapping(aObj)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            aInportInfo=find(aObj.fModelMappingInfo,'Inports');
            for aInport=aInportInfo
                inport=get_param(aInport,...
                'Object');
                inportName=inport.getRTWName();
                scName=aObj.fModelMappingInfo.getInport(aInport,...
                'StorageClass');

                value=slci.WSVarInfo;
                value.StorageClass=scName;
                portDataType=get_param(aInport,...
                'CompiledPortDataTypes');
                value.DataType=portDataType.Outport{1};


                aObj.fInportNameToStorageClassMap(inportName)=value;
            end
        end


        function createOutportStorageClassMapping(aObj)
            aOutportInfo=find(aObj.fModelMappingInfo,'Outports');
            for aOutport=aOutportInfo
                outportName=get_param(aOutport,...
                'Name');
                scName=aObj.fModelMappingInfo.getOutport(aOutport,...
                'StorageClass');

                value=slci.WSVarInfo;
                value.StorageClass=scName;
                portDataType=get_param(aOutport,...
                'CompiledPortDataTypes');
                value.DataType=portDataType.Inport{1};


                aObj.fOutportNameToStorageClassMap(outportName)=value;
            end
        end


        function addSignalNameBlockNameMapping(aObj,aKeyName,aBlkName)
            if~aObj.fSignalNametoBlockNameMap.isKey(aKeyName)
                aObj.fSignalNametoBlockNameMap(aKeyName)={aBlkName};
            else
                val=aObj.fSignalNametoBlockNameMap(aKeyName);
                val(end+1)={aBlkName};
                aObj.fSignalNametoBlockNameMap(aKeyName)=unique(val);
            end
        end


        function allocateMapContainers(aObj)

            aObj.fSignalNameToStorageClassMap...
            =containers.Map('KeyType','char',...
            'ValueType','any');

            aObj.fStateNameToStorageClassMap...
            =containers.Map('KeyType','char',...
            'ValueType','any');



            aObj.fDataStoreNameToStorageClassMap...
            =containers.Map('KeyType','char',...
            'ValueType','any');


            aObj.fModelParameterNameToStorageClassMap...
            =containers.Map('KeyType','char',...
            'ValueType','any');


            aObj.fInportNameToStorageClassMap...
            =containers.Map('KeyType','char',...
            'ValueType','any');


            aObj.fOutportNameToStorageClassMap...
            =containers.Map('KeyType','char',...
            'ValueType','any');


            aObj.fSignalNametoBlockNameMap...
            =containers.Map('KeyType','char',...
            'ValueType','any');
        end


        function mapConnectedBlocks(aObj,aSignalName,aSignalPortH)
            aPortObj=get_param(aSignalPortH,'Object');
            blockHandle=get_param(aPortObj.Parent,'Handle');
            blockObject=get_param(blockHandle,'Object');
            blockType=blockObject.BlockType;

            if(strcmpi(blockType,'Inport'))

                parent=blockObject.getParent();
                isSubSystem=strcmpi(get_param(parent.Handle,'BlockType'),'SubSystem');

                if isSubSystem

                    portNumber=str2double(blockObject.Port);
                    parentHandle=parent.Handle;
                    srcs=slci.internal.getActualSrc(parentHandle,portNumber-1);
                    for j=1:size(srcs,1)
                        srcBlockName=getfullname(srcs(j,1));
                        aObj.addSignalNameBlockNameMapping(aSignalName,srcBlockName);
                    end
                end

            elseif(strcmpi(blockType,'SubSystem'))

                portNumber=aPortObj.PortNumber;

                outportBlock=find_system(blockHandle,...
                'SearchDepth',1,'AllBlocks','on',...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'LookUnderReadProtectedSubsystems','on',...
                'BlockType','Outport','Port',num2str(portNumber));
                srcs=slci.internal.getActualSrc(outportBlock,0);
                for j=1:size(srcs,1)
                    srcBlockName=getfullname(srcs(j,1));
                    aObj.addSignalNameBlockNameMapping(aSignalName,srcBlockName);
                end
            end
        end
    end

end


