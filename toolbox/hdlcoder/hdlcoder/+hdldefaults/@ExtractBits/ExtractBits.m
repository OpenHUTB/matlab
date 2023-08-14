classdef ExtractBits<hdlimplbase.EmlImplBase



    methods
        function this=ExtractBits(block)
            supportedBlocks={...
            'simulink/Logic and Bit Operations/Extract Bits',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','emission',...
            'CodeGenFunc','emit',...
            'CodeGenParams',[],...
            'HandleType','useobjandcomphandles');

        end

    end

    methods
        [ul,ll,mode]=getBlockInfo(this,slbh,hC)
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
    end

end

