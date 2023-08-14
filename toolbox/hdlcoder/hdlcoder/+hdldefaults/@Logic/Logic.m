classdef Logic<hdlimplbase.EmlImplBase



    methods
        function this=Logic(block)
            supportedBlocks={'built-in/Logic'};

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.LogicHDLEmission');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        v=validatePortDatatypes(this,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

