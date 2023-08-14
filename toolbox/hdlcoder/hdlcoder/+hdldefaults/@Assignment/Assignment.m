classdef Assignment<hdlimplbase.EmlImplBase



    methods
        function this=Assignment(block)
            supportedBlocks={...
            'built-in/Assignment',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.AssignmentHDLEmission');
        end
    end

    methods
        hNewC=elaborate(this,hN,hC)
        [idxBase,ndims,idxParamArray,...
        idxOptionArray,outputSizeArray]=getBlockInfo(~,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
    end

    methods(Hidden)
        v_settings=block_validate_settings(~,~)
    end
end

