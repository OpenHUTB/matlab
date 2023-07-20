classdef NFPReinterpretCast<hdlimplbase.EmlImplBase



    methods
        function this=NFPReinterpretCast(block)
            supportedBlocks={...
            'built-in/FloatTypecast',...
'hdlcoderNFPCast/NFPCast'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Generate HDL in native floating point mode',...
            'HelpText','Wires will be emitted for this block in native floating point mode');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );


        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
        v=getHelpInfo(this,blkTag)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
    end

end

