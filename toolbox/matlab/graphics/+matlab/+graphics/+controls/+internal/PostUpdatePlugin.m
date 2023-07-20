classdef PostUpdatePlugin<handle



    properties(Access=protected)
PostUpdateListener
ProcessInteractionsListener
    end

    methods(Static)
        function doCacheLoad(canvasParent)

            if isempty(canvasParent)||~ishghandle(canvasParent)||...
                strcmp(canvasParent.BeingDeleted,'on')
                return
            end
            canvas=canvasParent.getCanvas();





            if~isa(canvas.NodeParent,'matlab.ui.container.internal.UIFlowContainer')...
                &&~isa(canvas.NodeParent,'matlab.ui.container.internal.UIGridContainer')

                ap=matlab.graphics.annotation.internal.getDefaultCamera(canvas.NodeParent,'overlay','-peek');



                if isempty(ap)
                    matlab.graphics.shape.internal.AnnotationPane('Parent',canvas.NodeParent,'Serializable','off');
                end
            end



            b=matlab.graphics.shape.internal.Button;
            bi=matlab.graphics.shape.internal.ButtonImage;
            iv=matlab.graphics.shape.internal.image.IconView;
            pb=matlab.ui.controls.ToolbarPushButton;
            sb=matlab.ui.controls.ToolbarStateButton;
            delete(b);
            delete(bi);
            delete(iv);
            delete(pb);
            delete(sb);



            x=[-1.8212,-1.5125,0.0715,0.4007
            -1.5195,0.5332,-0.6983,0.2459
            0.9606,0.7719,0.0159,-0.3897
            -2.8920,-1.9953,0.8494,1.9225];
            x\x;
        end

        function doProcessInteractions(canvasParent)


            if isempty(canvasParent)||~ishghandle(canvasParent)||...
                strcmp(canvasParent.BeingDeleted,'on')
                return
            end
            canvas=canvasParent.getCanvas();
            if~isempty(canvas)&&~isprop(canvas,'CanvasReadyForInteraction')
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.processQueuedDefaultInteractionInitialization(canvas);
            end
        end

        function doPostUpdateFcnForTest(canvasParent)





            canvas=canvasParent.getCanvas();
            if isempty(canvas)||isprop(canvas,'CanvasReadyForInteraction')
                return
            end
            matlab.graphics.controls.internal.PostUpdatePlugin.doProcessInteractions(canvasParent);
        end
    end

    methods
        function obj=PostUpdatePlugin(canvas,toolbarController)
            if~usejava('awt')||matlab.graphics.interaction.internal.isPublishingTest()||...
                ~matlab.ui.internal.hasDisplay||~matlab.ui.internal.isFigureShowEnabled
                return;
            end




            if~isdeployed
                obj.PostUpdateListener=addlistener(canvas,'PostUpdate',@(sourceObj,evtData)obj.cacheLoad(sourceObj));
                obj.ProcessInteractionsListener=addlistener(toolbarController,...
                'ProcessInteractions',@(sourceObj,evtData)obj.processInteractions(evtData.Canvas));
            end
        end

        function processInteractions(obj,canvas)

            if isempty(canvas)||~isvalid(canvas)||isAxesToolbarExcluded(ancestor(canvas,'figure'),canvas)
                return;
            end



            canvasParent=localGetCanvasContainingAncestor(canvas);
            if~isempty(canvasParent)&&isvalid(canvasParent)&&...
                strcmp(canvasParent.BeingDeleted,'off')&&~isprop(canvas,'CanvasReadyForInteraction')
                tbFcn=@()matlab.graphics.controls.internal.PostUpdatePlugin.doProcessInteractions(canvasParent);
                builtin('_dtcallback',tbFcn,internal.matlab.datatoolsservices.getSetCmdExecutionTypeIdle);
            end




            delete(obj.ProcessInteractionsListener);
            obj.ProcessInteractionsListener=[];



            if isempty(obj.ProcessInteractionsListener)&&...
                isempty(obj.PostUpdateListener)
                delete(obj);
            end
        end

        function cacheLoad(obj,canvas)

            if isempty(canvas)||~isvalid(canvas)||isAxesToolbarExcluded(ancestor(canvas,'figure'),canvas)
                return;
            end


            canvasParent=localGetCanvasContainingAncestor(canvas);
            if~isempty(canvasParent)&&isvalid(canvasParent)&&strcmp(canvasParent.BeingDeleted,'off')
                tbFcn=@()matlab.graphics.controls.internal.PostUpdatePlugin.doCacheLoad(canvasParent);
                builtin('_dtcallback',tbFcn,internal.matlab.datatoolsservices.getSetCmdExecutionTypeIdle);
            end


            delete(obj.PostUpdateListener);
            obj.PostUpdateListener=[];



            if isempty(obj.ProcessInteractionsListener)&&...
                isempty(obj.PostUpdateListener)
                delete(obj);
            end
        end
    end
end

function state=isAxesToolbarExcluded(fig,axesContainer)




    canvasContainer=ancestor(axesContainer,'matlab.ui.internal.mixin.CanvasHostMixin');

    state=true;

    if~isempty(fig)&&isvalid(fig)
        state=(((strcmp(fig.ToolBar,'none')&&strcmp(fig.ToolBarMode,'manual'))...
        ||(strcmp(fig.MenuBar,'none')&&strcmp(fig.MenuBarMode,'manual'))&&strcmp(fig.ToolBar,'auto'))||...
        isa(canvasContainer,'matlab.ui.container.internal.UIFlowContainer')||...
        isa(canvasContainer,'matlab.ui.container.internal.UIGridContainer'));
    end
end

function canvasContainingAncestor=localGetCanvasContainingAncestor(target)
    canvasContainingAncestor=ancestor(target,'matlab.ui.internal.mixin.CanvasHostMixin');
    if isempty(canvasContainingAncestor)
        canvasContainingAncestor=ancestor(target,'figure');
    end
end