classdef DebuggerMTreeNode<handle



    properties

        ID;
        DisplayLabel;
        Icon;
        Children;


        UnfilteredChildren;
        Type;
        FullPath;
        DisplayPath;


        SimRTHandle=[];
        SimRTStorageHandles=[];
        SimRTListeners=[];
        BreakPoints=[];


        BreakPointReasons={};
        BreakPointEventIDs=[];


        DebuggerObjHdl=[];
        EventCalendarChildNodes=[];


        RootNode=[];
    end

    methods(Static)
        function[obj,blkToTreeNodeMap]=createModelTreeStopped(modelName)
            obj=slde.ddg.DebuggerMTreeNode(modelName,'root',[],modelName,[]);
            blkToTreeNodeMap=containers.Map;
            blkToTreeNodeMap(modelName)=obj;
        end
        function[obj,blkToTreeNodeMap]=createModelTreeRunning(modelName)
            modelRT=simevents.ModelRoot.get(get_param(modelName,'Handle'));

            obj=slde.ddg.DebuggerMTreeNode(modelName,'root',[],'',[]);
            obj.RootNode=obj;


            evcals=modelRT.getEventCalendars();
            evns=[];
            for k=1:length(evcals)
                evn=slde.ddg.DebuggerMTreeNode(...
                ['Event calendar',int2str(k)],...
                'evcal',obj,'',obj);
                evn.SimRTHandle=evcals(k);
                evn.BreakPoints=false;
                evns=[evns,evn];%#ok
            end
            obj.EventCalendarChildNodes=evns;


            slde.ddg.DebuggerMTreeNode('Breakpoints','breakpoints',...
            obj,'',obj);


            stTree=slde.ddg.DebuggerMTreeNode('Storage','subsystem',...
            obj,modelName,obj);


            blkToTreeNodeMap=containers.Map;
            blkToTreeNodeMap=stTree.MapBlocksToNodes(blkToTreeNodeMap);


            uniqueBlks={};
            for e=1:length(evcals)
                blks=evcals(e).BlocksInSystem;
                for b=1:length(evcals(e).BlocksInSystem)
                    thisBlkObj=blks(b);
                    thisBlk=thisBlkObj.BlockPath;
                    if any(strcmp(thisBlk,uniqueBlks))
                        continue;
                    else
                        uniqueBlks=[uniqueBlks;thisBlk];
                    end

                    thisBlkPar=get_param(thisBlk,'Parent');
                    thisBlkName=strrep(get_param(thisBlk,'Name'),char(10),' ');

                    tNode=blkToTreeNodeMap(thisBlkPar);

                    stNode=slde.ddg.DebuggerMTreeNode(...
                    thisBlkName,'leafblock',tNode,thisBlk,obj);
                    stNode.SimRTHandle=thisBlkObj;
                    stNode.SimRTStorageHandles=thisBlkObj.Storage;
                    stNode.BreakPoints=false(length(stNode.SimRTStorageHandles),2);
                end
            end




            blkToTreeNodeMap=containers.Map;
            blkToTreeNodeMap=obj.pruneChildlessNodeHier(blkToTreeNodeMap,'');


            obj.resetChildren(false,'',[]);
        end
    end

    methods
        function id=getID(this)
            id=this.ID;
        end
        function str=getDisplayLabel(this)
            str=this.DisplayLabel;
        end
        function icon=getDisplayIcon(this)
            icon=this.Icon;
        end
        function has=hasChildren(this)
            has=~isempty(this.Children);
        end
        function children=getHierarchicalChildren(this)
            children=this.Children;
        end
        function setDebuggerObjHdl(this,dbgObj)
            this.DebuggerObjHdl=dbgObj;
        end
        function continueFromBreak(this)
            builtin('_slde_internal_sedebugexit',this.DebuggerObjHdl.mModel);


            com.mathworks.mlservices.MLExecuteServices.executeCommand(char(10));
        end
        function watchedEntityLocs=resetChildren(this,filtByOccupancy,...
            filtByName,watchedEntities)
            watchedEntityLocs=cell(1,length(watchedEntities));
            [~,watchedEntityLocs]=this.filterByOccupancy(filtByOccupancy,...
            watchedEntities,...
            watchedEntityLocs);
            if~isempty(filtByName)
                this.filterByName(filtByName);
            end
            this.assignIDRecursive(0);
        end
        function hb=hasEvcalBreakPoint(this,bpReason,evID)
            this.locAssert(strcmp(this.Type,'evcal'))
            hb=any(strcmp(this.BreakPointReasons,bpReason));
            if hb&&evID~=-1
                hb=any(this.BreakPointEventIDs==evID);
            end
        end
        function addEvCalBreakPoint(this,bpReason,evID)
            this.locAssert(strcmp(this.Type,'evcal'));
            if isempty(this.SimRTListeners)
                this.SimRTListeners=addlistener(...
                this.SimRTHandle,'PreExecute',@this.preExecute);
            end
            this.BreakPointReasons=union(this.BreakPointReasons,...
            {bpReason});
            if evID~=-1
                this.BreakPointEventIDs=union(this.BreakPointEventIDs,evID);
            end
        end
        function removeEvCalBreakPoint(this,bpReason,evID)
            this.locAssert(strcmp(this.Type,'evcal'));
            this.BreakPointReasons=setdiff(this.BreakPointReasons,...
            {bpReason});
            if evID~=-1
                this.BreakPointEventIDs=setdiff(this.BreakPointEventIDs,evID);
            end
            if isempty(this.BreakPointReasons)
                delete(this.SimRTListeners);
                this.SimRTListeners=[];
            end
        end
        function removeAllEvCalBreakPoints(this)
            this.locAssert(strcmp(this.Type,'evcal'));
            delete(this.SimRTListeners);
            this.SimRTListeners=[];
            this.BreakPointEventIDs=[];
            this.BreakPointReasons={};
        end
        function hb=hasBlockBreakPoint(this,stIdx,bpIdx)
            this.locAssert(strcmp(this.Type,'leafblock'));

            if stIdx==-1
                stIdx=1:length(this.SimRTStorageHandles);
            end
            hb=any(this.BreakPoints(stIdx,bpIdx));
        end
        function addBlockBreakPoint(this,stIdx,bpIdx)
            this.locAssert(strcmp(this.Type,'leafblock'));

            if stIdx==-1
                stIdx=1:length(this.SimRTStorageHandles);
            end

            for k=stIdx
                if bpIdx==1
                    l=addlistener(this.SimRTStorageHandles(k),'PostEntry',...
                    @this.postEntry);
                else
                    this.locAssert(bpIdx==2);
                    l=addlistener(this.SimRTStorageHandles(k),'PreExit',...
                    @this.preExit);
                end

                lVal.Listener=l;
                lVal.StIdx=k;
                lVal.BpType=bpIdx;

                this.SimRTListeners=[this.SimRTListeners,lVal];
            end
            this.BreakPoints(stIdx,bpIdx)=true;
        end
        function removeBlockBreakPoint(this,stIdx,bpIdx)
            this.locAssert(strcmp(this.Type,'leafblock'));

            if stIdx==-1
                stIdx=1:length(this.SimRTStorageHandles);
            end

            for k=stIdx
                fndIdx=0;
                for m=1:length(this.SimRTListeners)
                    if this.SimRTListeners(m).StIdx==k&&...
                        this.SimRTListeners(m).BpType==bpIdx
                        fndIdx=m;
                        break
                    end
                end
                if fndIdx~=0
                    delete(this.SimRTListeners(fndIdx).Listener);
                    this.SimRTListeners(fndIdx)=[];
                end
            end
            this.BreakPoints(stIdx,bpIdx)=false;
        end
        function addNextEventBreakPoint(this)
            this.locAssert(strcmp(this.Type,'root'));
            for k=1:length(this.EventCalendarChildNodes)
                thisChild=this.EventCalendarChildNodes(k);
                thisChild.addEvCalBreakPoint('nextEvent',-1);
            end
        end
        function removeNextEventBreakPoint(this)
            this.locAssert(strcmp(this.Type,'root'));
            for k=1:length(this.EventCalendarChildNodes)
                thisChild=this.EventCalendarChildNodes(k);
                thisChild.removeEvCalBreakPoint('nextEvent',-1);
            end
        end
        function is=isMatlabDESSystemBlock(~,name)


            is=false;
            bType=get_param(name,'BlockType');
            if strcmp(bType,'MATLABDiscreteEventSystem')
                is=true;
            elseif strcmp(bType,'SubSystem')
                hdl=get_param(name,'handle');
                id=sfprivate('block2chart',hdl);
                is=(id>0);
            end
        end
        function prototypes=getOneNodeOfEachType(this,prototypes)
            found=false;
            for i=1:length(prototypes)
                prototype=prototypes{i};
                if strcmp(prototype.Type,this.Type)
                    switch this.Type
                    case 'leafblock'
                        aIsMLSys=this.isMatlabDESSystemBlock(this.FullPath);
                        bIsMLSys=this.isMatlabDESSystemBlock(prototype.FullPath);
                        if aIsMLSys==bIsMLSys

                            found=true;
                            break;
                        end

                    otherwise
                        found=true;
                        break;
                    end
                end
            end
            if~found
                prototypes=[prototypes,{this}];
            end
            for i=1:length(this.UnfilteredChildren)
                prototypes=this.UnfilteredChildren{i}.getOneNodeOfEachType(prototypes);
            end
        end

    end

    methods(Access=private)
        function this=DebuggerMTreeNode(name,type,parent,objPath,rootNode)
            this.ID=0;
            this.DisplayLabel=name;
            this.UnfilteredChildren={};
            this.Children={};
            this.Type=type;
            this.FullPath=objPath;
            this.DisplayPath='';
            this.BreakPoints=false;
            this.RootNode=rootNode;


            switch type
            case 'root'
                this.Icon=this.getNodeIconRoot();
            case 'evcal'
                this.Icon=this.getNodeIconEvcal();
            case 'breakpoints'
                this.Icon=this.getNodeIconBreakpoints();
            case 'subsystem'
                this.Icon=this.getNodeIconSubsystem();
            case 'leafblock'
                this.Icon=this.getNodeIconLeafBlock();
            otherwise
                this.locAssert(true);
            end


            if strcmp(type,'subsystem')
                childPaths=find_system(objPath,'LookUnderMasks','on',...
                'FollowLinks','on','SearchDepth',1,...
                'BlockType','SubSystem');

                if parent~=rootNode
                    childPaths=childPaths(2:end);
                end

                for k=1:length(childPaths)
                    cName=strrep(get_param(childPaths{k},'Name'),char(10),' ');
                    slde.ddg.DebuggerMTreeNode(cName,'subsystem',this,childPaths{k},...
                    rootNode);
                end
            end


            if~isempty(parent)
                parent.addChild(this);
            end
        end

        function addChild(this,child)
            this.UnfilteredChildren{end+1}=child;
        end
        function setIconForBlock(this,hasEnt)
            this.locAssert(strcmp(this.Type,'leafblock'));
            if hasEnt
                this.Icon=this.getNodeIconWithEntity();
            else
                this.Icon=this.getNodeIconWithoutEntity();
            end
        end

        function bMap=MapBlocksToNodes(this,bMap)
            if~isempty(this.FullPath)
                bMap(this.FullPath)=this;
            end
            for k=1:length(this.UnfilteredChildren)
                bMap=MapBlocksToNodes(this.UnfilteredChildren{k},bMap);
            end
        end

        function[ssToTreeNodeMap,retain]=...
            pruneChildlessNodeHier(this,ssToTreeNodeMap,currPath)
            if isempty(currPath)
                currPath=this.DisplayLabel;
            else
                currPath=[currPath,'/',this.DisplayLabel];
            end
            switch this.Type
            case{'evcal','breakpoints'}
                retain=true;
            case 'leafblock'
                retain=~isempty(this.SimRTStorageHandles);
            case{'root','subsystem'}
                retChildren=false(1,length(this.UnfilteredChildren));
                for k=1:length(this.UnfilteredChildren)
                    [ssToTreeNodeMap,rc]=...
                    pruneChildlessNodeHier(this.UnfilteredChildren{k},...
                    ssToTreeNodeMap,currPath);
                    retChildren(k)=rc;
                end
                this.UnfilteredChildren=this.UnfilteredChildren(retChildren);
                retain=~isempty(this.UnfilteredChildren);
            otherwise
                this.locAssert(true);
            end
            if retain
                this.DisplayPath=currPath;
                ssToTreeNodeMap(currPath)=this;
            end
        end

        function[retain,wEntLocs]=filterByOccupancy(this,filtOcc,wEnts,wEntLocs)
            switch this.Type
            case 'leafblock'
                anyOccupied=false;
                st=this.SimRTStorageHandles;
                for s=1:length(st)
                    ents=st(s).Entity;
                    if~isempty(ents)
                        anyOccupied=true;
                        if isempty(wEnts)
                            break;
                        else
                            entIDs=[ents.ID];
                            [~,~,wIdx]=intersect(entIDs,wEnts);
                            wEntLocs(wIdx)=repmat({this.FullPath},...
                            1,length(wIdx));
                        end
                    end
                end
                setIconForBlock(this,anyOccupied);
                retain=~filtOcc||anyOccupied;
            case{'evcal','breakpoints'}
                retain=true;
            case{'root','subsystem'}
                retCh=false(1,length(this.UnfilteredChildren));
                for k=1:length(this.UnfilteredChildren)
                    [retCh(k),wEntLocs]=...
                    filterByOccupancy(this.UnfilteredChildren{k},...
                    filtOcc,wEnts,wEntLocs);
                end
                retain=any(retCh);
                this.Children=this.UnfilteredChildren(retCh);
            otherwise
                this.locAssert(true);
            end
        end

        function retain=filterByName(this,filtName)
            switch this.Type
            case{'evcal','breakpoints'}
                retain=true;
            case 'leafblock'
                retain=~isempty(strfindi(this.FullPath,filtName));
            case{'subsystem','root'}


                retCh=false(1,length(this.Children));
                for k=1:length(this.Children)
                    retCh(k)=filterByName(this.Children{k},filtName);
                end
                retain=any(retCh);
                this.Children=this.Children(retCh);

            otherwise
                retain=false;
                this.locAssert(true);
            end
        end

        function idVal=assignIDRecursive(this,idVal)
            this.ID=idVal;
            idVal=idVal+1;
            for k=1:length(this.Children)
                idVal=assignIDRecursive(this.Children{k},idVal);
            end
        end
        function dbgObj=getDebuggerObjHdl(this)
            dbgObj=this.RootNode.DebuggerObjHdl;
            this.locAssert(~isempty(dbgObj));
        end
        function postEntry(this,~,~)
            this.RootNode.DebuggerObjHdl.notifyDialogOnBP(this,'blockEntry');
            builtin('_slde_internal_sedebugentry',this.RootNode.DebuggerObjHdl.mModel);
            this.RootNode.DebuggerObjHdl.notifyDialogOnBPExit(this,'blockEntry');
        end
        function preExit(this,~,~)
            this.RootNode.DebuggerObjHdl.notifyDialogOnBP(this,'blockExit');
            builtin('_slde_internal_sedebugentry',this.RootNode.DebuggerObjHdl.mModel);
            this.RootNode.DebuggerObjHdl.notifyDialogOnBPExit(this,'blockExit');
        end
        function preExecute(this,a,b)
            doBreak=false;
            bpType='evcal';


            if any(strcmp(this.BreakPointReasons,'nextEvent'))||...
                any(strcmp(this.BreakPointReasons,'evcal'))
                doBreak=true;
            end


            if isempty(this.SimRTHandle.CurrentEvent)
                return;
            end
            currID=this.SimRTHandle.CurrentEvent.ID;
            anyEvBreak=find(this.BreakPointEventIDs==currID,1);
            if~isempty(anyEvBreak)
                doBreak=true;
                bpType='evID';

                this.BreakPointEventIDs(anyEvBreak)=[];
                if isempty(this.BreakPointEventIDs)
                    this.BreakPointReasons=setdiff(...
                    this.BreakPointReasons,{'evID'});
                end
                if isempty(this.BreakPointReasons)
                    delete(this.SimRTListeners);
                    this.SimRTListeners=[];
                end
            end

            if doBreak
                this.RootNode.DebuggerObjHdl.notifyDialogOnBP(this,bpType);
                builtin('_slde_internal_sedebugentry',this.RootNode.DebuggerObjHdl.mModel);
                this.RootNode.DebuggerObjHdl.notifyDialogOnBPExit(this,bpType);
            end
        end
        function icf=getNodeIconRoot(~)
            persistent icFile
            if isempty(icFile)
                icFile=fullfile(matlabroot,'toolbox','shared',...
                'dastudio','resources','simulink_model.png');
            end
            icf=icFile;
        end
        function icf=getNodeIconEvcal(~)
            persistent icFile
            if isempty(icFile)
                icFile=fullfile(matlabroot,'toolbox','shared',...
                'dastudio','resources','table.png');
            end
            icf=icFile;
        end
        function icf=getNodeIconBreakpoints(~)
            persistent icFile
            if isempty(icFile)
                icFile=fullfile(matlabroot,'toolbox','shared',...
                'dastudio','resources','SLEditor',...
                'SimulationRecord.png');
            end
            icf=icFile;
        end
        function icf=getNodeIconSubsystem(~)
            persistent icFile
            if isempty(icFile)
                icFile=fullfile(matlabroot,'toolbox','shared',...
                'dastudio','resources','SubSystemIcon.gif');
            end
            icf=icFile;
        end
        function icf=getNodeIconLeafBlock(~)
            persistent icFile
            if isempty(icFile)
                icFile=fullfile(matlabroot,'toolbox','shared',...
                'dastudio','resources','BlockIcon.png');
            end
            icf=icFile;
        end
        function icf=getNodeIconWithEntity(~)
            persistent icFile
            if isempty(icFile)
                icFile=fullfile(matlabroot,'toolbox','shared',...
                'dastudio','resources',...
                'SelectionCircle-On-Pressed.png');
            end
            icf=icFile;
        end
        function icf=getNodeIconWithoutEntity(~)
            persistent icFile
            if isempty(icFile)
                icFile=fullfile(matlabroot,'toolbox','shared',...
                'dastudio','resources',...
                'SelectionCircle-Off-Unselected.png');
            end
            icf=icFile;
        end
        function locAssert(~,asCond)



            assert(asCond)
        end
    end
end

function ret=strfindi(s1,s2)


    ret=strfind(lower(s1),lower(s2));

end