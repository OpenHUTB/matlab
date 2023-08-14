classdef NFPPow2<hdlimplbase.EmlImplBase



    methods
        function this=NFPPow2(block)
            supportedBlocks={...
'hdlNFPMathLib/NFPPow2'
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Generate HDL in native floating point mode',...
            'HelpText','Pow2 implementation for single.');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );
        end

    end

    methods
        hNewC=elaborate(this,hN,blockComp)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
    end

end

