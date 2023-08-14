classdef MinMaxCascade<hdldefaults.CascadeArch



    methods
        function this=MinMaxCascade(block)
            supportedBlocks={...
            'built-in/MinMax',...
            'dspstat3/Maximum',...
            'dspstat3/Minimum',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'Cascade'},...
            'Deprecates','hdldefaults.MinMaxCascadeHDLEmission');


        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        generateSLBlock(this,hC,targetBlkPath)
        decomposition=getDecomposition(this)
        impl=getFunctionImpl(this,hC)
        instantiateStages=getInstantiateStages(this)
        latencyInfo=getLatencyInfo(this,hC)
        val=getMaxOversampling(this,hC)
        stateInfo=getStateInfo(this,hC)
        isVectorOut=isDspMinmaxVectorOut(this,slbh,hCInSignal,blockType)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        cascadeExpandCgirComp_ValueAndIndex(this,hN,hC,opName,opOutType,ipf,bmp,tSignalsIn,tSignalsOut,casName,indexType,idxBase)
        cascadeStageCgirComp_ValueAndIndex(this,hN,hC,opName,decomposeStage,ipf,bmp,hSignalsIn,hSignalsOut,decompose_vector,isStartStage,indexType)
        hNewC=elaborate(this,hN,hC)
        elaborateCascadeMinMaxValue(this,hN,hC)
        elaborateCascadeMinMaxValueAndIndex(this,hN,hC)
        hNewC=elaborateMain(this,hN,hC)
        [fcnString,compType,blockType,idxBase,rndMode,satMode]=getBlockInfo(this,slbh)
        [operateOver,specifyDim]=getBlockInfoDSP(this,slbh)
        idComp=getCascadeControllerIndex(this,hN,hInSignals,hOutSignals,decomposeStage,isStartStage,name)
        compName=getCompName(this,hC,opName)
        constIndexSignals=getIndexConstantComp(this,hN,dimLen,idxBase,indexType,isDspVectorOut)
        [constIndex1,constIndex2,constComp1,constComp2]=getIndexConstantCompTwo(this,hN,indexType)
        optimize=optimizeForModelGen(this,hN,hC)
    end

end

