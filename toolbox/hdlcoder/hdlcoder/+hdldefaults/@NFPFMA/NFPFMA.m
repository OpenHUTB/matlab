classdef NFPFMA<hdlimplbase.EmlImplBase



    methods
        function this=NFPFMA(block)
            supportedBlocks={...
'hdlNFPMathLib/Fused Multiply-Add'
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Generate HDL in native floating point mode',...
            'HelpText','Fused-Multiply-Add implementation for single.');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );
        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
    end

end

