classdef RoundingFunction<hdlimplbase.EmlImplBase



    methods
        function this=RoundingFunction(block)
            supportedBlocks={...
            'built-in/Rounding',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Rounding Function Block',...
            'HelpText','HDL will be emitted for this Rounding Function block');


            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block);
        end

    end

    methods
        stateInfo=getStateInfo(~,~)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
    end

end

