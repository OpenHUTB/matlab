classdef(Sealed)FlexSrcSerializer<Simulink.SimulationData.SerializeInput.InputSerializer




    methods(Access=public)
        function this=FlexSrcSerializer(...
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

            isStructWithDst=false;
            if isstruct(data)

                isStructWithDst=this.areAllLeafsSimDst(data);
            end
            isValidInput=isa(data,'matlab.io.datastore.SimulationDatastore')||...
            isStructWithDst;
            if~isValidInput&&...
                ~isequal(this.slFeatures.flexibleFromWksLoading,1)
                msg=message('Simulink:SimInput:FlexibleFromWksDstOnly');
                ex=MSLException(msg);
                throwAsCaller(ex);
            end

            nodeIdx=1;
            block=find_system(this.model,'Handle',blkHandle);
            block=block{1};
            dataPath=get_param(block,'VariableName');
            isBusElement=~isequal(this.portBusTypes{1},'NOT_BUS');
            [serializedDataset{1},~]=...
            this.serialize_element_with_check(...
            this.interpolation(1),...
            data,...
            this.aobHierarchy{1},...
            nodeIdx,...
            block,...
            dataPath,...
            dataPath,...
            isBusElement,...
            this.portBusTypes{1},...
            1,...
            []...
            );
        end

        function throwError(this,~,errMsg,varargin)
            msgID='Simulink:SimInput:FlexibleFromWorkspaceError';
            msg=message(msgID,this.currBlock,this.model);
            rtInpException=MSLException(msg);

            causeObj=message(errMsg,varargin{:});
            causeException=MSLException(causeObj);

            rtInpException=addCause(rtInpException,causeException);
            throwAsCaller(rtInpException);
        end
    end

    methods(Access=private)
        function isStructWithDst=areAllLeafsSimDst(this,data)




            isStructWithDst=true;
            if isstruct(data)
                fields=fieldnames(data);
                for idx=1:numel(data)
                    for jdx=1:numel(fields)
                        isStructWithDst=this.areAllLeafsSimDst(data(idx).(fields{jdx}));
                        if~isStructWithDst
                            return
                        end
                    end
                end
            else
                if~isa(data,'matlab.io.datastore.SimulationDatastore')||...
                    ~isscalar(data)
                    isStructWithDst=false;
                    return
                end
            end
        end
    end

end


