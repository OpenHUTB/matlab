classdef RelationalOperator<hdlimplbase.EmlImplBase



    methods
        function this=RelationalOperator(block)
            supportedBlocks={'built-in/RelationalOperator'};

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.RelationalOperatorHDLEmission');


        end

    end

    methods
        [opName,inputSameDT]=getBlockInfo(~,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
        v=validatePortDatatypes(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end

end

