classdef BitSlice<hdlimplbase.EmlImplBase



    methods
        function this=BitSlice(block)
            supportedBlocks={...
            'hdlsllib/Logic and Bit Operations/Bit Slice',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
        v_settings=block_validate_settings(this,hC)

    end

end

