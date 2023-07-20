classdef Goto<hdlimplbase.EmlImplBase



    methods
        function this=Goto(block)
            supportedBlocks={...
            'built-in/Goto',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Goto Block Implementation',...
            'HelpText','Goto Block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates','hdldefaults.GotoBlock');

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        [tag,scope]=getTag(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
        registerImplParamInfo(this)
    end

end

