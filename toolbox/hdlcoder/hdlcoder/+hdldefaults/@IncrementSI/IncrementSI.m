classdef IncrementSI<hdlimplbase.EmlImplBase



    methods
        function this=IncrementSI(block)
            incBlk=['simulink/Additional Math',newline,'& Discrete/Additional Math:',newline,...
            'Increment - Decrement/Increment',newline,'Stored Integer'];

            supportedBlocks={...
incBlk...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates',{'hdldefaults.IncrementOrDecrementSI'});

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
    end

end

