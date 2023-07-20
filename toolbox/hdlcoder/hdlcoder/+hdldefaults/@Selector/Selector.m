classdef Selector<hdlimplbase.EmlImplBase



    methods
        function this=Selector(block)
            supportedBlocks={...
            'built-in/Selector',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.SelectorHDLEmission');


        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        [numDims,indexMode,indexOptionArray,indexParamArray,outputSizeArray,inputPortWidth,nfpOptions]=getBlockInfo(this,hC)
    end

end

