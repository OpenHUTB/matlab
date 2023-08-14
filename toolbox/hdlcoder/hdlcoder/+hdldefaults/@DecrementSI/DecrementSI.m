classdef DecrementSI<hdlimplbase.EmlImplBase



    methods
        function this=DecrementSI(block)
            decBlk=['simulink/Additional Math',newline,'& Discrete/Additional Math:',newline,...
            'Increment - Decrement/Decrement',newline,'Stored Integer'];

            supportedBlocks={...
decBlk
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

