classdef Backlash<hdlimplbase.EmlImplBase



    methods
        function this=Backlash(block)
            supportedBlocks={...
            'built-in/Backlash',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Backlash Block',...
            'HelpText','HDL will be emitted for this Backlash block');


            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block);

        end

    end

    methods
        [backlashWidth,initialOutput]=getBlockInfo(~,hC)
        stateInfo=getStateInfo(~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(~,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end




end

