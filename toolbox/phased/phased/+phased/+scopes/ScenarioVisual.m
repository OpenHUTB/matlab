classdef ScenarioVisual<matlabshared.scopes.visual.Visual




    properties(Dependent)
Title
GUIPlatformNames
RadarNames
TrailLength
CameraPerspective
CameraPosition
CameraOrientation
CameraViewAngle
ReferenceRadar
ShowLegend
ShowGround
ShowBeam
BeamWidth
BeamRange
BeamSteering
ShowName
ShowPosition
ShowAltitude
ShowSpeed
ShowAzEl
ShowRange
ShowRadialSpeed
    end
    properties
Fig
Axes
Ground
        Trajectories=[]
        VelocityInputPort=true
        OrientationInputPort=false
        Beam=[]
        hTitle=[]
hCrossHair
CameraButtons
        pReferenceRadar=1
        PlatformNames='Auto'
        NumTrajectories=0
        lastTime=[];
    end
    properties(Access=protected)
SourceListeners
CameraListeners
DialogListener
    end

    properties(Access=private)
        pMarkers;
        pMetrics;
        pDialogPanel;
        hSettingsDialog;
        pLastPos;
        pLastPosBackup;
        pGUIPlatformNames={'Radar 1'};
        pNumRadars=1;
        rPosPort=0;
        rVelPort=0;
        rOrientPort=0;
        tPosPort=0;
        tVelPort=0;
        tOrientPort=0;
        pstepNumStatus;
        pInitialVel;
    end

    methods
        function set.Title(this,value)
            this.hSettingsDialog.hSceneDialog.Title=value;
        end
        function value=get.Title(this)
            value=this.hSettingsDialog.hSceneDialog.Title;
        end
        function set.GUIPlatformNames(this,value)
            this.pGUIPlatformNames=value;


            if isLocked(this)
                this.hSettingsDialog.hSceneDialog.RadarNames=value(1:this.pNumRadars);
            end
        end
        function value=get.GUIPlatformNames(this)
            value=this.pGUIPlatformNames;
        end
        function value=get.RadarNames(this)
            value=this.pGUIPlatformNames(1:this.pNumRadars);
        end
        function set.ReferenceRadar(this,value)
            this.pReferenceRadar=value;
            if isLocked(this)
                this.hSettingsDialog.hSceneDialog.ReferenceRadar=value;
            end
        end
        function value=get.ReferenceRadar(this)
            value=this.pReferenceRadar;
        end
        function set.TrailLength(this,value)
            this.hSettingsDialog.hSceneDialog.TrailLength=value;
        end
        function value=get.TrailLength(this)
            value=this.hSettingsDialog.hSceneDialog.TrailLength;
        end

        function set.CameraPerspective(this,value)
            this.hSettingsDialog.hCameraDialog.CameraPerspective=value;
        end
        function value=get.CameraPerspective(this)
            value=this.hSettingsDialog.hCameraDialog.CameraPerspective;
        end
        function set.CameraPosition(this,value)
            this.hSettingsDialog.hCameraDialog.CameraPosition=value;
        end
        function value=get.CameraPosition(this)
            value=this.hSettingsDialog.hCameraDialog.CameraPosition;
        end
        function set.CameraOrientation(this,value)
            this.hSettingsDialog.hCameraDialog.CameraOrientation=value;
        end
        function value=get.CameraOrientation(this)
            value=this.hSettingsDialog.hCameraDialog.CameraOrientation;
        end
        function set.CameraViewAngle(this,value)
            this.hSettingsDialog.hCameraDialog.CameraViewAngle=value;
        end
        function value=get.CameraViewAngle(this)
            value=this.hSettingsDialog.hCameraDialog.CameraViewAngle;
        end
        function set.ShowLegend(this,value)
            this.hSettingsDialog.hSceneDialog.ShowLegend=value;
        end
        function value=get.ShowLegend(this)
            value=this.hSettingsDialog.hSceneDialog.ShowLegend;
        end
        function set.ShowGround(this,value)
            this.hSettingsDialog.hSceneDialog.ShowGround=value;
        end
        function value=get.ShowGround(this)
            value=this.hSettingsDialog.hSceneDialog.ShowGround;
        end
        function set.ShowBeam(this,value)
            this.hSettingsDialog.hSceneDialog.ShowBeam=value;
        end
        function value=get.ShowBeam(this)
            value=this.hSettingsDialog.hSceneDialog.ShowBeam;
        end
        function set.BeamWidth(this,value)
            this.hSettingsDialog.hSceneDialog.BeamWidth=value;
        end
        function value=get.BeamWidth(this)
            value=this.hSettingsDialog.hSceneDialog.BeamWidth;
        end
        function set.BeamRange(this,value)
            this.hSettingsDialog.hSceneDialog.BeamRange=value;
        end
        function value=get.BeamRange(this)
            value=this.hSettingsDialog.hSceneDialog.BeamRange;
        end
        function set.BeamSteering(this,value)
            this.hSettingsDialog.hSceneDialog.BeamSteering=value;
        end
        function value=get.BeamSteering(this)
            value=this.hSettingsDialog.hSceneDialog.BeamSteering;
        end
        function set.ShowName(this,value)
            this.hSettingsDialog.hAnnotationDialog.ShowName=value;
        end
        function value=get.ShowName(this)
            value=this.hSettingsDialog.hAnnotationDialog.ShowName;
        end
        function set.ShowPosition(this,value)
            this.hSettingsDialog.hAnnotationDialog.ShowPosition=value;
        end
        function value=get.ShowPosition(this)
            value=this.hSettingsDialog.hAnnotationDialog.ShowPosition;
        end
        function set.ShowAltitude(this,value)
            this.hSettingsDialog.hAnnotationDialog.ShowAltitude=value;
        end
        function value=get.ShowAltitude(this)
            value=this.hSettingsDialog.hAnnotationDialog.ShowAltitude;
        end
        function set.ShowSpeed(this,value)
            this.hSettingsDialog.hAnnotationDialog.ShowSpeed=value;
        end
        function value=get.ShowSpeed(this)
            value=this.hSettingsDialog.hAnnotationDialog.ShowSpeed;
        end
        function set.ShowAzEl(this,value)
            this.hSettingsDialog.hAnnotationDialog.ShowAzEl=value;
        end
        function value=get.ShowAzEl(this)
            value=this.hSettingsDialog.hAnnotationDialog.ShowAzEl;
        end
        function set.ShowRange(this,value)
            this.hSettingsDialog.hAnnotationDialog.ShowRange=value;
        end
        function value=get.ShowRange(this)
            value=this.hSettingsDialog.hAnnotationDialog.ShowRange;
        end
        function set.ShowRadialSpeed(this,value)
            this.hSettingsDialog.hAnnotationDialog.ShowRadialSpeed=value;
        end
        function value=get.ShowRadialSpeed(this)
            value=this.hSettingsDialog.hAnnotationDialog.ShowRadialSpeed;
        end

        function resetBeam(this)

            numRadars=this.pNumRadars;
            beamWidth=this.BeamWidth;
            if isscalar(beamWidth)
                beamWidth=beamWidth*ones(2,numRadars);
            elseif isrow(beamWidth)
                beamWidth=[beamWidth;beamWidth];
            elseif iscolumn(beamWidth)
                beamWidth=repmat(beamWidth,1,numRadars);
            end
            beamRange=this.BeamRange;
            if isscalar(beamRange)
                beamRange=beamRange*ones(1,numRadars);
            end
            for bIdx=1:numRadars
                beam=createBeam(this.Axes,beamWidth(:,bIdx),beamRange(bIdx));
                if~isempty(this.Beam)

                    oldBeam=this.Beam(bIdx);
                    beam.Matrix=oldBeam.Matrix;
                    beam.Visible=oldBeam.Visible;
                    delete(oldBeam)
                else

                    beam.Matrix=makehgtform('scale',eps);
                end
                beams(bIdx)=beam;
            end
            this.Beam=beams;
        end
    end
    methods(Access=protected)
        function cleanup(this)
            if ishghandle(this.Axes)
                delete(this.Axes);
            end


            set(hVisParent,'ResizeFcn',[]);
        end

    end
    methods(Static)
        function propertyDb=getPropertySet


            propertyDb=extmgr.PropertySet(...
            'ScenarioProperties','mxArray',[]);
        end
    end
    methods
        function updatePropertySet(this,hConfig)

            if nargin<2
                hConfig=this.Configuration;
            end
            numOfTrajectories=this.NumTrajectories;
            traj=[];mrk=[];metr=[];
            for k=1:numOfTrajectories
                [traj(k).x,traj(k).y,traj(k).z]=...
                getpoints(this.Trajectories(k));
                mrk(k).x=this.pMarkers(k).XData;
                mrk(k).y=this.pMarkers(k).YData;
                mrk(k).z=this.pMarkers(k).ZData;
                metr(k).Position=this.pMetrics(k).Position;
                metr(k).String=this.pMetrics(k).String;
            end
            sP.traj=traj;
            sP.mrk=mrk;
            sP.metr=metr;

            sP.lastTime=this.lastTime;
            sP.pLastPos=this.pLastPos;
            sP.pLastPosBackup=this.pLastPosBackup;
            if~isempty(this.Beam)
                sP.BeamMatrix={this.Beam.Matrix};
            else
                sP.BeamMatrix=[];
            end

            sP.CameraPerspective=this.CameraPerspective;
            if sP.CameraPerspective==2
                sP.CameraPosition=this.Axes.CameraPosition;
                sP.CameraTarget=this.Axes.CameraTarget;
                sP.CameraUpVector=this.Axes.CameraUpVector;
                sP.CameraViewAngle=this.Axes.CameraViewAngle;
            end
            sP.ShowLegend=this.ShowLegend;
            sP.ShowGround=this.ShowGround;
            sP.ShowName=this.ShowName;
            sP.ShowPosition=this.ShowPosition;
            sP.ShowAltitude=this.ShowAltitude;
            sP.ShowSpeed=this.ShowSpeed;
            sP.ShowAzEl=this.ShowAzEl;
            sP.ShowRange=this.ShowRange;
            sP.ShowRadialSpeed=this.ShowRadialSpeed;
            sP.Title=this.Title;
            sP.pInitialVel=this.pInitialVel;


            setValue(hConfig.pPropertySet,'ScenarioProperties',sP);
        end
    end
    methods
        function this=ScenarioVisual(varargin)
            this@matlabshared.scopes.visual.Visual(varargin{:});
            this.SourceListeners=...
            event.listener(this.Application,'SourceRun',@this.onSourceRun);
        end

        function setup(this,hVisParent)
            containerHandle=uicontainer(...
            'parent',hVisParent,...
            'pos',[0,0,1,1]);


            theDP=dialogmgr.DPVerticalPanel(containerHandle);

            theDP.Animation=false;
            theDP.AutoHide=false;

            theDP.PanelLock=true;
            theDP.PanelMinWidth=200;
            theDP.PanelMaxWidth=400;
            theDP.PanelWidth=250;
            theDP.PanelLockWidth=true;
            theDP.SplitterWidth=0;

            theDP.hBodySplitter.ArrowCount=1;
            theDP.hBodySplitter.Visible=false;
            theDP.hBodySplitter.VerticalStrip=false;
            theDP.hBodySplitter.BackgroundColor=[0,0,1];
            theDP.PixelFactor=1;
            theDP.ScrollBarWidth=18;
            theDP.BodyMinHeight=250;
            theDP.BodyMinWidth=300;
            theDP.BodyMinSizeTitle=getString(message('phased:apps:arrayapp:plot'));
            theDP.DialogBorderServicesChanges={'DialogClose','off'};
            theDP.DockLocationMouseDragEnable=false;
            theDP.DockLocation='left';
            theDP.DialogBorderFactory=@dialogmgr.DBTopBar;
            theDP.DialogHorizontalGutter=8;
            theDP.DialogVerticalGutter=0;
            theDP.DialogHoverHighlight=false;

            theDP.DialogBorderDecoration={...
            'TitlePanelBackgroundColorSource','Custom',...
            'TitlePanelBackgroundColor',[166,166,166]./255};
            theDP.DockedDialogNamesInit={'Settings'};


            this.pDialogPanel=theDP;
            theDP.UserData=this;
            setup@matlabshared.scopes.visual.Visual(this,theDP.hBodyPanel);

            theDP.hBodyPanel.BackgroundColor=[0.729,0.831,0.957];
            ax=axes('Parent',theDP.hBodyPanel,'DataAspectRatio',[1,1,1],...
            'Color',[0.87,0.92,0.98],...
            'Projection','perspective',...
            'ActivePositionProperty','position',...
            'Position',[0,0,1,1],...
            'XTickLabel','','YTickLabel','','ZTickLabel','');
            grid(ax,'on');hold(ax,'on');view(ax,45,10);
            ax.Clipping='off';ax.Visible='off';
            ax.SortMethod='depth';
            this.Axes=ax;
            light('Parent',ax');
            this.Ground=phased.scopes.ZBasePlane('Parent',ax,...
            'Color',[0.9529,0.8706,0.7333],'Value',0,...
            'Alpha',1);
            ax.XAxis.Visible='off';
            ax.YAxis.Visible='off';
            ax.ZAxis.Visible='off';
            this.hTitle=...
            annotation(ax.Parent,'textbox',[0.5,0.9,0,.1],...
            'VerticalAlignment','top','HorizontalAlignment','center',...
            'Interpreter','none','FitBoxToText','on','FontSize',12,...
            'Color',[.2,.2,.2],'EdgeColor','none',...
...
...
...
            'String',' ');

            hl=annotation(ax.Parent,'line',[0.45,.55],[0.5,.5],...
            'Color',[0,1,0],'Visible','off');
            vl=annotation(ax.Parent,'line',[0.5,.5],[0.45,.55],...
            'Color',[0,1,0],'Visible','off');
            this.hCrossHair=[hl,vl];
            this.hSettingsDialog=phased.scopes.ScenarioSettingsDialog(this);
            theDP.createAndRegisterDialog(this.hSettingsDialog);
            finalizeDialogRegistration(theDP);
            setDialogPanelVisible(theDP,true)
            setVisible(theDP,true);


            if~ismac&&~ispc
                sppi=get(0,'ScreenPixelsPerInch');
                if sppi>72
                    dSize=1;
                    if sppi>80
                        dSize=2;
                    end
                    if sppi>90
                        dSize=3;
                    end
                    theDP.Dialogs.DialogContent.changeFontSize(-dSize);
                end
            end





            this.Title='';
            f=ancestor(ax,'figure');
            f.Interruptible='on';
            f.HandleVisibility='callback';
            this.Fig=f;







        end











































        function renderToolbars(this)

            mainTB=this.Application.Handles.mainToolbar;
            ctb=cameratoolbar(mainTB.Parent,'NoReset');


            set(this.Axes,'CameraViewAngleMode','auto',...
            'PlotBoxAspectRatioMode','auto');
            uitoggleh=findall(ctb,'Type','uitoggletool');


            this.CameraButtons=uitoggleh(end:-1:5);

            this.CameraButtons([2,4,5,7])=[];
            set(this.CameraButtons,'Parent',mainTB);
            ctb.Visible='off';
            set(this.CameraButtons,'Enable','off','State','off');

            f=this.Fig;
            this.CameraListeners=...
            [addlistener(this.Axes,'CameraPosition',...
            'PostSet',@(~,~)updateCameraPosition(this))...
            ,addlistener(this.Axes,'CameraTarget',...
            'PostSet',@(~,~)updateCameraTarget(this))...
            ,addlistener(this.Axes,'CameraUpVector',...
            'PostSet',@(~,~)updateCameraUpVector(this))...
            ,addlistener(this.Axes,'CameraViewAngle',...
            'PostSet',@(~,~)updateCameraViewAngle(this))...
            ,addlistener(f,'SelectionType',...
            'PostSet',@(~,~)disableRightClick(f))];

            stepNumStatus=spcwidgets.Status(...
            this.Application.Handles.statusBar,...
            'Tag','StepNumStatus',...
            'AutoGrow',true,...
            'AutoGrowAllowSkips',false);
            stepNumStatus.Text='Frame 0';
            this.pstepNumStatus=stepNumStatus;
        end
        function updateCameraPosition(this)
            this.hSettingsDialog.hCameraDialog.CameraPosition=[];
            this.hSettingsDialog.hCameraDialog.CameraOrientation=[];
        end
        function updateCameraTarget(this)
            this.hSettingsDialog.hCameraDialog.CameraOrientation=[];
        end
        function updateCameraUpVector(this)
            this.hSettingsDialog.hCameraDialog.CameraOrientation=[];
        end
        function updateCameraViewAngle(this)
            this.hSettingsDialog.hCameraDialog.CameraViewAngle=[];
        end

        function onSourceRun(this,~,~)

            src=this.Application.DataSource;
            if isempty(src)||src.State.isInRapidAcceleratorAndNotRunning||isDataEmpty(src)
                return
            end
            this.rPosPort=1;
            if this.VelocityInputPort&&this.OrientationInputPort
                this.rVelPort=2;
                this.rOrientPort=3;
                this.tPosPort=4;
                this.tVelPort=5;
                this.tOrientPort=6;
            elseif this.VelocityInputPort
                this.rVelPort=2;
                this.tPosPort=3;
                this.tVelPort=4;
            elseif this.OrientationInputPort
                this.rOrientPort=2;
                this.tPosPort=3;
                this.tOrientPort=4;
            else
                this.tPosPort=2;
            end

            ax=this.Axes;
            rDims=getMaxDimensions(src,this.rPosPort);
            tDims=getMaxDimensions(src,this.tPosPort);

            numRadars=rDims(2);numTargets=tDims(2);
            this.pNumRadars=numRadars;

            numTrajectories=numRadars+numTargets;
            this.NumTrajectories=numTrajectories;
            platformNamesProp=this.PlatformNames;
            if strcmp(platformNamesProp,'Auto')
                plat=1;
                for r=1:numRadars
                    platformNames{plat}=['Radar ',num2str(r)];
                    plat=plat+1;
                end
                for t=1:numTargets
                    platformNames{plat}=['Target ',num2str(t)];
                    plat=plat+1;
                end
                this.GUIPlatformNames=platformNames;
            else

                this.GUIPlatformNames=platformNamesProp;
            end


            this.ReferenceRadar=this.ReferenceRadar;

            if~isempty(this.Trajectories)

                release(this);
            end


            platformColors=get(groot,'defaultAxesColorOrder');
            numColors=size(platformColors,1);
            N=this.TrailLength;
            if isscalar(N)
                N=N*ones(numTrajectories,1);
            end
            for k=1:numTrajectories


                pColor=platformColors(mod(k-1,numColors)+1,:);
                trajectories(k)=animatedline('Parent',ax,'MaximumNumPoints',N(k),...
                'LineWidth',2,'Color',pColor);

                args={'MarkerSize',8,...
                'MarkerEdgeColor',pColor,...
                'MarkerFaceColor',pColor};
                if k<=numRadars
                    markers(k)=plot3(nan,nan,nan,...
                    'Parent',ax,'Color',pColor,'Marker','s',args{:});
                else
                    markers(k)=plot3(nan,nan,nan,...
                    'Parent',ax,'Color',pColor,'Marker','o',args{:});
                end

                metrics(k)=text(nan,nan,nan,'','Parent',ax,...
                'FontSize',8,'Layer','front');

            end

            this.Trajectories=trajectories;
            this.pMarkers=markers;
            this.pMetrics=metrics;
            fig=this.Fig;










            fig.Visible='on';
            l=legend(markers,'String',this.GUIPlatformNames,...
            'Location','northwestoutside','AutoUpdate','off');
            l.UIContextMenu=[];
            fig.Visible='off';
            if~this.ShowLegend
                legend(this.Axes,'hide');
            end
            l.Position;
            l.Location='none';


            sP=getPropertyValue(this,'ScenarioProperties');
            if~isempty(sP)
                if~isempty(sP.traj)
                    traj=sP.traj;
                    mrk=sP.mrk;
                    metr=sP.metr;
                    for k=1:numTrajectories
                        addpoints(trajectories(k),traj(k).x,traj(k).y,traj(k).z);
                        set(markers(k),'XData',mrk(k).x,'YData',mrk(k).y,'ZData',mrk(k).z);
                        set(metrics(k),'Position',metr(k).Position,'String',metr(k).String);
                    end
                end
                this.lastTime=sP.lastTime;
                this.pLastPos=sP.pLastPos;
                this.pLastPosBackup=sP.pLastPosBackup;
            end
            this.resetBeam();
            if~isempty(sP)
                if~isempty(sP.BeamMatrix)
                    [this.Beam.Matrix]=sP.BeamMatrix{:};
                end
                if sP.CameraPerspective==2
                    ax.CameraPosition=sP.CameraPosition;
                    ax.CameraTarget=sP.CameraTarget;
                    ax.CameraUpVector=sP.CameraUpVector;
                    ax.CameraViewAngle=sP.CameraViewAngle;
                end
                this.CameraPerspective=sP.CameraPerspective;
                this.ShowLegend=sP.ShowLegend;
                this.ShowGround=sP.ShowGround;
                this.ShowName=sP.ShowName;
                this.ShowPosition=sP.ShowPosition;
                this.ShowAltitude=sP.ShowAltitude;
                this.ShowSpeed=sP.ShowSpeed;
                this.ShowAzEl=sP.ShowAzEl;
                this.ShowRange=sP.ShowRange;
                this.ShowRadialSpeed=sP.ShowRadialSpeed;
                this.Title=sP.Title;
                this.pInitialVel=sP.pInitialVel;
            end


            this.ShowBeam=this.ShowBeam;
        end
        function release(this)
            this.NumTrajectories=0;
            delete(this.Trajectories);
            this.Trajectories=[];
            this.lastTime=[];
            delete(this.pMarkers);
            delete(this.pMetrics);
            delete(this.Beam);
            this.Beam=[];
        end
        function reset(this)
            src=this.Application.DataSource;
            this.lastTime=-getSampleTimes(src,1);
            this.pLastPos=[];
            this.pLastPosBackup=[];
            this.pstepNumStatus.Text='';
            this.pInitialVel=nan(3,this.NumTrajectories);
            for k=1:this.NumTrajectories
                clearpoints(this.Trajectories(k))
                currMarker=this.pMarkers(k);
                currMetrics=this.pMetrics(k);
                currMarker.XData=nan;
                currMarker.YData=nan;
                currMarker.ZData=nan;
                currMetrics.Position=[nan,nan,nan];
            end

            [this.Beam.Matrix]=deal(makehgtform('scale',eps));

            this.CameraPerspective=this.CameraPerspective;
        end

        function ret=isLocked(this)
            src=this.Application.DataSource;
            ret=~isempty(src)&&isRunning(src);
        end

        function update(this)


            src=this.Application.DataSource;



            currentTime=src.getTimeOfDisplayData;
            st=getSampleTimes(src,1);

            beginTime=this.lastTime+st;

            numOfTrajectories=this.NumTrajectories;
            if beginTime>currentTime

                refreshOnly=true;
                beginTime=currentTime;

                this.pLastPos=this.pLastPosBackup;
            else
                refreshOnly=false;
            end


            dataSt=getData(src,beginTime,currentTime);
            pos=cat(1,dataSt([this.rPosPort,this.tPosPort]).values);
            if isempty(pos)
                return;
            end

            this.pstepNumStatus.Text=['Frame ',num2str(src.FrameCount)];


            bufferedPos=size(pos,2)-1;

            this.lastTime=currentTime;









            if this.VelocityInputPort
                vel=cat(1,dataSt([this.rVelPort,this.tVelPort]).values);
            else
                if bufferedPos
                    vel=(pos(:,end)-pos(:,end-1))/st;
                elseif~isempty(this.pLastPos)
                    vel=(pos-this.pLastPos)/st;
                else

                    vel=[];
                end
            end



            this.pLastPosBackup=this.pLastPos;
            this.pLastPos=pos(:,end);

            platformNames=this.GUIPlatformNames;
            posIndex=1;
            radarTraj=this.ReferenceRadar;
            radarIndex=(radarTraj-1)*3+1;
            radarPos=pos(radarIndex:radarIndex+2,end);
            refRadarVel=[];
            if~isempty(vel)
                refRadarVel=vel(radarIndex:radarIndex+2,end);
            end

            numRadars=this.pNumRadars;
            if this.OrientationInputPort

                orientAxes=dataSt(this.rOrientPort).values(end-(9*numRadars-1):end);

                radarAxesIndex=(radarTraj-1)*9+1;
                refRadarAxes=orientAxes(radarAxesIndex:radarAxesIndex+8);
                refRadarAxes=reshape(refRadarAxes,3,3);


                x=refRadarAxes(:,1);
                y=refRadarAxes(:,2);
                z=refRadarAxes(:,3);
                refRadarAxes=[x/norm(x),y/norm(y),z/norm(z)];
            else


                if~isempty(refRadarVel)
                    if isnan(this.pInitialVel(1,1))




                        idx=1;
                        for k=1:numOfTrajectories
                            getOrientation(this,vel(idx:idx+2,end),k);
                            idx=idx+3;
                        end
                    end
                    refRadarAxes=getOrientation(this,refRadarVel,radarTraj);
                else
                    refRadarAxes=[];
                end
            end
            showBeam=this.ShowBeam;

            for k=1:numOfTrajectories

                lastPos=pos(posIndex:posIndex+2,end);


                currTraj=this.Trajectories(k);

                if~refreshOnly
                    addpoints(currTraj,pos(posIndex,:),pos(posIndex+1,:),pos(posIndex+2,:));
                end


                currMarker=this.pMarkers(k);
                showMetric=true;
                if k<=numRadars
                    radarAxes=[];
                    if k==radarTraj
                        if this.CameraPerspective==3
                            this.Axes.CameraPosition=lastPos;


                            if~isempty(refRadarAxes)
                                beamSteering=this.BeamSteering;
                                if iscolumn(beamSteering)
                                    Az=beamSteering(1);El=beamSteering(2);
                                else
                                    Az=beamSteering(1,k);El=beamSteering(2,k);
                                end
                                radarTform=refRadarAxes;radarTform(4,4)=1;
                                orient=makehgtform('axisrotate',refRadarAxes(:,3),deg2rad(Az),...
                                'axisrotate',refRadarAxes(:,2),-deg2rad(El))*radarTform;
                                this.Axes.CameraTarget=lastPos+orient(1:3,1);
                                this.Axes.CameraUpVector=orient(1:3,3);
                            end
                            this.Axes.CameraViewAngle=max(this.BeamWidth);

                            showMetric=false;
                        end
                        if showBeam~=1
                            radarAxes=refRadarAxes;
                        end
                    else
                        if showBeam==3
                            if this.OrientationInputPort

                                radarAxesIndex=(k-1)*9+1;
                                radarAxes=orientAxes(radarAxesIndex:radarAxesIndex+8);
                                radarAxes=reshape(radarAxes,3,3);


                                x=radarAxes(:,1);
                                y=radarAxes(:,2);
                                z=radarAxes(:,3);
                                radarAxes=[x/norm(x),y/norm(y),z/norm(z)];
                            else




                                if~isempty(vel)
                                    radarIndex=(k-1)*3+1;
                                    radarVel=vel(radarIndex:radarIndex+2,end);
                                    radarAxes=getOrientation(this,radarVel,k);
                                end
                            end
                        end
                    end


                    if~isempty(radarAxes)
                        radarTform=radarAxes;radarTform(4,4)=1;
                        beamSteering=this.BeamSteering;
                        if iscolumn(beamSteering)
                            Az=beamSteering(1);El=beamSteering(2);
                        else
                            Az=beamSteering(1,k);El=beamSteering(2,k);
                        end
                        orient=makehgtform('axisrotate',radarAxes(:,3),deg2rad(Az),...
                        'axisrotate',radarAxes(:,2),-deg2rad(El))*radarTform;






                        trnslate=...
                        makehgtform('translate',lastPos);
                        try
                            this.Beam(k).Matrix=trnslate*orient;
                        catch ME
                            if strcmp(ME.identifier,'MATLAB:hg:BadTransformMatrix')

                                ME=MException('ScenarioVisual:BadOrientationMatrix','bad orientation matrix');
                                throw(ME);
                            else
                                rethrow(ME);
                            end
                        end
                    end
                end
                currMarker.XData=lastPos(1);
                currMarker.YData=lastPos(2);
                currMarker.ZData=lastPos(3);
                currMetrics=this.pMetrics(k);
                if showMetric

                    currMetrics.Position=lastPos;
                    metricsStr='';


                    if this.ShowName
                        metricsStr=['   ',platformNames{k}];
                    end

                    if this.ShowPosition

                        val=lastPos;
                        metricsStr=[metricsStr,sprintf(['\n           x: %.2f\n'...
                        ,'           y: %.2f\n'...
                        ,'           z: %.2f'],...
                        val(1),val(2),val(3))];
                    end


                    if this.ShowAltitude
                        [val,~,unit]=engunits(lastPos(3));
                        metricsStr=[metricsStr,sprintf('\n         alt: %.2f %sm',val,unit)];
                    end


                    if isempty(vel)
                        if this.ShowSpeed
                            metricsStr=[metricsStr,sprintf('\n   speed: N/A')];
                        end
                    else
                        lastVel=vel(posIndex:posIndex+2,end);
                        if this.ShowSpeed
                            [val,~,unit]=engunits(norm(lastVel));
                            metricsStr=[metricsStr,sprintf('\n   speed: %.2f %sm/s',val,unit)];
                        end
                    end
                    if k~=radarTraj


                        if this.ShowRange
                            [val,~,unit]=engunits(norm(lastPos-radarPos));
                            metricsStr=[metricsStr,sprintf('\n    range: %.2f %sm',val,unit)];
                        end


                        if this.ShowRadialSpeed
                            if isempty(refRadarVel)
                                metricsStr=[metricsStr,sprintf('\n      rspd: N/A')];
                            else
                                rspeed=radialspeed(lastPos,lastVel,...
                                radarPos,refRadarVel);
                                [val,~,unit]=engunits(rspeed);
                                metricsStr=[metricsStr,sprintf('\n      rspd: %.2f %sm/s',val,unit)];
                            end
                        end

                        if this.ShowAzEl
                            if isempty(refRadarAxes)
                                metricsStr=[metricsStr,sprintf('\n         az: N/A\n          el: N/A')];
                            else
                                lclcoord=phased.internal.global2localcoord(lastPos,'rs',radarPos,refRadarAxes);

                                ang=lclcoord(1:2,:);
                                metricsStr=[metricsStr,sprintf('\n         az: %.2f deg\n          el: %.2f deg',ang(1),ang(2))];
                            end
                        end
                    end

                    currMetrics.String=metricsStr;
                else
                    currMetrics.String='';
                end
                posIndex=posIndex+3;
            end
        end
        function M=getOrientation(this,v,k)






            initialVel=this.pInitialVel(:,k);
            if isnan(initialVel(1))


                this.pInitialVel(:,k)=v;
                M=eye(3);
            else
                M=rotvv(initialVel,v);
            end
        end
    end
end

function t=createBeam(ax,bw,range)

    n=20;
    bw=bw./2;


    theta=(-pi:2*pi/(n-1):pi)+pi/4;
    bwMax=max(bw);
    e=ceil(bwMax/180*20);
    phi2=(bw(1):-bw(1)/(e-1):0).';
    phi1=(bw(2):-bw(2)/(e-1):0).';


    x=[0;sind(phi1)]*cos(theta)*range;
    y=[0;sind(phi2)]*sin(theta)*range;

    z=([0;cosd(phi1)]*cos(theta).^2+[0;cosd(phi2)]*sin(theta).^2)*range;
    t=hgtransform('Parent',ax);


    c=ones(size(x));
    c(2:end,:)=20;
    s=surf(z,y,x,c,'Parent',t,'LineStyle','none',...
    'CDataMapping','direct',...
    'FaceAlpha',.4);
    s.XLimInclude='off';
    s.YLimInclude='off';
    s.ZLimInclude='off';
    set(s,'AmbientStrength',0.3,...
    'DiffuseStrength',0.6,...
    'SpecularStrength',0.9,...
    'SpecularExponent',20,...
    'SpecularColorReflectance',1.0,...
    'FaceLighting','gouraud');
end


function disableRightClick(f)
    if strcmp(f.SelectionType,'alt')
        f.SelectionType='normal';
    end
end
function T=rotvv(v1,v2)

    if isequal(v1,v2)
        T=eye(3);
    else
        nzidx=any(v1~=0);
        v1(:,nzidx)=bsxfun(@rdivide,v1(:,nzidx),sqrt(sum(abs(v1(:,nzidx).^2))));
        nzidx=any(v2~=0);
        v2(:,nzidx)=bsxfun(@rdivide,v2(:,nzidx),sqrt(sum(abs(v2(:,nzidx).^2))));

        v1azel=phased.internal.dirvec2azel(v1);
        v2azel=phased.internal.dirvec2azel(v2);

        T=rotazel(v2azel(1),v2azel(2))*rotazel(v1azel(1),v1azel(2)).';
    end

end
function T=rotazel(az,el)
    T=rotz(az)*roty(-el);
end