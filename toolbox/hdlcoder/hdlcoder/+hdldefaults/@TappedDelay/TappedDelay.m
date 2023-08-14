classdef TappedDelay<hdlimplbase.EmlImplBase



    methods
        function this=TappedDelay(block)
            supportedBlocks={...
            'simulink/Discrete/Tapped Delay',...
'hdl.TappedDelay'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Tapped Delay',...
            'HelpText','Tapped Delay code generation via PIR');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates','hdldefaults.TappedDelayHDLEmission');


        end

    end

    methods
        tdc=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
        [initVal,numDelays,delayorder,includecurrent]=getBlockInfo(this,hC)
    end

end

