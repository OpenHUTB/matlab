classdef(Sealed)GlobeViewer<matlab.mixin.SetGet




    properties
ReferenceLocation
PlatformHistoryDepth
TrackHistoryDepth
NumCovarianceSigma
CoverageRangeScale
TrackLabelScale
CoverageMode
TrackLabelOffset
ShowDroppedTracks
    end

    properties(Hidden)
Viewer
Debug
    end

    properties(Constant,Hidden)
        NumTrajectorySamples=1000
    end

    properties(Access=protected)

TrackInputParser
DetectionInputParser
PlatformInputParser
CoverageInputParser
TrajectoryInputParser


        ColorsDark=[255,255,17;...
        19,159,255;...
        255,105,41;...
        100,212,19;...
        183,70,255;...
        15,255,255;...
        255,19,166]/255;


        PlatformTrajectoryDoneIDs=[];
        TrackAndSourceIDs=[];
        TrackCounter=0;


QueueCleanUp
    end

    methods
        function set.ReferenceLocation(obj,x)
            validateattributes(x,{'numeric'},{'row','numel',3,'real','finite'});
            obj.ReferenceLocation=x;
        end

        function set.PlatformHistoryDepth(obj,x)
            validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'});
            obj.PlatformHistoryDepth=x;
        end

        function set.TrackHistoryDepth(obj,x)
            validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'});
            obj.TrackHistoryDepth=x;
        end

        function set.NumCovarianceSigma(obj,x)
            validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'});
            obj.NumCovarianceSigma=x;
        end

        function set.CoverageRangeScale(obj,x)
            validateattributes(x,{'numeric'},{'scalar','positive','finite'});
            obj.CoverageRangeScale=x;
        end

        function set.TrackLabelScale(obj,x)
            validateattributes(x,{'numeric'},{'scalar','positive','finite'});
            obj.TrackLabelScale=x;
        end

        function set.CoverageMode(obj,x)
            obj.CoverageMode=validatestring(x,{'Beam','Coverage'});
        end

        function set.TrackLabelOffset(obj,x)
            validateattributes(x,{'numeric'},{'row','numel',3,'real','finite'});
            obj.TrackLabelOffset=x;
        end

        function set.ShowDroppedTracks(obj,x)
            validateattributes(x,{'logical'},{'scalar'});
            obj.ShowDroppedTracks=x;
        end
    end


    methods
        function[obj,gl]=GlobeViewer(varargin)


            try
                matlab.internal.lang.capability.Capability.require('LocalClient');
            catch ME
                throwAsCaller(ME)
            end


            p=inputParser();
            p.StructExpand=false;
            addOptional(p,'Figure',[]);
            addParameter(p,'Basemap','satellite');
            addParameter(p,'Terrain','none');
            addParameter(p,'ReferenceLocation',[0,0,0]);
            addParameter(p,'PlatformHistoryDepth',1000);
            addParameter(p,'TrackHistoryDepth',1000);
            addParameter(p,'NumCovarianceSigma',2);
            addParameter(p,'CoverageRangeScale',1);
            addParameter(p,'TrackLabelScale',1);
            addParameter(p,'CoverageMode','Beam');
            addParameter(p,'TrackLabelOffset',[0,0,0]);
            addParameter(p,'ShowDroppedTracks',true);
            addParameter(p,'Name',"");
            addParameter(p,'Debug',false);
            parse(p,varargin{:});


            proplist={'ReferenceLocation','PlatformHistoryDepth','TrackHistoryDepth',...
            'NumCovarianceSigma','CoverageRangeScale',...
            'TrackLabelScale','CoverageMode','TrackLabelOffset','ShowDroppedTracks',...
            'Debug'};
            for i=1:numel(proplist)
                obj.(proplist{i})=p.Results.(proplist{i});
            end

            basemap=p.Results.Basemap;
            terrain=p.Results.Terrain;
            fig=p.Results.Figure;

            if isempty(fig)
                fig=uifigure("Position",[560,300,800,600],"Visible","off");
            end


            glopt=globe.internal.GlobeOptions;
            glopt.EnableHomeButton=true;
            glopt.EnableSceneModePicker=false;
            glopt.EnableBaseLayerPicker=true;
            glopt.EnableOSM=false;
            glopt.EnableAlternateCameraPosition=true;
            glopt.UseDebug=obj.Debug;
            gl=globe.graphics.GeographicGlobe("Parent",fig,...
            "Basemap",basemap,...
            "Terrain",terrain,...
            "GlobeOptions",glopt,...
            "NextPlot","add"...
            );


            obj.Viewer=gl.GlobeViewer;
            obj.Viewer.Name=p.Results.Name;


            createInputParsers(obj);


            gl.Parent.Visible='on';

        end
    end


    methods
        function plotScenario(obj,scene,varargin)



            narginchk(2,4);
            validateattributes(scene,{'trackingScenario'},{'scalar'});


            if scene.IsEarthCentered
                refframe='ECEF';
            else
                refframe='NED';
            end
            platforms=[scene.Platforms{:}];
            covcon=coverageConfig(scene);
            plotScenarioComps(obj,platforms,refframe,covcon,varargin{:});
        end

        function plotPlatform(obj,platforms,varargin)



            p=obj.PlatformInputParser;
            parse(p,platforms,varargin{:});
            markerstyle=p.Results.Marker;
            trajmode=p.Results.TrajectoryMode;
            color=p.Results.Color;
            width=p.Results.LineWidth;
            refframe=p.Results.ReferenceFrame;


            queuePlots(obj);

            N=numel(platforms);
            msg=message("shared_radarfusion:GlobeViewer:BadColorInput","Color","platforms");
            sizedColors=obj.validateColorSize(color,N,msg);
            if iscell(platforms)
                platforms=[platforms{:}];
            end
            ids=arrayfun(@(x)['marker',num2str(x.PlatformID)],platforms,'UniformOutput',false);

            allpositions=zeros(N,3);

            viewerColors=cell(1,N);
            for i=1:N
                platform=platforms(i);
                allpositions(i,:)=plat2lla(obj,platform,refframe);
                viewerColors{i}=sizedColors(i,:);
            end


            valid=~any(isnan(allpositions),2);


            obj.Viewer.marker(allpositions(valid,:),markerstyle,...
            "Color",viewerColors(valid),...
            "ID",ids(valid),...
            "IconSize",[8,8],...
            "Animation",'none');


            if strcmpi(trajmode,'Full')
                plotPlatformFullTrajectory(obj,platforms,sizedColors,width);
            elseif strcmpi(trajmode,'History')
                for i=find(valid)'
                    poslla=allpositions(i,:);
                    trajID="P"+num2str(platforms(i).PlatformID)+"History";
                    obj.Viewer.lineCollection({{poslla}},...
                    "Indices",{{1}},...
                    "Color",viewerColors(i),...
                    "Width",width,...
                    "ID",trajID,...
                    "HistoryDepth",obj.PlatformHistoryDepth);
                end
            end

            submitPlots(obj);
        end

        function plotTrajectory(obj,trajs,varargin)

            p=obj.TrajectoryInputParser;
            parse(p,trajs,varargin{:});
            color=p.Results.Color;
            width=p.Results.LineWidth;

            queuePlots(obj);

            if iscell(trajs)
                alltraj=trajs;
            else
                alltraj={trajs};
            end
            N=numel(alltraj);
            msg=message('shared_radarfusion:GlobeViewer:BadColorInput','Color','trajectories');
            sizedColor=obj.validateColorSize(color,N,msg);

            for i=1:N
                traj=alltraj{i};
                cond=isa(traj,'fusion.scenario.internal.mixin.PlatformTrajectory')&&...
                ~isempty(traj)&&isprop(traj,'Waypoints')&&size(traj.Waypoints,1)>1&&...
                isprop(traj,'TimeOfArrival')&&~isempty(traj.TimeOfArrival);
                if cond
                    plotTrajectoryLine(obj,traj,sizedColor(i,:),width);
                else
                    error(message('shared_radarfusion:GlobeViewer:BadTrajInput',...
                    'trajectory'));
                end
            end

            submitPlots(obj);
        end

        function plotTrack(obj,tracks,varargin)



            p=obj.TrackInputParser;
            parse(p,tracks,varargin{:});
            inputs=p.Results;
            refframe=validatestring(inputs.ReferenceFrame,{'NED','ENU','ECEF'});
            labelStyle=inputs.LabelStyle;


            [tracks,possel,velsel,colors,customlabels]=validateTrackInputsJointly(obj,tracks,inputs);


            [isCurrentTrack,newTrackIds,allIDs]=manageTrackIDs(obj,tracks);


            N=numel(tracks);
            allpositions=zeros(N,3);


            queuePlots(obj);

            for i=1:N
                track=tracks(i);
                color=colors{i};

                [poslla,covenu]=calcTrackPosition(obj,track,refframe,possel{i});
                allpositions(i,:)=poslla;


                obj.Viewer.lineCollection({{poslla}},"Color",color,...
                "Width",inputs.LineWidth,...
                "Indices",{{1}},...
                "ID",[allIDs{i},'History'],...
                "HistoryDepth",obj.TrackHistoryDepth,...
                "Animation","none");


                plotCovarianceEllipse(obj,poslla,covenu,['trackCovariance',allIDs{i}],color,0.3);


                plotTrackLabel(obj,track,poslla,color,labelStyle,refframe,velsel{i},customlabels(i));
            end


            obj.Viewer.marker(allpositions,'s',...
            'Color',colors,'ID',allIDs,...
            'IconSize',[8,8],...
            "Animation","none");


            removeDroppedTracks(obj,~isCurrentTrack);
            obj.TrackAndSourceIDs=[obj.TrackAndSourceIDs(:,isCurrentTrack),newTrackIds];

            submitPlots(obj);
        end

        function plotCoverage(obj,configs,varargin)


            queuePlots(obj);
            p=obj.CoverageInputParser;
            parse(p,configs,varargin{:});
            color=p.Results.Color;
            refframe=p.Results.ReferenceFrame;
            alpha=p.Results.Alpha;


            radarfusion.internal.coveragePlotter.validateConfig(configs);
            N=numel(configs);
            msg=message('shared_radarfusion:GlobeViewer:BadColorInput','Color','coverages');
            sizedColors=obj.validateColorSize(color,N,msg);
            for i=1:N
                config=configs(i);
                pos=config.Position;
                if anynan(pos)
                    continue
                end
                if strcmp(refframe,'ECEF')
                    location=fusion.internal.frames.ecef2lla(pos);
                elseif strcmp(refframe,'NED')
                    location=fusion.internal.frames.ned2lla(pos,obj.ReferenceLocation);
                else
                    location=fusion.internal.frames.enu2lla(pos,obj.ReferenceLocation);
                end

                numPoints=32;
                fov=config.FieldOfView;
                range=config.Range*obj.CoverageRangeScale;

                if strcmp(obj.CoverageMode,'Beam')
                    vertices=radarfusion.internal.coveragePlotter.beamVertices(numPoints,fov,range);
                    beam2sens=radarfusion.internal.coveragePlotter.beamFrameTransform(config.LookAngle);
                elseif strcmp(obj.CoverageMode,'Coverage')
                    vertices=radarfusion.internal.coveragePlotter.coverageVertices(numPoints,fov,config.ScanLimits,range);
                    beam2sens=eye(4);
                end
                faces=radarfusion.internal.coveragePlotter.getFaces(numPoints,[0,fov(1)]);
                sens2scenario=radarfusion.internal.coveragePlotter.coverageFrameTransform([0,0,0],config.Orientation);
                beam2scenario=sens2scenario*beam2sens;
                rotation=beam2scenario(1:3,1:3);
                vertices=(rotation*vertices')';
                faces=faces';
                indices=faces(:)-1;
                CData=repmat(sizedColors(i,:),numel(indices)/3+2,1);


                switch refframe
                case 'ECEF'
                    eulxyz=enu2ecef(obj,location(1),location(2));
                    eulzyx=euler2euler(obj,eulxyz,'xyz','zyx');
                case 'ENU'
                    eulzyx=[0,0,0];
                case 'NED'
                    eulzyx=[90,0,180];
                end

                surfRotation=eulzyx.*[1,-1,1];

                obj.Viewer.surface(location,vertices,indices,CData,...
                "Animation",'none',...
                "Transparency",alpha,...
                "Rotation",surfRotation,...
                "ID",['beamID',num2str(config.Index)]);
            end

            submitPlots(obj);
        end

        function plotDetection(obj,detections,varargin)


            p=obj.DetectionInputParser;
            parse(p,detections,varargin{:});
            refframe=validatestring(p.Results.ReferenceFrame,...
            {'NED','ENU','ECEF'});
            color=p.Results.Color;
            queuePlots(obj);

            if isempty(detections)
                submitPlots(obj)
                return
            end

            if iscell(detections)
                detarray=[detections{:}];
            else
                detarray=detections;
            end
            validateattributes(detarray,{'objectDetection'},{'vector'});
            sensInd=[detarray.SensorIndex];
            uniqSensInd=unique(sensInd);
            numSensors=numel(uniqSensInd);
            refloc=obj.ReferenceLocation;
            msg=message('shared_radarfusion:GlobeViewer:BadDetectionColorInput',...
            'Color','SensorIndex','detections');
            sensorColors=obj.validateColorSize(color,numSensors,msg);

            for i=1:numSensors
                dets=detarray(sensInd==uniqSensInd(i));
                n=numel(dets);
                allmeas_lla=zeros(n,3);
                allcov_enu=zeros(3,3,n);

                for k=1:n
                    [cartpos,~,cartcov]=...
                    matlabshared.tracking.internal.fusion.parseDetectionForInitFcn(dets(k),'plotDetection','double');

                    switch refframe
                    case 'NED'
                        llameas=fusion.internal.frames.ned2lla(cartpos',refloc);
                        Rned2enu=[0,1,0;1,0,0;0,0,-1];
                        allcov_enu(:,:,k)=Rned2enu*cartcov*Rned2enu';
                        allmeas_lla(k,:)=llameas;
                    case 'ENU'
                        llameas=fusion.internal.frames.enu2lla(cartpos',refloc);
                        allcov_enu(:,:,k)=cartcov;
                        allmeas_lla(k,:)=llameas;
                    case 'ECEF'
                        llameas=fusion.internal.frames.ecef2lla(cartpos');
                        Recef2enu=fusion.internal.frames.ecef2enurotmat(llameas(1),llameas(2));
                        allcov_enu(:,:,k)=Recef2enu*cartcov*Recef2enu';
                        allmeas_lla(k,:)=llameas;
                    end
                end

                obj.Viewer.point(allmeas_lla,...
                "Color",sensorColors(i,:),...
                "ID",{"detectionID"+num2str(uniqSensInd(i))},...
                "Animation",'none');

                for j=1:numel(dets)
                    cov=allcov_enu(:,:,j);
                    plotCovarianceEllipse(obj,allmeas_lla(j,:),cov,['detCovariance',num2str(uniqSensInd(i)),num2str(j)],sensorColors(i,:),0.2);
                end
            end

            submitPlots(obj);
        end
    end


    methods
        function clear(obj)

            obj.Viewer.point([0,0,-2000],"Animation","none");

            clear(obj.Viewer);
            obj.PlatformTrajectoryDoneIDs=[];
            obj.TrackAndSourceIDs=[];
            obj.TrackCounter=0;
        end

        function img=snapshot(obj)

            img=obj.Viewer.Window.getScreenshot;
            if nargout==0
                imshow(img);
            end
        end
    end


    methods(Access=protected)

        function plotScenarioComps(obj,platforms,refframe,covcon,detections,tracks)


            if~isempty(platforms)
                [kinPlatforms,wpPlatforms]=obj.sortPlatforms(platforms);
                if~isempty(wpPlatforms)

                    plotPlatform(obj,wpPlatforms,refframe,'TrajectoryMode','Full');
                end
                if~isempty(kinPlatforms)

                    plotPlatform(obj,kinPlatforms,refframe,'TrajectoryMode','History');
                end
            end


            if~isempty(covcon)
                plotCoverage(obj,covcon,refframe);
            end


            if nargin>4&&~isempty(detections)
                plotDetection(obj,detections,refframe);
            end


            if nargin>5
                plotTrack(obj,tracks,refframe);
            end
        end

        function position_lla=plat2lla(obj,platform,refframe)
            isLLA=isprop(platform,'Trajectory')&&isGeo(platform.Trajectory);
            pos=platform.Position(:)';
            if isLLA
                position_lla=pos;
            elseif strcmp(refframe,'NED')
                position_lla=fusion.internal.frames.ned2lla(pos,obj.ReferenceLocation);
            elseif strcmp(refframe,'ENU')
                position_lla=fusion.internal.frames.enu2lla(pos,obj.ReferenceLocation);
            elseif strcmp(refframe,'ECEF')
                position_lla=fusion.internal.frames.ecef2lla(pos);
            end

        end

        function plotPlatformFullTrajectory(obj,platforms,sizeColors,width)

            if isstruct(platforms)||~isempty(obj.sortPlatforms(platforms))
                error(message('shared_radarfusion:GlobeViewer:BadTrajMode',...
                'platforms','TrajectoryMode','History','None'));
            end

            for i=1:numel(platforms)
                id=platforms(i).PlatformID;


                if~any(obj.PlatformTrajectoryDoneIDs==id)
                    obj.PlatformTrajectoryDoneIDs=[obj.PlatformTrajectoryDoneIDs,id];
                    plotTrajectoryLine(obj,platforms(i).Trajectory,sizeColors(i,:),width)
                end
            end
        end

        function plotTrajectoryLine(obj,traj,color,width)
            nSamples=obj.NumTrajectorySamples;
            sampTimes=linspace(traj.TimeOfArrival(1),traj.TimeOfArrival(end),nSamples);
            samplePositions=lookupPose(traj,sampTimes);
            if isa(traj,'waypointTrajectory')
                switch traj.ReferenceFrame
                case 'NED'
                    sampleLLA=fusion.internal.frames.ned2lla(samplePositions,obj.ReferenceLocation);
                case 'ENU'
                    sampleLLA=fusion.internal.frames.enu2lla(samplePositions,obj.ReferenceLocation);
                end
            else
                sampleLLA=samplePositions;
            end
            obj.Viewer.lineCollection({sampleLLA},...
            "HistoryDepth",nSamples,...
            "Color",color,...
            "Width",width);
        end

        function plotCovarianceEllipse(obj,lla,cov_enu,id,color,alpha)

            covsize=obj.NumCovarianceSigma;
            if covsize==0
                return
            end


            [Rpa2enu,sqradii]=eig(cov_enu);
            radii=covsize*sqrt(diag(sqradii))';
            if det(Rpa2enu)<0

                Rpa2enu=Rpa2enu(:,[2,1,3]);
                radii=radii([2,1,3]);
            end
            eulzyx=eulerd(quaternion(real(Rpa2enu'),'rotmat','frame'),'zyx','frame');

            eulglobe=eulzyx.*[1,-1,1];



            obj.Viewer.ellipsoid(lla,real(radii),...
            'Rotation',eulglobe,...
            'Color',color,...
            'Transparency',alpha,...
            'ID',id,...
            'Animation','none');

        end

        function[tracks,posselOut,velselOut,colorsOut,labelsOut]=validateTrackInputsJointly(obj,tracks,inputs)

















            labelStyle=inputs.LabelStyle;
            colorsIn=inputs.Color;
            posselIn=inputs.PositionSelector;
            velselIn=inputs.VelocitySelector;
            customlabel=inputs.CustomLabel;

            iscelltracks=iscell(tracks);
            if iscelltracks
                P=numel(tracks);
                numellist=cellfun(@numel,tracks);
                N=sum(numellist);
                indlist=1+cumsum([0,numellist]);

                tracks=[tracks{:}];
            else
                P=1;
                N=numel(tracks);
            end


            if iscell(posselIn)
                if numel(posselIn)==1
                    posselOut=repmat(posselIn,1,N);
                elseif numel(posselIn)==P
                    posselOut=cell(1,N);
                    for i=1:P
                        posselOut(indlist(i):indlist(i+1)-1)=repmat(posselIn(i),1,numellist(i));
                    end
                else
                    error(message("shard_radarfusion:GlobeViewer:BadCellArraySize","plotTrack",num2str(P),"PositionSelector"));
                end
            else

                posselOut=repmat({posselIn},1,N);
            end


            if iscell(velselIn)
                if numel(velselIn)==1
                    velselOut=repmat(velselIn,1,N);
                elseif numel(velselIn)==P
                    velselOut=cell(1,N);
                    for i=1:P
                        velselOut(indlist(i):indlist(i+1)-1)=repmat(velselIn(i),1,numellist(i));
                    end
                else
                    error(message("shard_radarfusion:GlobeViewer:BadCellArraySize","plotTrack",num2str(P),"VelocitySelector"));
                end
            else

                velselOut=repmat({velselIn},1,N);
            end


            if strcmp(colorsIn,'Auto')
                colorsOut=autoColor(obj,tracks);
            elseif iscell(colorsIn)
                if numel(colorsIn)==1
                    colorsOut=repmat(colorsIn,1,N);
                elseif numel(colorsIn)==P
                    colorsOut=cell(1,N);
                    for i=1:P
                        colorsOut(indlist(i):indlist(i+1)-1)=repmat(colorsIn(i),1,numellist(i));
                    end
                else
                    error(message("shard_radarfusion:GlobeViewer:BadCellArraySize","plotTrack",num2str(P),"Color"));
                end
            else
                k=size(colorsIn,1);
                if k==1
                    colorsOut=repmat({colorsIn},1,N);
                elseif k==P
                    colorsOut=cell(1,N);
                    for i=1:P
                        colorsOut(indlist(i):indlist(i+1)-1)=repmat({colorsIn(i,:)},1,numellist(i));
                    end
                elseif k==N
                    colorsOut=num2cell(colorsIn,2)';
                elseif iscelltracks
                    error(message("shared_radarfusion:GlobeViewer:BadTrackColorInput","Color","tracks"));
                else
                    error(message("shared_radarfusion:GlobeViewer:BadColorInput","Color","tracks"));
                end
            end


            if strcmp(labelStyle,'Custom')
                if iscell(customlabel)
                    if numel(customlabel)==N
                        for i=1:N
                            try
                                validateattributes(customlabel{i},{'string','char'},{});
                            catch
                                error(message("shared_radarfusion:GlobeViewer:BadCustomLabelType","CustomLabel"));
                            end
                        end
                        labelsOut=customlabel;
                    elseif numel(customlabel)==1
                        try
                            validateattributes(customlabel{1},{'string','char'},{});
                        catch
                            error(message("shared_radarfusion:GlobeViewer:BadCustomLabelType","CustomLabel"));
                        end
                        labelsOut=repmat(customlabel,1,N);
                    else
                        error(message("shared_radarfusion:GlobeViewer:BadCustomLabelNumel","CustomLabel","tracks"));
                    end
                elseif isstring(customlabel)
                    if numel(customlabel)==N
                        labelsOut=num2cell(customlabel);
                    elseif numel(customlabel)==1
                        labelsOut=repmat({customlabel},1,N);
                    else
                        error(message("shared_radarfusion:GlobeViewer:BadCustomLabelNumel","CustomLabel","tracks"));
                    end
                elseif ischar(customlabel)
                    if isvector(customlabel)
                        labelsOut=repmat({customlabel},1,N);
                    else
                        error(message("shared_radarfusion:GlobeViewer:BadCustomLabelType","CustomLabel"));
                    end
                else
                    error(message("shared_radarfusion:GlobeViewer:BadCustomLabelType","CustomLabel"));
                end
            else
                labelsOut=cell(1,N);
            end
        end

        function colorsOut=autoColor(obj,tracks)



            N=numel(tracks);
            colorsOut=cell(1,N);
            currentIds=obj.TrackAndSourceIDs;

            counter=0;
            for i=1:N
                if~isempty(currentIds)
                    sid=tracks(i).SourceIndex;
                    tid=tracks(i).TrackID;
                    j=find(currentIds(1,:)==sid&currentIds(2,:)==tid);
                    if~isempty(j)
                        clrid=mod(currentIds(3,j),7);
                    else
                        counter=counter+1;
                        clrid=mod(obj.TrackCounter+counter,7);
                    end
                else
                    clrid=mod(obj.TrackCounter+i,7);
                end

                if clrid==0
                    clrid=7;
                end
                colorsOut{i}=obj.ColorsDark(clrid,:);
            end
        end

        function[isCurrentTrack,newTrackIds,allIDs]=manageTrackIDs(obj,tracks)

            currentIds=obj.TrackAndSourceIDs;
            isCurrentTrack=zeros(1,size(currentIds,2),'like',true);
            newTrackIds=[];
            N=numel(tracks);
            allIDs=cell(N,1);

            for i=1:N
                track=tracks(i);
                trackID=track.TrackID;
                sourceID=track.SourceIndex;
                if isempty(currentIds)
                    j=[];
                else
                    j=find(currentIds(1,:)==sourceID&currentIds(2,:)==trackID);
                end

                if~isempty(j)
                    isCurrentTrack(j)=true;
                else
                    obj.TrackCounter=obj.TrackCounter+1;
                    newTrackIds=[newTrackIds,[sourceID;trackID;obj.TrackCounter]];%#ok<AGROW>
                end

                rootID=['S',num2str(sourceID),'T',num2str(trackID)];
                allIDs{i}=rootID;
            end


            tmp=unique(allIDs);
            if numel(tmp)~=numel(allIDs)
                error(message('shared_radarfusion:GlobeViewer:DuplicateTrackInput','tracks','plotTrack'));
            end
        end

        function removeDroppedTracks(obj,delIdx)
            toDeleteTracks=obj.TrackAndSourceIDs(:,delIdx);
            for k=1:size(toDeleteTracks,2)
                name=['S',num2str(toDeleteTracks(1,k)),'T',num2str(toDeleteTracks(2,k))];

                covid=['trackCovariance',name];
                obj.Viewer.remove({covid});

                obj.Viewer.remove({name});

                labelId=[name,'Label'];
                obj.Viewer.remove({labelId});
                if~obj.ShowDroppedTracks

                    lineId=[name,'History'];
                    obj.Viewer.remove({lineId});
                end
            end
        end

        function[poslla,covenu]=calcTrackPosition(obj,track,refframe,possel)

            [pos,cov]=getTrackPositions(track,possel);
            try
                validateattributes(pos,{'numeric'},{'row','numel',3,'real'});
            catch
                error(message('shared_radarfusion:GlobeViewer:BadPositionSelector'));
            end


            switch refframe
            case 'NED'
                poslla=fusion.internal.frames.ned2lla(pos,obj.ReferenceLocation);
                Rned2enu=[0,1,0;1,0,0;0,0,-1];
                covenu=Rned2enu*cov*Rned2enu';
            case 'ENU'
                poslla=fusion.internal.frames.enu2lla(pos,obj.ReferenceLocation);
                covenu=cov;
            case 'ECEF'
                poslla=fusion.internal.frames.ecef2lla(pos);
                Recef2enu=fusion.internal.frames.ecef2enurotmat(poslla(1),poslla(2));
                covenu=Recef2enu*cov*Recef2enu';
            end
        end

        function plotTrackLabel(obj,track,lla,color,labelStyle,refframe,velsel,customlabel)
            poslla=lla+obj.TrackLabelOffset;
            displayname=['T',num2str(track.TrackID)];
            if track.SourceIndex>0
                displayname=['S',num2str(track.SourceIndex),displayname];
            end

            if strcmp(labelStyle,'ID')
                label={{['    ',displayname]}};
            elseif strcmp(labelStyle,'ATC')
                velocity=getTrackVelocities(track,velsel);

                try
                    validateattributes(velocity,{'numeric'},{'row','numel',3,'real'})
                catch
                    error(message('shared_radarfusion:GlobeViewer:BadVelocitySelector',...
                    'LabelStyle','ATC'));
                end

                switch refframe
                case 'ECEF'
                    Recef2ned=fusion.internal.frames.ecef2nedrotmat(lla(1),lla(2));
                    vned(:)=Recef2ned*velocity(:);
                case 'NED'
                    vned=velocity;
                case 'ENU'
                    vned=[velocity(2),velocity(1),-velocity(3)];
                end

                speed=norm(vned(1:2));
                climbrate=-(vned(3));
                minClimbIndicator=2;
                if climbrate>minClimbIndicator
                    climbIndicator=char(8593);
                elseif climbrate>-minClimbIndicator
                    climbIndicator=char(8596);
                else
                    climbIndicator=char(8595);
                end
                climbrate=abs(climbrate);
                heading=atan2d(vned(2),vned(1));
                trackInfo=sprintf('%s\n',...
                "    "+string(displayname),...
                "    "+"Lat, Lon: "+num2str(lla(1))+", "+num2str(lla(2)),...
                "    "+"Alt: "+num2str(round(lla(3)))+" "+climbIndicator+" "+num2str(round(climbrate))+"m/s",...
                "    "+"GS: "+num2str(round(speed*3.6))+"km/hr   H:"+num2str(heading,'%.1f')+char(176));
                label={{trackInfo}};
            else
                label={customlabel};
            end

            label_id=['S',num2str(track.SourceIndex),'T',num2str(track.TrackID),'Label'];
            obj.Viewer.labelCollection(poslla,label,...
            "Indices",{{1}},...
            "Scale",0.4*obj.TrackLabelScale,...
            "Color",color,...
            "ID",label_id);
        end
    end


    methods(Access=protected)
        function out=euler2euler(~,in,seqIn,seqOut)

            q=quaternion(in,'eulerd',seqIn,'frame');
            out=eulerd(q,seqOut,'frame');
        end

        function eulxyz=enu2ecef(~,lat,lon)
            eulxyz=[-(90-lat),0,-(90+lon)];
        end
    end


    methods(Access=protected)
        function createInputParsers(obj)

            checkRef=@(x)any(validatestring(x,{'NED','ENU','ECEF'}));
            checkColor=@(x)validateattributes(x,{'numeric'},{'2d','ncols',3,'<=',1,'>=',0});


            checkLabelStyle=@(x)any(validatestring(x,{'ID','ATC','Custom'}));
            p=inputParser;
            defpossel=[1,0,0,0,0,0;0,0,1,0,0,0;0,0,0,0,1,0];
            defvelsel=[0,1,0,0,0,0;0,0,0,1,0,0;0,0,0,0,0,1];
            addRequired(p,'tracks',@obj.checkTrackInput);
            addOptional(p,'ReferenceFrame','NED',checkRef);
            addParameter(p,'PositionSelector',defpossel);
            addParameter(p,'VelocitySelector',defvelsel);
            addParameter(p,'Color','Auto',@obj.checkTrackColorInput);
            addParameter(p,'LineWidth',1,@(x)validateattributes(x,{'numeric'},{'integer','positive','scalar'}));
            addParameter(p,'LabelStyle','ID',checkLabelStyle);
            addParameter(p,'CustomLabel',{});
            obj.TrackInputParser=p;


            p=inputParser;
            addRequired(p,'detections',@(x)validateattributes(x,{'cell','objectDetection'},{}));
            addOptional(p,'ReferenceFrame','NED',checkRef);
            addParameter(p,'Color',[15,255,255]/255,checkColor);
            obj.DetectionInputParser=p;


            p=inputParser;
            addRequired(p,'platforms',@obj.checkPlatformInput);
            addOptional(p,'ReferenceFrame','NED',checkRef);
            addParameter(p,'TrajectoryMode','History',@(x)ismember(x,{'History','Full','None'}));
            addParameter(p,'Marker','^');
            addParameter(p,'Color',[1,1,1],checkColor);
            addParameter(p,'LineWidth',1,@(x)validateattributes(x,{'numeric'},{'integer','positive','scalar'}));
            obj.PlatformInputParser=p;


            p=inputParser;
            addRequired(p,'trajs');
            addParameter(p,'Color',[1,1,1],checkColor);
            addParameter(p,'LineWidth',1,@(x)validateattributes(x,{'numeric'},{'integer','positive','scalar'}));
            obj.TrajectoryInputParser=p;


            p=inputParser;
            addRequired(p,'configs');
            addOptional(p,'ReferenceFrame','NED',checkRef);
            addParameter(p,'Color',obj.ColorsDark(6,:),checkColor);
            addParameter(p,'Alpha',0.4,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative','<=',1}));
            obj.CoverageInputParser=p;
        end
    end

    methods(Static,Hidden)
        function tf=checkTrackInput(track)
            trackfields={'SourceIndex','TrackID','State','StateCovariance'};
            if iscell(track)
                tf=true;
                for i=1:numel(track)
                    if isa(track{i},'objectTrack')||isa(track{i},'struct')&&all(isfield(track{i},trackfields))
                        tf=true&tf;
                    else
                        error(message('shared_radarfusion:GlobeViewer:BadTrackInput',...
                        'SourceIndex','TrackID','State','StateCovariance'));
                    end
                end
            elseif isa(track,'objectTrack')||isa(track,'struct')&&all(isfield(track,trackfields))
                tf=true;
            else
                error(message('shared_radarfusion:GlobeViewer:BadTrackInput',...
                'SourceIndex','TrackID','State','StateCovariance'));
            end
        end

        function tf=checkPlatformInput(platform)
            platformfields={'PlatformID','Position'};
            if iscell(platform)
                tf=true;
                for i=1:numel(platform)
                    if isa(platform{i},'fusion.scenario.Platform')||isa(platform{i},'struct')&&all(isfield(platform{i},platformfields))
                        tf=true&tf;
                    else
                        error(message('shared_radarfusion:GlobeViewer:BadPlatformInput',...
                        'PlatformID','Position'));
                    end
                end
            elseif isa(platform,'fusion.scenario.Platform')||isa(platform,'struct')&&all(isfield(platform,platformfields))
                tf=true;
            else
                error(message('shared_radarfusion:GlobeViewer:BadPlatformInput',...
                'PlatformID','Position'));
            end
        end

        function tf=checkTrackColorInput(x)
            if iscell(x)
                for i=1:numel(x)
                    validateattributes(x{i},{'numeric'},{'vector','numel',3,'<=',1,'>=',0})
                end
            elseif~all(strcmpi(x,'Auto'))
                validateattributes(x,{'numeric'},{'2d','ncols',3,'<=',1,'>=',0})
            end
            tf=true;
        end

        function sizedColors=validateColorSize(color,n,msg)





            ncolorInput=size(color,1);
            if ncolorInput==1

                sizedColors=repmat(color,n,1);
            elseif ncolorInput==n
                sizedColors=color;
            else
                error(msg);
            end
        end

        function[kinPlatforms,wpPlatforms]=sortPlatforms(platforms)

            kinPlatforms=[];
            wpPlatforms=[];
            for i=1:numel(platforms)
                if isprop(platforms(i).Trajectory,'Waypoints')&&...
                    size(platforms(i).Trajectory.Waypoints,1)>1
                    wpPlatforms=[wpPlatforms,platforms(i)];%#ok<AGROW>
                else
                    kinPlatforms=[kinPlatforms,platforms(i)];%#ok<AGROW>
                end
            end
        end
    end


    methods(Access=private)
        function queuePlots(obj)
            if~obj.Viewer.Queue&&~obj.Debug
                obj.Viewer.queuePlots;
                obj.QueueCleanUp=radarfusion.internal.graphics.onExit(@()unqueuePlots(obj.Viewer));
            end
        end

        function submitPlots(obj)
            if obj.Viewer.Queue
                obj.Viewer.submitPlots("Animation",'none',"WaitForResponse",false);
                cancel(obj.QueueCleanUp);
            end
        end
    end

    methods
        function delete(obj)


            delete(obj.QueueCleanUp);
        end
    end
end
