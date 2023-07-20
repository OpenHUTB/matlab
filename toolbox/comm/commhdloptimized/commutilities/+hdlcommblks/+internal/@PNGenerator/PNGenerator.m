classdef PNGenerator<hdlcommblks.internal.AbstractCommHDL






























    methods
        function this=PNGenerator(block)




            supportedBlocks={...
            ['commseqgen2/PN Sequence',newline,'Generator'],...
            ['commseqgen3/PN Sequence',newline,'Generator'],...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL code generation for PN Sequence Generator',...
            'HelpText','HDL code generation for PN Sequence Generator');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates','hdldefaults.PNgenHDLEmission');


        end

    end

    methods
        blockInfo=getBlockInfo(this,hC)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        nComp=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end

end

