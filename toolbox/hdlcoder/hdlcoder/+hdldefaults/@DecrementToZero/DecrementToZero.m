classdef DecrementToZero<hdlimplbase.EmlImplBase



    methods
        function this=DecrementToZero(block)
            decToZeroBlk=['simulink/Additional Math',newline,'& Discrete/Additional Math:',newline,...
            'Increment - Decrement/Decrement',newline,'To Zero'];

            supportedBlocks={...
            decToZeroBlk,...
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
        hNewC=elaborate(this,hN,hC)
    end

end

