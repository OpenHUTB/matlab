classdef FromWksSerializer<Simulink.SimulationData.SerializeInput.InputSerializer




    methods(Access=public)
        function this=FromWksSerializer(...
            model,...
            ds,...
            aobHierarchy,...
            interpolation,...
portBusTypes...
            )
            this.buildData=struct();
            this.model=model;
            this.ds=ds;
            this.aobHierarchy=aobHierarchy;
            this.interpolation=interpolation;
            this.portBusTypes=portBusTypes;
            this.isForConsistencyChecks=false;


            this.slFeatures=this.cacheSlFeatures();
        end

        function serializedDataset=serialize(this,blkHandle)
            serializedDataset=cell(1,1);
            data=this.ds;

            nodeIdx=1;
            dataPath=get_param(blkHandle,'VariableName');
            isBusElement=~isequal(this.portBusTypes{1},'NOT_BUS');
            [serializedDataset{1},~]=...
            this.serialize_element_with_check(...
            this.interpolation(1),...
            data,...
            this.aobHierarchy{1},...
            nodeIdx,...
            blkHandle,...
            dataPath,...
            dataPath,...
            isBusElement,...
            this.portBusTypes{1},...
            1,...
            []...
            );
        end

        function throwError(this,~,errMsg,varargin)
            block=[get(this.currBlock,'Path'),'/',get(this.currBlock,'Name')];
            msgID='Simulink:SimInput:FromWorkspaceError';
            blockName=strrep(block,newline,' ');
            msg=message(msgID,blockName,this.model);
            rtInpException=MSLException(msg);

            causeObj=message(errMsg,varargin{:});
            causeException=MSLException(causeObj);

            rtInpException=addCause(rtInpException,causeException);
            throwAsCaller(rtInpException);
        end
    end


    methods(Access=protected)
        checkForValidLeaf(this,element,dataPath,nodeIdx,isElementOfBus);
        turnOffInterp=validateInterpSettings(this,data,interpolation,inputPath);
    end
end
