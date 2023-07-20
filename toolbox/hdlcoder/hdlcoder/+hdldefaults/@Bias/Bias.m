classdef Bias<hdlimplbase.EmlImplBase



    methods
        function this=Bias(block)
            supportedBlocks={...
            'built-in/Bias',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Bias Block',...
            'HelpText','HDL will be emitted for this Bias-block');

            this.init('SupportedBlocks',supportedBlocks,...
            'ArchitectureNames','Linear',...
            'Description',desc,...
            'Block',block);

        end

    end

    methods
        cval=getBlockDialogValue(this,slbh)
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hBiasComp=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end

end

