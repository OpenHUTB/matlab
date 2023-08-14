classdef AlteraDSPBuilderBlackBox<hdldefaults.ThirdPartyBlackBox



    methods
        function this=AlteraDSPBuilderBlackBox(block)
            supportedBlocks={...
            'built-in/SubSystem',...
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Altera DSP Builder Black Box',...
            'HelpText','Instantiate an Altera DSP Builder black box entity');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','instantiation',...
            'Description',desc,...
            'ArchitectureNames',{'AlteraBlackBox'},...
            'Hidden',true);


        end

    end

    methods
        str=alterahdlname(this,strin)
        v_settings=block_validate_settings(~,~)
        hdlcode=emit(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(this,hC)
    end

end

