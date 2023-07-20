classdef SensorCanvas<matlabshared.application.Component&...
    matlabshared.application.Canvas&...
    driving.internal.scenarioApp.Zoom&...
    driving.internal.scenarioApp.FillAxes&...
    driving.internal.scenarioApp.UITools&...
    matlabshared.application.ComponentBanner




    properties
        InteractionMode='move';
        AddInputs={};
        Constrain=true;
        Mirror=true;
        Snap=true;
        Center=[1.5,0]
        UnitsPerPixel=0.015
    end

    properties(Hidden)
ClickLocation
        IsMoving=false;
        IsCopying=false;
        IsRotating=false;
        hCoverageAreas=matlab.graphics.GraphicsPlaceholder.empty;
        hCoverageAnchors;
        IsLidarAdded=false;
        hSensorSettings;
    end

    properties(SetAccess=protected,Hidden)
        Axes;
        hEgoCar;
        hFrontBumper;
        hFrontWindow;
        hFrontPassengerWheel;
        hFrontDriverWheel;
        hRearBumper;
        hRearWindow;
        hRearPassengerWheel;
        hRearDriverWheel;
        hRoofFront;
        hRoofCenter;
        hRotate;
        hSettingsMenu;
        hMirrorMenu;
        hConstrainMenu;
        hSnapMenu;
        hMirror;
        hSensorContextMenu;
        hAxesContextMenu;
        InitialQuadrant;
        CurrentYaw;
CurrentRange
CurrentFoV
        SensorIndex;
        CopyIndex;
        LastSize;
        FieldOfViewCache;
        HorizontalMirrorX;
        IsControlDown=false;
    end

    properties(Access=protected)
EgoCarIdListener
SensorSpecificationListener
    end

    methods
        function this=SensorCanvas(varargin)
            this@matlabshared.application.Component(varargin{:});
            designer=this.Application;
            this.EgoCarIdListener=addPropertyListener(designer,...
            'EgoCarId',@this.onEgoCarIdChanged);
            this.SensorSpecificationListener=event.listener(designer,...
            'CurrentSensorChanged',@this.onSpecificationIndexChanged);
            addlistener(this.Axes,{'XLim','YLim'},'PostSet',@this.onLimitChanged);
            update(this);
            initializeScrollZoom(this);
            initializeFloatingPalette(this,this.Figure,this.Axes);
            c=uicontextmenu(this.Figure,...
            'Tag','AxesContextMenu',...
            'Callback',@this.onAxesContextMenu);
            this.hAxesContextMenu=c;
            set([this.Axes,this.hEgoCar,getHitZones(this)],'UIContextMenu',c);
            contribute(this.Application.Toolstrip,this,'DisplayProperties','SensorCanvas',{'Constrain','Mirror','Snap'});



        end

        function set.Mirror(this,newMirror)
            this.Mirror=newMirror;
            setCheckBoxProperty(this.Application.Toolstrip,'Mirror',newMirror);
            updateMirrorLine(this);
        end

        function set.Snap(this,newSnap)
            this.Snap=newSnap;
            setCheckBoxProperty(this.Application.Toolstrip,'Snap',newSnap);
            if newSnap
                vis='on';
            else
                vis='off';
            end
            set(getHitZones(this),'Visible',vis);
        end

        function set.InteractionMode(this,newMode)
            this.InteractionMode=newMode;
            if strcmp(newMode,'add')
                highlightCanvas(this);
                set(this.hCoverageAreas,'HitTest','off');%#ok<*MCSUP>
                set(this.hCoverageAnchors,'HitTest','off');%#ok<*MCSUP>
                set(this.Figure,'Pointer','cross');
            else
                removeHighlightCanvas(this);
                set(this.hCoverageAreas,'HitTest','on');
                set(this.hCoverageAnchors,'HitTest','on');
                set(this.Figure,'Pointer','arrow');
            end
        end

        function enableAddSensor(this,varargin)
            this.InteractionMode='add';
            this.AddInputs=varargin;
        end

        function update(this)
            app=this.Application;
            sensorSpecs=app.SensorSpecifications;

            hAxes=this.Axes;
            hhCoverageAreas=this.hCoverageAreas;
            hhCoverageAnchors=this.hCoverageAnchors;
            newCoverage=false;


            [length,width,rearoverhang,frontoverhang,faceColor]=getEgoInfo(this);



            updateHitZones(this,length,width,rearoverhang,frontoverhang);


            updateEgoCar(this,length,width,rearoverhang,faceColor);


            nSensors=numel(sensorSpecs);
            fov=zeros(1,nSensors);
            for indx=1:nSensors

                spec=sensorSpecs(indx);
                if indx>numel(hhCoverageAreas)
                    newCoverage=true;
                    hhCoverageAreas(indx)=patch(hAxes,...
                    'Tag','CoverageArea',...
                    'UIContextMenu',this.hSensorContextMenu,...
                    'ButtonDownFcn',@this.onButtonDown,...
                    'UserData',indx);
                    hhCoverageAnchors(indx)=line(this.Axes,...
                    'Tag','CoverageAnchor',...
                    'ButtonDownFcn',@this.onButtonDown,...
                    'Visible','off',...
                    'XData',0,...
                    'YData',0,...
                    'Marker','o',...
                    'MarkerIndices',1,...
                    'MarkerFaceColor',[0,0,0],...
                    'MarkerEdgeColor','none',...
                    'MarkerSize',8);

                end
                fov(indx)=spec.FieldOfView(1);
                yaw=spec.Yaw;
                if isa(spec,'driving.internal.scenarioApp.LidarSensorSpecification')
                    yaw=yaw+mean(spec.AzimuthLimits);
                end
                driving.birdsEyePlot.internal.plotCoverageArea(hhCoverageAreas(indx),...
                spec.SensorLocation,spec.MaxRange,yaw,fov(indx));
                set(hhCoverageAnchors(indx),'XData',spec.SensorLocation(1),'YData',spec.SensorLocation(2));
                set(hhCoverageAreas(indx),'Visible','on',...
                'FaceColor',spec.CoverageFaceColor,...
                'EdgeColor',spec.CoverageEdgeColor,...
                'FaceAlpha',spec.CoverageFaceAlpha);


                if fov(indx)==360
                    anchorVis='on';
                else
                    anchorVis='off';
                end
                set(hhCoverageAnchors(indx),'Visible',anchorVis,...
                'UserData',indx,...
                'MarkerFaceColor',spec.CoverageFaceColor,...
                'MarkerEdgeColor',spec.CoverageEdgeColor);
            end
            this.FieldOfViewCache=fov;
            for indx=nSensors+1:numel(hhCoverageAreas)
                set(hhCoverageAreas(indx),'Visible','off');
                set(hhCoverageAnchors(indx),'Visible','off');
            end

            if newCoverage
                this.hCoverageAreas=hhCoverageAreas;
                this.hCoverageAnchors=hhCoverageAnchors;
            end

            updateCurrentSensor(this);
            updateMirrorLine(this);

            dir=driving.scenario.internal.AxesOrientation.getAxesDir(app.AxesOrientation);
            set(hAxes,'YDir',dir,'ZDir',dir);
        end
    end


    methods(Hidden)

        function applyAxesLimits(this,varargin)
            applyAxesLimits@matlabshared.application.FillAxes(this,varargin{:});
        end

        function onFocus(this)
            this.Application.MostRecentCanvas='sensors';
        end

        function pasteItem(this,item,location)
            oldLocation=item.SensorLocation;
            this.InitialQuadrant=getCurrentQuadrant(this,oldLocation);
            if nargin<3
                item.SensorLocation=item.SensorLocation-[0.5,0.5];
            end
            item=copy(item);
            if nargin>2
                item.SensorLocation=location(1:2);
            end
            x=item.SensorLocation(1);
            y=item.SensorLocation(2);
            yaw=item.Yaw;
            if this.Mirror
                yaw=applyMirror(this,x,y,yaw);
            end

            if this.Constrain
                [x,y,yaw]=applyConstrain(this,x,y,yaw);
            end

            if this.Snap
                [x,y,yaw,item.MaxRange,item.FieldOfView(1)]=applySnap(this,x,y,yaw,item.MaxRange,item.FieldOfView(1));
            end
            item.SensorLocation=[x,y];
            item.Yaw=yaw;
            app=this.Application;
            focusOnComponent(this);
            applyEdit(app,driving.internal.scenarioApp.undoredo.PasteSensor(app,item));
        end

        function[min,max]=getAxesSpan(~)
            min=2;
            max=500;
        end

        function onSensorContextMenu(this,h,~)
            cut=findobj(h,'Tag','CutItem');
            if isempty(cut)
                cut=uimenu(h,...
                'Tag','CutItem',...
                'Text',getString(message('Spcuilib:application:Cut')),...
                'Callback',@this.cutSensorCallback);
                uimenu(h,...
                'Tag','CopyItem',...
                'Text',getString(message('Spcuilib:application:Copy')),...
                'Callback',@this.copySensorCallback);
                delete=uimenu(h,...
                'Tag','DeleteItem',...
                'Text',getString(message('Spcuilib:application:Delete')),...
                'Callback',@this.deleteSensorCallback);
drawnow
            else
                delete=findobj(h,'Tag','DeleteItem');
            end
            set([cut,delete],'Enable',isStopped(this.Application.Simulator));
        end

        function onAxesContextMenu(this,h,~)
            this.ClickLocation=getCurrentPoint(this);
            paste=findobj(h,'Tag','PasteItem');

            if isempty(paste)
                paste=uimenu(h,...
                'Label',getString(message('Spcuilib:application:Paste')),...
                'Tag','PasteItem',...
                'Callback',@this.pasteSensorCallback);
                addCamera=uimenu(h,...
                'Separator','on',...
                'Tag','AddCamera',...
                'Label',getString(message('driving:scenarioApp:AddCameraMenuLabel')),...
                'Callback',@this.addCameraCallback);
                addRadar=uimenu(h,...
                'Tag','AddRadar',...
                'Label',getString(message('driving:scenarioApp:AddRadarMenuLabel')),...
                'Callback',@this.addRadarCallback);
                addLidar=uimenu(h,...
                'Tag','AddLidar',...
                'Label',getString(message('driving:scenarioApp:AddLidarMenuLabel')),...
                'Callback',@this.addLidarCallback);
                addINS=uimenu(h,...
                'Tag','AddINS',...
                'Label',getString(message('driving:scenarioApp:AddINSMenuLabel')),...
                'Callback',@this.addINSCallback);
                addUltrasonic=uimenu(h,...
                'Tag','AddUltrasonic',...
                'Label',getString(message('driving:scenarioApp:AddUltrasonicMenuLabel')),...
                'Callback',@this.addUltrasonicCallback);
drawnow
            else
                addCamera=findobj(h,'Tag','AddCamera');
                addRadar=findobj(h,'Tag','AddRadar');
                addLidar=findobj(h,'Tag','AddLidar');
                addINS=findobj(h,'Tag','AddINS');
                addUltrasonic=findobj(h,'Tag','AddUltrasonic');
            end
            app=this.Application;
            if isPasteEnabled(app)&&isa(app.CopyPasteBuffer,'driving.internal.scenarioApp.SensorSpecification')&&isStopped(app.Simulator)
                enab='on';
            else
                enab='off';
            end
            paste.Enable=enab;
            set([addCamera,addRadar,addLidar,addINS,addUltrasonic],'Enable',isStopped(app.Simulator));
        end

        function addCameraCallback(this,~,~)
            app=this.Application;
            this.AddInputs={'vision','Name',getUniqueName(getSensorAdder(app),getString(message('driving:scenarioApp:DefaultVisionName')))};
            inputs=getAddInputs(this,this.ClickLocation);
            edit=driving.internal.scenarioApp.undoredo.AddSensor(app,inputs{:});
            applyEditInCallback(app,edit,this);
        end

        function addRadarCallback(this,~,~)
            app=this.Application;
            this.AddInputs={'radar','Name',getUniqueName(getSensorAdder(app),getString(message('driving:scenarioApp:DefaultRadarName')))};
            inputs=getAddInputs(this,this.ClickLocation);
            edit=driving.internal.scenarioApp.undoredo.AddSensor(app,inputs{:});
            applyEditInCallback(app,edit,this);
        end

        function addLidarCallback(this,~,~)
            app=this.Application;
            this.AddInputs={'lidar','Name',getUniqueName(getSensorAdder(app),getString(message('driving:scenarioApp:DefaultLidarName')))};
            inputs=getAddInputs(this,this.ClickLocation);
            edit=driving.internal.scenarioApp.undoredo.AddSensor(app,inputs{:});
            applyEditInCallback(app,edit,this);
            postAddLidar(this);
        end

        function addINSCallback(this,~,~)
            app=this.Application;
            this.AddInputs={'ins','Name',getUniqueName(getSensorAdder(app),getString(message('driving:scenarioApp:DefaultINSName')))};
            inputs=getAddInputs(this,this.ClickLocation);
            edit=driving.internal.scenarioApp.undoredo.AddSensor(app,inputs{:});
            applyEditInCallback(app,edit,this);
            postAddINS(this);
        end

        function addUltrasonicCallback(this,~,~)
            app=this.Application;
            this.AddInputs={'ultrasonic','Name',getUniqueName(getSensorAdder(app),getString(message('driving:scenarioApp:DefaultUltrasonicName')))};
            inputs=getAddInputs(this,this.ClickLocation);
            edit=driving.internal.scenarioApp.undoredo.AddSensor(app,inputs{:});
            applyEditInCallback(app,edit,this);
        end

        function updateEgoCar(this,length,width,rearoverhang,faceColor)
            if nargin<2
                [length,width,rearoverhang,~,faceColor]=getEgoInfo(this);
            end
            width=width/2;
            vertices=[
            0,width;
            length,width;
            length,-width;
            0,-width]-[rearoverhang,0];

            set(this.hEgoCar,...
            'FaceColor',faceColor,...
            'Vertices',vertices,...
            'XData',vertices(:,1),...
            'YData',vertices(:,2));
            newSize=[width,length];



            if~isequal(newSize,this.LastSize)
                hAxes=this.Axes;
                yLim=[-width,width];
                yLim=yLim-[diff(yLim),-diff(yLim)]/4;
                xLim=[0,length]-rearoverhang;
                xLim=xLim-[diff(xLim),-diff(xLim)]/4;
                pos=get(hAxes,'Position');
                xyRatio=pos(3)/pos(4);
                actRatio=diff(xLim)/diff(yLim);




                if actRatio>xyRatio
                    yLim=yLim/(xyRatio/actRatio);
                elseif xyRatio>actRatio
                    shift=mean(xLim);
                    xLim=(xLim-shift)/(actRatio/xyRatio)+shift;
                end
                set(hAxes,'XLim',xLim,'YLim',yLim);

                this.LastSize=newSize;
            end
        end

        function updateCurrentSensor(this)
            hCoverages=this.hCoverageAreas;
            set(hCoverages,'LineWidth',0.5);
            index=getCurrentSensorIndex(this.Application);
            if~isempty(index)
                if numel(hCoverages)>=index
                    set(this.hCoverageAreas(index),'LineWidth',2);
                end
            end
        end

        function hZones=getHitZones(this)
            hZones=[this.hFrontBumper,this.hFrontWindow,this.hFrontPassengerWheel...
            ,this.hFrontDriverWheel,this.hRearBumper,this.hRearWindow...
            ,this.hRearPassengerWheel,this.hRearDriverWheel,this.hRoofFront,this.hRoofCenter];
        end

        function onLimitChanged(this,~,~)
            updateHitZones(this);
            updateMirrorLine(this);
        end

        function onSpecificationIndexChanged(this,~,~)
            updateCurrentSensor(this);
        end

        function updateMirrorLine(this)
            if this.Mirror
                vis='on';
            else
                vis='off';
            end
            hAxes=this.Axes;
            xMirror=this.HorizontalMirrorX;
            set(this.hMirror,'XData',[hAxes.XLim,nan,xMirror,xMirror],...
            'YData',[0,0,nan,hAxes.YLim],'Visible',vis);
        end

        function updateHitZones(this,length,width,rearoverhang,frontoverhang)
            if nargin==1
                [length,width,rearoverhang,frontoverhang]=getEgoInfo(this);
            end

            wheelbase=length-frontoverhang-rearoverhang;
            frontWindow=[wheelbase-0.9,0];
            rearWindow=[0,0];

            if frontWindow(1)<0
                frontWindow(1)=length-frontoverhang-rearoverhang;
            end

            roofRange=[];
            obj=getCurrentCoveragePatch(this);
            if~isempty(obj)
                index=obj.UserData;
                sensorSpecs=this.Application.SensorSpecifications;
                if index<=numel(sensorSpecs)
                    sensor=sensorSpecs(index);
                    if strcmp(sensor.Type,'lidar')
                        roofRange=120;
                    end
                end
            end

            updateHitZone(this,'FrontBumper',[length-rearoverhang,0],0,100,20);
            updateHitZone(this,'RearBumper',[-rearoverhang,0],-180,100,20);
            updateHitZone(this,'FrontPassengerWheel',[wheelbase,-width/2],[-180,0],50,90);
            updateHitZone(this,'FrontDriverWheel',[wheelbase,width/2],[0,180],50,90);
            updateHitZone(this,'RearPassengerWheel',[0,-width/2],[-180,0],50,90);
            updateHitZone(this,'RearDriverWheel',[0,width/2],[0,180],50,90);
            updateHitZone(this,'RoofFront',[frontWindow(1)-0.4,0],0,roofRange,[]);
            updateHitZone(this,'RoofCenter',[frontWindow(1)/2,0],0,roofRange,[]);
            updateHitZone(this,'FrontWindow',frontWindow,0,[],[]);
            updateHitZone(this,'RearWindow',rearWindow,-180,[],[]);

            this.HorizontalMirrorX=(frontWindow(1)+rearWindow(1))/2;
        end

        function updateHitZone(this,hitZone,center,yaw,maxRange,FoV)
            width=5;
            unitsPerPixel=getHVUnitsPerPixel(this);
            vertices=[
            width,width;
            -width,width;
            -width,-width;
            width,-width]*unitsPerPixel+center;
            set(this.(['h',hitZone]),...
            'UserData',struct('Center',center,'Yaw',yaw,'MaxRange',maxRange,'FieldOfView',FoV),...
            'Vertices',vertices,...
            'XData',vertices(:,1),...
            'YData',vertices(:,2));
        end

        function[xUnitsPerPixel,yUnitsPerPixel]=getHVUnitsPerPixel(this)
            [yUnitsPerPixel,xUnitsPerPixel]=getHVUnitsPerPixel@matlabshared.application.Canvas(this);
            if xUnitsPerPixel>yUnitsPerPixel
                yUnitsPerPixel=xUnitsPerPixel;
            else
                xUnitsPerPixel=yUnitsPerPixel;
            end
        end

        function[length,width,rearoverhang,frontoverhang,faceColor]=getEgoInfo(this)
            app=this.Application;
            egoId=app.EgoCarId;
            actors=app.Scenario.Actors;
            if isempty(egoId)||egoId>numel(actors)
                width=1.8;
                length=4.7;
                rearoverhang=1;
                frontoverhang=0.9;
                faceColor=[0,114,189]/255;
            else
                actor=actors(egoId);
                faceColor=actor.PlotColor;
                width=actor.Width;
                length=actor.Length;
                if isa(actor,'driving.scenario.Vehicle')
                    rearoverhang=actor.RearOverhang;
                    frontoverhang=actor.FrontOverhang;
                else
                    rearoverhang=0;
                    frontoverhang=0;
                end
            end
        end

        function onRotateButtonDown(this,hRotate,ev)
            app=this.Application;
            if ev.Button~=1||~isStopped(app.Simulator)
                return;
            end
            disableUndoRedo(app);
            if isOverRotateNode(this)
                this.CurrentYaw=[];
                this.IsRotating=true;
                this.SensorIndex=hRotate.UserData;
            else
                onButtonDown(this,this.Axes,ev);
            end
        end

        function name=getName(~)
            name=getString(message('driving:scenarioApp:SensorCanvasTitle'));
        end

        function tag=getTag(~)
            tag='SensorCanvas';
        end

        function hAxes=getAxes(this)
            hAxes=this.Axes;
        end

        function fig=getFigure(this)
            fig=this.Figure;
        end

        function resize(this)
            if~ishghandle(this.Figure)||~isvalid(this.Application)
                return;
            end
            updateLimits(this);
            update(this);
        end

        function obj=getCurrentCoveragePatch(this,xy)
            hCoverage=this.hCoverageAreas;
            if nargin>1
                for indx=numel(hCoverage):-1:1
                    if strcmp(hCoverage(indx).Visible,'on')&&...
                        inpolygon(xy(1),xy(2),hCoverage(indx).XData,hCoverage(indx).YData)
                        obj=hCoverage(indx);
                        return;
                    end
                end
                obj=[];
            else
                obj=hCoverage(this.SensorIndex);
            end
        end

        function obj=getCurrentCoverageAnchor(this)
            hCoverage=this.hCoverageAnchors;
            obj=hCoverage(this.SensorIndex);
        end



        function quadrant=getCurrentQuadrant(this,cp)

            yMidpoint=0;
            xMidpoint=this.HorizontalMirrorX;

            isleft=cp(2)>yMidpoint;
            isfront=cp(1)>xMidpoint;

            if isfront
                if isleft
                    quadrant=1;
                else
                    quadrant=2;
                end
            elseif isleft
                quadrant=4;
            else
                quadrant=3;
            end
        end

        function hideRotateWidget(this)
            hRot=this.hRotate;
            if~isempty(hRot)
                set(hRot,'Visible','off');
            end
        end

        function xy=showRotateWidget(this,sensorIndex,currentXY)
            hRot=this.hRotate;
            if isempty(hRot)


                hRot=line(this.Axes,...
                'Tag','RotateWidget',...
                'ButtonDownFcn',@this.onRotateButtonDown,...
                'UIContextMenu',this.hSensorContextMenu,...
                'XData',[0,1],...
                'YData',[0,1],...
                'Marker','o',...
                'MarkerIndices',2,...
                'MarkerFaceColor',[0,0,0],...
                'MarkerEdgeColor','none',...
                'MarkerSize',10);
                this.hRotate=hRot;
            end



            sensors=this.Application.SensorSpecifications;
            if sensorIndex>numel(sensors)
                xy=false;
                return;
            end
            sensor=sensors(sensorIndex);
            if sensor.FieldOfView(1)==360
                xy=false;
                return;
            end
            if this.IsRotating
                yaw=this.CurrentYaw;
            else
                yaw=sensor.Yaw;
                if isa(sensor,'driving.internal.scenarioApp.LidarSensorSpecification')
                    yaw=yaw+mean(sensor.AzimuthLimits);
                end
            end
            this.SensorIndex=sensorIndex;
            xy=sensor.SensorLocation;
            if nargin<3
                unitsPerPixel=getHVUnitsPerPixel(this);
                radiusInPixel=60;
                radiusInUnits=radiusInPixel*unitsPerPixel;

                yaw=deg2rad(yaw);
                xData=xy(1)+[0,radiusInUnits*cos(yaw)];
                yData=xy(2)+[0,radiusInUnits*sin(yaw)];
            else
                xData=[xy(1),currentXY(1)];
                yData=[xy(2),currentXY(2)];
            end
            xLim=this.Axes.XLim;
            yLim=this.Axes.YLim;




            if xData(2)>xLim(2)
                yData(2)=(yData(2)-yData(1))*abs(xLim(2)/xData(2))+yData(1);
                xData(2)=xLim(2);
            elseif xData(2)<xLim(1)
                yData(2)=(yData(2)-yData(1))*abs(xLim(1)/xData(2))+yData(1);
                xData(2)=xLim(1);
            end
            if yData(2)>yLim(2)
                xData(2)=(xData(2)-xData(1))*abs(yLim(2)/yData(2))+xData(1);
                yData(2)=yLim(2);
            elseif yData(2)<yLim(1)
                xData(2)=(xData(2)-xData(1))*abs(yLim(1)/yData(2))+xData(1);
                yData(2)=yLim(1);
            end
            set(hRot,...
            'Color',sensor.CoverageEdgeColor,...
            'MarkerFaceColor',sensor.CoverageEdgeColor,...
            'XData',xData,...
            'YData',yData,...
            'Visible','on',...
            'UserData',sensorIndex);
            if~useAppContainer(this.Application)
                uistack(hRot,'top');
            end
            xy=[xData(2),yData(2)];
        end

        function[x,y,yaw,range,fov]=applySnap(this,x,y,yaw,range,fov)
            allHits=getHitZones(this);
            ud=[allHits.UserData];
            allCenters=vertcat(ud.Center);

            allDistances=sum((allCenters-[x,y]).^2,2);

            indx=find(allDistances==min(allDistances),1,'first');

            if isempty(indx)
                return;
            end

            xDiff=abs(allCenters(indx,1)-x);
            yDiff=abs(allCenters(indx,2)-y);
            unitsPerPixel=getHVUnitsPerPixel(this);
            xDiff=xDiff/unitsPerPixel;
            yDiff=yDiff/unitsPerPixel;
            if xDiff<=6&&yDiff<=6
                x=allCenters(indx,1);
                y=allCenters(indx,2);

                newYaw=ud(indx).Yaw;
                if isscalar(newYaw)
                    yaw=newYaw;
                elseif yaw<=newYaw(1)||yaw>=newYaw(2)
                    yaw=mean(newYaw);
                end
                newRange=ud(indx).MaxRange;
                if~isempty(newRange)
                    range=newRange;
                end
                newFoV=ud(indx).FieldOfView;
                if~isempty(newFoV)
                    fov=newFoV;
                end
            end
        end

        function yaw=applyMirror(this,x,y,yaw)
            initialQuadrant=this.InitialQuadrant;
            currentQuadrant=getCurrentQuadrant(this,[x,y]);


            if(initialQuadrant==1||initialQuadrant==4)&&(currentQuadrant==2||currentQuadrant==3)||...
                (initialQuadrant==2||initialQuadrant==3)&&(currentQuadrant==1||currentQuadrant==4)
                yaw=-yaw;
            end
            if(initialQuadrant==1||initialQuadrant==2)&&(currentQuadrant==3||currentQuadrant==4)||...
                (initialQuadrant==3||initialQuadrant==4)&&(currentQuadrant==1||currentQuadrant==2)
                yaw=-(yaw-90)+90;
            end

            yaw=driving.scenario.internal.fixAngle(yaw);
        end

        function[x,y,yaw]=applyConstrain(this,x,y,yaw)

            [length,width,rearoverhang]=getEgoInfo(this);

            if x>=length-rearoverhang


                if abs(yaw)==90
                    yaw=0;
                elseif abs(yaw)>90
                    yaw=180-yaw;
                end
                x=length-rearoverhang;
            elseif x<=-rearoverhang

                if abs(yaw)==90
                    yaw=-180;
                elseif abs(yaw)<90
                    yaw=180-yaw;
                end
                x=-rearoverhang;
            end


            if y>=width/2
                if yaw<=-90
                    yaw=yaw-90;
                elseif yaw<=0
                    yaw=yaw+90;
                elseif yaw>=180
                    yaw=yaw-90;
                end
                y=width/2;
            elseif y<=-width/2


                if yaw>=90
                    yaw=yaw-270;
                end
                if yaw>=0
                    yaw=yaw-90;
                end
                if yaw<=-180
                    yaw=yaw+90;
                end

                y=-width/2;
            end

            yaw=driving.scenario.internal.fixAngle(yaw);
        end

        function deleteSensorCallback(this,~,~)
            app=this.Application;
            anyINS=any(string({app.SensorSpecifications.Type})=='ins');
            edit=driving.internal.scenarioApp.undoredo.DeleteSensor(app,this.SensorIndex);
            applyEdit(app,edit);
            if anyINS
                update(app.ActorProperties);
            end
        end

        function pasteSensorCallback(this,~,~)
            pasteItem(this.Application,this.ClickLocation);
        end

        function copySensorCallback(this,~,~)
            copyItem(this.Application);
        end

        function cutSensorCallback(this,~,~)
            cutItem(this.Application);
        end

        function settingsCallback(this,h,~)
            hMenu=this.hSettingsMenu;
            if isempty(hMenu)
                hMenu=uicontextmenu(this.Figure,'Tag','SensorSettingsMenu');
                this.hConstrainMenu=uimenu(hMenu,...
                'Tag','Constrain',...
                'Label',getString(message('driving:scenarioApp:ConstrainLabel')),...
                'Callback',@this.constrainCallback);
                this.hMirrorMenu=uimenu(hMenu,...
                'Tag','Mirror',...
                'Label',getString(message('driving:scenarioApp:MirrorLabel')),...
                'Callback',@this.mirrorCallback);
                this.hSnapMenu=uimenu(hMenu,...
                'Tag','Snap',...
                'Label',getString(message('driving:scenarioApp:SnapLabel')),...
                'Callback',@this.snapCallback);
                this.hSettingsMenu=hMenu;
            end
            this.hConstrainMenu.Checked=matlabshared.application.logicalToOnOff(this.Constrain);
            this.hMirrorMenu.Checked=matlabshared.application.logicalToOnOff(this.Mirror);
            this.hSnapMenu.Checked=matlabshared.application.logicalToOnOff(this.Snap);
            drawnow;
            set(this.hSettingsMenu,...
            'Position',h.Position(1:2)+[1,0],...
            'Visible','on');
        end

        function constrainCallback(this,~,~)
            this.Constrain=~this.Constrain;
            setCheckBoxProperty(this.Application.Toolstrip,'Constrain',this.Constrain);
        end

        function mirrorCallback(this,~,~)
            this.Mirror=~this.Mirror;
        end

        function snapCallback(this,~,~)
            this.Snap=~this.Snap;
        end

        function b=isOverRotateNode(this)
            [cp,unitsPerPixel]=getCurrentPoint(this);
            hRot=this.hRotate;
            if isempty(hRot)||~ishghandle(hRot)
                b=0;
                return;
            end
            center=[hRot.XData(2),hRot.YData(2),0];
            b=sqrt(sum((center-cp).^2))/unitsPerPixel<=5;
        end

        function postAddLidar(this)

            app=this.Application;
            if~this.IsLidarAdded
                app.EgoCentricView.ShowActorMeshes=true;
                app.BirdsEyePlot.ShowActorMeshes=true;
                this.IsLidarAdded=true;
            end
            if~driving.scenario.internal.setGetPersistentSetting('ActorMeshMessageShown')
                this.warningMessage(getString(message('driving:scenarioApp:ActorMeshMessage')),'ActorMeshMessage');
                driving.scenario.internal.setGetPersistentSetting('ActorMeshMessageShown',true);
            end
        end

        function postAddINS(this)


            app=this.Application;
            egoId=app.EgoCarId;
            if~isempty(egoId)
                scenario=app.Scenario;
                actors=scenario.Actors;
                if~isempty(actors)
                    egoCar=actors(egoId);
                    if isa(egoCar.MotionStrategy,'driving.scenario.Path')&&~isa(egoCar.MotionStrategy,'driving.scenario.SmoothTrajectory')

                        waittime=egoCar.MotionStrategy.WaitTime;

                        yaw=rad2deg(egoCar.MotionStrategy.Yaw);
                        otherArgs={};
                        if~isempty(waittime)
                            otherArgs=horzcat(otherArgs,{waittime});
                        end
                        if~isempty(yaw)
                            otherArgs=horzcat(otherArgs,{'Yaw',yaw});
                        end
                        try
                            smoothTrajectory(egoCar,egoCar.MotionStrategy.Waypoints,...
                            egoCar.MotionStrategy.Speed,otherArgs{:});
                        catch E %#ok<NASGU>
                            clearAllMessages(this);
                            this.warningMessage(getString(message('driving:scenarioApp:NegativeTrajectoryUpdatedMessage')),'NegativeTrajectoryUpdatedMessage');
                            return;
                        end
                    end
                    egoSpec=app.ActorSpecifications(egoId);
                    egoSpec.IsSmoothTrajectory=true;
                    update(app.ActorProperties);
                    if~driving.scenario.internal.setGetPersistentSetting('TrajectoryUpdatedMessageShown')
                        this.warningMessage(getString(message('driving:scenarioApp:TrajectoryUpdatedMessage')),'TrajectoryUpdatedMessage');
                        driving.scenario.internal.setGetPersistentSetting('TrajectoryUpdatedMessageShown',true);
                    end
                end
            end
        end
    end

    methods(Access=protected)

        function options=getAddToApplicationOptions(this)

            app=this.Application;




            tile=getComponentTileIndex(app,app.ScenarioView);
            if isempty(tile)
                tile=2;
            end
            options=struct(...
            'Title',getName(this),...
            'Tag',getTag(this),...
            'Closable',isCloseable(this),...
            'Tile',tile);
        end

        function performButtonDown(this,hCoverage,ev)
            app=this.Application;
            if~isStopped(app.Simulator)
                return;
            end
            cp=getCurrentPoint(this);
            hideRotateWidget(this);


            if any(strcmp(this.InteractionMode,{'move','none'}))&&strcmp(hCoverage.Tag,'SensorCanvasAxes')
                patch=getCurrentCoveragePatch(this,cp);
                if~isempty(patch)
                    hCoverage=patch;
                end
                this.InteractionMode='pan';
            end

            if strcmp(this.InteractionMode,'add')
                this.InteractionMode='move';
                inputs=getAddInputs(this,cp);
                edit=driving.internal.scenarioApp.undoredo.AddSensor(app,inputs{:});

                fig=this.Figure;
                ptr=fig.Pointer;
                fig.Pointer='watch';
                setTooltipString(this,getString(message('driving:scenarioApp:AddingSensorMessage')));
drawnow
                applyEditInCallback(app,edit,this);
                if strcmp(inputs{1},'lidar')
                    postAddLidar(this);
                elseif strcmp(inputs{1},'ins')
                    postAddINS(this);
                end
                fig.Pointer=ptr;
                setTooltipString(this,'');
            elseif strcmp(hCoverage.Tag,'CoverageArea')||strcmp(hCoverage.Tag,'CoverageAnchor')
                disableUndoRedo(this.Application);
                index=hCoverage.UserData;
                sensorSpecs=this.Application.SensorSpecifications;
                if index>numel(sensorSpecs)
                    return;
                end
                sensor=sensorSpecs(index);

                isCircleFOV=strcmp(hCoverage.Tag,'CoverageArea')&&sensor.FieldOfView(1)==360;
                this.CurrentFoV=sensor.FieldOfView(1);
                focusOnComponent(this.Application.SensorProperties);
                drawnow;
                focusOnComponent(this);
                if~isCircleFOV&&strcmp(this.Figure.SelectionType,'alt')&&ev.Button==1
                    hAxes=this.Axes;
                    this.IsCopying=true;
                    this.CopyIndex=index;
                    this.hCoverageAreas(end+1)=copyobj(hCoverage,hAxes);
                    this.hCoverageAnchors(end+1)=line(hAxes,...
                    'Tag','CoverageAnchor',...
                    'ButtonDownFcn',@this.onButtonDown,...
                    'Visible','off',...
                    'XData',0,...
                    'YData',0,...
                    'Marker','o',...
                    'MarkerIndices',1,...
                    'MarkerFaceColor',[0,0,0],...
                    'MarkerEdgeColor','none',...
                    'MarkerSize',8);
                    index=numel(this.hCoverageAreas);
                    set(this.hCoverageAreas(end),...
                    'UIContextMenu',this.hSensorContextMenu,...
                    'ButtonDownFcn',@this.onButtonDown,...
                    'UserData',index);
                    set(this.hCoverageAnchors(end),...
                    'ButtonDownFcn',@this.onButtonDown,...
                    'UserData',index);
                elseif ev.Button~=3
                    if isOverRotateNode(this)
                        this.IsRotating=true;
                    else
                        this.IsMoving=true;
                    end
                end
                yaw=sensor.Yaw;
                this.SensorIndex=index;
                this.CurrentYaw=yaw;
                this.InitialQuadrant=getCurrentQuadrant(this,sensor.SensorLocation);

                if this.IsMoving
                    sp=this.Application.SensorProperties;
                    sp.SpecificationIndex=this.SensorIndex;
                    update(sp);
                end
                if isCircleFOV
                    this.IsMoving=false;
                end
            elseif strcmp(hCoverage.Tag,'EgoCar')&&strcmp(this.Figure.SelectionType,'open')


                focusOnComponent(this.Application.ActorProperties);
            end
        end

        function performMouseMove(this,~,~)
            cp=getCurrentPoint(this);
            obj=hittest(this.Figure);
            if~ishghandle(obj)
                return
            end
            if any(strcmp(obj.Tag,{'SensorCanvasAxes','SensorCanvas'}))
                patch=getCurrentCoveragePatch(this,cp);
                if~isempty(patch)
                    obj=patch;
                end
            end
            tooltipString='';
            interp='none';
            pointer='arrow';
            if this.IsMoving||this.IsCopying
                delta=cp-this.InitialPoint;
                obj=getCurrentCoveragePatch(this);
                if this.IsCopying
                    index=this.CopyIndex;
                else
                    index=this.SensorIndex;
                end
                if index>numel(this.Application.SensorSpecifications)
                    return
                end
                sensor=this.Application.SensorSpecifications(index);
                location=sensor.SensorLocation;

                x=location(1)+delta(1);
                y=location(2)+delta(2);

                yaw=sensor.Yaw;
                if isa(sensor,'driving.internal.scenarioApp.LidarSensorSpecification')
                    yaw=yaw+mean(sensor.AzimuthLimits);
                end
                if this.Mirror
                    yaw=applyMirror(this,x,y,yaw);
                end

                if this.Constrain
                    [x,y,yaw]=applyConstrain(this,x,y,yaw);
                end

                range=sensor.MaxRange;
                fov=this.FieldOfViewCache(index);
                if this.Snap
                    [x,y,yaw,range,fov]=applySnap(this,x,y,yaw,range,fov);
                end

                this.CurrentFoV=fov;
                this.CurrentYaw=yaw;
                driving.birdsEyePlot.internal.plotCoverageArea(obj,[x,y],range,yaw,fov);
                if fov==360
                    set(this.hCoverageAnchors(index),'XData',x,'YData',y);
                end
                tooltipString=sprintf('%s\nX: %g, Y: %g',sensor.Name,x,y);
            elseif this.IsRotating
                index=this.SensorIndex;
                sensor=this.Application.SensorSpecifications(index);
                cp=getCurrentPoint(this);
                op=sensor.SensorLocation;
                y=cp(2)-op(2);
                x=cp(1)-op(1);
                newYaw=rad2deg(atan(y/x));
                if x<0
                    if y<0
                        newYaw=-180+newYaw;
                    else
                        newYaw=180+newYaw;
                    end
                end
                this.CurrentYaw=newYaw;
                obj=getCurrentCoveragePatch(this);
                driving.birdsEyePlot.internal.plotCoverageArea(obj,...
                op,sensor.MaxRange,newYaw,this.FieldOfViewCache(index));
                tooltipString=[num2str(newYaw),'{\circ}'];
                interp='tex';
                if this.FieldOfViewCache(index)~=360
                    showRotateWidget(this,this.SensorIndex,cp);
                end
            elseif strcmp(this.InteractionMode,'add')
                xLim=this.Axes.XLim;
                yLim=this.Axes.YLim;
                if cp(1)>=xLim(1)&&cp(1)<=xLim(2)&&cp(2)>=yLim(1)&&cp(2)<=yLim(2)
                    pointer='cross';
                    if any(obj==getHitZones(this))
                        tooltipString=sprintf('X: %g, Y: %g (%s)',cp(1),cp(2),getString(message(['driving:scenarioApp:',obj.Tag])));
                    else
                        tooltipString=sprintf('X: %g, Y: %g',cp(1),cp(2));
                    end
                end
            elseif any(strcmp(obj.Tag,{'CoverageArea','RotateWidget'}))
                xLim=this.Axes.XLim;
                yLim=this.Axes.YLim;
                if cp(1)<xLim(2)&&cp(1)>xLim(1)&&cp(2)<yLim(2)&&cp(2)>yLim(1)
                    sensorSpecs=this.Application.SensorSpecifications;
                    index=obj.UserData;
                    if index>numel(sensorSpecs)
                        return;
                    end
                    sensor=sensorSpecs(index);
                    if sensor.FieldOfView(1)==360
                        return;
                    end
                    if showRotateWidget(this,obj.UserData)
                        pointer='hand';
                    end
                    if isOverRotateNode(this)
                        yaw=sensor.Yaw;
                        if isa(sensor,'driving.internal.scenarioApp.LidarSensorSpecification')
                            yaw=yaw+mean(sensor.AzimuthLimits);
                        end
                        tooltipString=[num2str(yaw),'{\circ}'];
                        interp='tex';
                    else
                        tooltipString=sensor.Name;
                    end
                end
            elseif strcmp(this.InteractionMode,'pan')
                drag=this.InitialPoint-getCurrentPoint(this);
                this.Center=this.Center+drag(1:2);
                updateLimits(this);
            else
                if any(obj==getHitZones(this))
                    tooltipString=getString(message(['driving:scenarioApp:',obj.Tag]));
                elseif obj==this.hEgoCar
                    designer=this.Application;
                    actorSpecs=designer.ActorSpecifications;
                    egoId=designer.EgoCarId;
                    if isempty(egoId)||egoId>numel(actorSpecs)
                        tooltipString=getString(message('driving:scenarioApp:EgoCarTooltip'));
                    else
                        tooltipString=sprintf('%s (%s)',actorSpecs(egoId).Name,getString(message('driving:scenarioApp:EgoCarText')));
                    end
                end
                hideRotateWidget(this);
            end
            set(this.Figure,'Pointer',pointer);
            setTooltipString(this,tooltipString,interp)
        end

        function performButtonUp(this,~,~)
            if this.IsMoving
                this.IsMoving=false;
                onMouseMove(this);

                app=this.Application;
                index=this.SensorIndex;
                sensors=app.SensorSpecifications;
                if index>numel(sensors)
                    return;
                end
                sensor=sensors(index);
                fov=this.CurrentFoV;
                if~isempty(fov)&&(fov==360)
                    obj=getCurrentCoverageAnchor(this);
                else
                    obj=getCurrentCoveragePatch(this);
                end
                xData=get(obj,'XData');
                yData=get(obj,'YData');
                newLocation=[xData(1),yData(1)];
                yaw=this.CurrentYaw;
                if isa(sensor,'driving.internal.scenarioApp.LidarSensorSpecification')
                    yaw=yaw-mean(sensor.AzimuthLimits);
                end
                params={'SensorLocation'};
                values={newLocation};
                if yaw~=sensor.Yaw
                    params=[params,{'Yaw'}];
                    values=[values,{yaw}];
                end
                if~isempty(fov)&&this.FieldOfViewCache(index)~=fov&&(fov~=360)
                    params=[params,{'FieldOfView'}];
                    values=[values,{fov}];
                end

                range=this.CurrentRange;
                if range~=sensor.MaxRange
                    params=[params,{'MaxRange'}];
                    values=[values,{range}];
                end
                if numel(params)==1
                    edit=driving.internal.scenarioApp.undoredo.SetSensorProperty(app,...
                    sensor,params{1},values{1});
                else
                    edit=driving.internal.scenarioApp.undoredo.SetMultipleSensorProperties(app,...
                    sensor,params,values);
                end
                applyEdit(app,edit);
            elseif this.IsCopying
                this.IsCopying=false;

                app=this.Application;
                index=this.CopyIndex;
                sensor=app.SensorSpecifications(index);
                obj=this.hCoverageAreas(end);
                pvPairs=getPVPairs(sensor);
                xData=get(obj,'XData');
                yData=get(obj,'YData');
                newLocation=[xData(1),yData(1)];
                yaw=this.CurrentYaw;
                fov=this.CurrentFoV;
                inputs={'Name',getString(message('driving:scenarioApp:CopyOfTarget',sensor.Name))};
                if~isempty(fov)
                    inputs=[inputs,{'FieldOfView',fov}];
                end
                edit=driving.internal.scenarioApp.undoredo.AddSensor(app,...
                sensor.Type,pvPairs{:},'SensorLocation',newLocation,'Yaw',yaw,inputs{:});
                applyEdit(app,edit);
            elseif this.IsRotating
                this.IsRotating=false;
                app=this.Application;
                index=this.SensorIndex;
                newYaw=this.CurrentYaw;
                if isempty(newYaw)
                    return;
                end
                sensor=app.SensorSpecifications(index);
                if isa(sensor,'driving.internal.scenarioApp.LidarSensorSpecification')
                    newYaw=newYaw-mean(sensor.AzimuthLimits);
                end

                edit=driving.internal.scenarioApp.undoredo.SetSensorProperty(app,...
                sensor,'Yaw',newYaw);
                applyEdit(app,edit);
            end
            this.InteractionMode='none';
            enableUndoRedo(this.Application);
        end

        function inputs=getAddInputs(this,cp)
            x=cp(1);
            y=cp(2);
            yaw=0;
            range=[];
            fov=[];
            if this.Constrain
                [x,y,yaw]=applyConstrain(this,x,y,yaw);
            end
            if this.Snap
                [x,y,yaw,range,fov]=applySnap(this,x,y,yaw,[],[]);
            end
            extraInputs={};
            if~isempty(range)
                extraInputs={'MaxRange',range};
            end
            if~isempty(fov)&&~(fov==360)
                extraInputs=[extraInputs,{'FieldOfView',fov}];
            end
            inputs=[this.AddInputs,{'SensorLocation',[x,y],'Yaw',yaw},extraInputs];
        end

        function onEgoCarIdChanged(this,varargin)
            updateEgoCar(this);
            updateHitZones(this);
            updateLimitsForEgo(this);
            sensors=this.Application.SensorSpecifications;
            if~isempty(sensors)
                if any(string({sensors.Type})=='ins')
                    postAddINS(this);
                end
            end
        end

        function hFig=createFigure(this,varargin)
            hFig=createFigure@matlabshared.application.Component(this,...
            'WindowButtonMotionFcn',@this.onMouseMove,...
            'WindowButtonUpFcn',@this.onButtonUp,...
            varargin{:});

            hAxes=axes(hFig,...
            'ButtonDownFcn',@this.onButtonDown,...
            'ZLim',[-.1,.1],...
            'Box','on',...
            'LooseInset',[0.06,0.05,0.03,0.03],...
            'Tag','SensorCanvasAxes',...
            'CameraPositionMode','auto',...
            'CameraTargetMode','auto',...
            'DataAspectRatio',[1,1,1],...
            'CameraPositionMode','auto',...
            'CameraTargetMode','auto',...
            'CameraUpVectorMode','auto',...
            'CameraViewAngleMode','auto',...
            'Projection','orthographic');
            hAxes.Camera.TransparencyMethodHint='objectsort';
            this.Axes=hAxes;

            xlabel(hAxes,'X (m)');
            ylabel(hAxes,'Y (m)');
            zlabel(hAxes,'Z (m)');
            axis(hAxes,'vis3d');
            view(hAxes,-90,90);
            grid(hAxes,'off');
            grid(hAxes,'on');
            grid(hAxes,'minor');
            this.hEgoCar=patch(hAxes,...
            'ButtonDown',@this.onButtonDown,...
            'Tag','EgoCar',...
            'FaceAlpha',.2);
            createPushButton(this,hFig,'SensorSettings',@this.settingsCallback,...
            'TooltipString',getString(message('driving:scenarioApp:SensorCanvasSettingsDescription')),...
            'CData',getIcon(this.Application,'settings'),...
            'Position',[5,5,20,20]);
            this.hMirror=line(hAxes,...
            'Tag','Mirror',...
            'LineStyle',':',...
            'HitTest','off',...
            'Color',[.2,.2,.2]);
            locations={'FrontBumper','RearBumper','FrontWindow','RearWindow',...
            'FrontPassengerWheel','FrontDriverWheel','RearPassengerWheel',...
            'RearDriverWheel','RoofFront','RoofCenter'};
            for indx=1:numel(locations)
                this.(['h',locations{indx}])=patch(hAxes,...
                'ButtonDown',@this.onButtonDown,...
                'Tag',locations{indx},...
                'FaceAlpha',0.1);
            end

            this.hSensorContextMenu=uicontextmenu(hFig,...
            'Tag','Sensor',...
            'Callback',@this.onSensorContextMenu);
            updateLimitsForEgo(this);
        end

        function k=createKeyboard(this)
            k=driving.internal.scenarioApp.SensorCanvasKeyboard(this);
        end

        function updateLimitsForEgo(this)
            app=this.Application;
            ego=app.EgoCarId;
            actors=app.ActorSpecifications;
            if~isempty(ego)&&ego<=numel(actors)
                ego=actors(ego);
                this.Center=[ego.Length/2-ego.RearOverhang,0];
                pos=getpixelposition(this.Axes);
                this.UnitsPerPixel=ego.Length/pos(4)*1.3;
            end
            updateLimits(this);
        end
    end
end


