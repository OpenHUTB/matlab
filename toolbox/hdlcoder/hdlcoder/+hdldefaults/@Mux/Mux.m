classdef Mux<hdlimplbase.EmlImplBase



    methods
        function this=Mux(block)
            supportedBlocks={...
            'built-in/Mux',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.MuxHDLEmission');

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end

end

