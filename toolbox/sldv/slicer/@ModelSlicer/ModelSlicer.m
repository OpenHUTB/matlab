







classdef(Abstract)ModelSlicer<handle&matlab.mixin.Heterogeneous


    properties(Access=public,Hidden=true)
        slicingMode='static'
        modelH=[];




        designInterests=struct('blocks',[],'signals',[]);





        constraints=[];


        cvd=[]


        deadLogicData=[]


        hasError=false;


        options;


        currentSliceName='';
        currentSliceMdlH=-1;
        currentSliceMap=[];


        sliceSubSystemH=[];
        simDataLog=[];
        globalDsmData=[];

        session=[];




        atomicGroups=[];


        SimState=[];



        inactiveHdls=[];

        simHandler=[];
        showCtrlDep=false;

        mdlStructureInfo=[];
        mdlRefCtxMgr=[];

        collectCoverageDuringSimulation=true;


        dir='back';


        exc=[];
    end

    properties(Hidden=true)

        dlg=[];

        barH=[];


        useEmbeddedDDG=true;
        origStudioPos=[];
        dockedStudio=[];
        embedDDGComp=[];
        destroyListener=[];
    end

    properties(Hidden=true)

transforms

    end

    properties(Hidden=true,Constant=true)



        Terminated=0;
        Compiled=1;
        EditableHighlight=2;
        TerminatedForTimeWindowSimulation=3;
        CreatingIR=4;
        UsingCovTool=5;
    end

    properties(Dependent=true,SetAccess=public,GetAccess=public,Hidden=true)

        model;

        isSubsystemSlice;

        isHarness;

        compiled;
    end

    properties(Dependent=true,SetAccess=private,GetAccess=public,Hidden=true)
        refMdlToMdlBlk;
    end

    properties(SetAccess=private,GetAccess=public,Hidden=true)
        sdiInstance;
        savedRegularSdiSession=false;
        initialSdiRuns=[];
        preCompileMdlAndRefs=[];
    end

    events
eventModelSlicerDialogClosed
eventModelSlicerTimeWindowSet
eventModelSlicerSimStepHighlighted
    end

    methods(Abstract)
        status=checkCompatibility(obj,varargin);
        createIR(obj);
        [signalPaths,blocks]=analyse(obj)
        setAnalysisSeeds(obj,sc);

        yesno=isBlockValidTarget(obj,bh)
        yesno=isPortValidTarget(obj,ph)
        yesno=isTerminalBlock(obj,bh)
        desH=getSystemAllDescendants(obj);

        ancestors=utilGetAncestors(obj,bh);
        ancestors=utilGetVirtualBlkAncestors(obj);
        childComponents=utilGetAllChildComponents(obj);
        yesno=shouldRetainMdlBlockOutport(obj,blkH,deadBlocks);
        dsmNames=getGlobalDsmNames(obj);
        dsmHandles=getLocalDsms(obj);
    end

    methods(Abstract,Access=protected)
        [deadBlocks,allH,inactiveV]=utilComputeDeadBlocks(obj);
        modifiedSystems=removeUnusedBlocks(obj,sliceXfrmr,sliceMdl,handlesCopy,redundantMerges,handles);
        [hdls,deadBlocksMapped,toRemove,activeH,allNonVirtH,synthDeadBlockH]=utilGetAllHandles(obj,deadBlocks);
        replaceModelBlockH=utilGetReferencedModelBlocks(obj,handle);
        hasGlobal=checkHasGlobal(obj);
        utilRemoveBlocks(obj,sliceXfrmr,sliceRootSys,origSys,groups,sldvPassthroughDeadBlocks,synthDeadBlockH);
        preSliceSubsysPorts=getSubsysCache(obj,sliceMdl);
        postProcessSubsysPorts(obj,sliceXfrmr,sliceMdl,preSliceSubsysPorts);
    end

    methods

        function refMdlToMdlBlk=get.refMdlToMdlBlk(obj)
            if~isempty(obj.mdlStructureInfo)
                refMdlToMdlBlk=obj.mdlStructureInfo.refMdlToMdlBlk;
            else
                refMdlToMdlBlk=containers.Map('keyType','double',...
                'valueType','double');
            end
        end
    end

    methods(Access=protected)
        applyInlineTransforms(obj,hasMdlRef,sliceXfrmr,replaceModelBlockH,sliceMdl,hdls,origSys,sliceRootSys);
        configureSliceMdlSampleTime(obj,origSys,sliceMdl);
        [origSys,sliceRootSys,deadBlocks,toRemove,allNonVirtH]=createModelFileForSlice(obj,sliceMdl,sliceFileName,toRemove,allNonVirtH,deadBlocksMapped,deadBlocks);
        exportSlice(obj,deadBlocks,allH,inactiveV,groups,sliceMdl,newPath);
        deadBlocks=filterAtomicBlks(obj,sliceMdl,groups,deadBlocks,post);
        handlePortAttributes(obj,checkPortAttributes,fixPortAttributes,sliceMdl,UImode,expandLib,hasGlobal,sliceXfrmr,origAttrMap);
        inlineVariantsTransforms(obj,hasMdlRef,sliceXfrmr,replaceModelBlockH,hdls,origSys,sliceRootSys);
        issueInitValueWarning(obj,slicedMdl,sliceXfrmr,transformedSys);
        removeReplacedButUnusedBlocks(obj,sliceXfrmr);
        removeSLDVPassthroughBlocks(obj,sliceTransformer,sldvHandles);
        modifiedSystems=removeUnusedBlksAndPerformTransforms(obj,groups,handles,origSys,sliceRootSys,post,sliceMdl,sliceXfrmr);
        setSliceMapperForModelHierarchy(obj,origSys,sliceMdl,sliceXfrmr);


        function[checkPortAttributes,fixPortAttributes]=determineCheckAndFixPortAttributes(obj)

            checkPortAttributes=true;
            fixPortAttributes=true;
            if strcmp(get_param(obj.modelH,'DataTypeOverride'),'UseLocalSettings')

                if isfield(obj.options,'Diagnostics')
                    if isfield(obj.options.Diagnostics,'CheckPortAttributes')
                        checkPortAttributes=obj.options.Diagnostics.CheckPortAttributes;
                    end
                    if isfield(obj.options.Diagnostics,'FixPortAttributes')
                        fixPortAttributes=obj.options.Diagnostics.FixPortAttributes;
                    end
                end
            else
                checkPortAttributes=false;
                fixPortAttributes=false;
            end
        end

        function updateWaitBarTotalProgress(obj,checkPortAttributes,fixPortAttributes)
            progressTotal=7...
            +double(checkPortAttributes)...
            +double(fixPortAttributes)...
            +double(obj.options.InlineOptions.Libraries)...
            +double(obj.options.SliceOptions.ExtendSubsystems);

            updateWaitBar(obj,'reset',progressTotal)
            updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:ProcessingUnusedBlocks');
        end

        function sliceFileName=getSliceFileName(obj,sliceMdl,newPath)
            origSys=obj.model;
            mdlpath=which(origSys);
            [~,~,ext]=fileparts(mdlpath);
            if strcmp(ext,'.slx')
                sliceFileName=fullfile(newPath,[sliceMdl,'.slx']);
            elseif strcmp(ext,'.mdl')
                if exist(fullfile(newPath,[sliceMdl,'.slx']),'file')
                    error('ModelSlicer:SLXFileExists',...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:AnSlxFileWith')));
                else
                    sliceFileName=fullfile(newPath,[sliceMdl,'.mdl']);
                end
            else
                error('ModelSlicer:CannotFindModel',getString(message('Sldv:ModelSlicer:ModelSlicer:CannotFindModelFile')));
            end
        end

        function sliceMdlH=setConfigForSlice(obj,sliceMdl,newPath)
            curDir=pwd;
            cd(newPath);
            load_system(sliceMdl);
            obj.simHandler.revertModelProperties(sliceMdl);
            cfgSet=getActiveConfigSet(sliceMdl);
            if isa(cfgSet,'Simulink.ConfigSetRef')
                nonRefCfgSet=sldvshareprivate('mdl_get_configset',sliceMdl);
                copyConfigSet=attachConfigSetCopy(sliceMdl,nonRefCfgSet,true);
                copyConfigSet.Name='Reference Config Set';
                setActiveConfigSet(sliceMdl,copyConfigSet.Name);
            end
            sliceMdlH=get_param(sliceMdl,'Handle');
            cd(curDir);
        end

        function utilExpandTrivialSubsystems(obj,allNonVirtH,origSys,sliceRootSys,modifiedSystems,sliceXfrmr)
            import Transform.*;

            if obj.options.SliceOptions.ExtendSubsystems
                updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:ExpandingTrivialSubsystems');
                nonVirtBlkHs=getCopyHandles(allNonVirtH,obj.refMdlToMdlBlk,origSys,sliceRootSys);
                if obj.isSubsystemSlice

                    sliceSSHinSliceModel=getCopyHandles(obj.sliceSubSystemH,obj.refMdlToMdlBlk,origSys,sliceRootSys);
                    modifiedSystems(modifiedSystems==sliceSSHinSliceModel)=[];
                end
                expandTrivialSubsystems(sliceXfrmr,modifiedSystems,nonVirtBlkHs);
            end
        end

        function updateWaitBar(obj,varargin)
            persistent progressIdx
            persistent progressTotal

            if isempty(progressIdx)
                progressIdx=1;
            end
            if isempty(progressTotal)
                progressTotal=1;
            end

            switch varargin{1}
            case 'reset'
                progressTotal=varargin{2};
                progressIdx=1;
            otherwise
                if~isempty(obj.barH)&&ishandle(obj.barH)
                    waitbar(progressIdx/progressTotal,obj.barH,getString(message(varargin{1})));
                    progressIdx=progressIdx+1;
                end
            end
        end

        function changeReadonlySystemWritable(obj,slicedMdl)


            lumOpt=Transform.AtomicGroup.msLookUnderMasks(obj.options);
            fllOpt=Transform.AtomicGroup.msFollowLinks(obj.options);
            fssrefOpt=Transform.AtomicGroup.msLookInsideSubsystemReference(obj.options);


            sysH=find_system(slicedMdl,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'Permissions','ReadOnly');
            for i=1:length(sysH)
                set_param(sysH(i),'Permissions','ReadWrite')
            end
        end

        function replaceModelBlockH=getModelBlksToInline(obj)
            if obj.isSubsystemSlice
                replaceModelBlockH=utilGetReferencedModelBlocks(obj,obj.sliceSubSystemH);
                replaceModelBlockH=setdiff(replaceModelBlockH,obj.sliceSubSystemH);
            else
                replaceModelBlockH=utilGetReferencedModelBlocks(obj,obj.modelH);
            end
        end

        function post=postAnalyze(obj,activeH,irInactiveH,allH)
            post=[Transform.RedundantMerge];
            post.mdlStructureInfo=obj.mdlStructureInfo;
            for i=1:length(activeH)
                for j=1:length(post)
                    if post(j).applicable(activeH(i))
                        post(j).postAnalyze(activeH(i),...
                        irInactiveH);
                        post(j).filterDeadBlocks(allH);
                    end
                end
            end
        end

    end

    methods(Access=public,Hidden=true)

        function obj=ModelSlicer()
            obj.reset;
        end

        function getAllTransforms(obj)




            if~obj.inSteppingMode
                obj.transforms=[Transform.InactiveIf;...
                Transform.RedundantIf;...
                Transform.InactiveSwitch;...
                Transform.RedundantSwitch;...
                Transform.InactiveMPSwitch;...
                Transform.InactiveEnable;...
                Transform.InactiveTrigger;...
                Transform.InactiveEnableTrigger;...
                Transform.InactiveCase;...
                Transform.InactiveLogicalOperator];
            else

                obj.transforms=[Transform.InactiveIf;...
                Transform.RedundantIf;...
                Transform.InactiveSwitch;...
                Transform.RedundantSwitch;...
                Transform.InactiveMPSwitch;...
                Transform.InactiveEnable;...
                Transform.InactiveTrigger;...
                Transform.InactiveEnableTrigger;...
                Transform.InactiveCase;];
            end

        end


        function reset(obj)
            obj.slicingMode='static';
            obj.modelH=[];
            obj.designInterests=struct('blocks',[],'signals',[]);
            obj.getAllTransforms;
            obj.cvd=[];
            obj.options=SlicerConfiguration.getDefaultOptions;

            obj.dlg=[];
            obj.barH=[];
            obj.inactiveHdls=[];
            obj.initialSdiRuns=Simulink.sdi.getAllRunIDs();
        end


        function compileModel(obj)




            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            try
                obj.modelH=get_param(obj.model,'Handle');
            catch e
                rethrow(e);
            end

            try
                obj.checkCompatibility('CheckType','PreCompile');

                assert(~any(strcmp(get_param(obj.modelH,'SimulationStatus'),{'paused','compiled'})));
                if(~isa(obj.simHandler,'Coverage.SimulationHandler'))
                    s=ModelSlicer.getSimHandlerForSlicer(obj.modelH);
                    s.dlg=obj.dlg;
                    obj.simHandler=s;
                end

                obj.performPreCompileOperations();
                obj.simHandler.initialize;


                if~isempty(obj.dlg)
                    obj.dlg.setWidgetValue('DialogStatusText',...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:AnalyzingDependency')))
                end

                obj.createIR();

                obj.checkCompatibility('CheckType','PostCompile');
            catch ex

                obj.hasError=true;
                if~strcmp(get_param(obj.modelH,'SimulationStatus'),'stopped')
                    if isa(obj.simHandler,'Coverage.SimulationHandler')...
                        &&isvalid(obj.simHandler)
                        obj.simHandler.terminate();
                    end
                    obj.setModelSlicerActive(ModelSlicer.Terminated)
                end
                if~strcmp(ex.identifier,'ModelSlicer:Compatibility:Incompatible')
                    Mex=MException('ModelSlicer:Compatibility:Incompatible',...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:CompatTop',obj.model)));
                    Mex=Mex.addCause(ex);
                else
                    Mex=ex;
                end
                throw(Mex);
            end
            obj.setModelSlicerActive(ModelSlicer.Compiled)
            obj.hasError=false;

            obj.mdlRefCtxMgr=slslicer.internal.MdlRefCtxMgr(obj);
            ModelSlicer.addModelCloseCallback(obj.modelH);
        end

        function configureParams(obj)


            if(~isempty(obj.simHandler)&&...
                isa(obj.simHandler,'Coverage.SimulationHandler'))
                configureDefaultModelParameters(obj.simHandler);
                obj.simHandler.enableCoverageRecording();
            end
        end

        function performPreCompileOperations(obj)







            ModelSlicer.setModelsAndRefsCreatingIR(obj.model,true);
            obj.hideSignalHierarchyViewer;


            obj.removeEditTimeHighlight;
        end

        function removeEditTimeHighlight(obj)

            models=obj.preCompileMdlAndRefs;
            for idx=1:length(models)
                modelName=models{idx};
                if bdIsLoaded(modelName)



                    SLStudio.Utils.RemoveHighlighting(modelName);
                end
            end
        end

        function hideSignalHierarchyViewer(obj)
            signalHierarchyViewerDlgs=findDDGByTag('SigHierViewerDlg');




            for i=1:length(signalHierarchyViewerDlgs)
                sigHierDlg=signalHierarchyViewerDlgs(i);
                dlgSrc=sigHierDlg.getSource;



                if ismember(dlgSrc.getModel,obj.preCompileMdlAndRefs)
                    dlgSrc.delete;
                end
            end
        end

        function compileModelAfterEditableHighlight(obj)
            obj.configureParams;
            obj.compileModel;
        end


        function terminateModel(obj,varargin)



            if obj.compiled
                obj.simHandler.terminate(varargin{:});
                obj.setModelSlicerActive(ModelSlicer.Terminated)
                obj.atomicGroups=[];
                delete(obj.mdlRefCtxMgr);
                obj.mdlRefCtxMgr=[];
                obj.hideSignalHierarchyViewer;
            end
        end

        function clearSimHandler(obj)
            obj.simHandler=[];
        end

        function terminateModelForEditableHighlighting(obj)
            obj.terminateModel();
            obj.simHandler.restoreModelParameters;
            obj.setModelSlicerActive(ModelSlicer.EditableHighlight);
        end

        function terminateModelForTimeWindowSimulation(obj,force)
            if nargin<2
                force=false;
            end
            inFastRestartMode=obj.compiled&&...
            strcmp(get_param(obj.modelH,'FastRestart'),'on')&&...
            obj.simHandler.UsingStepper;
            if~inFastRestartMode||force
                obj.terminateModel(false);



                set_param(obj.modelH,'FastRestart','off');
                obj.setModelSlicerActive(ModelSlicer.TerminatedForTimeWindowSimulation);
            end
        end


        function activeSfElems=getSfElementsInSlice(this,blocks)

            invalid=~license('test','Stateflow');
            simStepping=this.inSteppingMode()&&~this.simHandler.cmdLineSim;
            if invalid||simStepping
                activeSfElems=struct('activeIds',[],'subChartStruct',[]);
                return;
            end

            sfIdx=slprivate('is_stateflow_based_block',blocks);



            sfBlocks=setdiff(blocks(sfIdx),this.inactiveHdls);
            allIDs=[];
            allSubchartStructs=[];
            chartIdToStructIdxMap=containers.Map('keyType','double','valueType','double');

            for i=1:length(sfBlocks)
                refBlk=get_param(sfBlocks(i),'ReferenceBlock');
                if isempty(refBlk)


                    thisBlkObj=get_param(sfBlocks(i),'Object');
                    sourceObj=thisBlkObj;
                    context=[];
                else
                    thisBlkObj=get_param(sfBlocks(i),'Object');
                    sourceObj=get_param(refBlk,'Object');
                    context=getfullname(sfBlocks(i));
                end




                linkchartObj=Stateflow.SLINSF.SubchartMan.getSubchartState(thisBlkObj);
                if~isempty(linkchartObj)&&isa(linkchartObj.getParent,'Stateflow.Object')
                    continue;
                end

                try
                    chart=idToHandle(sfroot,sfprivate('block2chart',sourceObj.Handle));
                catch mex
                    continue;
                end

                if isempty(chart)||~(isa(chart,'Stateflow.Chart')||...
                    isa(chart,'Stateflow.StateTransitionTableChart'))
                    continue;
                end

                yesno=Coverage.wasChartEntered(this.cvd,thisBlkObj,this.refMdlToMdlBlk);

                analysisData=this.getAnalysisData();
                [activeIds,subChartStruct]=Coverage.getActiveSfElems(analysisData,chart,[yesno;true;true],context,yesno);
                if~isempty(context)
                    s=struct('AtomicSubID',thisBlkObj.Handle,'Context',context,'childIDs',activeIds);
                    activeIds=[];
                    subChartStruct=[s,subChartStruct];%#ok<AGROW>
                end

                allIDs=[allIDs;reshape(activeIds,length(activeIds),1)];%#ok<AGROW>
                addAtomicChartIDsToStruct(subChartStruct);
            end
            activeSfElems=struct('activeIds',allIDs,'subChartStruct',allSubchartStructs);

            function addAtomicChartIDsToStruct(chartStructs)





                for j=1:length(chartStructs)
                    id=chartStructs(j).AtomicSubID;
                    if~isKey(chartIdToStructIdxMap,id)
                        if~isempty(allSubchartStructs)
                            allSubchartStructs(end+1)=chartStructs(j);%#ok<AGROW>
                        else
                            allSubchartStructs=chartStructs(j);
                        end
                        chartIdToStructIdxMap(id)=length(allSubchartStructs);
                    else
                        len=length(chartStructs(j).childIDs);
                        structIdx=chartIdToStructIdxMap(id);
                        allSubchartStructs(structIdx).childIDs=unique([allSubchartStructs(structIdx).childIDs,...
                        reshape(chartStructs(j).childIDs,1,len)]);
                    end
                end
            end
        end

        function refMdlH=getReferencedModels(obj)
            if~isempty(obj.refMdlToMdlBlk)
                refMdlH=obj.refMdlToMdlBlk.keys;
            else
                refMdlH={};
            end
        end

        function mdls=getRootModels(obj)
            try
                refH=obj.getReferencedModels();
            catch
                refH=[];
            end
            mdls=obj.modelH;

            if isempty(obj.sliceSubSystemH)
                for i=1:length(refH)
                    try
                        get_param(refH{i},'Name');
                        mdls(end+1)=refH{i};%#ok<AGROW>
                    catch

                    end
                end
            else



                mdls=Transform.AtomicGroup.searchModelBlocks(bdroot(obj.sliceSubSystemH));
            end
        end

        function clearHighlighter(obj)
            obj.removeHighlighting();
        end

        function removeHighlighting(obj,tag)%#ok<INUSD>
            if~isempty(obj.session)
                obj.session.clearAll();
                obj.session=[];
            end
        end

        function configureAnalysisDirection(obj,sc)

            if ismember(lower(sc.direction),{'back','either','forward'})
                obj.dir=lower(sc.direction);
            else
                error('SliceCriterion:FwdNotSupported',...
                getString(message('Sldv:ModelSlicer:gui:ForwardSlicingIsNot')));
            end
        end

        function[hasValidStarts,invalidBlk,invalidSig]=configureAnalysisSeeds(obj,sc)
            [hasValidStarts,invalidBlk,invalidSig]=obj.setAnalysisSeeds(sc);
            obj.constraints=getInactiveFrmConstraint(sc);

            scfg=SlicerConfiguration.getConfiguration(obj.modelH);
            obj.options=scfg.options;
            obj.showCtrlDep=sc.showCtrlDep;
            obj.exc=sc.getExclusionBlks;

            function inactivePorts=getInactiveFrmConstraint(sc)
                inactivePorts=[];
                blkids=sc.getConstraintBlks;
                for i=1:numel(blkids)
                    blkH=slslicer.internal.getBlkHFromID(blkids{i});
                    ph=get(blkH,'PortHandles');
                    constPortStruct=sc.constraints(blkids{i});
                    constPortNums=constPortStruct.PortNumbers;
                    activePorts=ph.Inport(constPortNums);
                    inactivePorts=[inactivePorts,setdiff(ph.Inport,activePorts)];%#ok<AGROW>
                end
            end
        end

        function configureDeadLogicData(obj,sc)
            obj.cvd=[];
            obj.deadLogicData=sc.getDeadLogicData;
        end

        function configureCoverageData(obj,sc)
            obj.cvd=sc.cvd;
        end

        function exportStaticSlice(ms,name,thePath)
            ms.checkOutLicense();

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            if ms.compiled
                ms.checkCompatibility('CheckType','slice');
                if~isempty(ms.barH)&&ishandle(ms.barH)
                    waitbar(0.05,ms.barH,...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:ComputingUnusedBlocks')));
                end
                [deadBlocks,allH,inactiveV]=ms.utilComputeDeadBlocks;
                ms.atomicGroups=Transform.AtomicGroup(ms.model,ms.options);
                ms.exportSlice(deadBlocks,allH,inactiveV,ms.atomicGroups,name,thePath);
            else
                error('ModelSlicer:ModelNotCompiled',...
                getString(message('Sldv:ModelSlicer:ModelSlicer:ModelMustCompiledFirst')));
            end
        end

        function exportDynamicSlice(ms,cvd,name,thePath,sc)

            ms.checkOutLicense();

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>


            if ms.compiled
                ms.checkCompatibility('CheckType','slice');
                ms.cvd=cvd;
                [SimStartTime,SimStopTime]=cvd.getStartStopTime();
                if SimStartTime>0||ms.isSubsystemSlice

                    ms.simulateForExport(SimStartTime,SimStopTime);

                    if ms.mdlRefCtxMgr.hasMultiInstanceRefMdls()
                        if exist('sc','var')&&sc.reloadForStaleCpyRefMdl()
                            ms.cvd.refreshCvData(sc.cvFileName,ms.model);
                        end
                    end
                end

                if~isempty(ms.barH)&&ishandle(ms.barH)
                    waitbar(0.05,ms.barH,...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:ComputingUnusedBlocks')));
                end
                [deadBlocks,allH,inactiveV]=ms.utilComputeDeadBlocks;

                ms.exportSlice(deadBlocks,allH,inactiveV,ms.atomicGroups,name,thePath);
            else
                error('ModelSlicer:ModelNotCompiled',...
                getString(message('Sldv:ModelSlicer:ModelSlicer:ModelMustCompiledFirst')));
            end
        end

        function validateDeadLogicData(this,dlData)
            allH=this.getAllMdls();
            if isa(dlData,'Sldv.DeadLogicData')
                sys=dlData.getAllRefinedSys();
                sysMdlH=unique(cellfun(@(s)bdroot(get_param(s,'handle')),sys));
                if~isempty(intersect(sysMdlH,allH))
                    return;
                end
            end
            Mex=MException('ModelSlicer:IncorrectDeadLogic',...
            getString(message('Sldv:ModelSlicer:ModelSlicer:IncorrectDeadLogic',this.model)));
            modelslicerprivate('MessageHandler','single_error',Mex,this.model,~isempty(this.dlg));
        end
    end

    methods
        function out=get.model(obj)

            if~isempty(obj.modelH)
                out=get_param(obj.modelH,'Name');
            else
                out='';
            end
        end
        function set.model(obj,mdl)
            if~isempty(mdl)
                assert(ischar(mdl));
                try
                    obj.modelH=get_param(mdl,'Handle');
                catch e

                    if strcmp(e.identifier,...
                        'Simulink:Commands:InvSimulinkObjectName')
                        throw(e);
                    else
                        rethrow(e);
                    end
                end
            else
                obj.modelH=[];
            end
        end
        function out=get.isSubsystemSlice(obj)
            out=~isempty(obj.sliceSubSystemH);
        end
        function yesno=get.isHarness(obj)
            yesno=~isempty(get_param(obj.modelH,'HarnessUUID'));
        end
        function yesno=get.compiled(obj)
            yesno=slslicer.internal.checkDesiredSimulationStatus(obj.modelH,'isSimStatusPausedOrCompiledOrRunning');
        end

        function set.collectCoverageDuringSimulation(obj,val)
            assert(~obj.inSteppingMode());
            obj.collectCoverageDuringSimulation=val;
            obj.simHandlerCovCollectionEnable(val);
        end
    end


    methods(Access=public,Hidden=true)

        function checkOutLicense(obj)%#ok<MANU>

            invalid=builtin('_license_checkout',...
            'SL_Verification_Validation','quiet');
            if invalid
                error('ModelSlicer:NotLicensed',getString(message(...
                'Sldv:ModelSlicer:ModelSlicer:NotLicensed')));
            end
        end

        function yesno=hasValidCoverageData(obj)
            yesno=true;
            if obj.compiled&&~isempty(obj.cvd)
                mdlHs=Analysis.filterModelBlocksUnderNoReadWrite(obj.refMdlToMdlBlk,obj.getRootModels);
                yesno=obj.cvd.hasValidCoverageData(mdlHs);
            end
        end

        function[yesno,startTime]=isSimStateSlice(obj)
            startTime=0;
            if~isempty(obj.cvd)
                startTime=obj.cvd.getStartStopTime(obj);
                startTime=Coverage.SimulationHandler.getAdjustedStartTime(startTime,obj.cvd);
            end
            yesno=startTime>0;
        end

        function startTime=getStartTimeForSlice(obj)
            [~,startTime]=isSimStateSlice(obj);
        end
        function setModelSlicerActive(obj,value)


            mdlHs=obj.getRootModels;
            for n=1:length(mdlHs)
                set_param(mdlHs(n),'ModelSlicerActive',value);
            end
        end

        function setPreCompileMdlAndRefs(obj)
            obj.preCompileMdlAndRefs=...
            slslicer.internal.getAllModels(obj.modelH);
        end


        function[sldvData,status,IncompatibilityMessages]=refineForDeadLogic(obj,sysH,analysisTime)
            obj.checkOutLicense();
            wasCompiled=obj.compiled;
            if wasCompiled
                obj.terminateModel();
            end
            [sldvData,status,IncompatibilityMessages]=...
            Sldv.DeadLogicData.generateDeadLogicResults(sysH,analysisTime,~isempty(obj.dlg));
            if wasCompiled
                obj.compileModel;
            end
        end


        function sdiInstance=getSdiInstance(obj)
            if isempty(obj.sdiInstance)
                obj.launchSdi();
            end
            sdiInstance=obj.sdiInstance;
        end

        function refreshSdiView(obj)



            if isThisUsingSdi(obj)

                sc=getActiveSC(obj);
                sdiInst=obj.sdiInstance;
                if~isempty(sc.sdiViewObj)&&sc.sdiViewObj.isEnabled
                    viewObj=sc.sdiViewObj;
                    allRuns=Simulink.sdi.getAllRunIDs;
                    if isempty(viewObj.runID)||~all(ismember(viewObj.runID,allRuns))
                        progIndicator=Sldv.Utils.ScopedProgressIndicator('Sldv:ModelSlicer:gui:RefreshingSdiProgress');
                        obj.clearSdi();
                        viewObj.plotSimData();
                        delete(progIndicator);
                    else
                        obj.clearSdi(viewObj.runID);
                        viewObj.renameSlicerRun();
                    end



                    sdiInst.showDataCursors()
                    pos=viewObj.cursorPositions;
                    if~isempty(pos)&&any(pos)
                        sdiInst.setDataCursorPositions(pos);
                    end


                    intervals=viewObj.constraintIntervals;
                    if~isempty(intervals)
                        sdiInst.highlightIntervals(intervals);
                    end


                    sdiInst.enableController(true);
                    sdiInst.enableButton(false);
                end
            end
        end

        function enableSdiSlicerController(obj,val)
            if~isempty(obj.sdiInstance)
                obj.sdiInstance.enableController(val);
            end
        end

        function[success,currentUserH]=launchSdi(obj)



            obj.saveAndCloseRegularSdi();



            if~ModelSlicer.isSlicerSdiOpen()
                progIndicator=Sldv.Utils.ScopedProgressIndicator('Sldv:ModelSlicer:gui:LaunchingSdiProgress');

                Simulink.sdi.slicer(1);
                Simulink.sdi.view;
                sdiInst=Simulink.sdi.internal.controllers.Slicer.getController();

                waitfor(sdiInst,'ClientID');

                [success,currentUserH]=sdiInst.registerSlicerObj(obj);
                if~success
                    return;
                end


                sdiInst.showDataCursors();
                obj.sdiInstance=sdiInst;

                delete(progIndicator);
                obj.refreshSdiView();
            else

                [success,currentUserH]=isThisUsingSdi(obj);
            end

        end

        function saveAndCloseRegularSdi(obj)




            allRuns=Simulink.sdi.getAllRunIDs();
            if~Simulink.sdi.slicer&&...
                ~obj.savedRegularSdiSession&&...
                ~isempty(allRuns)&&...
                ~isempty(obj.initialSdiRuns)

                sessionFile='';
                if isfield(obj.options.AnalysisOptions,'PromptSdiSave')&&...
                    obj.options.AnalysisOptions.PromptSdiSave

                    qStr=getString(message('Sldv:ModelSlicer:gui:SaveSdiSessionQuestStr'));
                    qTitle=getString(message('Sldv:ModelSlicer:gui:SaveSdiSessionTitle'));

                    yesStr=getString(message('MATLAB:finishdlg:Yes'));
                    noStr=getString(message('MATLAB:finishdlg:No'));
                    answer=questdlg(qStr,qTitle,yesStr,noStr,yesStr);
                    if strcmp(answer,yesStr)
                        [filename,pathname,~]=uiputfile('*.mldatx',...
                        getString(message('Sldv:ModelSlicer:gui:SaveSdiFileName')));

                        if~isequal(filename,0)
                            sessionFile=fullfile(pathname,filename);
                        end
                    end
                else
                    fname=strrep(['sdi_session_',datestr(now,'HH_MM_PM'),'.mldatx'],' ','_');
                    sessionFile=fullfile(pwd,fname);
                end
                if~isempty(sessionFile)
                    Simulink.sdi.save(sessionFile);
                    mInfo=getString(message('Sldv:ModelSlicer:gui:SavedSdiSessionName',sessionFile));
                    modelslicerprivate('MessageHandler','open',obj.model);
                    modelslicerprivate('MessageHandler','info',mInfo);
                end
                obj.savedRegularSdiSession=true;
            end
            if~Simulink.sdi.slicer&&Simulink.sdi.Instance.isSDIRunning()
                Simulink.sdi.close();
            end
        end

        function[yesno,currentUserH]=isThisUsingSdi(obj)
            try
                sdiInst=Simulink.sdi.internal.controllers.Slicer.getController();
            catch
                yesno=false;
                currentUserH=[];
                return;
            end
            yesno=sdiInst.isThisSlicerRegistered(obj);
            currentUserH=sdiInst.getCurrentUser();
        end

        function releaseSdi(obj,close)
            if isThisUsingSdi(obj)
                sdiInst=obj.sdiInstance;
                obj.clearSdi();

                if~isempty(sdiInst)
                    sdiInst.deRegisterSlicerObj(obj);
                    obj.sdiInstance=[];
                end

                if~(exist('close','var')&&close==false)
                    Simulink.sdi.close();
                end


                Simulink.sdi.slicer(0);
            end
        end

        function closeSdiCallback(obj)
            sc=obj.getActiveSC();
            if~isempty(sc.sdiViewObj)
                sc.sdiViewObj.saveSessionToTempFile();
            end
            obj.releaseSdi(false);


            if~isempty(obj.dlg)
                obj.dlg.refresh;
            end
        end

        function clearSdi(obj,retainID)
            if inSteppingMode(obj)

                return;
            end
            if nargin<2
                retainID=[];
            end
            sdiInst=obj.sdiInstance;
            if~isempty(sdiInst)&&...
                sdiInst.isThisSlicerRegistered(obj)
                if isempty(retainID)
                    Simulink.sdi.clear();
                else
                    allRuns=Simulink.sdi.getAllRunIDs();
                    allRuns=setdiff(allRuns,retainID);
                    if~isempty(allRuns)
                        arrayfun(@(r)Simulink.sdi.deleteRun(r),allRuns);
                    end
                end
                sdiInst.hideDataCursors();
                sdiInst.sliceAreaOff();
            end
        end

        function applySdiTimeWindow(obj,tw)



            obj.enableSdiSlicerController(false);

            startTime=tw(1);
            stopTime=tw(2);

            cfg=SlicerConfiguration.getConfiguration(obj.modelH);
            selectedIdx=cfg.selectedIdx;
            sc=cfg.sliceCriteria(selectedIdx);


            assert(sc.sdiViewObj.isEnabled);

            [currStartTime,currStopTime]=sc.cvd.getStartStopTime();

            valid=sc.cvd.setStartStopTime(startTime,stopTime);
            if valid
                sc.dirty=true;
                sc.refresh();
            else
                sc.cvd.setStartStopTime(currStartTime,currStopTime);
                obj.sdiInstance.setDataCursorPositions([currStartTime,currStopTime]);
                msg=getString(message('Sldv:ModelSlicer:gui:InvalidTimeWindow'));
                if~isempty(obj.dlg)
                    obj.dlg.setWidgetValue('DialogStatusText',msg);
                else
                    error('ModelSlicer:API:EmptyInterval',msg);
                end
            end
            obj.enableSdiSlicerController(true);
        end

        function refreshDynamicSlice(obj)







            if~isempty(obj.dlg)&&~isa(obj.dlg,'DAStudio.Dialog')
                return;
            end

            if isempty(obj.simHandler)...
                ||obj.simHandler.initializing...
                ||obj.simHandler.cmdLineSim...
                ||obj.simHandler.finishedSim...
                ||~obj.collectCoverageDuringSimulation
                return;
            end

            sc=getActiveSC(obj);
            obj.updateCoverageForTimeStep(sc);
            sc.useCvd=true;
            sc.dirty=true;
            sc.refresh();
        end

        function notifyHighlightRefresh(obj)
            notify(obj,'eventModelSlicerSimStepHighlighted');
        end

        function refreshDynamicSliceForStepFromExistingData(obj)
            assert(~obj.collectCoverageDuringSimulation);

            if isempty(obj.simHandler)...
                ||obj.simHandler.initializing
                return;
            end

            sc=getActiveSC(obj);

            if ifSpuriousMdlTimeForStepBack()
                return;
            end

            if~isempty(sc.cvd)&&get_param(obj.modelH,'TimeOfMajorStep')>sc.cvd.streamStopTime
                Mex=MException('Sldv:ModelSlicer:Coverage:NotCoveredInCoverageData',...
                getString(message('Sldv:ModelSlicer:Coverage:NotCoveredInCoverageData',...
                num2str(get_param(obj.modelH,'TimeOfMajorStep')),...
                sc.cvd.streamStartTime,sc.cvd.streamStopTime)));
                modelslicerprivate('MessageHandler','open',obj.model);
                modelslicerprivate('MessageHandler','warning',Mex,obj.model);
            end
            obj.setTimeStepForHighlight(sc);
            sc.useCvd=true;
            sc.dirty=true;
            sc.refresh();

            function yesno=ifSpuriousMdlTimeForStepBack()





                yesno=false;
                if obj.inSteppingMode&&obj.simHandler.steppingBack&&...
                    ~isempty(sc.cvd)
                    tstart=get_param(obj.modelH,'TimeOfMajorStep');
                    prevTstart=sc.cvd.getStartStopTime();
                    if(tstart<prevTstart)
                        idxCurr=sc.cvd.binarySearch(sc.cvd.tout,tstart);
                        idxPrev=sc.cvd.binarySearch(sc.cvd.tout,prevTstart);
                        yesno=(idxPrev-idxCurr)~=1;
                    end
                end
            end
        end

        function yesno=inSteppingMode(this)
            yesno=~isempty(this.model)...
            &&strcmpi(get_param(this.model,'SimulationStatus'),'paused')&&...
            strcmp(get_param(this.model,'FastRestart'),'on');
        end

        function sc=getActiveSC(obj)
            cfg=SlicerConfiguration.getConfiguration(obj.modelH);

            selectedIdx=cfg.selectedIdx;
            sc=cfg.sliceCriteria(selectedIdx);
        end

        function allMdls=getAllMdls(obj)
            refMdls=cell2mat(obj.getReferencedModels());
            allMdls=[obj.modelH,refMdls];
        end

        function addSliceRefreshCallbacks(obj)
            obj.simHandler.addSimulationPauseCallBack(...
            @(~,~)obj.refreshDynamicSliceForStepFromExistingData);
            obj.simHandler.addSimulationStopCallBack(...
            @(~,~)obj.refreshDynamicSliceForStepFromExistingData);
        end

        function removeSliceRefreshCallbacks(obj)
            obj.simHandler.removeSimulationPauseCallBack();
            obj.simHandler.removeSimulationStopCallBack();
        end

        function resetDependencies(obj)
            obj.inactiveHdls=[];
        end
    end

    methods(Access=protected)
        function simulateForExport(obj,SimStartTime,SimStopTime)
















            subsystemIO=[];
            globalData=[];
            origFastRestart=get_param(obj.modelH,'FastRestart');
            if~isempty(obj.sliceSubSystemH)&&~Simulink.SubsystemType.isModelBlock(obj.sliceSubSystemH)
                try
                    Sldv.SubsystemLogger.checkUnsupportedSystem(obj.sliceSubSystemH,~obj.compiled);
                catch ex
                    Mex=MException('ModelSlicer:SubsystemSlicing:UnspportedDynamicSlice',...
                    getString(message('Sldv:ModelSlicer:Transform:UnsupportedDynamicSSSlice')));
                    Mex=Mex.addCause(ex);
                    throw(Mex);
                end
            end
            if obj.compiled
                if~isempty(obj.sliceSubSystemH)
                    if~Simulink.SubsystemType.isModelBlock(obj.sliceSubSystemH)
                        subsystemIO=Sldv.SubsystemLogger.deriveSubsystemPortInfo(obj.sliceSubSystemH);
                    else
                        globalData=Sldv.ModelblockLogger.deriveDSWExecPriorToMdlBlk(...
                        obj.sliceSubSystemH,obj.modelH,...
                        obj.refMdlToMdlBlk,...
                        obj.getGlobalDsmNames());
                        obj.globalDsmData=globalData;
                    end
                end


                obj.terminateModelForTimeWindowSimulation(~isempty(obj.sliceSubSystemH));
            end

            obj.simDataLog=[];
            try
                if SimStartTime>0



                    adjustedSimStartTime=Coverage.SimulationHandler.getAdjustedStartTime(SimStartTime,obj.cvd);
                else
                    adjustedSimStartTime=SimStartTime;
                end
                if~isempty(obj.sliceSubSystemH)
                    if~Simulink.SubsystemType.isModelBlock(obj.sliceSubSystemH)
                        loggerObj=Sldv.SubsystemLogger('slicerlogsignals');
                        loggerObj.intervalStartTime=adjustedSimStartTime;
                        loggerObj.intervalStopTime=SimStopTime;
                        loggerObj.recordCoverage=false;
                        data=loggerObj.logInputSignals(obj.sliceSubSystemH,subsystemIO,obj.modelH);
                    else
                        loggerObj=Sldv.ModelblockLogger('slicerlogsignals');
                        loggerObj.intervalStartTime=adjustedSimStartTime;
                        loggerObj.intervalStopTime=SimStopTime;
                        loggerObj.globalDsmData=globalData;
                        loggerObj.setSlicerContextInfo(obj.refMdlToMdlBlk,...
                        obj.getGlobalDsmNames());
                        loggerObj.recordCoverage=false;
                        data=loggerObj.logInputSignals(obj.sliceSubSystemH,obj.modelH);
                    end
                    obj.simDataLog=data;
                    obj.SimState=loggerObj.SimState;
                    set_param(obj.modelH,'FastRestart',origFastRestart);
                else
                    obj.SimState=...
                    obj.simHandler.runSimAndGetSimStateWithoutCov(adjustedSimStartTime,SimStartTime);




                end
            catch Mex
                if~obj.compiled
                    obj.compileModel;
                end
                rethrow(Mex);
            end
            if~obj.compiled
                obj.compileModel;
            end
        end

        function analysisData=getAnalysisData(obj)
            if~isempty(obj.cvd)
                analysisData=obj.cvd;
            else
                analysisData=obj.deadLogicData;
            end
        end

        function updateCoverageForTimeStep(obj,sc)
            if~obj.simHandler.enhCovAvailable
                covdata=obj.simHandler.getStepCov();
                if~isempty(covdata)
                    sc.cvd=covdata;
                else
                    return;
                end
            else
                obj.simHandler.getSimCovDataFromWorkspace();
                covdata=obj.simHandler.processStreamingData();
                sc.cvd=covdata;
                if~isempty(obj.dlg)
                    scfg=SlicerConfiguration.getConfiguration(obj.modelH);
                    Coverage.saveCoverage(scfg);
                end
            end
        end

        function setTimeStepForHighlight(obj,sc)
            if~isempty(sc.cvd)
                if obj.inSteppingMode
                    tstart=get_param(obj.modelH,'TimeOfMajorStep');
                    tstop=tstart;
                else
                    tstart=sc.cvd.streamStartTime;
                    tstop=sc.cvd.streamStopTime;
                end
                sc.cvd.setStartStopTime(tstart,tstop);
            end
        end

        function simHandlerCovCollectionEnable(obj,val)
            if~isempty(obj.simHandler)
                if~val
                    obj.simHandler.collectCoverageFromSim=false;
                    obj.addSliceRefreshCallbacks();
                else
                    obj.removeSliceRefreshCallbacks();
                    obj.simHandler.collectCoverageFromSim=true;
                end
            end
        end
    end


    methods(Static=true,Access=public,Hidden=true)
        function addParamsForSliceMapping(sliceMdl,origSys)
            try
                add_param(sliceMdl,'SlicerOriginalModel',bdroot(origSys));
                add_param(sliceMdl,'SlicerOriginalModelFile',get_param(bdroot(origSys),'FileName'));
            catch Mex
                if strcmp(Mex.identifier,'Simulink:Commands:ParamExists')
                    set_param(sliceMdl,'SlicerOriginalModel',bdroot(origSys));
                    set_param(sliceMdl,'SlicerOriginalModelFile',get_param(bdroot(origSys),'FileName'));
                else
                    rethrow(Mex)
                end
            end
        end

        function out=getRedundantMergeBlks(post)
            out=[];
            for idx=numel(post)
                if isa(post,'Transform.RedundantMerge')
                    if~isempty(post(idx).redundant)
                        out=[post(idx).redundant.handle];
                    end
                end
            end
        end

        function notifyModelInlined(data,mdlRefPath,newSubsysH,refModelName,...
            refMdlIsInlinedWithNewSubsys)
            slMap=data{1};
            referenceMdlToMdlBlk=data{2};
            mdlRefBlkH=referenceMdlToMdlBlk(get_param(refModelName,'Handle'));
            [yesno,blkH]=Analysis.isRootOfMdlref(referenceMdlToMdlBlk,mdlRefBlkH);
            if yesno
                mdlRefBlkH=blkH;
            end
            if~isempty(slMap)
                slMap.inlineMdlRefBlk(mdlRefPath,newSubsysH,refModelName,...
                mdlRefBlkH,refMdlIsInlinedWithNewSubsys);
            end
        end

        function yesno=isSynthesized(bh)
            obj=get(bh,'Object');
            yesno=obj.isSynthesized;
        end

        function modelNameChangeCallback(modelH,modelName,UImode)


            newName=get_param(modelH,'Name');
            if~strcmp(newName,modelName)

                warnState=warning('off','Simulink:Engine:MdlFileShadowing');

                Mex=MException('ModelSlicer:ChangeNameWhileActive',...
                getString(message('Sldv:ModelSlicer:ModelSlicer:ChangeNameWhileActive')));
                modelslicerprivate('MessageHandler','single_warning',Mex,modelName,UImode);

                set_param(modelH,'Name',modelName);

                warning(warnState.state,'Simulink:Engine:MdlFileShadowing');
            end
        end

        function setModelsCreatingIR(models,value)

            mode=ModelSlicer.Terminated;
            if value>0
                mode=ModelSlicer.CreatingIR;
            end
            for n=1:length(models)
                set_param(cell2mat(models(n)),'ModelSlicerActive',mode);
            end
        end

        function setModelsAndRefsCreatingIR(model,value)




            mdlAndRefs=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',true,'KeepModelsLoaded',true);
            ModelSlicer.setModelsCreatingIR(mdlAndRefs,value);
        end

        function addModelCloseCallback(modelH)















            bdObj=get_param(modelH,'Object');
            if~bdObj.hasCallback('PreClose','SlicerModelCloseCallback')
                Simulink.addBlockDiagramCallback(modelH,'PreClose','SlicerModelCloseCallback',...
                @()ModelSlicer.modelCloseCallback(modelH));
            end
        end

        function removeModelCloseCallback(modelH)



            bdObj=get_param(modelH,'Object');
            if bdObj.hasCallback('PreClose','SlicerModelCloseCallback')

                Simulink.removeBlockDiagramCallback(modelH,'PreClose','SlicerModelCloseCallback');
            end
        end

        function modelCloseCallback(modelH)







            persistent slicer_license_exists;

            if isempty(slicer_license_exists)
                slicer_license_exists=SliceUtils.isSlicerAvailable();
            end
            if slicer_license_exists

                uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
                if ishandle(uiObj)
                    topModelH=uiObj.getSource.Model.modelH;
                    if topModelH==modelH
                        uiObj.delete;
                    end
                end

                try
                    if isActiveSliceModel(modelH)
                        origMdlName=get_param(modelH,'SlicerOriginalModel');
                        try
                            mdlH=get_param(origMdlName,'Handle');
                            sliceMapper=modelslicerprivate('sliceActiveModelMapper','get',mdlH);
                            if~isempty(sliceMapper)
                                sliceMdlName=get_param(modelH,'Name');
                                if strcmp(sliceMdlName,sliceMapper.sliceMdlName)

                                    allRefModels=keys(sliceMapper.refMdlInfo);
                                    refMdlCnt=numel(allRefModels);
                                    allModels=zeros(1,refMdlCnt+1);
                                    allModels(1)=mdlH;
                                    for idx=1:refMdlCnt
                                        try
                                            allModels(idx+1)=get_param(allRefModels{idx},'Handle');
                                        catch Mex3 %#ok<NASGU>
                                        end
                                    end
                                    modelslicerprivate('sliceActiveModelMapper','set',allModels,[]);
                                end
                            end
                        catch Mex2 %#ok<NASGU>
                        end
                    end
                catch Mex1 %#ok<NASGU>
                end
            end
            ModelSlicer.removeModelCloseCallback(modelH);
        end

        function yesno=isSlicerSdiOpen()
            yesno=Simulink.sdi.slicer&&...
            Simulink.sdi.Instance.isSDIRunning();
        end

        function simHandler=getSimHandlerForSlicer(modelH,isSliceMdl)
            simHandler=[];
            if nargin<2
                isSliceMdl=false;
            end
            if SliceUtils.isSlicerAvailable
                simHandler=Coverage.SimulationHandler(modelH);
                simHandler.isOrigModel=~isSliceMdl;
                if~isSliceMdl
                    simHandler.enableCoverageRecording();
                end
            end
        end
    end
end

function yesno=isActiveSliceModel(modelH)
    addedParams=strsplit(get_param(modelH,'UserBdParams'),';');
    yesno=ismember('SlicerOriginalModel',addedParams);
end
