classdef DependencyHandler




    methods(Access=private)
        function setBlksUsingDFEq(~,sc)
            sc.allNonVirtualBlocks=unique(...
            sc.modelSlicer.atomicGroups.filterProtectedChildren(...
            sc.modelSlicer.allNVBlkHs,...
            sc.modelSlicer.options));
            sc.allLineHandles=sc.modelSlicer.allLineHandles;


            sc.activeBlocks=intersect(sc.allActiveBlocks,...
            sc.allNonVirtualBlocks);
        end

        function setBlksUsingDFGIR(~,sc,b)







            allExtraOriginalBlks=cell2mat(...
            sc.modelSlicer.ir.synBlkHToOrigBlkHMap.values);

            sc.allNonVirtualBlocks=...
            unique(...
            sc.modelSlicer.atomicGroups.filterProtectedChildren(...
            [sc.modelSlicer.ir.allNonSynthesizedBlocks(:);...
            allExtraOriginalBlks(:)],...
            sc.modelSlicer.options));








            allSynBlocks=cell2mat(...
            sc.modelSlicer.ir.synBlkHToOrigBlkHMap.keys);

            allActiveSynBlocks=intersect(b,allSynBlocks);


            allActiveSynBlocksCell=num2cell(allActiveSynBlocks);
            allExtraActiveOriginalBlks=cell2mat(...
            sc.modelSlicer.ir.synBlkHToOrigBlkHMap.values(allActiveSynBlocksCell));











            allrefMdl=cell2mat(sc.modelSlicer.refMdlToMdlBlk.keys);
            allrefMdlIdex=ismember(allExtraActiveOriginalBlks,[allrefMdl,sc.modelSlicer.modelH]);

            allExtraActiveOriginalBlks=allExtraActiveOriginalBlks(~allrefMdlIdex);

            allExtraActiveOriginalBlks=...
            sc.modelSlicer.atomicGroups.filterProtectedChildren(allExtraActiveOriginalBlks,sc.modelSlicer.options);

            sc.setStartingPoints();
            b=[b;reshape(sc.startingPoints,[],1)];
            sc.activeBlocks=unique([intersect(b,sc.allNonVirtualBlocks);allExtraActiveOriginalBlks(:)]);
        end

        function setDependenciesUsingDFEq(this,sc,allSrcP,allDstP,allBlks)
            portBlks=[];
            parentBlks=[];
            vblks=[];
            if sc.handleMultiInstanceRefs()
                b=this.updateMultiRefDependencies(sc,portBlks,parentBlks,vblks,allBlks,allSrcP,allDstP);
            else
                sc.dependencies=[sc.allLineHandles;allBlks;sc.sliceSubSystemH];
                b=[allBlks;sc.sliceSubSystemH];
                gSrc=unique(allSrcP);
                sc.portsToLabel=gSrc;

                sc.stateflowElems=getSfElementsInSlice(sc.modelSlicer,b);
            end
        end

        function setDependenciesUsingDFGIR(this,sc,allSrcP,allDstP,allBlks)
            if sc.seedHandler.hasVirtualStarts(sc)






                [vpsrcP,vpdstP,vblks]=...
                slslicer.internal.virtual.getSegBetweenVirtAndDFG(...
                sc,sc.seedHandler.getVirtualToDFGMap(sc));

                allSrcP=[allSrcP,vpsrcP'];
                allDstP=[allDstP,vpdstP'];




            else
                vblks=[];
            end



            [portBlks,allSrcP,allDstP]=sc.seedHandler.utilForVirtualSubsystemHighlight(allSrcP,allDstP,sc);



            if sc.seedHandler.hasVirtualStarts(sc)
                parentBlks=slslicer.internal.SLCompGraphUtil.Instance.getBlockAncestors(...
                sc.getVirtualStarts,sc.modelSlicer.refMdlToMdlBlk);
            else
                parentBlks=[];
            end

            [ssSrcP,ssDstP]=slslicer.internal.getSegBetweenSysPortAndActStart(...
            sc.modelSlicer.designInterests.signals,sc.direction);
            allSrcP=[allSrcP,ssSrcP];
            allDstP=[allDstP,ssDstP];

            if sc.handleMultiInstanceRefs()
                b=this.updateMultiRefDependencies(sc,portBlks,parentBlks,vblks,allBlks,allSrcP,allDstP);
            else
                [sc.dependencies,b,gSrc]=this.getSlElems(sc,portBlks,parentBlks,vblks,allSrcP,allDstP,allBlks);
                sc.portsToLabel=gSrc;

                sc.stateflowElems=getSfElementsInSlice(sc.modelSlicer,b);
            end


            sc.allActiveBlocks=unique([sc.allActiveBlocks;b]);
            sc.activeBlocks=unique([intersect(sc.allActiveBlocks,sc.allNonVirtualBlocks);sc.activeBlocks]);
        end

        function b=updateMultiRefDependencies(this,sc,portBlks,parentBlks,vblks,allBlks,allSrcP,allDstP)
            partitions=sc.modelSlicer.mdlRefCtxMgr.partitionByBD(allBlks,allSrcP,allDstP);
            for idx=1:length(partitions)
                part=partitions(idx);

                mdlName=part.mdlName;
                mdlH=get_param(mdlName,'handle');
                srcP=part.src;
                dstP=part.dst;
                blks=part.blks;
                visibleMdl=part.visible;

                [handles,b,gSrc]=this.getSlElems(sc,portBlks,parentBlks,vblks,srcP,dstP,blks);
                if~isempty(sc.modelSlicer.refMdlToMdlBlk)&&isKey(sc.modelSlicer.refMdlToMdlBlk,mdlH)
                    handles=setdiff(handles,sc.modelSlicer.refMdlToMdlBlk(mdlH));
                end
                if Simulink.internal.isModelReferenceMultiInstanceNormalModeCopy(mdlName)
                    blocksForSf=slslicer.internal.MdlRefCtxMgr.mapSlElementsToModel(b,mdlName);
                else
                    blocksForSf=b;
                end


                sfElems=getSfElementsInSlice(sc.modelSlicer,blocksForSf);

                if Simulink.internal.isModelReferenceMultiInstanceNormalModeCopy(mdlName)
                    sfElems.activeIds=slslicer.internal.MdlRefCtxMgr.mapSfElementsToModel(sfElems.activeIds,...
                    get_param(mdlName,'ModelReferenceNormalModeOriginalModelName'));
                end

                if visibleMdl
                    sc.dependencies=[sc.dependencies;handles];
                    sc.portsToLabel=[sc.portsToLabel;gSrc];
                    sc.stateflowElems.activeIds=[sc.stateflowElems.activeIds;sfElems.activeIds];
                    sc.stateflowElems.subChartStruct=[sc.stateflowElems.subChartStruct;sfElems.subChartStruct];
                end

                sp=sc.modelSlicer.mdlRefCtxMgr.getElemByBD(sc.startingPoints,get_param(mdlName,'handle'));
                ep=sc.modelSlicer.mdlRefCtxMgr.getElemByBD(sc.exclusionPoints,get_param(mdlName,'handle'));
                sc.hiliteElems(mdlName)=struct('startingPoints',sp,...
                'dependencies',handles,'exclusionPoints',ep,...
                'stateflowElems',sfElems);
            end
        end

        function[handles,b,gSrc]=getSlElems(~,sc,portBlks,parentBlks,vblks,srcP,dstP,blks)
            utils=SystemsEngineering.SEUtil;
            if~isempty(srcP)&&~isempty(dstP)
                [handles,vBlks,gSrc,gDst]=utils.getAllSegmentsInPath(srcP,dstP);%#ok<ASGLU>
            else
                handles=[];
                vBlks=[];
                gSrc=[];
                gDst=[];
            end

            b=unique([blks;vBlks;parentBlks';portBlks;vblks;sc.sliceSubSystemH]);


            filt=arrayfun(@(x)isNotSynthesized(x),b);
            b=b(filt);

            objs=[b;slslicer.internal.SLGraphUtil.getAllSystems(b)];
            handles=unique([handles;objs]);

            function yesno=isNotSynthesized(bh)
                try
                    obj=get(bh,'Object');
                    yesno=~obj.isSynthesized;
                catch
                    yesno=false;
                end
            end
        end
    end

    methods(Static)
        function[invalidBlk,invalidSig]=checkInvalidBlocksAndSignals(ms)
            if slfeature('NewSlicerBackend')
                invalidBlk=[];
                invalidSig=[];
            else
                [~,invalidBlk,invalidSig]=ms.getDesignInterestsDfgIds;
            end
        end

        function setActiveAndNVBlks(sc,b)
            import slslicer.internal.*
            obj=DependencyHandler();
            if slfeature('NewSlicerBackend')
                obj.setBlksUsingDFEq(sc);
            else
                obj.setBlksUsingDFGIR(sc,b)
            end
        end

        function setMSDependencies(ms,allSrcP,allDstP,allHandles)
            allLineHandles=allHandles(strcmp(get_param(allHandles,'type'),'line'))';
            ms.allSrcP=allSrcP;
            ms.allDstP=allDstP;
            ms.allLineHandles=allLineHandles;
        end

        function setDependencies(sc,allSrcP,allDstP,allBlks)
            import slslicer.internal.*
            sc.dependencies=[];
            sc.stateflowElems=struct('activeIds',[],'subChartStruct',[]);
            sc.hiliteElems.remove(sc.hiliteElems.keys);
            obj=DependencyHandler();
            if slfeature('NewSlicerBackend')
                obj.setDependenciesUsingDFEq(sc,sc.modelSlicer.allSrcP,sc.modelSlicer.allDstP,allBlks);
            else
                obj.setDependenciesUsingDFGIR(sc,allSrcP,allDstP,allBlks);
            end
        end

        function resetDependencies(sc)
            sc.activeBlocks=[];
            sc.allNonVirtualBlocks=[];
            sc.allActiveBlocks=[];
            sc.allLineHandles=[];

            sc.modelSlicer.resetDependencies();
        end
    end


end
