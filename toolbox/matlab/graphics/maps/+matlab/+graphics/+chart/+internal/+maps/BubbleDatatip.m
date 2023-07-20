classdef BubbleDatatip<handle





    properties(Access=?tGeographicBubbleChartDatatips,Transient,NonCopyable)
PointDatatip
Linger
ModeChangedListener
    end

    methods
        function obj=BubbleDatatip(scatterobj)

            hTarget=scatterobj;
            hLinger=matlab.graphics.interaction.actions.Linger(hTarget);
            hLinger.LingerResetMethod='exitaxes';
            hLinger.LingerTime=1;
            hLinger.enable();
            addlistener(hLinger,'EnterObject',@(~,e)obj.updateDatatip(e));
            addlistener(hLinger,'ExitObject',@(~,e)obj.updateDatatip(e));
            addlistener(hLinger,'LingerOverObject',@(~,~)obj.lingerFcn);
            addlistener(hLinger,'LingerReset',@(~,e)obj.updateDatatip(e));
            obj.Linger=hLinger;
        end
    end

    methods(Hidden)
        function updateDatatipDuringPrint(obj)
            if~isempty(obj.PointDatatip)
                updateDatatip(obj);
            end
        end
    end

    methods(Access=private)
        function updateDatatip(obj,eventobj)


            if isempty(obj.PointDatatip)
                createDatatip(obj);
            end
            hTip=obj.PointDatatip;

            ds=matlab.graphics.interaction.uiaxes.DragSingleton.getInstance();
            midDrag=ds.MidDrag;
            if nargin>1&&eventobj.EventName=="EnterObject"&&~midDrag







                hCursor=hTip.Cursor;
                dataIndex=hCursor.DataIndex;
                newIndex=eventobj.NearestPoint;
                movePoint=~isequal(dataIndex,newIndex);
                if movePoint
                    hCursor.DataIndex=newIndex;
                end




                hTarget=hTip.DataSource;
                if~isscalar(hTarget.SizeData)
                    hTip.MarkerSize=sqrt(hTarget.SizeData(newIndex));
                else
                    hTip.MarkerSize=sqrt(hTarget.SizeData);
                end
                if~isscalar(hTarget.CData(:,1))
                    hTip.MarkerFaceColor=hTarget.CData(newIndex,:);
                else
                    hTip.MarkerFaceColor=hTarget.CData(1,:);
                end
                toggleDatatipLocator(hTip,'on');
            elseif nargin>1&&eventobj.EventName=="LingerReset"



                hTip.DataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly;
                toggleDatatipLocator(hTip,'off');
            else



                toggleDatatipLocator(hTip,'off');
            end
        end

        function lingerFcn(obj)

            hTip=obj.PointDatatip;
            if isempty(hTip.String)
                toggleDatatipLocator(hTip,'off');
            else
                showTip=hTip.Visible=="on";
                if showTip
                    hTip.DataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerAndTip;


                    hTip.TipHandle.ScribeHost.bringToFront();
                end
            end
        end

        function createDatatip(obj)

            hTarget=obj.Linger.Target;
            hCursor=matlab.graphics.shape.internal.PointDataCursor(hTarget);
            hCursor.Interpolate='off';

            hTip=matlab.graphics.shape.internal.PointDataTip(hCursor,...
            'Draggable','off',...
            'Visible','off',...
            'HandleVisibility','off',...
            'DataTipStyle',matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly);

            hLocator=hTip.LocatorHandle;
            hLocator.Marker='o';
            hLocator.PickableParts='none';
            hLocator.HitTest='off';
            hLocator.ScribeMarkerHandleEdge.LineWidth=2;
            hLocator.ScribeMarkerHandleEdge.EdgeColorData=uint8([250;250;250;255]);
            obj.PointDatatip=hTip;



            hTip.TipHandle.Text.PickableParts='none';
            hTip.TipHandle.Rectangle.PickableParts='none';
            scribePeer=hTip.TipHandle.ScribeHost.getScribePeer();
            scribePeer.PickableParts='none';
            hLocator.setMarkerPickableParts('none');




            hFigure=ancestor(hTarget,'figure');
            uigetmodemanager(hFigure);
            hModeManager=hFigure.ModeManager;
            modelistener=hModeManager.listener('CurrentMode',...
            'PostSet',@(~,e)obj.modeChangedEvent());
            obj.ModeChangedListener=modelistener;
        end


        function modeChangedEvent(obj)


            hLinger=obj.Linger;
            if isscalar(hLinger)&&isvalid(hLinger)
                hFigure=ancestor(hLinger.Target,'figure');
                currentMode=hFigure.ModeManager.CurrentMode;
                if isscalar(currentMode)&&strcmp(currentMode.Name,'Standard.EditPlot')
                    hLinger.disable();
                    updateDatatip(obj)
                else
                    hLinger.enable();
                end
            end
        end

        function delete(obj)
            if isscalar(obj.Linger)&&isvalid(obj.Linger)
                delete(obj.Linger)
            end
            delete(obj.ModeChangedListener)
        end
    end
end

function toggleDatatipLocator(hTip,onoff)
    hTip.Visible=onoff;
    hLocator=hTip.LocatorHandle;
    hLocator.ScribeMarkerHandleEdge.Visible=onoff;
    hLocator.ScribeMarkerHandleFace.Visible=onoff;
end