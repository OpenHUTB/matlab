classdef helperPertScenarioGlobeViewer<handle
    properties(Hidden)
Figure
GlobeViewer
InfoBox
    end

    properties
        PositionCoordinates='Geodetic'
        ReferenceFrame='ECEF'
        ReferenceLocation=[0,0,0]
    end

    properties
        TargetHistoryLength=2
        ShowTrackCovariance=true
        CoverageRange=463000;
        TrackHistoryLength=5
        TrackLabelScale=1
    end

    properties(Access=protected)
        ColorsDark=[255,255,17;...
        19,159,255;...
        255,105,41;...
        100,212,19;...
        183,70,255;...
        15,255,255;...
        255,19,166]/255;

        pDisplayTime=0
        pDisplayNumDebris=0
        pDisplayNumTracks=0
    end

    properties(Access=protected)
        TrackIDs=[];

        TrackPointGlobeIDs={};
        TrackHistoryGlobeIDs={};
        TrackCovarianceGlobeIDs={};
    end

    methods
        function obj=helperPertScenarioGlobeViewer(fig)
            if~nargin
                fig=uifigure('Visible','on');
                fig.Position=[200,100,1600,1024];

            end


            glopt=globe.internal.GlobeOptions;
            glopt.EnableHomeButton=true;
            glopt.EnableSceneModePicker=true;
            glopt.EnableBaseLayerPicker=false;

            gl=globe.graphics.GeographicGlobe("Parent",fig,...
            "Basemap",'streets-dark',...
            "terrain","none",...
            "GlobeOptions",glopt);

            obj.GlobeViewer=gl.GlobeViewer;
            obj.Figure=fig;
        end

        function clear(obj)
            clear(obj.GlobeViewer);
            obj.TrackIDs=[];

            obj.TrackPointGlobeIDs={};
            obj.TrackHistoryGlobeIDs={};
            obj.TrackCovarianceGlobeIDs={};
        end

        function updateDisplay(obj,time,platforms,detections,covcon,tracks)
            narginchk(2,6);

            obj.GlobeViewer.queuePlots;


            obj.pDisplayTime=round(time/60);


            if nargin>2&&~isempty(platforms)
                obj.pDisplayNumDebris=numel(platforms);
                plotTarget(obj,[],platforms);
            end


            if nargin>3&&~isempty(detections)
                plotDetection(obj,detections);
            end


            if nargin>4&&~isempty(covcon)
                plotCoverage(obj,covcon);
            end


            if nargin>5
                obj.pDisplayNumTracks=numel(tracks);
                plotTrack(obj,tracks);
            end


            obj.InfoBox.Text=getInfoText(obj);

            obj.GlobeViewer.submitPlots("Animation",'none',"WaitForResponse",false);
        end

        function showScenario(obj,scene,varargin)

            time=scene.SimulationTime;
            platforms=[scene.Platforms{:}];
            if isempty(varargin)
                detections=[];
            else
                detections=varargin{1};
            end
            covcon=coverageConfig(scene);
            clear(obj);
            if scene.IsGeo
                obj.PositionCoordinates='Geodetic';
                obj.ReferenceFrame='ECEF';
                obj.ReferenceLocation=[0,0,0];
                updateDisplay(obj,time,platforms,detections,covcon);

            else

                obj.PositionCoordinates=scene.ScenarioCoordinates;
                obj.ReferenceFrame=scene.ScenarioAxes;
                obj.ReferenceLocation=scene.ReferenceLocation;
                updateDisplay(obj,time,platforms,detections,covcon);
                setCameraPosition(obj,[scene.ReferenceLocation(1:2),7e5]);
            end

        end

    end


    methods
        function plotTarget(obj,name,platforms)
            color=[1,1,1];
            N=numel(platforms);
            ids={platforms.PlatformID};

            allpositions=zeros(N,3);
            for i=1:N
                platform=platforms(i);
                position_lla=getPosition(obj,platform);
                allpositions(i,:)=position_lla;


            end





            obj.plotPoints(allpositions,...
            "Color",color,...
            "ID",ids,...
            "Size",5,...
            "Animation",'none');



            obj.plotLines(allpositions,...
            "Indices",{1:N},...
            "Color",color,...
            "Width",1,...
            "ID","lineCollection",...
            "HistoryDepth",obj.TargetHistoryLength);



            if~isempty(name)
                label=string(name);
                obj.GlobeViewer.labelCollection({position_lla},{{label}},...
                "Indices",{{1}},...
                "Scale",0.4,...
                "Color",[255,255,17]/255,...
                "ID",string(['label',ID]));
            end
        end

        function plotTrack(obj,tracks)
            unit2meter=1;

            currentTrackIds=obj.TrackIDs;
            isCurrentTrackID=zeros(1,numel(currentTrackIds),'like',true);
            newTrackIds=[];

            N=numel(tracks);
            allpositions=zeros(N,3);
            allIDs=cell(N,1);



            allcolors=cell(1,N);


            for i=1:N

                track=tracks(i);
                ID=track.TrackID;
                j=find(currentTrackIds==ID);
                if~isempty(j)
                    isCurrentTrackID(j)=true;
                else
                    newTrackIds=[newTrackIds,ID];%#ok<AGROW>
                end

                name=['T',num2str(ID)];
                color=getColorByID(obj,track.ObjectClassID);



                [posecef,covariance]=getTrackPositions(track,[1,0,0,0,0,0;0,0,1,0,0,0;0,0,0,0,1,0]);
                posecef=posecef*unit2meter;
                covariance=covariance*unit2meter^2;


                poslla=obj.ecef2lla(posecef);
                allpositions(i,:)=poslla;
                allcolors{i}=color;
                allIDs{i}=string(name);



                obj.plotLines(poslla,"Color",color,...
                "Width",1,...
                "Indices",{{1}},...
                "ID",[name,'History'],...
                "HistoryDepth",obj.TrackHistoryLength);

                if obj.ShowTrackCovariance
                    obj.plotCovarianceEllipse(poslla,covariance,ID,color);
                end

                obj.GlobeViewer.labelCollection(poslla,{{name}},...
                "Indices",{{1}},...
                "Scale",obj.TrackLabelScale,...
                "Color",color,...
                "ID",[name,'Label']);














            end
            obj.plotPoints(allpositions,'Color',allcolors,'ID',allIDs,'Animation','none');


            toDeleteTracks=currentTrackIds(~isCurrentTrackID);
            for k=1:numel(toDeleteTracks)

                covid=['trackCovariance',num2str(toDeleteTracks(k))];
                obj.GlobeViewer.remove({covid});

                pointid=['T',num2str(toDeleteTracks(k))];
                obj.GlobeViewer.remove({pointid});

                lineId=[pointid,'History'];
                obj.GlobeViewer.remove({lineId});

                labelId=[pointid,'Label'];
                obj.GlobeViewer.remove({labelId});
            end

            obj.TrackIDs=[currentTrackIds(isCurrentTrackID),newTrackIds];
        end

        function plotCoverage(obj,configs)
            color=[15,255,255]/255;
            for i=1:numel(configs)
                config=configs(i);
                location=fusion.internal.frames.ecef2lla(config.Position);
                numPoints=32;
                fov=config.FieldOfView;

                range=obj.CoverageRange;

                vertices=radarfusion.internal.coveragePlotter.beamVertices(numPoints,fov,range);
                faces=radarfusion.internal.coveragePlotter.getFaces(numPoints);
                beam2sens=radarfusion.internal.coveragePlotter.beamFrameTransform(config.LookAngle);
                sens2scenario=radarfusion.internal.coveragePlotter.coverageFrameTransform([0,0,0],config.Orientation);
                beam2scenario=sens2scenario*beam2sens;



                rotation=beam2scenario(1:3,1:3);
                vertices=(rotation*vertices')';

                faces=faces';
                indices=faces(:)-1;
                CData=repmat(color,numel(indices)/3+2,1);


                surfRotation=latlong2globerot(obj,location(1),location(2));

                obj.GlobeViewer.surface(location,vertices,indices,CData,...
                "Animation",'none',...
                "Transparency",0.5,...
                "Rotation",surfRotation,...
                "ID",['radarConeID',num2str(config.Index)]);
            end
        end

        function plotTrajectory(obj,trajectory,varargin)






            numTrajectories=numel(trajectory);
            poses=cell(1,numTrajectories);

            for i=1:numTrajectories
                if iscell(trajectory)
                    thisTrajectory=trajectory{i};
                elseif numTrajectories==1
                    thisTrajectory=trajectory;
                else
                    thisTrajectory=trajectory(i);
                end
                pos=lookupPose(thisTrajectory,(thisTrajectory.TimeOfArrival(1):thisTrajectory.TimeOfArrival(end)));
                poses{i}=num2cell(pos,2);
            end

            obj.GlobeViewer.lineCollection(poses,varargin{:},"Animation",'none');
        end

        function plotDetection(obj,detections)

            color=[255,19,166]/255;
            unit2meter=1;
            detarray=[detections{:}];
            sensInd=[detarray.SensorIndex];
            uniqSensInd=unique(sensInd);
            numSensors=numel(uniqSensInd);
            for i=1:numSensors
                dets=detarray(sensInd==uniqSensInd(i));
                allmeas=[dets.Measurement];
                pos=allmeas(1:3,:)';

                obj.GlobeViewer.point(obj.ecef2lla(pos*unit2meter),...
                "Color",color,...
                "ID",{uniqSensInd(i)},...
                "Animation",'none');
            end
        end
    end


    methods
        function varargout=snap(obj)
            img=obj.GlobeViewer.Window.getScreenshot;
            if nargout==0
                imshow(img);
                varargout={};
            else
                varargout={img};
            end
        end

        function plotLocalNED(obj,lat,lon)
            plotLocalENU(obj,lat,lon,[90,0,180]);
        end

        function plotLocalENU(obj,lat,lon,rotation)
            if nargin==3
                rotation=[0,0,0];
            end

            width=5e4;
            length=2e6;

            theta=0:0.1:2*pi;
            Z=width*cos(theta);
            Y=width*sin(theta);
            X=length*ones(1,numel(theta));
            Z=[0,Z];
            Y=[0,Y];
            X=[0,X];
            numPts=numel(Z);
            V=ones(numPts-2,1);
            c2=2:1:numPts-1;
            V=[V,c2'];
            c3=3:1:numPts;
            V=[V,c3'];
            V=[V;[1,numPts,2]];
            V=V';
            indices=V(:);
            indices=indices-1;
            CData=repmat([1,0,0],numel(indices)/3+2,1);
            xyzData=[X',Y',Z'];

            obj.GlobeViewer.surface([lat,lon,0],xyzData,indices,CData,...
            "Animation",'none',...
            "ID",'localENUX',...
            "rotation",rotation);


            Z=width*sin(theta);
            Y=length*ones(1,numel(theta));
            X=width*cos(theta);
            Z=[0,Z];
            Y=[0,Y];
            X=[0,X];
            numPts=numel(Z);
            V=ones(numPts-2,1);
            c2=2:1:numPts-1;
            V=[V,c2'];
            c3=3:1:numPts;
            V=[V,c3'];
            V=[V;[1,numPts,2]];
            V=V';
            indices=V(:);
            indices=indices-1;
            CData=repmat([0,1,0],numel(indices)/3+2,1);
            xyzData=[X',Y',Z'];

            obj.GlobeViewer.surface([lat,lon,0],xyzData,indices,CData,...
            "Animation",'none',...
            "ID",'localENUY',...
            "rotation",rotation);


            Z=length*ones(1,numel(theta));
            Y=width*cos(theta);
            X=width*sin(theta);
            Z=[0,Z];
            Y=[0,Y];
            X=[0,X];
            numPts=numel(Z);
            V=ones(numPts-2,1);
            c2=2:1:numPts-1;
            V=[V,c2'];
            c3=3:1:numPts;
            V=[V,c3'];
            V=[V;[1,numPts,2]];
            V=V';
            indices=V(:);
            indices=indices-1;
            CData=repmat([0,0,1],numel(indices)/3+2,1);
            xyzData=[X',Y',Z'];

            obj.GlobeViewer.surface([lat,lon,0],xyzData,indices,CData,...
            "Animation",'none',...
            "ID",'localENUZ',...
            "rotation",rotation);
        end

        function plotLocalECEF(obj,lat,lon)
            eulxyz=enu2ecef(obj,lat,lon);
            eulzyx=euler2euler(obj,eulxyz,'xyz','zyx');

            eulglobe=eulzyx.*[1,-1,1];
            plotLocalENU(obj,lat,lon,eulglobe);
        end

        function positionCamera(obj,position,orientation)













            if nargin<2
                return
            end

            setCameraPosition(obj,position);

            if nargin>2
                setCameraOrientation(obj,orientation);
            end
        end
    end

    methods(Hidden)
        function showRules(viewer,trajRules)



            alignmentRule=trajRules(1);
            scope=alignmentRule.Scope;
            lat=(scope(1):0.01:scope(2));
            lonEast=polyval(alignmentRule.LowerBound,lat);
            lonWest=polyval(alignmentRule.UpperBound,lat);

            best=(lonEast+lonWest)/2;
            traj=geoTrajectory([lat',best',zeros(numel(lat),1)],(1:numel(lat)));


            distanceFromLanding=calculateDistance(traj,-1);
            altUB=max(polyval(trajRules(2).UpperBound,distanceFromLanding),polyval(trajRules(3).UpperBound,distanceFromLanding));
            altLB=min(polyval(trajRules(2).LowerBound,distanceFromLanding),polyval(trajRules(3).LowerBound,distanceFromLanding));


            nGate=numel(lat);
            xyz=cell(5,1);
            viewer.GlobeViewer.queuePlots;

            for i=1:nGate
                xyz{1}={lat(i),lonEast(i),altLB(i)};
                xyz{2}={lat(i),lonEast(i),altUB(i)};
                xyz{3}={lat(i),lonWest(i),altUB(i)};
                xyz{4}={lat(i),lonWest(i),altLB(i)};
                xyz{5}={lat(i),lonEast(i),altLB(i)};
                viewer.GlobeViewer.lineCollection({xyz},'Color',[0,0,0],"Width",2,"Animation",'none');
            end
            viewer.GlobeViewer.submitPlots("Animation",'none',"WaitForResponse",false);
        end
    end


    methods(Access=protected)
        function position_lla=getPosition(obj,positionObject)


            unit2meter=1;
            if isprop(positionObject,'Trajectory')
                if isa(positionObject.Trajectory,'geoTrajectory')
                    coords='Geodetic';
                else
                    coords=positionObject.Trajectory.PositionCoordinates;
                end
            else
                coords=obj.PositionCoordinates;
            end

            if strcmp(coords,'Geodetic')
                position_lla=positionObject.Position;
            else
                switch obj.ReferenceFrame
                case 'ECEF'
                    position_ecef=positionObject.Position*unit2meter;
                    position_lla=fusion.internal.frames.ecef2lla(position_ecef);
                case 'NED'
                    position_ned=positionObject.Position*unit2meter;
                    position_lla=fusion.internal.frames.ned2lla(position_ned,obj.ReferenceLocation);
                case 'ENU'
                    position_enu=positionObject.Position*unit2meter;
                    position_lla=fusion.internal.frames.enu2lla(position_enu,obj.ReferenceLocation);
                end
            end
        end

        function text=getInfoText(obj)
            text=vertcat(string(['Elapsed simulation time: ',num2str(obj.pDisplayTime),' (min)']),...
            string(['Current number of tracks: ',num2str(obj.pDisplayNumTracks)]),...
            string(['Total number of debris: ',num2str(obj.pDisplayNumDebris)]));
        end

        function plotPoints(obj,positions,varargin)
            obj.GlobeViewer.point(positions,varargin{:});
        end

        function plotLines(obj,positions,varargin)
            obj.GlobeViewer.lineCollection(num2cell(num2cell(positions,2)'),...
            varargin{:});
        end

        function plotCovarianceEllipse(obj,lla,cov,id,color)
            [x,y,z]=makeEllipsoid(obj,[0,0,0],cov,30,20);
            [f,v]=surf2patch(x,y,z);
            f=lidarsim.internal.mesh.utilities.f4Tof3(f);
            f=f';

            lat=lla(1);
            lon=lla(2);
            eulxyz=enu2ecef(obj,lat,lon);
            eulzyx=euler2euler(obj,eulxyz,'xyz','zyx');

            eulglobe=eulzyx.*[1,-1,1];

            surface(obj.GlobeViewer,lla,v,f(:)-1,repmat(color,size(f,2)+2,1),...
            'Rotation',eulglobe,...
            'Transparency',0.4,...
            'ID',['trackCovariance',num2str(id)],...
            'Animation','none');
        end

        function rgb=getColorByID(obj,id)

            clrid=mod(id,size(obj.ColorsDark,1));
            if clrid==0
                clrid=size(obj.ColorsDark,1);
            end
            rgb=obj.ColorsDark(clrid,:);
        end

        function[x,y,z]=makeEllipsoid(~,positions,covariances,npts,sdwidth)

            [v,d]=eig(covariances);


            v=real(v);
            d=real(d);


            d=sdwidth*sqrt(max(diag(d),0));


            [x,y,z]=ellipsoid(0,0,0,d(1),d(2),d(3),npts);
            ellip=[x(:),y(:),z(:)]';


            ellip=v*ellip;
            ellip=bsxfun(@plus,ellip,positions');

            x=reshape(ellip(1,:),size(x));
            y=reshape(ellip(2,:),size(y));
            z=reshape(ellip(3,:),size(z));
        end

        function faces=generateFaces(~,platform)

            L=platform.Dimensions.Length;
            W=platform.Dimensions.Width;
            H=platform.Dimensions.Height;



            f=[1,1,1;1,-1,1;1,-1,-1;1,1,-1].*[L,W,H];
            l=[1,1,1;1,1,-1;-1,1,-1;-1,1,1].*[L,W,H];
            u=[1,1,1;-1,1,1;-1,-1,1;1,-1,1].*[L,W,H];
            b=[-1,1,1;-1,1,-1;-1,-1,-1;-1,-1,1].*[L,W,H];
            r=[-1,-1,1;-1,-1,-1;1,-1,-1;1,-1,1].*[L,W,H];
            d=[1,1,-1;1,-1,-1;-1,-1,-1;-1,1,-1].*[L,W,H];

            faces=[f;l;u;b;r;d]/2;


            originOffset=platform.Dimensions.OriginOffset;
            faces=faces-originOffset;








            faces=reshape(faces',3,4,[]);
        end

        function plotExtent(obj,platform,position,color)

            if platform.Dimensions.Length~=0
                faces=generateFaces(obj,platform);
                [tri,xyzData]=surf2patch(squeeze(faces(1,:,:)),...
                squeeze(faces(2,:,:)),...
                squeeze(faces(3,:,:)),'triangles');
                tri=tri';
                tri=tri(:)-1;

                eulxyz=enu2ecef(obj,position(1),position(2));
                eulzyx=euler2euler(obj,eulxyz,'xyz','zyx');

                globe2scenario=eulzyx.*[1,-1,1];


                q=platform.Trajectory.CurrentOrientation;
                xyzData=rotatepoint(q,xyzData);

                surface(obj.GlobeViewer,position,xyzData,tri,repmat(color,size(tri,2)+2,1),...
                'Rotation',globe2scenario,...
                'Transparency',0.4,...
                'ID',['platformExtent',num2str(platform.PlatformID)],...
                'Animation','none');
            end
        end

    end


    methods(Access=protected)
        function eulglobe=latlong2globerot(obj,lat,lon)
            switch obj.ReferenceFrame
            case 'ECEF'
                eulxyz=enu2ecef(obj,lat,lon);
                eulzyx=euler2euler(obj,eulxyz,'xyz','zyx');
            case 'ENU'
                eulzyx=[0,0,0];
            case 'NED'
                eulzyx=[90,0,180];
            end

            eulglobe=eulzyx.*[1,-1,1];
        end

        function lla=ecef2lla(~,ecef)
            lla=fusion.internal.frames.ecef2lla(ecef);
        end

        function out=euler2euler(~,in,seqIn,seqOut)

            q=quaternion(in,'eulerd',seqIn,'frame');
            out=eulerd(q,seqOut,'frame');
        end

        function eulxyz=enu2ecef(~,lat,lon)
            eulxyz=[-(90-lat),0,-(90+lon)];
        end
    end

    methods(Access=protected)
        function setCameraPosition(obj,cameraPosition)
            gv=obj.GlobeViewer;
            if~isempty(gv)&&isvalid(gv)
                controller=gv.Controller;
                if~isempty(controller)&&isvalid(controller)
                    args.CameraPosition=cameraPosition;
                    setCameraPosition(controller,args)
                end
            end
        end

        function cameraPosition=getCameraPosition(obj,defaultCameraPosition)
            if nargin==1
                defaultCameraPosition=obj.GlobeOptions.CameraPosition;
            end
            cameraPosition=defaultCameraPosition;

            gv=obj.GlobeViewer;
            if~isempty(gv)&&isvalid(gv)
                controller=gv.Controller;
                if~isempty(controller)&&isvalid(controller)
                    position=getCameraPosition(controller);
                    if isstruct(position)
                        cameraPosition=[position.latitude,position.longitude,position.height];
                    else
                        cameraPosition=position;
                    end
                end
            end
        end

        function setCameraOrientation(obj,value)
            gv=obj.GlobeViewer;
            if~isempty(gv)&&isvalid(gv)
                controller=gv.Controller;
                if~isempty(controller)&&isvalid(controller)
                    roll=value(1);
                    pitch=value(2);
                    heading=value(3);
                    args.CameraOrientation.Roll=deg2rad(roll);
                    args.CameraOrientation.Pitch=deg2rad(pitch);
                    args.CameraOrientation.Heading=deg2rad(heading);
                    setCameraOrientation(controller,args)
                end
            end
        end

        function[roll,pitch,heading]=getCameraOrientation(obj,cameraOrientation)
            if nargin==1
                cameraOrientation=globe.internal.GlobeOptions.DefaultCameraOrientation;
            end
            roll=cameraOrientation(1);
            pitch=cameraOrientation(2);
            heading=cameraOrientation(3);

            gv=obj.GlobeViewer;
            if~isempty(gv)&&isvalid(gv)
                controller=gv.Controller;
                if~isempty(controller)&&isvalid(controller)
                    orientation=getCameraOrientation(controller);
                    if isstruct(orientation)
                        roll=orientation.roll;
                        pitch=orientation.pitch;
                        heading=orientation.heading;
                    else
                        roll=orientation(1);
                        pitch=orientation(2);
                        heading=orientation(3);
                    end
                end
            end
        end
    end
end
function distance=calculateDistance(llaTrajectory,direction)

    posECEF=lookupPose(llaTrajectory,llaTrajectory.TimeOfArrival,'ECEF');

    distance=zeros(size(posECEF,1),1);
    for i=2:size(posECEF,1)
        distance(i)=distance(i-1)+norm(posECEF(i,:)-posECEF(i-1,:));
    end
    if nargin==3&&direction==-1
        distance=distance(end)-distance;
    end
end