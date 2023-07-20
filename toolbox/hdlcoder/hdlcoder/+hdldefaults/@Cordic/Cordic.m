classdef Cordic<hdlimplbase.EmlImplBase




    methods
        function this=Cordic(block)
            supportedBlocks={...
            'built-in/Trigonometry',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Cordic',...
            'Deprecates','SinCosCordic');
        end
    end

    methods
        hNewC=elaborate(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        cordicInfo=getBlockInfo(this,slbh)
        stateInfo=getStateInfo(this,hC)
        cordicInfo=getSysObjInfo(this,hC,sysObjHandle)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
        params=hideImplParams(~,~,~)


    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        latencyInfo=getLatencyInfo(this,hC)
        flag=getUsePipelines(this,isSysObj)
        optimize=optimizeForModelGen(this,hN,hC)
    end


    methods(Static)
        cordicInfo=getSinCosCordicInfo(numIter,fcnName,inputWL)
    end

end

