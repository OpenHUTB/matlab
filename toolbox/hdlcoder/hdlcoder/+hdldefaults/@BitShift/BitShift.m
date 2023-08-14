classdef BitShift<hdlimplbase.EmlImplBase



    methods
        function this=BitShift(block)
            supportedBlocks={...
            'hdlsllib/Logic and Bit Operations/Bit Shift',...
            'built-in/ArithShift',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.BitOpsHDLEmission');

        end

    end

    methods
        blkInfo=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        hNewC=elaborateBarrelShifter(this,hN,hC)
        hNewC=elaborateDynamicShifter(this,hN,hC)
        builtin=isBuiltinShift(this,slbh)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

