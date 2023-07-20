classdef PointerMixin<handle





    properties(Access=private)
        DataTipClass='matlab.graphics.shape.internal.ScribePeer';
        DataAnnotatableClass='matlab.graphics.chart.interaction.DataAnnotatable';
        RulerClass='matlab.graphics.axis.decorator.Ruler';
        CategoricalRulerClass='matlab.graphics.axis.decorator.CategoricalRuler';
        AxesToolbarClass='matlab.ui.controls.AxesToolbar';
        AxesClass='matlab.graphics.axis.AbstractAxes';
        ImageClass='matlab.graphics.primitive.Image';
    end

    properties
        OriginalPointer;
        FigureModeChangeListener;
        CacheInvisibleAxes;
        PointerModeChangeStrategy;
    end

    methods(Access={?matlab.graphics.controls.ToolbarController,?tPointerMixin})
        function setPointerStrategy(obj,type)
            if~isempty(obj.PointerModeChangeStrategy)
                delete(obj.PointerModeChangeStrategy);
            end

            if strcmp(type,'figure')
                strategy=matlab.graphics.controls.internal.FigurePointerModeStrategy;
            elseif strcmp(type,'axes')
                strategy=matlab.graphics.controls.internal.AxesPointerModeStrategy;
            else
                strategy=matlab.graphics.controls.internal.FigurePointerModeStrategy;
            end

            obj.PointerModeChangeStrategy=strategy;
        end
    end

    methods(Access={?tPointerMixin})
        function result=hasDisabledInteractions(obj,eventData,fig)
            result=false;



            if~isprop(eventData,'Primitive')
                return
            end

            ax=ancestor(eventData.Primitive,obj.AxesClass);

            if isempty(ax)
                ax=obj.getInvisibleAxes(eventData);
            end



            dt=ancestor(eventData.Primitive,obj.DataTipClass);
            if isempty(ax)&&~isempty(dt)
                ax=obj.getAxesFromDataTip(dt);
            end

            if~isempty(ax)&&isa(ax,'matlab.graphics.axis.AbstractAxes')



                result=strcmp(ax.InteractionContainer.Enabled,'off')||...
                strcmp(ax.InteractionsMode,'manual')||strcmp(ax.InteractionContainer_I.InteractionsArrayMode,'manual');
            end



            if~isempty(ax)&&~matlab.ui.internal.isUIFigure(fig)
                result=result||((strcmp(fig.ToolBar,'none')&&strcmp(fig.ToolBarMode,'manual'))...
                ||(strcmp(fig.MenuBar,'none')&&strcmp(fig.MenuBarMode,'manual'))&&strcmp(fig.ToolBar,'auto'));
            end

        end

        function ax=getAxesFromDataTip(obj,datatip)
            fig=ancestor(datatip,'matlab.ui.Figure');
            hTip=findobj(fig,'Type','DataTip');


            ind=arrayfun(@(h)h.getPointDataTip.LocatorHandle.ScribeHost.PeerHandle==datatip,hTip);

            retObj=hTip(ind);

            ax=ancestor(retObj,obj.AxesClass);
        end

        function axes=getInvisibleAxes(obj,eventData)
            axes=matlab.graphics.axis.Axes.empty;

            if isa(eventData,'matlab.graphics.controls.internal.InvisibleAxesEnterExitEventData')
                if strcmp(eventData.Direction,'mouseenter')
                    axes=eventData.Axes;
                    obj.CacheInvisibleAxes=axes;
                else
                    obj.CacheInvisibleAxes=[];
                end
            end
        end

        function result=allowsPanBeforeZoom(obj,hitObj)
            result=true;




            if isa(hitObj,obj.CategoricalRulerClass)
                result=false;
                return;
            end

            ax=ancestor(hitObj,obj.AxesClass);

            if~isempty(ax)
                result=isempty(findobj(ax,'-isa',obj.ImageClass,'-depth',1));
            end

        end

        function result=hasUserModifiedPointer(~,fig)
            result=strcmp(fig.PointerMode,'manual');
        end

        function hitObj=getHitObject(obj,eventData)


            if~isprop(eventData,'Primitive')
                hitObj=matlab.graphics.axis.Axes.empty;
                return
            end


            hitPrim=eventData.Primitive;



            hitObj=ancestor(hitPrim,obj.DataTipClass);

            if isempty(hitObj)

                hitObj=ancestor(hitPrim,obj.DataAnnotatableClass);
            end

            if isempty(hitObj)

                hitObj=ancestor(hitPrim,obj.RulerClass);
            end

            if isempty(hitObj)

                hitObj=ancestor(hitPrim,obj.AxesToolbarClass);
            end

            if isempty(hitObj)

                hitObj=ancestor(hitPrim,obj.AxesClass);
            end

            if isempty(hitObj)

                hitObj=obj.getInvisibleAxes(eventData);
            end

            if isempty(hitObj)


                hitObj=obj.CacheInvisibleAxes;
            end
        end

        function result=getAxes3D(~,ax)



            result=~isempty(ax)&&~is2D(ax);
        end

        function[pan,rotate,datatip]=getEnabledByBehavior(obj,hitObj)

            dataTipBehavior=hggetbehavior(hitObj,'DataCursor','-peek');

            ax=hitObj;

            if~isa(hitObj,obj.AxesClass)
                ax=ancestor(hitObj,obj.AxesClass);
            end

            panBehavior=hggetbehavior(ax,'Pan','-peek');
            rotateBehavior=hggetbehavior(ax,'Rotate3d','-peek');


            pan=isempty(panBehavior)||panBehavior.Enable;
            rotate=isempty(rotateBehavior)||rotateBehavior.Enable;
            datatip=isempty(dataTipBehavior)||dataTipBehavior.Enable;
        end

        function pointer=getPointerFromObject(obj,hitObj,isWebFigure)

            pointer=obj.OriginalPointer;

            ax=ancestor(hitObj,obj.AxesClass);
            is3d=obj.getAxes3D(ax);

            [panEnabled,rotateEnabled,datatipEnabled]=obj.getEnabledByBehavior(hitObj);

            if isa(hitObj,obj.DataTipClass)&&datatipEnabled
                pointer='datacursor';
            end

            if isa(hitObj,obj.DataAnnotatableClass)
                if isa(ax,'matlab.graphics.axis.PolarAxes')
                    pointer='arrow';
                elseif datatipEnabled
                    pointer='datacursor';
                end
            end

            if isa(hitObj,obj.AxesToolbarClass)
                pointer='arrow';
            end

            if isa(hitObj,obj.RulerClass)&&...
                isa(hitObj.Parent,obj.AxesClass)

                if panEnabled
                    switch(hitObj.Axis)
                    case 0
                        if is3d
                            pointer='pan_x';
                        else
                            pointer='pan_horizontal';
                        end
                    case 1
                        if is3d
                            pointer='pan_y';
                        else
                            pointer='pan_vertical';
                        end
                    case 2
                        pointer='pan_z';
                    end
                end


                if isWebFigure
                    pointer=obj.OriginalPointer;
                end

                if isa(ax,'matlab.graphics.axis.GeographicAxes')||...
                    isa(ax,'matlab.graphics.axis.PolarAxes')
                    pointer='arrow';
                end
            end

            if isa(hitObj,obj.AxesClass)
                if is3d&&rotateEnabled
                    pointer='rotate';
                elseif~is3d&&panEnabled
                    pointer='arrow';
                end

                if isa(hitObj,'matlab.graphics.axis.PolarAxes')
                    pointer='arrow';
                end
            end

            if~obj.allowsPanBeforeZoom(hitObj)
                pointer='arrow';
            end
        end


        function handleModeChanged(obj,sourceObj,eventData)
            obj.PointerModeChangeStrategy.handleModeChange(sourceObj,eventData);
        end

        function result=isModeEnabled(obj,sourceObj,eventData)
            result=obj.PointerModeChangeStrategy.isModeEnabled(sourceObj,eventData);
        end

        function createModeListener(obj,sourceObj,eventData)
            obj.PointerModeChangeStrategy.createModeListener(sourceObj,eventData);
        end
    end

    methods(Access=public)
        function updatePointer(obj,source,eventData)


            fig=ancestor(source,'matlab.ui.Figure');
            isWebFigure=matlab.ui.internal.isUIFigure(fig);

            if obj.hasUserModifiedPointer(fig)||...
                obj.isModeEnabled(source,eventData)
                return
            elseif isWebFigure&&isdeployed


                return
            end

            obj.createModeListener(source,eventData);

            if isempty(obj.OriginalPointer)
                obj.OriginalPointer=fig.Pointer;
            end



            if obj.hasDisabledInteractions(eventData,fig)
                return
            end

            hitObj=obj.getHitObject(eventData);


            if~isempty(hitObj)
                pointer=obj.getPointerFromObject(hitObj,isWebFigure);
            else
                pointer=obj.OriginalPointer;
            end



            matlab.graphics.interaction.internal.setPointer(fig,pointer);
        end

        function delete(obj)
            if isvalid(obj)
                delete(obj.PointerModeChangeStrategy);
            end
        end
    end
end

