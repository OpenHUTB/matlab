classdef Switch<hdlimplbase.EmlImplBase



    methods
        function this=Switch(block)
            supportedBlocks={...
            'built-in/Switch',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','built-in Switch in PIR',...
            'HelpText','Switch code generation via the PIR MuxComp implementation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.SwitchHDLEmission','hdldefaults.SwitchRTW'});

        end

    end

    methods

        hNewC=elaborate(this,hN,hC)
        [compareStr,compareVal,roundMode,overflowMode]=getBlockInfo(~,hC)
        implInfo=truncateImplParams(~,slbh,implInfo)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end

    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

