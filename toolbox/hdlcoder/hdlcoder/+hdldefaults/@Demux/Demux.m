classdef Demux<hdlimplbase.EmlImplBase



    methods
        function this=Demux(block)
            supportedBlocks={...
            'built-in/Demux',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.DemuxHDLEmission');

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end

end

