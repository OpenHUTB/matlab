classdef IntegerDelay<hdlimplbase.EmlImplBase



    methods
        function this=IntegerDelay(block)
            supportedBlocks={...
            'simulink/Discrete/Integer Delay',...
            'built-in/Delay',...
            'hdl.Delay',...
            };

            if nargin==0
                block='';
            end
            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.IntegerDelayHDLEmission');
        end
    end

    methods
        v_settings=block_validate_settings(this,hC)
        idComp=elaborate(this,hN,hC)

        scalarIC=getInitialValue(~,hC,slbh)
        stateInfo=getStateInfo(~,~)
        val=hasDesignDelay(~,~,~)
        ishwfr=isInHwFriendly(~,hC)
        postElab(this,hN,hPreElabC,hPostElabC)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
        v=validateImplParams(this,hC)
    end

    methods(Hidden)
        status=isFrameProcessing(~,hC,ipmode)
    end
end
