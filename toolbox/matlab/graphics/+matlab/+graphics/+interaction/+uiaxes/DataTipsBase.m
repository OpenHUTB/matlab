classdef DataTipsBase<matlab.graphics.interaction.uiaxes.InteractionBase



    properties
pixelPointEnter
prevLoc
        buffer=30
eventTimer_I
listeners
linger
objectListenerTarget
eventMoveName
eventDisableName
eventEnableName
eventScrollName
parentLayer
    end
    properties(Hidden,Access='protected')
        dataTipStyle matlab.graphics.shape.internal.util.PointDataTipStyle;
    end
    properties(Constant,Hidden,Access=?tDatatips)

        TIME=0.75;
    end

    properties(Dependent,Hidden)
EventTimer
    end

    properties(Access=protected)
        DataTipProvider matlab.graphics.interaction.uiaxes.DataTipProvider;
    end

    methods
        function hObj=DataTipsBase(ax,objectListenerTarget,eventMoveName,...
            eventDisableName,eventEnableName,eventScrollName)
            hObj=hObj@matlab.graphics.interaction.uiaxes.InteractionBase;

            hObj.Axes=ax;
            hObj.Figure=ancestor(ax,'figure');



            hObj.initializeBufferScale();

            hObj.objectListenerTarget=objectListenerTarget;
            hObj.eventMoveName=eventMoveName;
            hObj.eventDisableName=eventDisableName;
            hObj.eventEnableName=eventEnableName;
            hObj.eventScrollName=eventScrollName;
        end
    end

    methods

        function setDataTipProvider(hObj,hProvider)
            hObj.DataTipProvider=hProvider;
        end
        function hProvider=getDataTipProvider(hObj)
            hProvider=hObj.DataTipProvider;
        end

        function deleteTip(hObj)


            if~isempty(hObj.DataTipProvider)&&~isempty(hObj.DataTipProvider.get())&&isvalid(hObj.DataTipProvider.get())&&...
                strcmpi(hObj.DataTipProvider.get().PinnedView,'off')
                hObj.DataTipProvider.deleteTip();
                hObj.buffer=30;
            end
        end




        function[updateFcn,isEnabled]=behaviorCheck(~,target)
            isEnabled=true;
            updateFcn=[];
            bh=hggetbehavior(target,'DataCursor','-peek');
            if~isempty(bh)
                if~bh.Enable
                    isEnabled=false;
                else
                    updateFcn=bh.UpdateFcn;
                end
            end
        end



        function[updateFcnMode,interpolate,interpreter]=modeAccessorCheck(hObj,target)
            updateFcnMode=[];
            interpolate='off';
            interpreter='tex';



            fig=ancestor(target,'figure');
            if~isempty(fig)&&isprop(fig,'DataCursorState')&&~isempty(fig.DataCursorState)
                updateFcnMode=fig.DataCursorState.UpdateFcn;
                interpreter=fig.DataCursorState.Interpreter;
                if strcmp(fig.DataCursorState.SnapToDataVertex,'off')
                    interpolate='on';
                end
            end




            hAx=hObj.Axes;
            if~isempty(hAx)&&isa(hAx,'matlab.graphics.axis.AbstractAxes')...
                &&~isempty(hAx.Interactions)
                ind=arrayfun(@(x)isa(x,'matlab.graphics.interaction.interactions.DataTipInteraction'),hAx.Interactions);
                if~isempty(hAx.Interactions(ind))
                    if strcmpi(hAx.Interactions(ind).SnapToDataVertex,'on')
                        interpolate='off';
                    else
                        interpolate='on';
                    end
                end
            end
        end

        function tip=createDatatips(hObj,hit,e)
            if~isempty(hObj.DataTipProvider.get())
                hObj.deleteTip();
            end

            ax=hObj.Axes;
            tip=[];


            hTarget=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hit);











            [updateFcn,isEnabled]=hObj.behaviorCheck(ax);
            if isempty(updateFcn)&&isEnabled
                [updateFcn,isEnabled]=hObj.behaviorCheck(hTarget);
            end
            if~isEnabled
                return;
            end
            [updateFcnMode,Interpolate,interpreter]=hObj.modeAccessorCheck(ax);


            hCursor=matlab.graphics.shape.internal.PointDataCursor(hTarget);


            hCursor.Interpolate=Interpolate;
            if isprop(e,'NearestPoint')&&~isempty(e.NearestPoint)&&~isnan(e.NearestPoint)&&strcmp(hCursor.Interpolate,'off')


                hCursor.moveToIndex(e.NearestPoint);
            else



                hCursor.moveTo(e.PointInPixels-0.5);
            end


            tip=matlab.graphics.shape.internal.PointDataTip(hCursor,...
            'Visible','on',...
            'HandleVisibility','off',...
            'DataTipStyle',hObj.dataTipStyle,...
            'PinnedView','off',...
            'Interpreter',interpreter);
            tip.TipHandle.ScribeHost.Tag='TransientGraphicsTip';


            if~isempty(updateFcnMode)
                tip.UpdateFcn=updateFcnMode;
            elseif~isempty(updateFcn)
                tip.UpdateFcn=updateFcn;
            end
        end

        function ret=isNonLinear(hObj,hFig)
            ret=matlab.ui.internal.isUIFigure(hFig)&&~isempty(hObj.Axes)&&~strcmpi(hObj.Axes.DataSpace.isLinear,'on');
        end


        function dist=getDistance(hObj,e)
            dx=abs(hObj.pixelPointEnter(1)-e.Point(1));
            dy=abs(hObj.pixelPointEnter(2)-e.Point(2));
            dist=sqrt(dx^2+dy^2);
        end


        function initializeBufferScale(hObj)
            sc=hObj.getDpiScale();
            hObj.buffer=hObj.buffer*sc(3);
        end

        function scale=getDpiScale(~)
            scale=matlab.ui.internal.PositionUtils.getDevicePixelScreenSize()./get(groot,'ScreenSize');
        end

        function hit=getHitObject(~,hitObject)


            hit=ancestor(hitObject,'matlab.graphics.chart.interaction.DataAnnotatable','node');
            if isempty(hit)
                hit=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hitObject);
            end
        end


        function hLinger=createLinger(~,ax,objectListenerTarget,eventMoveName)
            hLinger=matlab.graphics.interaction.actions.Linger(ax,objectListenerTarget,eventMoveName);
            hLinger.GetNearestPointFcn=@getNearestPoint;
            hLinger.LingerTime=matlab.graphics.interaction.uiaxes.DataTipsBase.TIME;
            hLinger.IncludeChildren=true;
            hLinger.enable();
        end

        function attachListeners(hObj,~,canvas)
            if~isempty(canvas)
                hObj.listeners.Exit=event.listener(...
                canvas,'ButtonExited',@(o,e)canvasExitCallback(hObj));
            end
            hObj.listeners.Delete=event.listener(hObj.Axes,'ObjectBeingDestroyed',@(e,d)hObj.delete());


            if~isempty(hObj.eventMoveName)
                if~isempty(hObj.objectListenerTarget)
                    hObj.listeners.Scroll=event.listener(hObj.objectListenerTarget,hObj.eventScrollName,@(o,e)hObj.disableOnScroll(o,e));
                    hObj.listeners.Press=event.listener(hObj.objectListenerTarget,hObj.eventDisableName,@(o,e)hObj.disableLinger(o,e));
                    hObj.listeners.Release=event.listener(hObj.objectListenerTarget,hObj.eventEnableName,@(o,e)hObj.enableLinger(o,e));
                    hObj.listeners.Motion=event.listener(hObj.objectListenerTarget,hObj.eventMoveName,@(o,e)hObj.motionCallback(o,e));
                end
                hObj.listeners.Enter=event.listener(hObj.linger,'EnterObject',@(o,e)hObj.lingerEnterCallback(o,e));
            end
        end



        function ret=validate(hObj,o,e)




            if isempty(e.HitObject)||~isvalid(e.HitObject)||isa(e.HitObject,'matlab.graphics.primitive.Image')
                ret=false;
                return;
            end
            isval=hObj.strategy.isValidMouseEvent(hObj,o,e);
            ishit=hObj.strategy.isObjectHit(hObj,o,e);
            ret=isval&&ishit;
        end
    end

    methods



        function t=get.EventTimer(obj)
            if isempty(obj.eventTimer_I)||~isvalid(obj.eventTimer_I)
                obj.eventTimer_I=timer('StartDelay',0.2,'Name','EventTimer');
                obj.eventTimer_I.TimerFcn=enableLingerCreator(obj.eventTimer_I,obj.linger);
            end
            t=obj.eventTimer_I;
        end

        function set.EventTimer(obj,val)
            obj.eventTimer_I=val;
        end
    end


    methods(Hidden)

        function enable(hObj)
            ax=hObj.Axes;

            if~isempty(hObj.eventMoveName)
                hObj.linger=hObj.createLinger(ax,hObj.objectListenerTarget,hObj.eventMoveName);
            end
            fig=ancestor(ax,'figure');
            canvas=ancestor(ax,'matlab.graphics.primitive.canvas.Canvas','node');
            hObj.attachListeners(fig,canvas);
        end




        function disableLinger(hObj,~,e)


            if~isprop(e,'HitObject')||~isa(e.HitObject,'matlab.graphics.shape.internal.ScribePeer')
                hObj.deleteTip();
                if~isempty(hObj.linger)
                    hObj.linger.disable();
                end
            end
        end


        function disableOnScroll(hObj,o,e)
            hObj.disableLinger(o,e);
            hObj.deleteTip();
            stop(hObj.EventTimer);
            start(hObj.EventTimer);
        end




        function motionCallback(hObj,~,e)



            dist=0;
            if~isempty(hObj.pixelPointEnter)
                dist=hObj.getDistance(e);
            end



            obj=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(e.HitObject);





            if dist>hObj.buffer...
                &&~isempty(hObj.DataTipProvider.get())&&isvalid(hObj.DataTipProvider.get())...
                &&~isequal(obj,hObj.DataTipProvider.get().Host)...
                &&~isequal(obj,hObj.DataTipProvider.get().TipHandle.ScribeHost.getScribePeer())
                hObj.deleteTip();
            end
        end

        function canvasExitCallback(hObj)
            hObj.deleteTip();
            if~isempty(hObj.linger)
                hObj.linger.resetLinger();
            end
        end

        function lingerEnterCallback(hObj,o,e)
            if isnan(e.NearestPoint)||~hObj.validate(o,e)
                return;
            end

            hitObject=hObj.getHitObject(e.HitObject);

            if isempty(hitObject)
                return;
            end


            primpos=hitObject.getReportedPosition(e.NearestPoint);
            currentLocDataSpaceCoords=primpos.getLocation(e.HitObject);
            if numel(currentLocDataSpaceCoords)<=2
                currentLocDataSpaceCoords(3)=0;
            end



            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            if~pickUtils.isValidInPickSpace(e.HitObject,currentLocDataSpaceCoords)
                return
            end




            dist=0;
            if~isempty(hObj.pixelPointEnter)
                dist=hObj.getDistance(e);
            end






            if~isempty(hObj.DataTipProvider.get())&&isvalid(hObj.DataTipProvider.get())
                if~isempty(hObj.prevLoc)...
                    &&~isequal(currentLocDataSpaceCoords,hObj.prevLoc)...
                    &&isequal(hObj.DataTipProvider.get().DataTipStyle,matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly)
                    hObj.deleteTip();
                elseif dist>hObj.buffer



                    hObj.deleteTip();
                else
                    return;
                end
            end

            hObj.createOnLingerEnter(hitObject,e);



            if~isnan(e.NearestPoint)
                target=hitObject;
                hObj.prevLoc=currentLocDataSpaceCoords;
                if~isa(target,'matlab.graphics.Graphics')
                    target=hObj.Axes;
                end

                pixelPoint=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(target,currentLocDataSpaceCoords(:));


                OffSet=brushing.select.translateToContainer(target,[0,0]);
                hObj.pixelPointEnter=pixelPoint-OffSet';
            end
        end



        function createOnLingerEnter(hObj,hitObject,e)

        end


        function delete(hObj)
            if~isempty(hObj.eventTimer_I)&&isvalid(hObj.eventTimer_I)
                stop(hObj.eventTimer_I);
                delete(hObj.eventTimer_I);
                hObj.eventTimer_I=[];
            end
            if~isempty(hObj.DataTipProvider)&&~isempty(hObj.DataTipProvider.get())&&isvalid(hObj.DataTipProvider.get())&&strcmp(hObj.DataTipProvider.get().PinnedView,'off')
                hObj.DataTipProvider.deleteTip();
            end
            if~isempty(hObj.linger)&&isvalid(hObj.linger)
                delete(hObj.linger)
            end
        end





        function ret=isTipInteractionEnabled(hObj,hTip)
            hFig=ancestor(hTip,'figure');
            ret=isempty(hFig)...
            ||~matlab.internal.editor.figure.FigureUtils.isEditorSnapshotGraphicsView(hFig);
        end

        function enableLinger(hObj,~,~)
            local_enableLinger(hObj.eventTimer_I,hObj.linger);
        end

    end

end





function local_enableLinger(eventTimer,hLinger)
    if~isempty(eventTimer)&&isvalid(eventTimer)
        stop(eventTimer);
    end
    if~isempty(hLinger)
        hLinger.enable();
    end
end

function res=enableLingerCreator(eventTimer,hLinger)
    res=@(e,d)local_enableLinger(eventTimer,hLinger);
end


function nearestPoint=getNearestPoint(hitObject,eventData)



    HIGH_SURFACE_VERTEX_COUNT=1e6;

    hit=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hitObject);

    if isempty(hit)
        hit=ancestor(hitObject,'matlab.graphics.chart.interaction.DataAnnotatable','node');
    end

    if isempty(hit)


        nearestPoint=NaN;
    elseif(isa(hit,'matlab.graphics.chart.primitive.Surface')||...
        isa(hit,'matlab.graphics.primitive.Surface'))&&...
        numel(hit.ZData_I)>HIGH_SURFACE_VERTEX_COUNT
        nearestPoint=NaN;
    else


        nearestPoint=hit.getNearestPoint(eventData.PointInPixels);
    end

end