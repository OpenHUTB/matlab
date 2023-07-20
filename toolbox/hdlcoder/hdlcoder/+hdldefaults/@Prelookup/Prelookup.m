classdef Prelookup<hdlimplbase.EmlImplBase



    methods
        function this=Prelookup(block)
            supportedBlocks={...
            'built-in/PreLookup',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);

        end

    end

    methods
        v_settings=block_validate_settings(this,~)
        newComp=elaborate(this,hN,hC)
        [bp_data_typed,bpType_ex,kType_ex,fType_ex,idxOnly,powerof2,diagnostics]=getBlockInfo(~,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
        v=validatePortDatatypes(~,hC)
    end


    methods(Hidden)
        retval=usesSimulinkHandleForModelGen(~,~,~)
    end

end

