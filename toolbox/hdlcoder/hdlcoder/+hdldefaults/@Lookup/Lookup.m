classdef Lookup<hdlimplbase.EmlImplBase



    methods
        function this=Lookup(block)
            supportedBlocks={...
            'built-in/Lookup',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Inline');



            this.setPublish(false);

        end

    end

    methods
        v_settings=block_validate_settings(this,hC)
        [tablein,tableout,oType_ex]=getBlockInfo(~,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
    end

end

