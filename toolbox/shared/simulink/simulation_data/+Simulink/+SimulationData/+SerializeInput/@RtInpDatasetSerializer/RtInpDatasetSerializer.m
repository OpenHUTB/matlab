classdef(Sealed)RtInpDatasetSerializer<Simulink.SimulationData.SerializeInput.InputSerializer




    properties(Access=private)


diagStruct
    end

    methods(Access=public)
        function this=RtInpDatasetSerializer(...
            buildData,...
            model,...
            ds,...
            aobHierarchy,...
            interpolation,...
            portBusTypes,...
            msgPortIdxs,...
            isForConsistencyChecks,...
            rootInportsInfo)
            this.buildData=buildData;
            this.model=model;
            this.ds=ds;
            this.aobHierarchy=aobHierarchy;
            this.interpolation=interpolation;
            this.portBusTypes=portBusTypes;
            this.msgPortIdxs=msgPortIdxs;
            this.isForConsistencyChecks=isForConsistencyChecks;
            this.rootInportsInfo=rootInportsInfo;
            this.diagStruct=[];


            this.slFeatures=this.cacheSlFeatures();
        end

        function[serializedDataset,diagStruct]=serializeDataset(this)
            if(isempty(this.rootInportsInfo))
                [numExternalInputPorts,rootInports,numInports,...
                enablePort,~,enablePortIdx,...
                triggerPort,~,triggerPortIdx,...
                ~,containsBusElPorts]=...
                Simulink.SimulationData.util.countRootInportsByType(this.model);
            else
                numExternalInputPorts=this.rootInportsInfo.numExternalInputPorts;
                rootInports=this.rootInportsInfo.rootInports;
                numInports=this.rootInportsInfo.numInports;
                enablePort=this.rootInportsInfo.enablePort;
                enablePortIdx=this.rootInportsInfo.enablePortIdx;
                triggerPort=this.rootInportsInfo.triggerPort;
                triggerPortIdx=this.rootInportsInfo.triggerPortIdx;
                containsBusElPorts=this.rootInportsInfo.containsBusElPorts;
            end

            if containsBusElPorts&&this.slFeatures.rootBusElementPortLoading
                this.ds=this.expandDatasetForBusElPorts(...
                rootInports,...
                numel(enablePort)+numel(triggerPort),...
                this.rootInportsInfo);
            end

            if this.ds.numElements~=numExternalInputPorts
                DAStudio.error(...
                'Simulink:Logging:InvInputLoadNameList',...
                numExternalInputPorts,...
                this.ds.numElements...
                );
            end
            serializedDataset=cell(1,numExternalInputPorts);



            this.verify_message_inport_data(rootInports);

            inputPath=get_param(this.model,'ExternalInput');

            diagStruct=[];
            elementIdx=1;
            while elementIdx<=numExternalInputPorts
                datasetElement=this.ds.get(elementIdx);
                nodeIdx=1;
                dataPath=sprintf('%s{%d}',inputPath,elementIdx);
                assert(...
                elementIdx<=numInports||...
                elementIdx==enablePortIdx||...
                elementIdx==triggerPortIdx...
                );
                if elementIdx<=numInports
                    block=rootInports{elementIdx};
                elseif elementIdx==enablePortIdx
                    block=enablePort{1};
                else
                    block=triggerPort{1};
                end
                isBusElement=~isequal(this.portBusTypes{elementIdx},'NOT_BUS');
                [serializedDataset{elementIdx},diagStruct]=...
                this.serialize_element_with_check(...
                this.interpolation(elementIdx),...
                datasetElement,...
                this.aobHierarchy{elementIdx},...
                nodeIdx,...
                block,...
                inputPath,...
                dataPath,...
                isBusElement,...
                this.portBusTypes{elementIdx},...
                elementIdx,...
diagStruct...
                );
                elementIdx=elementIdx+1;
            end
        end

        function[result,diagStruct]=loc_serialize_dataset_element_partition(...
            this,...
            datasetElement,...
name...
            )
            result=this.serialize_dataset_element_fcncall(...
            datasetElement,...
''...
            );
            result.SignalName=name;
            diagStruct=[];
        end

        function throwError(this,isExtInpErr,errMsg,varargin)
            if this.isForConsistencyChecks



                if isExtInpErr
                    mappingException=MSLException(...
                    'ConsistencyCheck:ExtInpError',...
                    'External Input Error');
                else
                    mappingException=MSLException(...
                    'ConsistencyCheck:ExtInpError',...
                    'Root Inport Mapping Error');
                end
                rtInpException=MSLException(message(errMsg,varargin{:}));
                mappingException=mappingException.addCause(rtInpException);
                throwAsCaller(mappingException);
            else


                msgID='Simulink:SimInput:DatasetRootInportError';
                msg=message(msgID,this.currBlock,this.model);
                rtInpException=MSLException(msg);

                causeObj=message(errMsg,varargin{:});
                causeException=MSLException(causeObj);

                rtInpException=addCause(rtInpException,causeException);
                throwAsCaller(rtInpException);
            end
        end
    end
end


