classdef DiagramManager<handle








    properties(Access=private)

ViewIdToWindow

ViewIdToDebugWindow





ViewIdToObjectInfo


DebugMode



        PAGE_TITLE=getString(message('Slvnv:slreq_tracediagram:WindowTitle'));

        WINDOW_TITLE_SURFIX_MAXLENGTH=30;
    end

    methods(Access=private)
        function this=DiagramManager()
            this.ViewIdToWindow=containers.Map('KeyType','char','ValueType','any');
            this.ViewIdToDebugWindow=containers.Map('KeyType','char','ValueType','any');
            this.ViewIdToObjectInfo=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods
        function delete(this)
            this.closeAll;
        end


        function addObjectInfoFromViewId(this,viewId,objInfo)
            this.ViewIdToObjectInfo(viewId)=objInfo;
        end


        function objInfo=getObjectInfoFromViewId(this,viewId)
            objInfo=[];
            if isKey(this.ViewIdToObjectInfo,viewId)
                objInfo=this.ViewIdToObjectInfo(viewId);
            end
        end


        function windowTitle=getWindowTitle(this,object)



            try
                if isa(object,'slreq.data.Requirement')
                    adpManager=slreq.adapters.AdapterManager.getInstance;
                    adp=adpManager.getAdapterByDomain(object.domain);
                    artifact=object.getReqSetArtifactUri();
                    label=adp.getSummary(artifact,object.id);
                    type=getString(message('Slvnv:slreq:Requirement'));
                    surfix=[type,': ',label];
                elseif isa(object,'slreq.data.Link')
                    label=object.getDisplayLabel;
                    type=getString(message('Slvnv:slreq:Link'));
                    surfix=[type,': ',label];

                elseif isstruct(object)&&~isempty(object.id)
                    adpManager=slreq.adapters.AdapterManager.getInstance;
                    adp=adpManager.getAdapterByDomain(object.domain);
                    artifact=object.artifactUri;
                    label=adp.getSummary(artifact,object.id);
                    surfix=label;
                else





                    if isa(object,'slreq.data.RequirementSet')||...
                        isa(object,'slreq.data.LinkSet')
                        filePath=object.filepath;
                    elseif dig.isProductInstalled('Simulink')&&is_simulink_handle(object)
                        filePath=get(object,'filename');
                    elseif isstruct(object)&&isempty(object.id)
                        filePath=object.artifactUri;
                    else
                        filePath=object;
                    end

                    fileHandler=slreq.uri.FilePathHelper(filePath);
                    surfix=fileHandler.getShortName();
                end

                if length(surfix)>this.WINDOW_TITLE_SURFIX_MAXLENGTH
                    surfix=[surfix(1:this.WINDOW_TITLE_SURFIX_MAXLENGTH),'...'];
                end

                windowTitle=[this.PAGE_TITLE,' - ',surfix];
            catch ex
                warning('fail to get window title, use the default one');
                windowTitle=this.PAGE_TITLE;

            end
        end

        function openWindow(this,targetObj)
















            viewId=slreq.internal.tracediagram.utils.DiagramManager.getViewId(targetObj);

            if this.isDebug
                viewIdToWindow=this.ViewIdToDebugWindow;
            else
                viewIdToWindow=this.ViewIdToWindow;
            end

            if isKey(viewIdToWindow,viewId)
                windowObj=viewIdToWindow(viewId);
                winInstance=windowObj.getOrCreateDiagramWindow();

            else
                objectInfo.obj=targetObj;
                if isa(targetObj,'slreq.data.RequirementSet')||...
                    isa(targetObj,'slreq.data.LinkSet')||...
                    isstruct(targetObj)&&isempty(targetObj.id)||...
                    ischar(targetObj)
                    objectInfo.isArtifact=true;
                else
                    objectInfo.isArtifact=false;
                end






                this.ViewIdToObjectInfo(viewId)=objectInfo;
                windowTitle=this.getWindowTitle(objectInfo.obj);
                windowObj=slreq.internal.tracediagram.utils.DiagramWindow.show(viewId,windowTitle);
                viewIdToWindow(viewId)=windowObj;%#ok<NASGU>
                winInstance=windowObj.getOrCreateDiagramWindow();
            end

            if winInstance.isVisible
                winInstance.bringToFront();
            else
                winInstance.show();
            end
        end

        function out=isDebug(~)
            out=evalin('base',...
            'exist(''slreqtracediagramDebug'',''var'') == 1')&&...
            evalin('base','slreqtracediagramDebug');
        end

        function closeWindow(this,viewId)
            if isKey(this.ViewIdToWindow,viewId)
                windowObj=this.ViewIdToWindow(viewId);
                windowObj.delete;
            end

            if isKey(this.ViewIdToDebugWindow,viewId)
                windowObj=this.ViewIdToWindow(viewId);
                windowObj.delete;
            end
        end

        function closeAll(this)
            closeAllWindowInstances(this.ViewIdToDebugWindow);
            closeAllWindowInstances(this.ViewIdToWindow);
        end

        function graph=generateGraphFromViewId(this,targetViewId)


            dataObjInfo=this.getObjectInfoFromViewId(targetViewId);
            if isempty(dataObjInfo)

                error('Invalid view Id, diagram manager changed in memory');
            end

            dataObj=dataObjInfo.obj;
            if~ischar(dataObj)&&ishandle(dataObj)&&~isvalid(dataObj)


                err=MException(message('Slvnv:slreq_tracediagram:ErrorInvalidViewID'));
                throw(err);
            end

            if dataObjInfo.isArtifact
                graph=slreq.internal.tracediagram.data.ArtifactGraph(targetViewId);
            else
                graph=slreq.internal.tracediagram.data.ElementGraph(targetViewId);
            end

            graph.setStartingPoint(dataObj);

        end
    end

    methods(Static)

        function result=exists()
            instance=slreq.internal.tracediagram.utils.DiagramManager.getInstance(false);
            result=~isempty(instance)&&isvalid(instance);
        end

        function closeAllWindows()

            if slreq.internal.tracediagram.utils.DiagramManager.exists()
                windowMgr=slreq.internal.tracediagram.utils.DiagramManager.getInstance();
                windowMgr.closeAll();
            end
        end

        function out=getInstance(doInit)
            persistent diagramManager

            if nargin<1
                doInit=true;
            end

            if(isempty(diagramManager)||~isvalid(diagramManager))&&doInit
                diagramManager=slreq.internal.tracediagram.utils.DiagramManager();
            end

            out=diagramManager;
        end

        function viewId=getViewId(itemInfo)
            if isa(itemInfo,'slreq.data.Link')
                targetNode=itemInfo.source;
            elseif isa(itemInfo,'slreq.data.LinkSet')
                targetNode=itemInfo.artifact;
            else
                targetNode=itemInfo;
            end

            itemId=slreq.internal.tracediagram.data.Node.getNodeKey(targetNode);
            viewId=slreq.utils.getMD5hash(itemId);
        end
    end

end

function closeAllWindowInstances(viewIdToWindow)
    allViewIds=viewIdToWindow.keys;
    for index=1:length(allViewIds)
        viewId=allViewIds{index};
        cWindowObj=viewIdToWindow(viewId);
        viewIdToWindow.remove(viewId);
        cWindowObj.delete;
    end
end
