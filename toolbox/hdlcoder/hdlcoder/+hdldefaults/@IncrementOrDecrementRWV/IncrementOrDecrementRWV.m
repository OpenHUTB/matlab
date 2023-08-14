classdef IncrementOrDecrementRWV<hdlimplbase.EmlImplBase



    methods
        function this=IncrementOrDecrementRWV(block)
            incBlk=['simulink/Additional Math',newline,'& Discrete/Additional Math:',newline,...
            'Increment - Decrement/Increment',newline,'Real World'];

            decBlk=['simulink/Additional Math',newline,'& Discrete/Additional Math:',newline,...
            'Increment - Decrement/Decrement',newline,'Real World'];

            supportedBlocks={...
            incBlk,...
decBlk
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);

            this.setPublish(false);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
    end

end

