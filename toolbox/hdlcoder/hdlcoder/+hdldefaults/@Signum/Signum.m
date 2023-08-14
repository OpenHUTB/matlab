classdef Signum<hdlimplbase.EmlImplBase





    methods
        function this=Signum(block)

            supportedBlocks={...
            'built-in/Signum',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.SignumHDLEmission');
        end

    end

    methods
        [dspMode,nfpOptions]=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
        v=validateBlock(this,hC)
    end

end

