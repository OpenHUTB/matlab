classdef RateTransition<hdlimplbase.EmlImplBase



    methods
        function this=RateTransition(block)
            supportedBlocks={...
            'built-in/RateTransition',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.RateTransitionHDLEmission');



        end

    end

    methods
        rtComp=elaborate(~,hN,hC)
        implInfo=truncateImplParams(~,slbh,implInfo)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        compatible=isAdaptivePipeliningCompatible(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
        [initC,dintegrity_on,ddtransfer_on,inputRate,outputRate,areRatesSynchronous,isAsyncRTAsWire]=getBlockInfo(this,hC)
    end

end

