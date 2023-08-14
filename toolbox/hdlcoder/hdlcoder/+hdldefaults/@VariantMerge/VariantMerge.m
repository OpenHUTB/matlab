classdef VariantMerge<hdlimplbase.EmlImplBase





    methods
        function this=VariantMerge(block)
            supportedBlocks={...
            'built-in/VariantMerge',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end

end
