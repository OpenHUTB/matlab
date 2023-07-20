classdef MinMaxTree<hdldefaults.TreeArch



    methods
        function this=MinMaxTree(block)
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
            'ArchitectureNames',{'Tree'},...
            'Deprecates','hdldefaults.MinMaxTreeHDLEmission');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        hNewC=elaborateTreeMinMaxValue(this,hN,oldhN,blockInfo,compName)
        impl=getFunctionImpl(this,hC)
        implInfo=truncateImplParams(~,slbh,implInfo)
        stateInfo=getStateInfo(this,hC)
        needDetailedElab=needDetailedElaboration(this,hN,hInSignals,dspMode)
        isVectorOut=isDspMinmaxVectorOut(~,blockDSPInfo,hCInSignal,blockType)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        retval=allowElabModelGen(this,hN,hC)
        v_settings=block_validate_settings(this,hC)
        treeComp=elaborateMain(this,hN,hC)
        hNewC=elaborateTreeMinMaxValueAndIndex(this,hN,oldhN,blockInfo,blockDSPInfo,blockName)
        blockInfo=getBlockInfo(this,hC)
        blockDSPInfo=getBlockInfoDSP(this,hC)
        constIndexSignals=getIndexConstantComp(this,hN,dimLen,idxBase,indexType,isDspVectorOut)
        blockInfo=getSysObjInfo(this,sysObj)
        [blockDSPInfo,v]=getSysObjInfoDSP(this,hC,v)
    end

end

