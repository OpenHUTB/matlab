


classdef ModelSlicer<ModelSlicer


    properties(Access=public,Hidden=true)

        userVirtStartToActSrc=[];



        virtualStarts=[];


        ir=[]
    end

    methods(Access=public,Hidden=true)


        function createIR(obj)
            [obj.ir,obj.mdlStructureInfo]=Analysis.createIR(obj.model);
        end






        function[signalPaths,blocks]=staticDependence(this,varargin)

            this.checkOutLicense();

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>


            if nargin<2
                dir='back';
            else
                dir=varargin{1};
            end

            if nargin<3
                additionalInactiveHandles=[];
            else
                additionalInactiveHandles=varargin{2};
            end

            this.inactiveHdls=additionalInactiveHandles;

            if this.compiled
                this.checkCompatibility('CheckType','Highlight');
                dfgIds=this.getDesignInterestsDfgIds;
                c=this.getNonRootContexts;

                this.atomicGroups=Transform.AtomicGroup(this.model,this.options);

                additionV=[];
                for idx=1:numel(additionalInactiveHandles)
                    if strcmp(get(additionalInactiveHandles(idx),'type'),'block')
                        additionV=[additionV;this.getDfgIdForBlock(...
                        additionalInactiveHandles(idx))];%#ok<AGROW>
                    else
                        additionV=[additionV;this.getSigDfgIds(...
                        additionalInactiveHandles(idx))];%#ok<AGROW>
                    end
                end

                try
                    dfgConstraintInportIds=...
                    this.ir.dfgInportHToInputIdx.values(num2cell(...
                    this.constraints));
                    dfgConstraintInportIds=cell2mat(dfgConstraintInportIds);
                    dfgConstraintInportIds=reshape(dfgConstraintInportIds,...
                    numel(dfgConstraintInportIds),1);
                catch
                    dfgConstraintInportIds=[];
                end

                subsystemBoundaryIds=[];
                subsystemEdgeIds=[];
                if~isempty(this.sliceSubSystemH)
                    [subsystemBoundaryIds,subsystemEdgeIds,unconstraintBlkMap]...
                    =Transform.SubsystemSliceUtils.getSubsystemBoundaryIds(...
                    this.sliceSubSystemH,this.ir,dir);
                end

                if~isempty(this.dlg)
                    this.dlg.setWidgetValue('DialogStatusText',...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:ComputingDependency')))
                end

                if slavteng('feature','DeadlogicForSlice')&&~isempty(this.deadLogicData)
                    this.atomicGroups=Transform.AtomicGroup(this.model,this.options);
                    [inactiveV,~,contexts,inactiveH]=this.identifyInactiveElements(this.atomicGroups);
                else
                    inactiveV=[];
                    contexts=c;
                    inactiveH=[];
                end
                this.inactiveHdls=[reshape(inactiveH,1,length(inactiveH))...
                ,reshape(additionalInactiveHandles,1,length(additionalInactiveHandles))];
                [signalPaths,blocks]=this.computeDependence(dir,...
                dfgIds,[inactiveV;additionV;subsystemBoundaryIds;dfgConstraintInportIds],subsystemEdgeIds,contexts);
                [signalPaths,blocks]=this.fixHighlightForConstraintSubsystem(...
                signalPaths,blocks,additionalInactiveHandles,dir);
                if~isempty(this.sliceSubSystemH)&&~unconstraintBlkMap.isempty
                    this.issueWarningForUnconstraintBlockForSubystemSlice(blocks,unconstraintBlkMap);
                end
            else
                error('ModelSlicer:ModelNotCompiled',...
                getString(message('Sldv:ModelSlicer:ModelSlicer:ModelMustCompiledFirst')));
            end
        end

        function[signalPaths,blocks]=dynamicDependence(this,cvd,varargin)

            this.checkOutLicense();

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

            if nargin<3
                dir='back';
            else
                dir=varargin{1};
            end


            if nargin<4
                additionalInactiveHandles=[];
            else
                additionalInactiveHandles=varargin{2};
            end

            if this.compiled
                this.checkCompatibility('CheckType','Highlight');
                this.cvd=cvd;
                dfgIds=this.getDesignInterestsDfgIds;

                additionV=[];
                for idx=1:numel(additionalInactiveHandles)
                    if strcmp(get(additionalInactiveHandles(idx),'type'),'block')
                        additionV=[additionV;this.getDfgIdForBlock(...
                        additionalInactiveHandles(idx))];%#ok<AGROW>
                    else
                        additionV=[additionV;this.getSigDfgIds(...
                        additionalInactiveHandles(idx))];%#ok<AGROW>
                    end
                end

                subsystemBoundaryIds=[];
                subsystemEdgeIds=[];
                if~isempty(this.sliceSubSystemH)
                    [subsystemBoundaryIds,subsystemEdgeIds,unconstraintBlkMap]...
                    =Transform.SubsystemSliceUtils.getSubsystemBoundaryIds(...
                    this.sliceSubSystemH,this.ir,dir);
                end

                try
                    dfgConstraintInportIds=...
                    this.ir.dfgInportHToInputIdx.values(num2cell(...
                    this.constraints));
                    dfgConstraintInportIds=cell2mat(dfgConstraintInportIds);
                    dfgConstraintInportIds=reshape(dfgConstraintInportIds,...
                    numel(dfgConstraintInportIds),1);
                catch
                    dfgConstraintInportIds=[];
                end

                if~isempty(this.dlg)
                    this.dlg.setWidgetValue('DialogStatusText',...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:ComputingDependency')))
                end
                this.atomicGroups=Transform.AtomicGroup(this.model,this.options);
                [inactiveV,~,contexts,inactiveH]=this.identifyInactiveElements(this.atomicGroups);

                this.inactiveHdls=[reshape(inactiveH,1,length(inactiveH))...
                ,reshape(additionalInactiveHandles,1,length(additionalInactiveHandles))];
                [signalPaths,blocks]=this.computeDependence(dir,...
                dfgIds,[inactiveV;additionV;subsystemBoundaryIds;dfgConstraintInportIds]...
                ,subsystemEdgeIds,contexts);
                [signalPaths,blocks]=this.fixHighlightForConstraintSubsystem(...
                signalPaths,blocks,additionalInactiveHandles,dir);
                if~isempty(this.sliceSubSystemH)&&~unconstraintBlkMap.isempty
                    this.issueWarningForUnconstraintBlockForSubystemSlice(blocks,unconstraintBlkMap);
                end
            else
                error('ModelSlicer:ModelNotCompiled',...
                getString(message('Sldv:ModelSlicer:ModelSlicer:ModelMustCompiledFirst')));
            end
        end

        function[hasValidStarts,invalidBlk,invalidSig]=setAnalysisSeeds(obj,sc)
            [bh,~]=sc.getStartBlockHandles;
            ph=sc.getStartSignalHandles;
            obj.designInterests=struct('blocks',bh,...
            'signals',ph);
            obj.userVirtStartToActSrc=sc.seedHandler.getVirtualToDFGMap(sc);


            obj.virtualStarts=sc.getVirtualStarts;
            obj.sliceSubSystemH=sc.sliceSubSystemH;
            [dfgIds,invalidBlk,invalidSig]=obj.getDesignInterestsDfgIds;
            hasValidStarts=~isempty(dfgIds);
        end

        function[s,b]=analyse(obj)
            if~isempty(obj.cvd)
                [s,b]=obj.dynamicDependence(obj.cvd,obj.dir,obj.exc);
            else
                [s,b]=obj.staticDependence(obj.dir,obj.exc);
            end
            if~isempty(obj.sliceSubSystemH)
                [b,s]=...
                Transform.SubsystemSliceUtils.filterHighlightPath(obj.sliceSubSystemH,b,s,obj.dir,obj.ir);
            end
        end

        status=checkCompatibility(obj,varargin);
    end


    methods(Access=public,Hidden=true)
        [inactiveV,inactiveE,activeC,inactiveHdls]=identifyInactiveElements(obj,groups)




        [dfgIds,invalidBlk,invalidSig]=getDesignInterestsDfgIds(obj)


        dfgId=getDfgIdForBlock(this,blockH)


        dfgId=getSigDfgIds(obj,portH)


        [signalPaths,blocks]=computeDependence(obj,mode,dfgIds,...
        inactiveV,inactiveE,activeC)


        [blocks,allH]=computeDeadBlocks(obj,mode,dfgIds,...
        inactiveV,inactiveE,activeC)



        function c=getNonRootContexts(obj)
            c=obj.ir.getNonRootContexts;
        end

        function[srcDfgId,dstDfgId]=getControlDependence(obj,activeC)
            [srcDfgId,dstDfgId]=obj.ir.getControlDependence(activeC);
        end

        function desH=getSystemAllDescendants(obj)
            desH=[];
            if isempty(obj.sliceSubSystemH)
                return;
            end
            if~isKey(obj.ir.handleToDfgIdx,obj.sliceSubSystemH)&&...
                isKey(obj.ir.origBlkHToSynBlkHMap,obj.sliceSubSystemH)


                subSystemH=obj.ir.origBlkHToSynBlkHMap(obj.sliceSubSystemH);
            else
                subSystemH=obj.sliceSubSystemH;
            end

            if~obj.ir.handleToDfgIdx.isKey(subSystemH)

                return;
            end
            targetSysId=obj.ir.handleToTreeIdx(subSystemH);
            targetSysTreeNode=MSUtils.treeNodes(targetSysId);
            desc=obj.ir.tree.nonleafDescendants(targetSysTreeNode);
            sysId={desc.Id};
            for k=1:length(sysId)
                sysTreeNode=MSUtils.treeNodes(sysId{k});
                descendants=obj.ir.tree.children(sysTreeNode);

                desIds={descendants.Id};
                desH=[desH,cell2mat(obj.ir.treeIdxToHandle.values(desIds))];%#ok<AGROW>
            end
        end

        function ancestors=utilGetAncestors(obj,bh)
            ancestors=obj.ir.getAncestoresInTree(bh);
        end

        function childComponents=utilGetAllChildComponents(obj)
            root=obj.ir.tree.getRoot;
            nonleafNodes=obj.ir.tree.nonleafDescendants(root);
            childComponents=arrayfun(...
            @(n)obj.ir.treeIdxToHandle(n.Id),nonleafNodes);
        end

        function ancestors=utilGetVirtualBlkAncestors(obj)
            allvinportseeds=setdiff(obj.virtualStarts,obj.designInterests.blocks);
            ancestors=slslicer.internal.getParentBlks(allvinportseeds,obj.refMdlToMdlBlk);
        end

        function yesno=shouldRetainMdlBlockOutport(obj,blkH,~)
            yesno=ismember(blkH,obj.virtualStarts);
        end

        function dsmNames=getGlobalDsmNames(obj)
            dsmNames=obj.ir.globalDsmNameToDfgIdx.keys;
        end

        function dsmHandles=getLocalDsms(obj)
            dsmHandles=cell2mat(obj.ir.dsmToDfgVarIdx.keys);
        end

        [sig,block]=fixHighlightForConstraintSubsystem(this,sig,block,excl,dir)
    end

    methods(Access=protected)
        removeBusExpandedBlocks(~,sliceXfrmr,synthDeadBlockH);

        function[deadBlocks,allH,inactiveV]=utilComputeDeadBlocks(obj)
            dfgIds=obj.getDesignInterestsDfgIds;
            c=obj.getNonRootContexts;

            if~isempty(obj.cvd)||(slavteng('feature','DeadlogicForSlice')&&~isempty(obj.deadLogicData))
                obj.atomicGroups=Transform.AtomicGroup(obj.model,obj.options);
                [inactiveV,~,contexts,inactiveH]=obj.identifyInactiveElements(obj.atomicGroups);
            else
                inactiveV=[];
                contexts=c;
                inactiveH=[];
            end

            obj.inactiveHdls=inactiveH;

            subsystemBoundaryIds=[];
            subsystemEdgeIds=[];
            if~isempty(obj.sliceSubSystemH)
                [subsystemBoundaryIds,subsystemEdgeIds]=Transform.SubsystemSliceUtils.getSubsystemBoundaryIds(...
                obj.sliceSubSystemH,obj.ir,'back');
            end
            [deadBlocks,allH]=obj.computeDeadBlocks('back',dfgIds,...
            [inactiveV;subsystemBoundaryIds],subsystemEdgeIds,contexts);
        end

        function[hdls,deadBlocksMapped,toRemove,activeH,allNonVirtH,synthDeadBlockH]=utilGetAllHandles(obj,deadBlocks)


            import Analysis.*;
            hdls=getAllBlocks(obj.ir.tree,obj.ir.treeIdxToHandle);
            activeBlocks=setdiff(hdls,deadBlocks);
            activeBlocksMapped=mapSynthesizedBlocks(obj.refMdlToMdlBlk,activeBlocks);


            activeBlocksMapped=setdiff(activeBlocksMapped,deadBlocks);

            deadBlocksMapped=mapSynthesizedBlocks(obj.refMdlToMdlBlk,deadBlocks);
            deadBlocksMapped=setdiff(deadBlocksMapped,activeBlocksMapped);


            notSynthIds=arrayfun(@(x)~ModelSlicer.isSynthesized(x),deadBlocksMapped);
            toRemove=deadBlocksMapped(notSynthIds);
            synthDeadBlockH=deadBlocksMapped(~notSynthIds);

            activeH=setdiff(hdls,toRemove);

            notSynthIds=arrayfun(@(x)~ModelSlicer.isSynthesized(x),activeH);
            allNonVirtH=activeH(notSynthIds);
            allNonVirtH=[allNonVirtH,obj.virtualStarts];

            function newHandles=mapSynthesizedBlocks(refMdlToMdlBlk,deadBlocks)

                import slslicer.internal.*
                newHandles=deadBlocks;
                ut=SLCompGraphUtil.Instance;
                for ind=1:numel(deadBlocks)
                    bh=deadBlocks(ind);
                    [yesno,graphBH]=isBusExpandedBlock(bh);
                    if yesno
                        newHandles(ind)=graphBH;
                    else
                        [yesno,graphBH]=Analysis.isRootOfMdlref(refMdlToMdlBlk,bh);
                        if yesno
                            newHandles(ind)=graphBH;
                        else
                            [yesno,graphBH]=ut.isSynthesizedSysForMdl(bh);
                            if yesno
                                newHandles(ind)=graphBH;
                            end
                        end
                    end
                end



                newHandles=unique(newHandles);

                function[yesno,graphBlkH]=isBusExpandedBlock(bh)
                    yesno=false;
                    graphBlkH=[];
                    bObj=get_param(bh,'Object');
                    if bObj.isSynthesized
                        parentH=bObj.getCompiledParent;
                        parentObj=bObj.getParent;
                        if~isempty(parentObj)...
                            &&~strcmp(get_param(parentH,'Type'),'block_diagram')...
                            &&strcmp(get_param(parentH,'virtual'),'on')
                            yesno=true;
                            graphBlkH=parentObj.getOriginalBlock;
                        end
                    end
                end
            end
        end

        function post=postAnalyze(obj,activeH,inactiveV,allH)


            irInactiveH=obj.utilGetAllInactiveHandles(inactiveV);

            post=postAnalyze@ModelSlicer(obj,activeH,irInactiveH,allH);
        end

        function replaceModelBlockH=utilGetReferencedModelBlocks(obj,handle)
            replaceModelBlockH=Analysis.getReferencedModelBlocks(obj.ir,obj.refMdlToMdlBlk,handle);
        end

        function modifiedSystems=removeUnusedBlocks(obj,sliceXfrmr,sliceMdl,handlesCopy,redundantMerges,handles)
            modifiedSystems=Transform.removeNVBlocks(sliceXfrmr,sliceMdl,handlesCopy,false,...
            [],redundantMerges,obj.refMdlToMdlBlk,handles,obj.options);
        end

        function utilRemoveBlocks(obj,sliceXfrmr,sliceRootSys,origSys,groups,sldvPassthroughDeadBlocks,synthDeadBlockH)
            import Transform.*;
            updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:RemovingUnusedVirtualBlocks');
            removeUnreachableVirtualBlocks(sliceXfrmr,sliceRootSys,origSys,groups,obj.options);
            obj.removeReplacedButUnusedBlocks(sliceXfrmr);
            obj.removeSLDVPassthroughBlocks(sliceXfrmr,sldvPassthroughDeadBlocks);
            obj.removeBusExpandedBlocks(sliceXfrmr,synthDeadBlockH);
        end

        function hasGlobal=checkHasGlobal(obj)
            hasGlobal=~(isempty(obj.ir.dfgIdxToGlobalDsmName)&&isempty(obj.ir.dfgIdxToDsm));
        end

        function simulateForExport(obj,SimStartTime,SimStopTime)

            simulateForExport@ModelSlicer(obj,SimStartTime,SimStopTime);
            obj.fixStaleDfgHandlesForVirtualStarts();
        end

        function fixStaleDfgHandlesForVirtualStarts(obj)














            staleSigIdx=~ishandle(obj.designInterests.signals);

            if~any(staleSigIdx)||isempty(obj.userVirtStartToActSrc)

                return;
            end

            obj.designInterests.signals(staleSigIdx)=[];

            for i=1:length(obj.virtualStarts)
                vStartH=obj.virtualStarts(i);
                actSrcs=obj.userVirtStartToActSrc(vStartH);
                if any(~ishandle(actSrcs))
                    [~,~,suggest]=slslicer.internal.checkStart(obj,...
                    vStartH);

                    obj.designInterests.signals=[obj.designInterests.signals;...
                    reshape(suggest.actSrc,numel(suggest.actSrc),1)];
                end
            end
            obj.designInterests.signals=unique(obj.designInterests.signals);

        end

        function issueWarningForUnconstraintBlockForSubystemSlice(...
            this,activeBlocks,unconstraintBlkMap)%#ok<INUSL>
            targetBlk=unconstraintBlkMap.keys;
            for n=1:length(targetBlk)
                if ismember(targetBlk{n},activeBlocks)
                    inpBlkH=unconstraintBlkMap(targetBlk{n});
                    Mex=MException('ModelSlicer:SubsystemSlice:NoImplicitExclusion',...
                    getString(message('Sldv:ModelSlicer:Transform:NoImplicitExclusion',getfullname(inpBlkH))));
                    modelslicerprivate('MessageHandler','warning',Mex,this.model);
                end
            end
        end

        function preSliceSubsysPorts=getSubsysCache(~,sliceMdl)
            preSliceSubsysPorts=Transform.CacheSubsysPortInfo(sliceMdl);
        end

        function postProcessSubsysPorts(~,sliceXfrmr,sliceMdl,preSliceSubsysPorts)
            import Transform.*
            FixPartiallyRemovedSubsysPorts(sliceXfrmr,sliceMdl,preSliceSubsysPorts);
        end

        function irInactiveH=utilGetAllInactiveHandles(obj,inactiveV)
            ir=obj.ir;%#ok<*PROPLC>
            I=num2cell(inactiveV);
            isProc=ir.dfgIdxToHandle.isKey(I);
            inactiveProcId=I(isProc);

            inactiveH=cell2mat(ir.dfgIdxToHandle.values(inactiveProcId));


            inactiveTreeIndices=[];
            for i=1:length(inactiveH)
                if ir.handleToTreeIdx.isKey(inactiveH(i))
                    inactiveTreeIndices(end+1)=ir.handleToTreeIdx(inactiveH(i));%#ok<AGROW>
                end
            end

            inactiveTreeNodes=ir.tree.descendantsFor(MSUtils.treeNodes(inactiveTreeIndices));
            irInactiveH=arrayfun(@(x)ir.treeIdxToHandle(x.Id),inactiveTreeNodes);
        end
    end
end
