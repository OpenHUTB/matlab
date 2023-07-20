classdef DirectLookupTable<hdlimplbase.EmlImplBase



    methods
        function this=DirectLookupTable(block)
            supportedBlocks={...
            'built-in/LookupNDDirect',...
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
        hNewC=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        compatible=isAdaptivePipeliningCompatible(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
        v=validatePortDatatypes(~,hC)
    end


    methods(Hidden)
        retval=usesSimulinkHandleForModelGen(~,~,~)
    end

end

