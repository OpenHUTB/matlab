classdef Pol2CartCordic<hdlimplbase.EmlImplBase



    methods
        function this=Pol2CartCordic(block)
            supportedBlocks={...
            'built-in/MagnitudeAngleToComplex',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Pol2CartCordic');

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        cordicInfo=getBlockInfo(this,slbh)
        latencyInfo=getLatencyInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
        v=validatePortDatatypes(~,hC)
    end


    methods(Hidden)
        generateSLBlock(this,hC,targetBlkPath)
        optimize=optimizeForModelGen(this,hN,hC)
    end

end

