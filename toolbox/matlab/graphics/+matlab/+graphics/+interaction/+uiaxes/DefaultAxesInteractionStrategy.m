classdef(Sealed)DefaultAxesInteractionStrategy<matlab.graphics.interaction.uiaxes.InteractionStrategy



    properties(Transient)
        BoundZoomToExtentsOrOrigLimits=true;
        BoundPanAndZoomToImage=true;
    end

    methods
        function hObj=DefaultAxesInteractionStrategy()
            hObj@matlab.graphics.interaction.uiaxes.InteractionStrategy;
        end
    end


    methods(Sealed)
        function tf=isValidMouseEvent(~,obj,~,e)

            hManager=uigetmodemanager(obj.Figure);
            hMode=hManager.CurrentMode;
            modeactive=isobject(hMode)&&isvalid(hMode)&&~isempty(hMode);

            legendhit=matlab.graphics.interaction.internal.hitLegendWithDefaultButtonDownFcn(e);

            hitobject=gobjects(0);
            if~isempty(e.HitObject)&&isvalid(e.HitObject)
                hitobject=e.HitObject;
            end

            datatiptextboxhit=~isempty(hitobject)&&...
            isa(hitobject,'matlab.graphics.shape.internal.ScribePeer')&&...
            ~strcmp(hitobject.Tag,'TransientGraphicsTip');

            toolbarButtonHit=~isempty(hitobject)&&...
            ~isempty(ancestor(hitobject,'matlab.graphics.controls.AxesToolbarButton'));

            handlevisibilityoff=strcmp(obj.Axes.HandleVisibility,'off');
            hashardwarecallbacks=strcmp(obj.Axes.hasInteractionHint('HardwareCallbacks'),'on');

            tf=true;
            if modeactive||legendhit||datatiptextboxhit||...
                handlevisibilityoff||hashardwarecallbacks||...
toolbarButtonHit
                tf=false;
            end
        end

        function tf=isObjectHit(hObj,obj,~,e)




            ruler=matlab.graphics.interaction.internal.hitRuler(e);
            if(~isempty(ruler))
                tf=false;
                return;
            end

            axeslist=matlab.graphics.interaction.internal.hitAxes(obj.Figure,e);
            tf=any(axeslist==obj.Axes);

            if hObj.hitPolarAxes(obj,e)
                tf=true;
            end
        end

        function tf=hitPolarAxes(~,obj,e)
            tf=false;
            hitobject=gobjects(0);
            if~isempty(e.HitObject)&&isvalid(e.HitObject)
                hitobject=e.HitObject;
            end
            hitpolaraxes=ancestor(hitobject,'polaraxes');
            if hitpolaraxes==obj.Axes
                tf=true;
            end
        end



        function setPanLimits(hObj,hAxes,x,y,z)
            is2d=nargin<5;




            if isempty(hAxes.InteractionContainer.PanDisabled)
                panBehave=hggetbehavior(hAxes,'Pan','-peek');
                if~isempty(panBehave)&&~panBehave.Enable
                    hAxes.InteractionContainer.PanDisabled=true;
                else
                    hAxes.InteractionContainer.PanDisabled=false;
                end
            end

            if~isempty(hAxes.InteractionContainer.PanDisabled)&&hAxes.InteractionContainer.PanDisabled
                return
            end

            if is2d
                if isempty(hAxes.InteractionContainer.PanConstraint2D)
                    fig=ancestor(hAxes,'figure');
                    panMode=getuimode(fig,'Exploration.Pan');
                    panBehave=hggetbehavior(hAxes,'Pan','-peek');
                    hAxes.InteractionContainer.PanConstraint2D=hObj.getPanConstraint2D(panBehave,panMode);
                end

                [newx,newy]=hObj.constrain2DLimits(hAxes,hAxes.InteractionContainer.PanConstraint2D,x,y);
                hObj.setOriginalLimits(hAxes);
                hObj.setYYAxisInactiveYLimModeIfAuto(hAxes);
                setPanLimits@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,newx,newy);
            else
                if isempty(hAxes.InteractionContainer.PanConstraint3D)
                    panBehave=hggetbehavior(hAxes,'Zoom','-peek');
                    hAxes.InteractionContainer.PanConstraint3D=hObj.getConstraint3D(panBehave);
                end

                [newx,newy,newz]=hObj.constrain3DLimits(hAxes,hAxes.InteractionContainer.PanConstraint3D,x,y,z);
                hObj.setOriginalLimits(hAxes);
                setPanLimits@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,newx,newy,newz);
            end
        end

        function setZoomLimits(hObj,hAxes,x,y,z)
            is2d=nargin<5;

            if isempty(hAxes.InteractionContainer.ZoomDisabled)
                zoomBehave=hggetbehavior(hAxes,'Zoom','-peek');
                if~isempty(zoomBehave)&&(~zoomBehave.Enable||strcmp(zoomBehave.Version3D,'camera'))
                    hAxes.InteractionContainer.ZoomDisabled=true;
                else
                    hAxes.InteractionContainer.ZoomDisabled=false;
                end
            end

            if~isempty(hAxes.InteractionContainer.ZoomDisabled)&&hAxes.InteractionContainer.ZoomDisabled
                return
            end

            if is2d
                if isempty(hAxes.InteractionContainer.ZoomConstraint2D)
                    fig=ancestor(hAxes,'figure');
                    zoomMode=getuimode(fig,'Exploration.Zoom');
                    zoomBehave=hggetbehavior(hAxes,'Zoom','-peek');
                    hAxes.InteractionContainer.ZoomConstraint2D=hObj.getZoomConstraint2D(hAxes,zoomBehave,zoomMode);
                end

                [newx,newy]=hObj.constrain2DLimits(hAxes,hAxes.InteractionContainer.ZoomConstraint2D,x,y);
                hObj.setOriginalLimits(hAxes);
                hObj.setYYAxisInactiveYLimModeIfAuto(hAxes);
                setZoomLimits@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,newx,newy);

            else
                if isempty(hAxes.InteractionContainer.ZoomConstraint3D)
                    zoomBehave=hggetbehavior(hAxes,'Zoom','-peek');
                    hAxes.InteractionContainer.ZoomConstraint3D=hObj.getConstraint3D(zoomBehave);
                end

                [newx,newy,newz]=hObj.constrain3DLimits(hAxes,hAxes.InteractionContainer.ZoomConstraint3D,x,y,z);
                hObj.setOriginalLimits(hAxes);
                setZoomLimits@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,newx,newy,newz);
            end
        end

        function setView(hObj,hAxes,v)
            rotate_behave=hggetbehavior(hAxes,'Rotate3d','-peek');
            if isempty(rotate_behave)||rotate_behave.Enable
                hObj.setOriginalLimits(hAxes);
                setView@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,v);
            end
        end

        function setUntransformedZoomLimits(hObj,hAxes,hDataSpace,norm_xlim,norm_ylim,norm_zlim)
            is2d=nargin<6;

            boundtoextentsforimage=false;
            if hObj.BoundPanAndZoomToImage&&is2d
                boundtoextentsforimage=~isempty(findobj(hAxes,'Type','image'));
            end

            if boundtoextentsforimage
                bounds=getGraphicsExtents(hAxes);
                [norm_xlim,norm_ylim]=hObj.bound2DLimits(hDataSpace,norm_xlim,norm_ylim,bounds);
            elseif hObj.BoundZoomToExtentsOrOrigLimits
                origlims=getappdata(hAxes,'zoom_zoomOrigAxesLimits');
                if isempty(origlims)
                    origlims=matlab.graphics.interaction.getDoubleAxesLimits(hAxes);
                end

                extents=getGraphicsExtents(hAxes);
                bounds=matlab.graphics.interaction.internal.getWiderLimits(extents,origlims);
                if~is2d
                    [norm_xlim,norm_ylim,norm_zlim]=hObj.bound3DLimits(hDataSpace,norm_xlim,norm_ylim,norm_zlim,bounds);
                else
                    [norm_xlim,norm_ylim]=hObj.bound2DLimits(hDataSpace,norm_xlim,norm_ylim,bounds);
                end
            end

            if~is2d
                setUntransformedZoomLimits@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,hDataSpace,norm_xlim,norm_ylim,norm_zlim);
            else
                setUntransformedZoomLimits@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,hDataSpace,norm_xlim,norm_ylim);
            end
        end

        function setUntransformedPanLimits(hObj,hAxes,hDataSpace,norm_xlim,norm_ylim,norm_zlim)
            is2d=nargin<6;
            if hObj.BoundPanAndZoomToImage
                boundlimits=~isempty(findobj(hAxes,'Type','image'));
            end

            if boundlimits
                bounds=getGraphicsExtents(hAxes);
                if is2d
                    [norm_xlim,norm_ylim]=hObj.bound2DLimits(hDataSpace,norm_xlim,norm_ylim,bounds);
                end
            end

            if is2d
                setUntransformedPanLimits@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,hDataSpace,norm_xlim,norm_ylim);
            else
                setUntransformedPanLimits@matlab.graphics.interaction.uiaxes.InteractionStrategy(hObj,hAxes,hDataSpace,norm_xlim,norm_ylim,norm_zlim);
            end
        end
    end


    methods(Access=?tDefaultAxesInteractionStrategy)
        function setOriginalLimits(~,ax)
            matlab.graphics.interaction.internal.initializeView(ax);
        end

        function[newx,newy]=constrain2DLimits(~,hAxes,constraint,x,y)
            newx=x;
            newy=y;

            if~isempty(constraint)&&~strcmp(constraint,'unconstrained')
                if~contains(constraint,'x')
                    newx=hAxes.XLim;
                end
                if~contains(constraint,'y')
                    newy=hAxes.YLim;
                end
            end
        end

        function constraint=getPanConstraint2D(~,behavior,mode)
            if isempty(behavior)&&isempty(mode)
                constraint='unconstrained';
                return;
            end

            modeconstraint=[];
            if~isempty(mode)
                modeconstraint=mode.ModeStateData.style;
            end

            behaveconstraint=[];
            if~isempty(behavior)
                behaveconstraint=behavior.Constraint3D;
            end

            constraint=matlab.graphics.interaction.internal.reconcileAxesAndFigureConstraints(behaveconstraint,modeconstraint);
        end


        function constraint=getZoomConstraint2D(~,hAxes,behavior,mode)
            if isempty(behavior)&&isempty(mode)
                constraint='unconstrained';
                return;
            end

            modeconstraint='none';
            if~isempty(mode)
                modeconstraint=mode.ModeStateData.Constraint;
            end

            behaveconstraint=[];
            if~isempty(behavior)
                behaveconstraint=behavior.Constraint3D;
            end

            constraint=matlab.graphics.interaction.internal.zoom.chooseConstraint(hAxes,modeconstraint,behaveconstraint);
        end

        function[newx,newy,newz]=constrain3DLimits(~,hAxes,constraint,x,y,z)
            newx=x;
            newy=y;
            newz=z;

            if~isempty(constraint)&&~strcmp(constraint,'unconstrained')
                if~contains(constraint,'x')
                    newx=hAxes.XLim;
                end
                if~contains(constraint,'y')
                    newy=hAxes.YLim;
                end
                if~contains(constraint,'z')
                    newz=hAxes.ZLim;
                end
            end
        end

        function constraint=getConstraint3D(~,behavior)
            constraint='unconstrained';
            if~isempty(behavior)
                constraint=behavior.Constraint3D;
            end
        end

        function[norm_xlim,norm_ylim,norm_zlim]=bound3DLimits(~,hDataSpace,norm_xlim,norm_ylim,norm_zlim,bounds)
            [xbounds,ybounds,zbounds]=matlab.graphics.interaction.internal.TransformLimits(hDataSpace,bounds(1:2),bounds(3:4),bounds(5:6));
            xlimits=[0,1];
            ylimits=[0,1];
            zlimits=[0,1];

            isWithinBounds=matlab.graphics.interaction.internal.isWithinLimits(xlimits,xbounds)&&...
            matlab.graphics.interaction.internal.isWithinLimits(ylimits,ybounds)&&...
            matlab.graphics.interaction.internal.isWithinLimits(zlimits,zbounds);

            if isWithinBounds
                norm_xlim=matlab.graphics.interaction.internal.boundLimits(norm_xlim,xbounds,true);
                norm_ylim=matlab.graphics.interaction.internal.boundLimits(norm_ylim,ybounds,true);
                norm_zlim=matlab.graphics.interaction.internal.boundLimits(norm_zlim,zbounds,true);
            end
        end

        function[norm_xlim,norm_ylim]=bound2DLimits(~,hDataSpace,norm_xlim,norm_ylim,bounds)
            [xbounds,ybounds]=matlab.graphics.interaction.internal.TransformLimits(hDataSpace,bounds(1:2),bounds(3:4),[0,1]);
            xlimits=[0,1];
            ylimits=[0,1];

            isWithinBounds=matlab.graphics.interaction.internal.isWithinLimits(xlimits,xbounds)&&...
            matlab.graphics.interaction.internal.isWithinLimits(ylimits,ybounds);

            if isWithinBounds
                norm_xlim=matlab.graphics.interaction.internal.boundLimits(norm_xlim,xbounds,true);
                norm_ylim=matlab.graphics.interaction.internal.boundLimits(norm_ylim,ybounds,true);
            end
        end

        function setYYAxisInactiveYLimModeIfAuto(~,ax)
            if isscalar(ax.TargetManager)&&...
                numel(ax.TargetManager.Children)>1

                if ax.ActiveDataSpaceIndex==2
                    yyaxis(ax,'left');
                    ax.YLimMode='manual';
                    yyaxis(ax,'right');
                else
                    yyaxis(ax,'right');
                    ax.YLimMode='manual';
                    yyaxis(ax,'left');
                end
            end
        end
    end
end

