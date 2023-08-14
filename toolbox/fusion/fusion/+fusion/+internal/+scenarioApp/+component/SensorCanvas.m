classdef SensorCanvas<fusion.internal.scenarioApp.component.BaseComponent&...
    matlabshared.application.Canvas&...
    matlabshared.application.Zoom&...
    matlabshared.application.FillAxes

    properties
        InteractionMode='none';
    end

    properties(SetAccess=protected,Hidden)


Layout
XYAxes
XZAxes
YZAxes
VisibleAxes
        XYUnitsPerPixel=1
        XZUnitsPerPixel=1
        YZUnitsPerPixel=1


        XYMarker matlab.graphics.primitive.Line
        XZMarker matlab.graphics.primitive.Line
        YZMarker matlab.graphics.primitive.Line

        XYPatch matlab.graphics.primitive.Patch
        XZPatch matlab.graphics.primitive.Patch
        YZPatch matlab.graphics.primitive.Patch


        XYSensorMarker matlab.graphics.primitive.Line
        XZSensorMarker matlab.graphics.primitive.Line
        YZSensorMarker matlab.graphics.primitive.Line

        XYSensorMarkerCurrent matlab.graphics.primitive.Line
        XZSensorMarkerCurrent matlab.graphics.primitive.Line
        YZSensorMarkerCurrent matlab.graphics.primitive.Line

        HighlightColor=[0.3010,0.7450,0.9330]
        HighlightWidth=2;


XYCoveragePlotter
XZCoveragePlotter
YZCoveragePlotter


CachedPosition
        ActiveCanvas;

    end

    properties(Dependent)
CurrentPlatform
CurrentSensor
    end

    methods
        function plat=get.CurrentPlatform(this)
            plat=this.Application.getCurrentPlatform;
        end

        function sensor=get.CurrentSensor(this)
            sensor=this.Application.getCurrentSensor;
        end
    end


    methods
        function this=SensorCanvas(varargin)
            this@fusion.internal.scenarioApp.component.BaseComponent(varargin{:});
            this@matlabshared.application.Canvas();
            toolbarAndInteractions(this);
            set(getFigure(this),'WindowScrollWheelFcn',this.Application.initCallback(@this.scrollWheelCallback));
            this.VisibleAxes=[1,0,0];
            updateAxesLayout(this);
            this.Figure.Visible='off';
        end

        function tag=getTag(~)
            tag='SensorCanvas';
        end

        function ax=getAxes(this)
            ax=this.ActiveCanvas;
            if isempty(ax)
                ax=ancestor(hittest(this.Figure),'axes');
            end

            if isempty(ax)||~ishghandle(ax,'axes')
                ax=this.XYAxes;
            end
        end

        function fig=getFigure(this)
            fig=this.Figure;
        end

        function clear(this)
            [xyMarker,xzMarker,yzMarker,...
            xyPatch,xzPatch,yzPatch]=getMarkerAndPatch(this);
            delete(xyMarker);
            delete(xzMarker);
            delete(yzMarker);
            delete(xyPatch);
            delete(xzPatch);
            delete(yzPatch);

            this.XYPatch=matlab.graphics.primitive.Patch.empty;
            this.XZPatch=matlab.graphics.primitive.Patch.empty;
            this.YZPatch=matlab.graphics.primitive.Patch.empty;
            this.XYMarker=matlab.graphics.primitive.Line.empty;
            this.XZMarker=matlab.graphics.primitive.Line.empty;
            this.YZMarker=matlab.graphics.primitive.Line.empty;
        end

        function[a,b,c,d,e,f]=getMarkerAndPatch(this)
            a=this.XYMarker;
            b=this.XZMarker;
            c=this.YZMarker;
            d=this.XYPatch;
            e=this.XZPatch;
            f=this.YZPatch;
        end

        function[tooltip,cp]=getCursorText(this)
            cp=getCurrentPoint(this);
            ax=getAxes(this);
            dimStr=ax.Tag(8:9);
            dims=getDims(dimStr);
            tooltip=upper(dimStr(1))+":"+num2str(cp(dims(1)))+", "+upper(dimStr(2))+":"+num2str(cp(dims(2)));
        end

        function[sensorDropdownIdx,sensorID]=getClosestSensorIndex(this,cp,xData,yData)
            [~,ids,allids]=getCurrentPlatformSensorIDs(this);
            [~,idx]=min(vecnorm(cp-[xData(:),yData(:)],2,2));
            sensorID=ids(idx);
            sensorDropdownIdx=find(allids==sensorID,1);
        end

        function[curxyz,xyz]=getCurrentSensorXYZData(this)
            [curxyz,xyz]=getSensorLocations(this.Application);
        end

        function[curid,ids,allids]=getCurrentPlatformSensorIDs(this)
            [curid,ids,allids]=getCurrentPlatformSensorIDs(this.Application);
        end

        function update(this)

            updateSensorCoverages(this);
            updatePlatform(this);
            updateSensorMarkers(this);

            updateAxesLayout(this);
        end

        function updateAndFit(this)
            update(this);
            fitAxesToPlatform(this);
        end
    end

    methods(Hidden)
        function newItem=pasteItem(this,item,location)
            platform=getCurrentPlatform(this.Application);
            if~isempty(platform)
                newItem=copy(item);
                if nargin<3



                    unitsPerPixel=getHVUnitsPerPixel(this);
                    offset=[1,-1,0]*8*unitsPerPixel;


                    newItem.MountingLocation=item.MountingLocation+offset;
                else




                    newItem.MountingLocation=location;
                end
                newItem.PlatformID=platform.ID;
            end
        end

        function onFocus(this)
            this.Application.FocusedComponent='sensor';
        end
    end


    methods(Access=protected,Hidden)
        function fitAxesToPlatform(this,ax)
            plat=this.CurrentPlatform;

            if isempty(plat)
                xlim=[-100,100];
                ylim=[-100,100];
                zlim=[-100,100];
            else
                xlim=1.5/2*max(10,plat.Dimension(1)+plat.Dimension(4))*[-1,1];
                ylim=1.5/2*max(10,plat.Dimension(2)+plat.Dimension(5))*[-1,1];
                zlim=1.5/2*max(10,plat.Dimension(3)+plat.Dimension(6))*[-1,1];
            end

            if nargin==2
                if isequal(ax,this.XYAxes)
                    applyAxesLimits(this,xlim,ylim,ax);
                elseif isequal(ax,this.YZAxes)
                    applyAxesLimits(this,ylim,zlim,ax);
                elseif isequal(ax,this.XZAxes)
                    applyAxesLimits(this,xlim,zlim,ax);
                end
            else
                applyAxesLimits(this,xlim,ylim,this.XYAxes);
                applyAxesLimits(this,ylim,zlim,this.YZAxes);
                applyAxesLimits(this,xlim,zlim,this.XZAxes);
            end
            resize(this);
        end

        function updatePlatform(this)

            xyAxes=this.XYAxes;
            xzAxes=this.XZAxes;
            yzAxes=this.YZAxes;

            [xyMarker,xzMarker,yzMarker,...
            xyPatch,xzPatch,yzPatch]=getMarkerAndPatch(this);

            currentPlatform=this.CurrentPlatform;
            if isempty(currentPlatform)
                clear(this);
                this.XYAxes.Title.String='';
                this.Figure.Name=getName(this);
                return
            end

            patchPvPairs={'FaceColor',[0.1,0.1,0.1],...
            'EdgeColor',[0,0,0],...
            'FaceAlpha',0.1,...
            'ButtonDownFcn',@this.onButtonDown};

            markerPvPairs={'Marker','^',...
            'MarkerFaceColor','k',...
            'ButtonDownFcn',@this.onButtonDown};


            if isempty(xyPatch)||~ishghandle(xyPatch)
                xyPatch=patch('Parent',xyAxes,...
                patchPvPairs{:},'Tag','platform.patch.xy','Hittest','off');
                xzPatch=patch('Parent',xzAxes,...
                patchPvPairs{:},'Tag','platform.patch.xz','Hittest','off');
                yzPatch=patch('Parent',yzAxes,...
                patchPvPairs{:},'Tag','platform.patch.yz','Hittest','off');

            end

            if isempty(xyMarker)||~ishghandle(xyMarker)
                xyMarker=line('Parent',xyAxes,...
                markerPvPairs{:},'Tag','platform.marker.xy');
                xzMarker=line('Parent',xzAxes,...
                markerPvPairs{:},'Tag','platform.marker.xz');
                yzMarker=line('Parent',yzAxes,...
                markerPvPairs{:},'Tag','platform.marker.yz');
                set([xyMarker,xzMarker,yzMarker],...
                'XData',0,'YData',0,'ZData',0,...
                'UserData',currentPlatform);
            end

            faces=generateFaces(currentPlatform,'local');
            set(xyPatch,...
            'XData',squeeze(faces(1,:,:)),...
            'YData',squeeze(faces(2,:,:)),...
            'ZData',0.*squeeze(faces(3,:,:)),...
            'UserData',currentPlatform);
            set(xzPatch,...
            'XData',squeeze(faces(1,:,:)),...
            'YData',0.*squeeze(faces(2,:,:)),...
            'ZData',squeeze(faces(3,:,:)),...
            'UserData',currentPlatform);
            set(yzPatch,...
            'XData',0.*squeeze(faces(1,:,:)),...
            'YData',squeeze(faces(2,:,:)),...
            'ZData',squeeze(faces(3,:,:)),...
            'UserData',currentPlatform);
            set([xyMarker,xzMarker,yzMarker],...
            'XData',0,'YData',0,'ZData',0,...
            'UserData',currentPlatform);


            this.XYAxes.Title.String=['Platform: ',currentPlatform.Name];
            this.XYPatch=xyPatch;
            this.XZPatch=xzPatch;
            this.YZPatch=yzPatch;
            this.XYMarker=xyMarker;
            this.XZMarker=xzMarker;
            this.YZMarker=yzMarker;
        end

        function updateSensorMarkers(this)
            xySensor=this.XYSensorMarker;
            xzSensor=this.XZSensorMarker;
            yzSensor=this.YZSensorMarker;

            xySensorCurrent=this.XYSensorMarkerCurrent;
            xzSensorCurrent=this.XZSensorMarkerCurrent;
            yzSensorCurrent=this.YZSensorMarkerCurrent;

            sensorCurrentPvPairs={'Marker','o',...
            'LineStyle','none',...
            'MarkerSize',10,...
            'MarkerEdgeColor',this.HighlightColor,...
            'LineWidth',this.HighlightWidth,...
            'MarkerFaceColor','k'};

            sensorPvPairs={'Marker','o',...
            'LineStyle','none',...
            'MarkerFaceColor',this.XYAxes.Color};

            if isempty(xySensor)||~ishghandle(xySensor)
                xySensor=line('Parent',this.XYAxes,...
                'Tag','sensor.marker.xy',...
                'ButtonDownFcn',@this.onButtonDown);

                xzSensor=line('Parent',this.XZAxes,...
                'Tag','sensor.marker.xz',...
                'ButtonDownFcn',@this.onButtonDown);
                yzSensor=line('Parent',this.YZAxes,...
                'Tag','sensor.marker.yz',...
                'ButtonDownFcn',@this.onButtonDown);
            end

            if isempty(xySensorCurrent)||~ishghandle(xySensorCurrent)
                xySensorCurrent=line('Parent',this.XYAxes,...
                'Tag','currentsensor.marker.xy',...
                'ButtonDownFcn',@this.onButtonDown);
                xzSensorCurrent=line('Parent',this.XZAxes,...
                'Tag','currentsensor.marker.xz',...
                'ButtonDownFcn',@this.onButtonDown);
                yzSensorCurrent=line('Parent',this.YZAxes,...
                'Tag','currentsensor.marker.yz',...
                'ButtonDownFcn',@this.onButtonDown);
            end

            [currentSensorXYZ,sensorXYZ]=this.getCurrentSensorXYZData();
            set(xySensor,'XData',sensorXYZ(:,1),...
            'YData',sensorXYZ(:,2),...
            'ZData',0*sensorXYZ(:,3),...
            sensorPvPairs{:});
            set(xzSensor,'XData',sensorXYZ(:,1),...
            'YData',0*sensorXYZ(:,2),...
            'ZData',sensorXYZ(:,3),...
            sensorPvPairs{:});
            set(yzSensor,'XData',0*sensorXYZ(:,1),...
            'YData',sensorXYZ(:,2),...
            'ZData',sensorXYZ(:,3),...
            sensorPvPairs{:});

            set(xySensorCurrent,'XData',currentSensorXYZ(:,1),...
            'YData',currentSensorXYZ(:,2),...
            'ZData',0*currentSensorXYZ(:,3),...
            sensorCurrentPvPairs{:});
            set(xzSensorCurrent,'XData',currentSensorXYZ(:,1),...
            'YData',0*currentSensorXYZ(:,2),...
            'ZData',currentSensorXYZ(:,3),...
            sensorCurrentPvPairs{:});
            set(yzSensorCurrent,'XData',0*currentSensorXYZ(:,1),...
            'YData',currentSensorXYZ(:,2),...
            'ZData',currentSensorXYZ(:,3),...
            sensorCurrentPvPairs{:});

            uistack(xySensor,'top');
            uistack(xzSensor,'top');
            uistack(yzSensor,'top');
            uistack(xySensorCurrent,'top');
            uistack(xzSensorCurrent,'top');
            uistack(yzSensorCurrent,'top');

            this.XYSensorMarker=xySensor;
            this.XZSensorMarker=xzSensor;
            this.YZSensorMarker=yzSensor;
            this.XYSensorMarkerCurrent=xySensorCurrent;
            this.XZSensorMarkerCurrent=xzSensorCurrent;
            this.YZSensorMarkerCurrent=yzSensorCurrent;
        end

        function updateSensorCoverages(this)
            sensors=this.Application.getSensorsByPlatform();
            clear(this.XYCoveragePlotter);
            clear(this.YZCoveragePlotter);
            clear(this.XZCoveragePlotter);
            plotCoverage(this.XYCoveragePlotter,sensors);
            plotCoverage(this.XZCoveragePlotter,sensors);
            plotCoverage(this.YZCoveragePlotter,sensors);
        end

        function updateAxesLayout(this)
            visibleAxes=logical(this.VisibleAxes);
            allAxes=[this.XYAxes,this.XZAxes,this.YZAxes];
            idx=find(visibleAxes);


            set(findall(allAxes),'visible','off');
            set(findall(allAxes(visibleAxes)),'visible','on');


            switch sum(idx)
            case 1
                this.XYAxes.Layout.TileSpan=[3,3];
            case 3
                this.XYAxes.Layout.TileSpan=[2,3];
                this.XZAxes.Layout.TileSpan=[1,3];

            case 4
                this.XYAxes.Layout.TileSpan=[3,2];
                this.YZAxes.Layout.TileSpan=[3,1];
            case 6
                this.XYAxes.Layout.TileSpan=[2,2];
                this.XZAxes.Layout.TileSpan=[1,2];
                this.YZAxes.Layout.TileSpan=[2,1];
            end
            set(findall(allAxes(visibleAxes),'Tag','Tooltip'),'visible','off');


            resize(this);


            t=this.XYAxes.Title;
            t.Position(2)=1-t.FontSize-t.Parent.TickLength(2);
        end

        function updateToolbarBtns(this)

            yz(1)=findobj(this.XYAxes.Toolbar,'tag','btnyz1');
            yz(2)=findobj(this.YZAxes.Toolbar,'tag','btnyz2');
            yz(3)=findobj(this.XZAxes.Toolbar,'tag','btnyz3');

            xz(1)=findobj(this.XYAxes.Toolbar,'tag','btnxz1');
            xz(2)=findobj(this.YZAxes.Toolbar,'tag','btnxz2');
            xz(3)=findobj(this.XZAxes.Toolbar,'tag','btnxz3');

            yzonoff=matlabshared.application.logicalToOnOff(this.VisibleAxes(3));
            xzonoff=matlabshared.application.logicalToOnOff(this.VisibleAxes(2));

            set(yz,'Value',yzonoff);
            set(xz,'Value',xzonoff);

        end
    end


    methods(Hidden)
        function applyAxesLimits(this,hLim,vLim,ax)
            if nargin==3
                ax=getAxes(this);
            end
            pos=getpixelposition(ax);
            unitsPerPixel=max(diff(hLim)/pos(3),diff(vLim)/pos(4));
            setUnitsPerPixel(this,unitsPerPixel,ax);
        end

        function updateAxisLimits(this,ax)
            if nargin<2
                ax=getAxes(this);
            end
            pos=getpixelposition(ax);

            unitsPerPixel=max(getUnitsPerPixel(this,ax),1e-9);
            range=[-1,1]*unitsPerPixel/2;

            view=ax.View;
            hrange=range*pos(3);
            vrange=range*pos(4);
            isAxisCollapsed=any(pos(3:4)==0);
            if isequal(view,[0,90])&&~isAxisCollapsed
                set(ax,...
                'XLim',hrange,...
                'YLim',vrange);
            elseif isequal(view,[0,0])&&~isAxisCollapsed
                set(ax,...
                'XLim',hrange,...
                'ZLim',vrange);
            elseif isequal(view,[90,0])&&~isAxisCollapsed

                set(ax,...
                'YLim',hrange,...
                'ZLim',vrange);
            elseif isequal(view,[-90,90])&&~isAxisCollapsed
                set(ax,...
                'XLim',vrange,...
                'YLim',hrange);
            end
        end

        function updateLimits(this)
            updateAxisLimits(this,getAxes(this));
        end

        function resize(this,~,~)
            updateAxisLimits(this,this.XYAxes);
            updateAxisLimits(this,this.XZAxes);
            updateAxisLimits(this,this.YZAxes);
        end

        function unitsPerPixel=getUnitsPerPixel(this,ax)
            switch ax.Tag(end-1:end)
            case 'xy'
                unitsPerPixel=this.XYUnitsPerPixel;
            case 'xz'
                unitsPerPixel=this.XZUnitsPerPixel;
            case 'yz'
                unitsPerPixel=this.YZUnitsPerPixel;
            end
        end

        function setUnitsPerPixel(this,unitsPerPixel,ax)
            switch ax.Tag(end-1:end)
            case 'xy'
                this.XYUnitsPerPixel=unitsPerPixel;
            case 'xz'
                this.XZUnitsPerPixel=unitsPerPixel;
            case 'yz'
                this.YZUnitsPerPixel=unitsPerPixel;
            end
        end

        function performZoom(this,zoomLevel,ax)

            [hRange,vRange,hLim,vLim]=getAxesRangeAndLimits(this);
            center=[sum(hLim)/2,sum(vLim)/2];
            hLim=center(1)+[-hRange,hRange]*zoomLevel;
            vLim=center(2)+[-vRange,vRange]*zoomLevel;
            applyAxesLimits(this,hLim,vLim,ax);
            updateLimits(this);
        end

        function zoomIn(this,h)
            ax=ancestor(h,'axes');
            performZoom(this,0.25,ax);
        end

        function zoomOut(this,h)
            ax=ancestor(h,'axes');
            performZoom(this,1,ax);
        end
    end


    methods(Hidden)
        function scrollWheelCallback(this,~,ev)



            hAxes=ancestor(hittest(this.Figure),'axes');
            if~isempty(hAxes)
                this.ActiveCanvas=hAxes;
            else
                hAxes=getAxes(this);
            end
            axesPos=getpixelposition(hAxes);
            mousePoint=get(getFigure(this),'CurrentPoint');
            if mousePoint(1)<axesPos(1)||...
                mousePoint(2)<axesPos(2)||...
                mousePoint(1)>axesPos(1)+axesPos(3)||...
                mousePoint(2)>axesPos(2)+axesPos(4)
                return
            end

            [hRange,vRange,hLim,vLim]=getAxesRangeAndLimits(this,false);
            hPercent=(0-hLim(1))/hRange;
            vPercent=(0-vLim(1))/vRange;
            zoomFactor=(1+ev.VerticalScrollCount*ev.VerticalScrollAmount/50);
            hRange=hRange*zoomFactor;
            vRange=vRange*zoomFactor;
            [hRange,vRange]=fixAxesRange(this,hRange,vRange);
            hLim=0+[-hRange*hPercent,hRange*(1-hPercent)];
            vLim=0+[-vRange*vPercent,vRange*(1-vPercent)];
            applyAxesLimits(this,hLim,vLim);
            updateAxisLimits(this);
        end

        function keyPressCallback(~,~,~)

        end

        function sensorCanvasXZ(this,~,ev)
            this.Application.sensorCanvasXZ(matlab.lang.OnOffSwitchState(ev.Value));
        end

        function sensorCanvasYZ(this,~,ev)
            this.Application.sensorCanvasYZ(matlab.lang.OnOffSwitchState(ev.Value));
        end

        function restoreViewCallback(this,h,~)
            ax=ancestor(h,'axes');
            this.fitAxesToPlatform(ax);
        end
    end


    methods
        function onSensorDeleted(this,toDelete)
            this.XYCoveragePlotter.clear(toDelete);
            this.XZCoveragePlotter.clear(toDelete);
            this.YZCoveragePlotter.clear(toDelete);
        end

        function toggleSensorAxes(this,face,value)
            visibleAxes=this.VisibleAxes;
            if strcmp(face,'X-Z')
                visibleAxes(2)=value;
            elseif strcmp(face,'Y-Z')
                visibleAxes(3)=value;
            end
            this.VisibleAxes=visibleAxes;
            updateAxesLayout(this);
            updateToolbarBtns(this);
        end
    end


    methods
        function set.InteractionMode(this,newMode)
            this.InteractionMode=newMode;
            if startsWith(newMode,'add.')
                ptr='cross';
            elseif startsWith(newMode,'drag.')||startsWith(newMode,'pan.')
                ptr='hand';
            else
                ptr='arrow';
            end
            set(this.Figure,'Pointer',ptr);
        end

        function cancelInteraction(this)
            iMode=this.InteractionMode;
            this.InteractionMode='none';
            if startsWith(iMode,'add.sensor')

                this.Application.resetCurrentSensor();
            elseif startsWith(iMode,'drag.sensor')

            else
                update(this);
            end
            setTooltipString(this,'');
        end
    end


    methods(Access=protected)
        function performButtonDown(this,hSrc,~)

            hApp=this.Application;
            if strcmp(this.InteractionMode,'add.sensor')


                newSensor=hApp.SensorToAdd;
                tag=get(getAxes(this),'Tag');
                dims=getDims(tag(8:9));
                cp=getCurrentPoint(this);
                newSensor.MountingLocation(dims)=cp(dims);
                this.Application.addSensor(newSensor)
                this.InteractionMode='none';
            elseif startsWith(hSrc.Tag,'sensor.')


                cp=getCurrentPoint(this);
                dims=getDims(hSrc.Tag(end-1:end));
                dropdownIdx=getClosestSensorIndex(this,cp(dims),hSrc.XData,hSrc.YData);
                setCurrentSensorByIndex(hApp,dropdownIdx);
                this.ActiveCanvas=hSrc.Parent;
                set(this.Figure,'Pointer','arrow');
            elseif startsWith(hSrc.Tag,'currentsensor.')



                if isLeftClick(this)
                    set(this.Figure,'Pointer','fleur');
                    this.CachedPosition=this.CurrentSensor.MountingLocation;
                    this.InteractionMode=['drag.sensor',hSrc.Tag(end-2:end)];
                    this.ActiveCanvas=hSrc.Parent;
                end
            end
        end

        function performMouseMove(this,~,ev)
            iMode=this.InteractionMode;
            if any(strcmp(iMode,{'none','add.sensor'}))
                if ishghandle(ev.HitObject,'axes')&&startsWith(ev.HitObject.Tag,'canvas.')
                    this.ActiveCanvas=ev.HitObject;
                elseif ishghandle(ev.HitObject,'patch')&&...
                    (startsWith(ev.HitObject.Tag,'beam')||...
                    startsWith(ev.HitObject.Tag,'coverage'))
                    this.ActiveCanvas=ancestor(ev.HitObject,'axes');
                end
            end
            tooltip='';
            currentPoint=getCurrentPoint(this);

            if startsWith(iMode,'drag.sensor.')
                set(this.Figure,'Pointer','fleur');
                dims=getDims(iMode(end-1:end));

                this.CurrentSensor.MountingLocation(dims)=currentPoint(dims);
                notifyEventToApplicationDataModel(this.Application,'SensorsChanged');
            elseif strcmp(iMode,'add.sensor')
                if isOverAxes(this)
                    tooltip=getCursorText(this);
                    set(this.Figure,'Pointer','cross');
                else
                    set(this.Figure,'Pointer','arrow');
                end
            else
                hSrc=hittest(this.Figure);
                if isempty(hSrc)
                    return;
                elseif startsWith(hSrc.Tag,'sensor.')
                    set(this.Figure,'Pointer','hand');
                elseif startsWith(hSrc.Tag,'currentsensor.')
                    set(this.Figure,'Pointer','fleur');
                else
                    set(this.Figure,'Pointer','arrow');
                end



            end
            setTooltipString(this,tooltip);
        end

        function performButtonUp(this,~,~)
            iMode=this.InteractionMode;

            this.InteractionMode='none';
            if startsWith(iMode,'drag.sensor.')

                currentPoint=getCurrentPoint(this);
                oldPos=this.CachedPosition;


                dims=getDims(iMode(end-1:end));
                newPos=oldPos;


                newPos(dims)=currentPoint(dims);



                this.Application.setSensorProperty('MountingLocation',newPos,oldPos);
            end
            this.ActiveCanvas=[];
        end

        function b=isLeftClick(this)
            b=strcmp(this.Figure.SelectionType,'normal');
        end

        function b=isRightClick(this)
            b=strcmp(this.Figure.SelectionType,'alt');
        end
    end


    methods(Access=protected)
        function fig=createFigure(this,varargin)
            fig=createFigure@matlabshared.application.Component(this,varargin{:});
            tl=tiledlayout(fig,3,3,'TileSpacing','compact','Padding','compact');
            this.Layout=tl;
            this.XYAxes=axes(tl,...
...
            'ZLim',[-1e7,1e7],...
            'XGrid','on',...
            'YGrid','on',...
            'Box','on',...
            'Ydir','reverse',...
            'Zdir','reverse',...
            'Tag','canvas.xy',...
            'ButtonDownFcn',@this.onButtonDown);
            this.XZAxes=axes(tl,...
...
            'YLim',[-1e7,1e7],...
            'XGrid','on',...
            'ZGrid','on',...
            'Box','on',...
            'ZDir','reverse',...
            'Ydir','reverse',...
            'Tag','canvas.xz',...
            'ButtonDownFcn',@this.onButtonDown);
            this.YZAxes=axes(tl,...
...
            'XLim',[-1e7,1e7],...
            'YGrid','on',...
            'ZGrid','on',...
            'Box','on',...
            'Zdir','reverse',...
            'Ydir','reverse',...
            'Tag','canvas.yz',...
            'ButtonDownFcn',@this.onButtonDown);


            this.XYAxes.Layout.Tile=1;
            this.YZAxes.Layout.Tile=3;
            this.XZAxes.Layout.Tile=7;

            view(this.XZAxes,0,0);
            view(this.YZAxes,90,0);

            xlabel(this.XYAxes,'X_{platform} (m)');
            ylabel(this.XYAxes,'Y_{platform} (m)');
            xlabel(this.XZAxes,'X_{platform} (m)');
            zlabel(this.XZAxes,'Z_{platform} (m)');
            ylabel(this.YZAxes,'Y_{platform} (m)');
            zlabel(this.YZAxes,'Z_{platform} (m)');

            set(this.XYAxes.Title,'Units','normalized','FontUnits','normalized');

            this.XYAxes.Camera.TransparencyMethodHint='objectsort';
            this.XZAxes.Camera.TransparencyMethodHint='objectsort';
            this.YZAxes.Camera.TransparencyMethodHint='objectsort';

            btndwncb=this.Application.initCallback(@this.onButtonDown);
            this.XYCoveragePlotter=fusion.internal.scenarioApp.plotter.CoveragePlotter(this.XYAxes,btndwncb);
            this.XZCoveragePlotter=fusion.internal.scenarioApp.plotter.CoveragePlotter(this.XZAxes,btndwncb);
            this.YZCoveragePlotter=fusion.internal.scenarioApp.plotter.CoveragePlotter(this.YZAxes,btndwncb);


            this.VisibleAxes=[1,0,0];
        end

        function toolbarAndInteractions(this)

            [tb,btns]=axtoolbar(this.XYAxes,{'restoreview'},'Visible','on');


            xyZoomScene=findobj(btns,'Tag','restoreview');
            xyZoomScene.ButtonPushedFcn=@(src,evt)restoreViewCallback(this,src);


            xyZoomOut=axtoolbarbtn(tb,'push');
            xyZoomOut.ButtonPushedFcn=@(src,evt)zoomOut(this,src);
            xyZoomOut.Tooltip=getString(message(strcat(this.ResourceCatalog,'ScenarioCanvasZoomOut')));
            xyZoomOut.Icon='zoomout';
            xyZoomOut.Tag='SensorZoomOut.xy';


            xyZoomIn=axtoolbarbtn(tb,'push');
            xyZoomIn.ButtonPushedFcn=@(src,evt)zoomIn(this,src);
            xyZoomIn.Tooltip=getString(message(strcat(this.ResourceCatalog,'ScenarioCanvasZoomIn')));
            xyZoomIn.Icon='zoomin';
            xyZoomIn.Tag='SensorZoomIn.xy';

            yzbtn=axtoolbarbtn(tb,'state','tag','btnyz1');
            yzbtn.Icon=iconFile(this,'cube_right_16.png');
            yzbtn.ValueChangedFcn=this.Application.initCallback(@this.sensorCanvasYZ);
            yzbtn.Tooltip=msgString(this,'YZView');
            xzbtn=axtoolbarbtn(tb,'state','tag','btnxz1');
            xzbtn.Icon=iconFile(this,'cube_left_16.png');
            xzbtn.ValueChangedFcn=this.Application.initCallback(@this.sensorCanvasXZ);
            xzbtn.Tooltip=msgString(this,'XZView');

            [tb,btns]=axtoolbar(this.YZAxes,{'restoreview'},'Visible','on');


            yzZoomScene=findobj(btns,'Tag','restoreview');
            yzZoomScene.ButtonPushedFcn=@(src,evt)restoreViewCallback(this,src);


            yzZoomOut=axtoolbarbtn(tb,'push');
            yzZoomOut.ButtonPushedFcn=@(src,evt)zoomOut(this,src);
            yzZoomOut.Tooltip=getString(message(strcat(this.ResourceCatalog,'ScenarioCanvasZoomOut')));
            yzZoomOut.Icon='zoomout';
            yzZoomOut.Tag='SensorZoomOut.yz';


            yzZoomIn=axtoolbarbtn(tb,'push');
            yzZoomIn.ButtonPushedFcn=@(src,evt)zoomIn(this,src);
            yzZoomIn.Tooltip=getString(message(strcat(this.ResourceCatalog,'ScenarioCanvasZoomIn')));
            yzZoomIn.Icon='zoomin';
            yzZoomIn.Tag='SensorZoomIn.yz';

            yzbtn=axtoolbarbtn(tb,'state','tag','btnyz2');
            yzbtn.Icon=iconFile(this,'cube_right_16.png');
            yzbtn.ValueChangedFcn=this.Application.initCallback(@this.sensorCanvasYZ);
            yzbtn.Tooltip=msgString(this,'YZView');
            xzbtn=axtoolbarbtn(tb,'state','tag','btnxz2');
            xzbtn.Icon=iconFile(this,'cube_left_16.png');
            xzbtn.ValueChangedFcn=this.Application.initCallback(@this.sensorCanvasXZ);
            xzbtn.Tooltip=msgString(this,'XZView');

            [tb,btns]=axtoolbar(this.XZAxes,{'restoreview'},'Visible','on');


            xzZoomScene=findobj(btns,'Tag','restoreview');
            xzZoomScene.ButtonPushedFcn=@(src,evt)restoreViewCallback(this,src);


            xzZoomOut=axtoolbarbtn(tb,'push');
            xzZoomOut.ButtonPushedFcn=@(src,evt)zoomOut(this,src);
            xzZoomOut.Tooltip=getString(message(strcat(this.ResourceCatalog,'ScenarioCanvasZoomOut')));
            xzZoomOut.Icon='zoomout';
            xzZoomOut.Tag='SensorZoomOut.xz';


            xzZoomIn=axtoolbarbtn(tb,'push');
            xzZoomIn.ButtonPushedFcn=@(src,evt)zoomIn(this,src);
            xzZoomIn.Tooltip=getString(message(strcat(this.ResourceCatalog,'ScenarioCanvasZoomIn')));
            xzZoomIn.Icon='zoomin';
            xzZoomIn.Tag='SensorZoomIn.xy';

            yzbtn=axtoolbarbtn(tb,'state','tag','btnyz3');
            yzbtn.Icon=iconFile(this,'cube_right_16.png');
            yzbtn.ValueChangedFcn=this.Application.initCallback(@this.sensorCanvasYZ);
            yzbtn.Tooltip=msgString(this,'YZView');
            xzbtn=axtoolbarbtn(tb,'state','tag','btnxz3');
            xzbtn.Icon=iconFile(this,'cube_left_16.png');
            xzbtn.ValueChangedFcn=this.Application.initCallback(@this.sensorCanvasXZ);
            xzbtn.Tooltip=msgString(this,'XZView');

        end
    end
end

function dims=getDims(chars)

    dims=abs(chars)-119;

end