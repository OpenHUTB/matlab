classdef(Sealed,Hidden)ReductionManager<handle










    methods(Hidden)


        reduceModel(obj);

    end

    properties(Transient)

        ActiveMdlRefBlks={};

        ActiveRefMdls={};


        BDNameRedBDNameMap=containers.Map;


        ModelBlocksInLib={};

        ModelsToBeProcessed={};

        SubModelConfigPropagationMap=containers.Map;


        ModelRefModelInfoStructsVec(:,1)Simulink.variant.reducer.types.VRedModelBlock;


        ProcessedModelInfoStructsVec(:,1)Simulink.variant.reducer.types.VRedModelInfo;


        CompiledPortAttributesMap=containers.Map;

        LibInfoStructsVec(:,1)Simulink.variant.reducer.types.VRedLibraryBlock;


        AllLibBlksMap=containers.Map;




        LibBlkToModelInstanceMap=containers.Map;

        ResolvedLibBlockInfo=struct([]);

        LogMsgs={};

        Warnings={};







        PortsToAddBusSubsystemBlock=struct([]);





        OrigMdlAnnotationAreas(1,:)Simulink.internal.variantlayout.AnnotationArea;


        SysHandlesToLayout(:,1)double=[];


        SysPathsToLayout=containers.Map('keyType','char','valueType','double');



        LayerPlacedSystems(:,1)double=[];


        AddedBlockSrcDstPortVec(:,1)double=[];




        ReportDataObj(1,1)Simulink.variant.reducer.summary.SummaryData;





        InactiveAZVCOffIVBlockToActivePortMap=containers.Map('keyType','char','valueType','any');

        FullRangeAnalysisInfo=[];




        CompiledBusSrcPortAttribsMap=containers.Map('keyType','char','valueType','any');


        BlocksInserted(:,1)double=[];



        IsVariableDependencyAnalysisSuccess(1,1)logical=false;




        Error=[];
        VarNameSimParamExpressionHierarchyMap=containers.Map;
        SubModelToModelMap=containers.Map('keyType','char','valueType','any');
        ApplyConfigInfo(1,1)Simulink.variant.reducer.types.VRedApplyConfigInfo;
        LibsToCopy=[];
        LibsToCopyWithPath=[];
        AllLibInfo=[];

        ResMRLibInfo=[];
        AllRefBlocksInfo(1,1)Simulink.variant.reducer.types.VRedRefBlocksInfo;

        SRBlkInstToRedSRBD=containers.Map('keyType','char','valueType','char');

        ModelBlocksInLinkedSR={};


        ProcessedImplicitSRBlocks=containers.Map('keyType','double','valueType','double');

        RedBDLevelMap=containers.Map('keyType','uint32','valueType','any');




        RedundantSRFiles=containers.Map('keyType','char','valueType','char');



        ProcessedSRInstancesInRedBD=containers.Map('keyType','double','valueType','char');


        ProcessedMdlBlksInRedSRBD=containers.Map('keyType','double','valueType','double');


        ProcessedLibBlksInRedSRBD=containers.Map('keyType','double','valueType','double');

        CfgToMdlRefData;
    end

    properties(Transient,SetAccess=private)

        ReductionOptions(1,1)Simulink.variant.reducer.ReductionOptions;

        DataDictionaryRenameManager;





        PortsToAddSigSpec=containers.Map('keyType','char','valueType','any');


        Environment Simulink.variant.reducer.Environment;




    end

    methods


        function obj=ReductionManager(rOptsStruct)





            aliveSwitch=Simulink.variant.reducer.AliveSwitch.getInstance();
            aliveSwitch.setAliveStatus(true);


            obj.ReductionOptions=Simulink.variant.reducer.ReductionOptions(rOptsStruct);

            obj.DataDictionaryRenameManager=Simulink.variant.reducer.DataDictionaryRenameManager(obj);



            obj.clearContents();


            obj.Environment=Simulink.variant.reducer.Environment();


            obj.ReportDataObj=Simulink.variant.reducer.summary.SummaryData();
        end


        function delete(obj)

            obj.clearContents();




            hplgmngr=Simulink.PluginMgr;
            hplgmngr.detachForAllModels('VARIANTREDUCER');




            aliveSwitch=Simulink.variant.reducer.AliveSwitch.getInstance();
            aliveSwitch.setAliveStatus(false);

        end



        function environment=getEnvironment(obj)

            environment=obj.Environment;

        end



        function rOpts=getOptions(obj)

            rOpts=obj.ReductionOptions;

        end


        generateReport(obj);

        function clearContents(obj)

            obj.PortsToAddSigSpec=containers.Map('keyType','char','valueType','any');
            obj.CompiledPortAttributesMap=containers.Map('keyType','char','valueType','any');
            obj.AllLibBlksMap=containers.Map('keyType','char','valueType','any');
            obj.SubModelConfigPropagationMap=containers.Map('keyType','char','valueType','any');
            obj.BDNameRedBDNameMap=containers.Map('keyType','char','valueType','char');

            obj.InactiveAZVCOffIVBlockToActivePortMap=containers.Map('keyType','char','valueType','any');
            obj.CompiledBusSrcPortAttribsMap=containers.Map('keyType','char','valueType','any');
            obj.FullRangeAnalysisInfo=[];
            obj.LibBlkToModelInstanceMap=containers.Map('keyType','char','valueType','char');


            obj.ModelRefModelInfoStructsVec=Simulink.variant.reducer.types.VRedModelBlock.empty;
            obj.ProcessedModelInfoStructsVec=Simulink.variant.reducer.types.VRedModelInfo.empty;
            obj.LibInfoStructsVec=Simulink.variant.reducer.types.VRedLibraryBlock.empty;
            obj.ResolvedLibBlockInfo=struct([]);
            obj.PortsToAddBusSubsystemBlock=struct([]);
            obj.AllRefBlocksInfo=Simulink.variant.reducer.types.VRedRefBlocksInfo;
            obj.VarNameSimParamExpressionHierarchyMap=containers.Map;
            obj.SubModelToModelMap=containers.Map('keyType','char','valueType','any');
            obj.LibsToCopy=[];
            obj.LibsToCopyWithPath=[];
            obj.AllLibInfo=[];
            obj.ResMRLibInfo=[];
            obj.SRBlkInstToRedSRBD=containers.Map('keyType','char','valueType','char');
            obj.ModelBlocksInLinkedSR={};
            obj.ProcessedImplicitSRBlocks=containers.Map('keyType','double','valueType','double');
            obj.RedBDLevelMap=containers.Map('keyType','uint32','valueType','any');
            obj.RedundantSRFiles=containers.Map('keyType','char','valueType','char');
            obj.ProcessedSRInstancesInRedBD=containers.Map('keyType','double','valueType','char');
            obj.ProcessedMdlBlksInRedSRBD=containers.Map('keyType','double','valueType','double');
            obj.ProcessedLibBlksInRedSRBD=containers.Map('keyType','double','valueType','double');
            obj.SysPathsToLayout=containers.Map('keyType','char','valueType','double');
            obj.CfgToMdlRefData=containers.Map('keyType','char','valueType','any');
        end

        function throwOnError(obj)
            if~isempty(obj.Error)
                throw(obj.Error)
            end
        end
    end

    methods(Hidden,Access={?VariantReducerTester,?VRedUnitTest})


        cleanUpModels(obj,err);

        err=validateIOArgs(obj);

        err=setupAbsOutDir(obj);

        err=preprocessInput(obj);

        err=assertGPCOnMultiActiveBlocks(obj);

        err=applyConfigs(obj);

        err=processLibs(obj);

        err=processConfigsForModels(obj);

        err=reduceBDCopies(obj);

        addBusSubsystemBlocks(obj);

        analyzeDeps(obj);

        saveBDCopies(obj);

        addSignalSpecificationBlocks(obj);

        layoutReducedModel(obj);

        saveModelsAndDependencies(obj);

        reduceAndSaveCommonDeps(obj);

        generateReducerLog(obj,err);

        setupReportData(obj);

        err=reduceMasks(obj);

        postProcessReduceModelError(obj);
        copyBDs(obj);
        [newRefsBlk,allRefsBlk]=accumulateRefsForBlkIteratively(obj,newRefsBlk,allRefsBlk);
        saveSRCopies(obj);
        blockHandle=getBlockHandleForReducedModel(obj,blockPath,blkInfo);
        blkPath=getBlockInRedSR(obj,blkInSR,blkInfo);
    end

    methods(Hidden,Access={?VRedUnitTest})

        annotationAreaObjVec=i_getAreaAnnotMargins(obj);

        callbacks=i_getCallbacks(obj)

        blkH=i_addBlock(obj,blkToAdd)

        populatePortsToAddBusHierSSOrSigSpec(obj,srcPort,dstPorts,attributeStructVec,isDstAttrib,isLib,isBusCase,origBlkCell)

        isCondModified=i_modifyVarCondExpr(obj,varBlockPath,enumForModCond,varargin)

        i_modifyMdlRefBlkLink(obj,mdlRefBlk)

        [blkAttribsVec,origBlkCell]=getCompiledPortAttributesForLibBlk(obj,blkPath,portNumber)

        wireUpDisabledVSS(obj,varBlockPath,portsToAddConstant)

        setPortsToAddSigSpec(obj,portParent,ssPortInfo);

        collectPortAttributesForSSRefBlocks(obj);
    end

    methods(Hidden,Access={?VariantReducerTester})


        function callbacks=hGetCallbacks(obj)
            callbacks=obj.i_getCallbacks();
        end

    end

    methods(Hidden,Static)
        varBlkChoiceInfoStructsVec=i_checkAndPopulateVarBlkChoiceInfo(...
        compVarBlockPath,varBlkChoiceInfoStructsVec,varBlkActChoice,varargin)
        specialBlockInfoStructsVec=i_checkAndPopulateSpecialBlockInfo(...
        compSpecialBlockPath,specialBlockInfoStructsVec,specialBlockInfo,varargin)
    end

end




