classdef MdlRefCtxMgr<handle








    properties
        hasMultiInstanceRefMdls=false;
        visibileMdlToActMdl=containers.Map('keytype','char','valuetype','char');
        mdlToVisibleMdl=containers.Map('keytype','char','valuetype','char')
        visibleRefMdlHs=[];
        copyRefMdlHs=[];
        topMdl=[];
        allMdlHs=[];
        cosObjs={};
        mdlOpenListeners={};
        ms=[];
        editorChangedService=[];
        editorChangeCbId=[];
    end

    methods
        function obj=MdlRefCtxMgr(ms)
            obj.ms=ms;

            obj.topMdl=ms.model;
            obj.allMdlHs=ms.getAllMdls();


            allvisibleMdlH=cellfun(@(m)get_param(m,'handle'),...
            [find_mdlrefs(ms.modelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',true,'KeepModelsLoaded',true);...
            Simulink.observer.internal.loadObserverModelsForBD(ms.modelH)']);

            obj.visibleRefMdlHs=setdiff(allvisibleMdlH,ms.modelH);
            obj.copyRefMdlHs=setdiff(obj.allMdlHs,allvisibleMdlH);

            obj.checkMultiNormalMdlRef();
            if(obj.hasMultiInstanceRefMdls)
                obj.buildMdlMaps();
                obj.refreshAllMdlCtx();
                obj.addMdlRefreshListeners();
            end
        end

        function delete(obj)
            cellfun(@(l)delete(l),obj.mdlOpenListeners);
            obj.mdlOpenListeners={};
            obj.cosObjs={};
            if~isempty(obj.editorChangeCbId)&&...
                ~isempty(obj.editorChangedService)
                c=obj.editorChangedService;
                c.unRegisterServiceCallback(obj.editorChangeCbId);
                obj.editorChangeCbId=[];
                obj.editorChangedService=[];
            end
        end


        function elemH=mapToActualH(obj,elemH,visibleMdl)
            import slslicer.internal.*;
            if nargin<3
                visibleMdl=bdroot(elemH);
            end
            visibleMdl=getfullname(visibleMdl);
            actMdl=obj.visibileMdlToActMdl(visibleMdl);
            if isequal(visibleMdl,actMdl)
                return;
            end
            elemH=MdlRefCtxMgr.mapSlElementsToModel(elemH,actMdl);
        end


        function elemH=mapToVisibleH(obj,elemH,actMdl)
            import slslicer.internal.*;
            if nargin<3
                actMdl=bdroot(elemH(1));
            end
            actMdl=getfullname(actMdl);
            if~isKey(obj.mdlToVisibleMdl,actMdl)
                return;
            end
            visibleMdl=obj.mdlToVisibleMdl(actMdl);
            if isequal(visibleMdl,actMdl)
                return;
            end
            elemH=MdlRefCtxMgr.mapSlElementsToModel(elemH,visibleMdl);
        end



        function[elemH,idx]=getElemByBD(obj,elemH,mdlH)
            [elemH,idx]=filterByBd(elemH,mdlH);
            elemH=obj.mapToVisibleH(elemH,mdlH);

            function[e,idx]=filterByBd(e,bd)
                idx=(bdroot(e)==bd);
                e=e(idx);
            end
        end





        function partitions=partitionByBD(obj,allBlks,allSrcP,allDstP)
            import slslicer.internal.*;
            util=SLCompGraphUtil;

            partitions=struct('mdlName',[],...
            'src',[],'dst',[],'blks',[],'visible',[]);




            ipSrcIdx=strcmpi(get_param(allSrcP,'PortType'),'inport');
            ipSrcs=allSrcP(ipSrcIdx);
            for i=1:length(ipSrcs)
                mdlBlkH=get_param(ipSrcs(i),'ParentHandle');
                refMdl=get_param(mdlBlkH,'NormalModeModelName');
                ipSrcs(i)=MdlRefCtxMgr.mapSlElementsToModel(util.findDstPortsForInport(ipSrcs(i)),refMdl);
            end
            refDsts=allDstP(ipSrcIdx);

            allSrcP(ipSrcIdx)=[];
            allDstP(ipSrcIdx)=[];



            nonOpIdx=~strcmpi(get_param(allSrcP,'PortType'),'outport');
            allSrcP(nonOpIdx)=[];
            allDstP(nonOpIdx)=[];

            for i=1:length(obj.allMdlHs)
                mdlH=obj.allMdlHs(i);
                mdlName=getfullname(mdlH);

                blks=obj.getElemByBD(allBlks,mdlH);

                src=obj.getElemByBD(allSrcP,mdlH);
                dst=obj.getElemByBD(allDstP,mdlH);

                [auxSrc,idx]=obj.getElemByBD(ipSrcs,mdlH);
                auxDst=obj.mapToVisibleH(refDsts(idx),mdlH);

                src=[src,auxSrc];%#ok<AGROW>
                dst=[dst,auxDst];%#ok<AGROW>



                visible=true;
                if isKey(obj.mdlToVisibleMdl,mdlName)
                    vname=obj.mdlToVisibleMdl(mdlName);
                    if isKey(obj.visibileMdlToActMdl,vname)
                        visible=strcmp(obj.visibileMdlToActMdl(...
                        vname),mdlName);
                    end
                end
                partitions(i)=struct('mdlName',mdlName,...
                'src',src,'dst',dst,'blks',blks,'visible',visible);
            end
        end
    end

    methods(Hidden=true)

        function refreshMdlHilite(obj,mdlH)
            mdlName=getfullname(mdlH);

            oldCtxMdl='';
            if isKey(obj.visibileMdlToActMdl,mdlName)
                oldCtxMdl=obj.visibileMdlToActMdl(mdlName);
            end

            refreshMdlCtxFromStudio(obj,mdlH);

            newCtxMdl=obj.visibileMdlToActMdl(mdlName);

            sc=obj.ms.getActiveSC;
            if~isempty(sc.overlay)&&~isequal(oldCtxMdl,newCtxMdl)
                sc.overlay.updateRefMdlDisplay(sc,oldCtxMdl,newCtxMdl);
            end
        end

        function refreshMdlHiliteForEditorReuse(obj)
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if isempty(studios)
                return;
            end

            st=studios(1);
            stApp=st.App;
            activeEditor=stApp.getActiveEditor;
            blockDiagramHandle=activeEditor.blockDiagramHandle;
            mdlName=getfullname(blockDiagramHandle);
            obj.refreshMdlHilite(get_param(mdlName,'handle'));
        end
    end

    methods(Access=private)

        function buildMdlMaps(obj)
            obj.mdlToVisibleMdl(obj.topMdl)=obj.topMdl;
            if~isempty(obj.ms.refMdlToMdlBlk)
                mdlMap=obj.ms.refMdlToMdlBlk;
                refMdls=mdlMap.keys;
                for i=1:length(refMdls)
                    refMdl=refMdls{i};
                    bp=get(refMdl,...
                    'ModelReferenceNormalModeVisibilityBlockPath');
                    mdlBlk=bp.getBlock(bp.getLength);
                    visibleMdl=get_param(mdlBlk,'ModelName');
                    obj.mdlToVisibleMdl(getfullname(refMdl))=visibleMdl;
                end
            end
        end

        function refreshAllMdlCtx(obj)
            obj.visibileMdlToActMdl(obj.topMdl)=obj.topMdl;
            for i=1:length(obj.visibleRefMdlHs)
                mdlH=obj.visibleRefMdlHs(i);
                if~isKey(obj.visibileMdlToActMdl,getfullname(mdlH))
                    obj.refreshMdlCtxFromStudio(mdlH);
                end
            end
        end




        function refreshMdlCtxFromStudio(obj,mdlH)
            mdlName=getfullname(mdlH);
            ed=GLUE2.Util.findAllEditors(mdlName);
            obj.visibileMdlToActMdl(mdlName)=mdlName;
            if isempty(ed)
                return;
            end
            mdlBlkH=getSpawningMdlBlk(ed(1),mdlH);

            if ishandle(mdlBlkH)&&Simulink.SubsystemType.isModelBlock(mdlBlkH)
                mdlBlkSid=get_param(mdlBlkH,'SID');

                ownerMdlH=bdroot(mdlBlkH);
                ownerMdlName=getfullname(ownerMdlH);

                if~isKey(obj.visibileMdlToActMdl,ownerMdlName)
                    refreshMdlCtxFromStudio(obj,ownerMdlH);
                end

                actualOwnerMdl=obj.visibileMdlToActMdl(ownerMdlName);
                obj.visibileMdlToActMdl(mdlName)=...
                get_param([actualOwnerMdl,':',mdlBlkSid],'NormalModeModelName');
            end
        end


        function addMdlRefreshListeners(obj)
            ed=GLUE2.Util.findAllEditors(obj.topMdl);
            if~isempty(ed)
                studio=ed(1).getStudio;
                c=studio.getService('GLUE2:ActiveEditorChanged');
                obj.editorChangedService=c;
                obj.editorChangeCbId=c.registerServiceCallback(@(~)obj.refreshMdlHiliteForEditorReuse());
            end
        end


        function checkMultiNormalMdlRef(obj)




            mdlH=get_param(obj.topMdl,'handle');
            [~,mdlBlkH]=Transform.AtomicGroup.searchModelBlocks(mdlH);
            refMdls=string(arrayfun(@(b){get_param(b,'ModelName')},mdlBlkH));
            modeVal=string(arrayfun(@(b){get_param(b,'SimulationMode')},mdlBlkH));
            refTuple=[refMdls;modeVal]';
            len=size(mdlBlkH,2);
            flags=arrayfun(@(idx)checkWithNextIndex(idx),1:len-1);
            if any(flags)
                obj.hasMultiInstanceRefMdls=true;
            end
            function yesno=checkWithNextIndex(idx)
                assert(idx>0&&idx<len);
                yesno=all(refTuple(idx,:)==refTuple(idx+1,:))&&...
                refTuple(idx,2)=="Normal";
            end
        end
    end

    methods(Static)

        function elemH=mapSlElementsToModel(elemH,mapMdl)
            for i=1:length(elemH)
                e=elemH(i);
                type=get_param(e,'type');
                if~ishandle(e)
                    continue;
                end
                try
                    if strcmpi(type,'block')
                        elemH(i)=getEquivalentBlkH(e);
                    elseif strcmpi(type,'port')
                        pt=get_param(e,'PortType');
                        portNum=get_param(e,'PortNumber');
                        ownerH=getEquivalentBlkH(get_param(e,'ParentHandle'));
                        ph=get_param(ownerH,'porthandles');
                        if strcmpi(pt,'inport')
                            elemH(i)=ph.Inport(portNum);
                        elseif strcmpi(pt,'outport')
                            elemH(i)=ph.Outport(portNum);
                        else
                            field=[upper(pt(1)),pt(2:end)];
                            elemH(i)=ph.(field);
                        end
                    end
                catch
                end
            end
            function mapH=getEquivalentBlkH(origH)
                sid=get_param(getfullname(origH),'SID');
                mapH=get_param([mapMdl,':',sid],'handle');
            end

        end


        function newIds=mapSfElementsToModel(origIds,mapMdl)
            newIds=origIds;
            for idx=1:length(origIds)
                try
                    id=origIds(idx);
                    h=idToHandle(sfroot,id);
                    sidComp=strsplit(Simulink.ID.getSID(h),':');
                    sidComp{1}=mapMdl;
                    newSid=strjoin(sidComp,':');
                    h=Simulink.ID.getHandle(newSid);
                    if isa(h,'Stateflow.Object')
                        newIds(idx)=h.Id;
                    end
                catch
                end
            end
        end



        function[blkH,inRefModel]=mapBlkPathObjToActHandle(blockPathObj)
            numBlks=blockPathObj.getLength;
            if numBlks>1
                inRefModel=true;
            end

            mdlName=bdroot(blockPathObj.getBlock(1));


            for i=1:numBlks-1
                sid=[mdlName,':',get_param(blockPathObj.getBlock(i),'SID')];
                mdlName=get_param(sid,'NormalModeModelName');
            end
            blkH=get_param([mdlName,':',get_param(blockPathObj.getBlock(numBlks),'SID')],'handle');
        end
    end
end

function mdlBlkH=getSpawningMdlBlk(~,modelH)
    mdlBlkH=-1;
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if~isempty(studios)
        studio=studios(1);
        studioApp=studio.App;
        activeEditor=studioApp.getActiveEditor;
        try
            mdlBlkH=getClosestSpawningMdlBlkFromEd(activeEditor);
        catch
            mdlBlkH=-1;
        end
    end
    if mdlBlkH==-1
        bp=get_param(modelH,'ModelReferenceNormalModeVisibilityBlockPath');
        if~isempty(bp)
            mdlBlkH=get_param(bp.getBlock(bp.getLength),'handle');
        end
    end
end


function blkH=getClosestSpawningMdlBlkFromEd(activeEditor)
    hid=activeEditor.getHierarchyId;
    pid=GLUE2.HierarchyService.getParent(hid);
    if(GLUE2.HierarchyService.isValid(pid))
        m3iobj=GLUE2.HierarchyService.getM3IObject(pid);
        block=m3iobj.temporaryObject;
        blkH=block.handle;
    end

    if strcmpi(get(blkH,'Type'),'block')
        if~Simulink.SubsystemType.isModelBlock(blkH)
            pid=GLUE2.HierarchyService.getParent(pid);
            bp=Simulink.BlockPath.fromHierarchyIdAndHandle(pid,blkH);
            blkH=get_param(bp.getBlock(bp.getLength-1),'handle');
        end
    else
        blkH=-1;
    end
end
