classdef DeadZone<hdlimplbase.EmlImplBase



    methods
        function this=DeadZone(block)
            supportedBlocks={...
            'built-in/DeadZone',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Dead Zone Block',...
            'HelpText','HDL will be emitted for this Dead Zone block');


            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block);

        end

    end

    methods
        [lowerLimit,upperLimit,rndMode,satMode]=getBlockInfo(~,hC)
        stateInfo=getStateInfo(~,~)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end

end

