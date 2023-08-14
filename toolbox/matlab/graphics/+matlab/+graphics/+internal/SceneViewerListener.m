









classdef SceneViewerListener<JavaVisible
    methods
        function this=SceneViewerListener(selectedObjects)
            this.init(selectedObjects);
        end

        function init(this,selectedObjects)


            this.SelectedObjects=selectedObjects;
            this.SceneViewers=matlab.graphics.internal.SceneViewerListener.gcv(selectedObjects);
            delete(this.Listeners)
            this.Listeners=event.listener.empty;
            for k=1:length(this.SceneViewers)
                this.Listeners(k)=event.listener(this.SceneViewers(k),'PostUpdate',@(es,ed)refresh(this));
                setappdata(this.SceneViewers(k),'SceneViewerListener',this.Listeners(k));
            end


            this.ContainerSizeChangeListeners=event.listener.empty;
            sizeChangableContainerObjects=selectedObjects(cellfun(@(x)ishghandle(x)&&...
            isa(x,'matlab.ui.internal.mixin.CanvasHostMixin'),selectedObjects));
            delete(this.ContainerSizeChangeListeners)
            delete(this.ContainerLocationChangeListeners)
            for k=1:length(sizeChangableContainerObjects)
                this.ContainerSizeChangeListeners(k)=...
                event.listener(sizeChangableContainerObjects{k},'SizeChanged',@(es,ed)refresh(this));
                this.ContainerLocationChangeListeners(k)=...
                event.listener(sizeChangableContainerObjects{k},'LocationChanged',@(es,ed)refresh(this));
            end
        end

        function refresh(this)




            IdeletedObjects=cellfun(@(x)~isvalid(x),this.SelectedObjects);
            if any(IdeletedObjects)
                this.SelectedObjects(IdeletedObjects)=[];
            end



            if~isequal(this.SceneViewers,matlab.graphics.internal.SceneViewerListener.gcv(this.SelectedObjects))
                delete(this.Listeners);
                delete(this.ContainerSizeChangeListeners);
                this.init(this.SelectedObjects);
            end


            com.mathworks.mde.inspector.Inspector.doRefresh;
        end
    end
    methods(Static)

        function svArray=gcv(selectedObjects)


            svArray=gobjects(0);
            for k=1:length(selectedObjects)
                if isobject(selectedObjects{k})&&ishghandle(selectedObjects{k})
                    canvasContainer=ancestor(selectedObjects{k},'matlab.ui.internal.mixin.CanvasHostMixin');

                    if~isempty(canvasContainer)
                        try
                            svArray(k)=canvasContainer.getCanvas;
                        catch ex


                            if strcmp(ex.identifier,'MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality')
                                if isprop(canvasContainer,'Canvas')
                                    svArray(k)=canvasContainer.Canvas;
                                end
                            else
                                rethrow(ex);
                            end
                        end
                    end
                end
            end
            svArray=unique(svArray);
        end



        function state=isRenderedMCOSGraphic(selectedObjects)
            for k=1:length(selectedObjects)
                if isobject(selectedObjects{k})&&ishghandle(selectedObjects{k})&&...
                    ~isempty(ancestor(selectedObjects{k},'matlab.ui.internal.mixin.CanvasHostMixin'))
                    state=true;
                    return
                end
            end
            state=false;
        end

        function beingDeleted=isBeingDeleted(selectedObject)
            if~isvalid(selectedObject)
                beingDeleted=true;
            elseif isprop(selectedObject,'BeingDeleted')&&strcmp('on',selectedObject.BeingDeleted)
                beingDeleted=true;
            elseif~isempty(ancestor(selectedObject,'figure'))&&strcmp('on',get(ancestor(selectedObject,'figure'),'BeingDeleted'))
                beingDeleted=true;
            else
                beingDeleted=false;
            end
        end

    end

    properties
        SelectedObjects=[];
        Listeners=event.listener.empty;
        ContainerSizeChangeListeners=event.listener.empty;
        ContainerLocationChangeListeners=event.listener.empty;
        SceneViewers=matlab.graphics.primitive.canvas.JavaCanvas.empty;
    end
end
