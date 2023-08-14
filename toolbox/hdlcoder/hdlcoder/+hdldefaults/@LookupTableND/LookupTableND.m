classdef LookupTableND<hdlimplbase.EmlImplBase



    methods
        function this=LookupTableND(block)
            supportedBlocks={...
            'built-in/Lookup_n-D',...
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
        stateInfo=getStateInfo(this,hC)
        compatible=isAdaptivePipeliningCompatible(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
        v=validatePortDatatypes(~,hC)
    end


    methods(Hidden)
        newComp=elaborate(this,hN,hC)
        [table_data_typed,bpType_ex,oType_ex,fType_ex,powerof2,interpVal,bp_data,dims,rndMode,satMode,diagnostics,extrap,spacing]=getBlockInfo(~,hC)
        nfpOptions=getNFPBlockInfo(this)
        retval=usesSimulinkHandleForModelGen(~,~,~)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
        implInfo=truncateImplParams(~,slbh,implInfo)
    end

end

