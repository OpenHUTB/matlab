classdef DAStudioHelper<handle






    properties
        Studio=[];
    end

    properties(Dependent)
        AllEditors;
        ActiveEditor;
        TopModelHandle;
        ActiveModelHandle;
        OpenedModelHandles;
        CurrentCanvasHandle;
        AllOpenedCanvasHandles;
        App;
        CanvasModelBlockHandle;
    end

    methods(Access=private)

        function this=DAStudioHelper(target)
            if isa(target,'GLUE2.Editor')
                this.Studio=target.getStudio;
            elseif isa(target,'DAS.Studio')
                this.Studio=target;
            end

        end
    end

    methods


        function app=get.App(this)
            app=this.Studio.App;
        end

        function modelH=get.TopModelHandle(this)
            modelH=this.Studio.App.blockDiagramHandle;
        end


        function editor=get.ActiveEditor(this)
            editor=this.Studio.App.getActiveEditor;
        end


        function modelH=get.ActiveModelHandle(this)
            editor=this.ActiveEditor;
            modelH=getDiagramForEditor(editor);
        end


        function modelHs=get.OpenedModelHandles(this)
            allEditors=this.AllEditors;
            modelHs=[];
            for eindex=1:length(allEditors)
                cEditor=allEditors(eindex);
                canvasRootHandle=getDiagramForEditor(cEditor);
                modelHs=unique([modelHs,canvasRootHandle]);
            end
        end


        function canvasHandle=get.CurrentCanvasHandle(this)
            editor=this.ActiveEditor;
            canvasHandle=this.getCanvasHandle(editor);
        end


        function trueOrFalse=isCurrentCanvasStateflow(this)
            editor=this.ActiveEditor;
            diagram=editor.getDiagram;
            trueOrFalse=isa(diagram,'StateflowDI.Subviewer');
        end


        function trueOrFalse=isCurrentCanvasFromSSRefInstance(this)


            canvasHandle=this.CurrentCanvasHandle;
            isSf=this.isCurrentCanvasStateflow;

            isBlockDiagram=~isSf&&strcmpi(get_param(canvasHandle,'Type'),'block_diagram');











            trueOrFalse=~isBlockDiagram...
            &&(~isempty(rmisl.getRefSidFromObjSSRefInstance(canvasHandle,isSf))...
            ||(~isSf&&~isempty(get_param(canvasHandle,'ReferencedSubsystem'))));
        end


        function bringStudioToTop(this)
            this.Studio.raise;
        end


        function canvasModelBlockHandle=get.CanvasModelBlockHandle(this)
            editor=this.ActiveEditor;
            canvasModelBlockHandle=this.getCanvasModelBlockHandle(editor);
        end



        function allEditors=get.AllEditors(this)
            allEditors=this.Studio.App.getAllEditors;
        end


        function allCanvasHandles=get.AllOpenedCanvasHandles(this)
            allCanvasHandles=[];
            allEditors=this.AllEditors;
            for editor=allEditors
                allCanvasHandles(end+1)=this.getCanvasHandle(editor);%#ok<AGROW>
            end
        end
    end

    methods(Static)

        function out=createHelper(target)
            if nargin<1
                target=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            end

            if isempty(target)
                out=slreq.utils.DAStudioHelper.empty;
            else
                out=slreq.utils.DAStudioHelper(target(1));
            end
        end


        function canvasHandle=getCanvasHandle(editor)
            cDiagram=editor.getDiagram;
            if isa(cDiagram,'StateflowDI.Subviewer')

                canvasHandle=double(cDiagram.backendId);
            elseif isa(cDiagram,'InterfaceEditor.Diagram')



                canvasHandle=cDiagram.Model.SLGraphHandle;
            elseif isa(cDiagram,'SA_M3I.StudioAdapterDiagram')
                canvasHandle=double(cDiagram.blockHandle);
            else

                canvasHandle=double(cDiagram.handle);
            end
        end


        function blockHandle=getCanvasModelBlockHandle(editor)
            hid=editor.getHierarchyId;
            pid=GLUE2.HierarchyService.getParent(hid);
            if(GLUE2.HierarchyService.isValid(pid))
                m3iobj=GLUE2.HierarchyService.getM3IObject(pid);
                block=m3iobj.temporaryObject;
                blockHandle=block.handle;
            end

        end


        function allRootHandles=getReferencingModels(modelH,activeOnly)


            if nargin<2
                activeOnly=true;
            end
            allRootHandles=[];

            allStudios=slreq.utils.DAStudioHelper.getAllStudios;
            for cStudio=allStudios
                studioHelper=slreq.utils.DAStudioHelper.createHelper(cStudio);
                rootHandle=studioHelper.TopModelHandle;
                if rootHandle~=modelH
                    if activeOnly
                        canvasHandle=studioHelper.ActiveModelHandle;
                        if canvasHandle==modelH
                            allRootHandles=[allRootHandles,rootHandle];%#ok<AGROW>
                        end
                    else
                        allCanvasModels=studioHelper.AllOpenedCanvasHandles;
                        if any(allCanvasModels==modelH)


                            allRootHandles=unique([allRootHandles,rootHandle]);
                        end
                    end
                end
            end
            allRootHandles=unique(allRootHandles);
        end


        function allRefHandles=getRefModelInStudio(modelH)



            allRefHandles=[];
            allStudios=DAS.Studio.getAllStudios;
            for sindex=1:length(allStudios)
                cStudio=allStudios{sindex};
                studioHelper=slreq.utils.DAStudioHelper.createHelper(cStudio);
                rootHandle=studioHelper.TopModelHandle;
                if rootHandle==modelH
                    allCanvasHandle=studioHelper.OpenedModelHandles;
                    allRefHandles=allCanvasHandle(allCanvasHandle~=rootHandle);
                end
            end
        end


        function[modelHandle,canvasHandle,canvasModelHandle,studio]=getCurrentBDHandle
            modelHandle=[];
            canvasHandle=[];
            canvasModelHandle=[];
            studio=[];

            studioHelper=slreq.utils.DAStudioHelper.createHelper();

            if~isempty(studioHelper)
                modelHandle=studioHelper.TopModelHandle;
                canvasHandle=studioHelper.CurrentCanvasHandle;
                canvasModelHandle=studioHelper.ActiveModelHandle;
                studio=studioHelper.Studio;
            end
        end


        function[studios,topModelList]=getActiveStudios(modelH,considerHarness)






            topModelList=[];
            studios=DAS.Studio.empty;
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if ischar(modelH)&&dig.isProductInstalled('Simulink')&&is_simulink_loaded
                try
                    modelH=get_param(modelH,'Handle');
                catch ex %#ok<NASGU>
                    studios=[];
                    return;
                end
            end

            for cStudio=allStudios
                cStudioHelper=slreq.utils.DAStudioHelper.createHelper(cStudio);
                activeHandle=cStudioHelper.ActiveModelHandle;
                if isempty(activeHandle)


                    continue;
                end
                if considerHarness


                    activeHandle=rmisl.getOwnerModelFromHarness(activeHandle);
                end

                if activeHandle==modelH
                    studios(end+1)=cStudio;%#ok<AGROW>
                    topModelList(end+1)=cStudioHelper.TopModelHandle;%#ok<AGROW>
                    continue
                end
            end
        end


        function currentModelH=getCurrentCanvasModelHandle(rootModelHandle,considerHarness)

            if considerHarness


                rootModelHandle=rmisl.getOwnerModelFromHarness(rootModelHandle);
            end

            currentModelH=[];
            if ischar(rootModelHandle)
                if dig.isProductInstalled('Simulink')&&is_simulink_loaded
                    try
                        rootModelHandle=get_param(rootModelHandle,'Handle');
                    catch ex %#ok<NASGU>
                        currentModelH=[];
                        return;
                    end
                else
                    currentModelH=[];
                    return;
                end
            end

            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            for cStudio=allStudios
                cStudioHelper=slreq.utils.DAStudioHelper.createHelper(cStudio);
                if cStudioHelper.TopModelHandle==rootModelHandle

                    currentModelH=cStudioHelper.ActiveModelHandle;
                    if considerHarness
                        currentModelH=rmisl.getOwnerModelFromHarness(currentModelH);
                    end
                    return;
                end
            end

        end



        function[studios,rootModels]=getAllStudios(modelH,rootOnly)
            if nargin<1
                modelH='';
            end
            rootModels=[];

            if nargin<2
                rootOnly=true;
            end
            studios=DAS.Studio.empty;
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if isempty(modelH)
                studios=allStudios;
            else
                if ischar(modelH)
                    if dig.isProductInstalled('Simulink')&&is_simulink_loaded
                        try
                            modelH=get_param(modelH,'Handle');
                        catch ex %#ok<NASGU>
                            studios=[];
                            return;
                        end
                    else
                        studios=[];
                        return;
                    end
                end

                for cStudio=allStudios
                    cStudioHelper=slreq.utils.DAStudioHelper.createHelper(cStudio);

                    if rootOnly
                        if cStudioHelper.TopModelHandle==modelH
                            studios(end+1)=cStudio;%#ok<AGROW>
                            continue;
                        end
                    else
                        if any(cStudioHelper.OpenedModelHandles==modelH)
                            studios(end+1)=cStudio;%#ok<AGROW>
                            rootModels(end+1)=cStudioHelper.TopModelHandle;%#ok<AGROW>
                            continue;
                        end
                    end
                end
            end
        end


        function modelHs=getModelsToHideReqInfo(modelH)


            modelHs=[];
            allUsingModelHandles=slreq.utils.DAStudioHelper.getReferencingModels(modelH);
            allOtherModelHs=allUsingModelHandles(allUsingModelHandles~=modelH);
            disableOwnerBadge=true;

            for index=1:length(allOtherModelHs)
                if slreq.utils.isInPerspective(allOtherModelHs(index),false)
                    disableOwnerBadge=false;
                    break;
                end
            end

            if disableOwnerBadge
                modelHs(end+1)=modelH;
            end

            allRefedModels=slreq.utils.DAStudioHelper.getRefModelInStudio(modelH);

            for index=1:length(allRefedModels)
                cRefModel=allRefedModels(index);

                disableThisBadge=true;
                allUsingModelHandles=slreq.utils.DAStudioHelper.getReferencingModels(cRefModel,false);
                allUsingModelHandles=unique([cRefModel,allUsingModelHandles]);
                for cUsingModelH=allUsingModelHandles
                    if slreq.utils.isInPerspective(cUsingModelH,false)
                        disableThisBadge=false;
                        break;
                    end
                end
                if disableThisBadge
                    modelHs(end+1)=cRefModel;%#ok<AGROW>
                end

            end

        end
    end
end

function diagramHandle=getDiagramForEditor(editor)
    if isempty(editor)
        diagramHandle=[];
        return;
    end
    diagram=editor.getDiagram;
    if isa(diagram,'StateflowDI.Subviewer')



        hid=editor.getHierarchyId;%#ok<NASGU>

        blockH=eval('StateflowDI.SFDomain.getSLHandleForHID(hid)');
        diagramHandle=bdroot(blockH);
    elseif isa(diagram,'InterfaceEditor.Diagram')



        diagramHandle=bdroot(diagram.Model.SLGraphHandle);
    else


        diagramHandle=editor.blockDiagramHandle;
    end
end
