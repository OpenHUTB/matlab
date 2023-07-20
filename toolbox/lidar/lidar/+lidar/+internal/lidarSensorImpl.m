classdef(Hidden)lidarSensorImpl<matlab.System




    properties(SetAccess='private')




        SensorIndex=1;





        HostID=1;
    end

    properties






        UpdateRate=0.1;








        Position=[1.5,0,1.6];






        Orientation=[0,0,0];





        MaxRange=120;






        RangeAccuracy=0.002;








        HasNoise=true;








        HasOrganizedOutput=true;







        AzimuthResolution=0.16;






        ElevationResolution=1.25;





        AzimuthLimits=[-180,180];





        ElevationLimits=[-20,20];





        ElevationAngles=[];












































        ActorProfiles=[];
    end

    properties(Access='private')

        pIsValidTime=true;
        pSmallValue=1e-4;
        pHasFirstUpdate=false;
        pTimeLastUpdate=0;
    end

    properties(Access='private')

        pSSFObjectInternal=[];
    end

    methods
        function this=lidarSensorImpl(props)


            iValidateSensorIndex(props.SensorIndex);
            iValidateHostID(props.HostID);
            iValidateUpdateRate(props.UpdateRate);
            iValidateMaxRange(props.MaxRange);
            iValidatePosition(props.Position);
            iValidateOrientation(props.Orientation);
            iValidateAngleLimitsInput(props.AzimuthLimits,'AzimuthLimits');
            iValidateAngleLimitsInput(props.ElevationLimits,'ElevationLimits');
            iValidateRangeAccuracy(props.RangeAccuracy);
            iValidateAngleResolution(props.AzimuthResolution,props.AzimuthLimits,'AzimuthResolution');
            iValidateAngleResolution(props.ElevationResolution,props.ElevationLimits,'ElevationResolution');
            iValidateHasOrganizedOutput(props.HasOrganizedOutput);
            iValidateHasNoise(props.HasNoise);

            this.SensorIndex=props.SensorIndex;
            this.HostID=props.HostID;
            this.UpdateRate=props.UpdateRate;
            this.MaxRange=props.MaxRange;
            this.Position=props.Position;
            this.Orientation=props.Orientation;
            this.AzimuthLimits=props.AzimuthLimits;
            this.ElevationLimits=props.ElevationLimits;
            this.AzimuthResolution=props.AzimuthResolution;
            this.ElevationResolution=props.ElevationResolution;
            this.RangeAccuracy=props.RangeAccuracy;
            this.HasNoise=props.HasNoise;
            this.HasOrganizedOutput=props.HasOrganizedOutput;

            if(~isempty(props.ElevationAngles))
                iValidateElevationAngles(props.ElevationAngles);
                this.ElevationAngles=props.ElevationAngles;
            end

            if(~isempty(props.ActorProfiles))
                props.ActorProfiles=iValidateActorProfiles(props.ActorProfiles,this.HostID);
            end


            this.pSSFObjectInternal=matlabshared.scenario.internal.SSF;

            if(~isempty(props.ActorProfiles))
                this.ActorProfiles=props.ActorProfiles;
            end

            addSensor(this);
        end
    end

    methods

        function set.ActorProfiles(this,profiles)
            profiles=iValidateActorProfiles(profiles,this.get('HostID'));
            this.ActorProfiles=addActorProfilesToSSF(this,profiles);
        end

        function set.UpdateRate(this,val)
            iValidateUpdateRate(val);
            this.UpdateRate=val;
            this.updateSensorConfig();
        end

        function set.Position(this,val)
            iValidatePosition(val)
            this.Position=val;
            this.updateSensorConfig();
        end

        function set.Orientation(this,val)
            iValidateOrientation(val)
            this.Orientation=val;
            this.updateSensorConfig();
        end

        function set.MaxRange(this,val)
            iValidateMaxRange(val)
            this.MaxRange=val;
            this.updateSensorConfig();
        end

        function set.AzimuthResolution(this,val)
            iValidateAngleResolution(val,this.get('AzimuthLimits'),'AzimuthResolution');
            this.AzimuthResolution=val;
            this.updateSensorConfig();
        end

        function set.ElevationResolution(this,val)
            iValidateAngleResolution(val,this.get('ElevationLimits'),'ElevationResolution');
            this.ElevationResolution=val;
            this.updateSensorConfig();
        end

        function set.AzimuthLimits(this,val)
            iValidateAngleLimitsInput(val,'AzimuthLimits')
            this.AzimuthLimits=val;
            this.updateSensorConfig();
        end

        function set.ElevationLimits(this,val)
            iValidateAngleLimitsInput(val,'ElevationLimits')
            this.ElevationLimits=val;
            this.updateSensorConfig();
        end

        function set.ElevationAngles(this,val)
            iValidateElevationAngles(val)
            this.ElevationAngles=val;
            this.updateSensorConfig();
        end

        function set.RangeAccuracy(this,val)
            iValidateRangeAccuracy(val);
            this.RangeAccuracy=val;
        end

        function set.HasOrganizedOutput(this,val)
            iValidateHasOrganizedOutput(val);
            this.HasOrganizedOutput=val;
        end

        function set.HasNoise(this,val)
            iValidateHasNoise(val);
            this.HasNoise=val;
        end

    end

    methods(Access='protected')
        function[ptCloud,validTime,clusters]=stepImpl(this,tgtPoses,time)

            if(numel(this.ActorProfiles)<=0)

                error(message('lidar:lidarSensor:emptyActorProfiles'));
            end
            tgtPoses=iValidateActorPoses(tgtPoses,[this.ActorProfiles.ActorID]);
            validateattributes(time,{'single','double'},...
            {'finite','scalar','real','nonnegative','nonsparse'},'step','time');
            validTime=true;

            if(~this.isValidTime(time)||numel(tgtPoses)<=0)
                ptCloud=pointCloud([0,0,0]);
                validTime=false;
                clusters=[];
                return;
            end


            updatedActorPoses=mw.scenario.proto.ActorPose.empty(length(tgtPoses),0);
            for idx=1:length(tgtPoses)
                actorPose=tgtPoses(idx);
                actorID=actorPose.ActorID;
                actorPosition=double(actorPose.Position);
                actorRPY=deg2rad(double([actorPose.Roll,actorPose.Pitch,actorPose.Yaw]));
                updatedActorPoses(idx)=...
                matlabshared.scenario.internal.utils.getActorPose(actorID,actorPosition,...
                actorRPY,double(tgtPoses(idx).Velocity),double(tgtPoses(idx).AngularVelocity));
            end


            this.pSSFObjectInternal.updateActorPoses(updatedActorPoses);
            intersectionsRefObj=this.pSSFObjectInternal.getIntersectionsRef(this.SensorIndex,true);

            if(intersectionsRefObj.NumIntersections<=0)
                ptCloud=pointCloud([0,0,0]);
                validTime=false;
                clusters=[];
                return;
            end


            xyzPoints=intersectionsRefObj.getAll('positions');
            ranges=intersectionsRefObj.getAll('distances');
            surfaceNormals=intersectionsRefObj.getAll('normals');
            rayDirections=intersectionsRefObj.getAll('ray_directions');
            targetActorIDs=intersectionsRefObj.getAll('target_ids');
            targetMaterialReflectances=intersectionsRefObj.getAll('target_materials').forAttribute('TargetReflectances');

            [ptCloud,clusters]=makePointCloud(this,xyzPoints,ranges,...
            surfaceNormals,rayDirections,targetActorIDs,...
            targetMaterialReflectances(:));


            this.pTimeLastUpdate=time;
            this.pHasFirstUpdate=true;
        end
    end

    methods(Hidden,Access='private')
        function profiles=addActorProfilesToSSF(this,profiles)

            if(isempty(this.pSSFObjectInternal))
                return;
            end

            doAddSensor=false;
            if(~isempty(this.ActorProfiles))

                resetScene(this);
                doAddSensor=true;
            end


            actorProfiles=mw.scenario.proto.ActorProfile.empty(length(profiles),0);
            for idx=1:length(profiles)
                actorID=profiles(idx).ActorID;
                actorPosition=[0,0,0];
                actorRPY=[0,0,0];
                actorLWH=double([profiles(idx).Length,profiles(idx).Width,profiles(idx).Height]);
                s=struct('MeshVertices',double(profiles(idx).MeshVertices),...
                'MeshFaces',double(profiles(idx).MeshFaces),...
                'OriginOffset',double(profiles(idx).OriginOffset));
                actorProfiles(idx)=matlabshared.scenario.internal.utils.getActorProfile(...
                actorID,profiles(idx).ClassID,actorLWH,actorPosition,actorRPY,s);
            end

            for idx=1:numel(profiles)
                if(~isempty(profiles(idx).MeshTargetReflectances))
                    numMaterials=size(profiles(idx).MeshTargetReflectances,1);
                    materials=mw.scenario.proto.Material.empty(numMaterials,0);
                    material_indices=zeros(numMaterials,1,'uint32');
                    for idx2=1:numMaterials
                        materials(idx2)=matlabshared.scenario.internal.utils.getProto(...
                        struct('TargetReflectances',double(profiles(idx).MeshTargetReflectances(idx2))),...
                        'material');
                        material_indices(idx2)=idx2-1;
                    end
                    actorProfiles(idx).mesh_model.material=materials;
                    actorProfiles(idx).mesh_model.material_indices=material_indices;
                end
            end


            this.pSSFObjectInternal.addActors(actorProfiles);
            this.pSSFObjectInternal.createScene();

            if(doAddSensor)
                this.addSensor();
            end
        end

        function[ptCloud,clusters]=makePointCloud(this,xyzPoints,ranges,surfaceNormals,rayDirections,targetActorIDs,targetReflectances)


            zeroRangeIndices=find(ranges<=0);
            xyzPoints(zeroRangeIndices)=NaN;
            xyzPoints(zeroRangeIndices+size(xyzPoints,1))=NaN;
            xyzPoints(zeroRangeIndices+size(xyzPoints,1)*2)=NaN;

            clusters=double(targetActorIDs);
            clusters(:,2)=zeros(size(clusters));


            actorID_ClassID_Map=containers.Map([0,this.ActorProfiles.ActorID],...
            [0,this.ActorProfiles.ClassID]);
            clusters(:,2)=arrayfun(@(x)actorID_ClassID_Map(x),clusters(:,1));


            reflectivities=computeReflectivity(this,surfaceNormals,rayDirections,targetReflectances);

            if(this.HasNoise)
                xyzPoints=addNoise(this,xyzPoints);
            end




            if(isempty(this.ElevationAngles))
                numRows=numel(this.ElevationLimits(1):this.ElevationResolution:this.ElevationLimits(2));
            else
                numRows=numel(this.ElevationAngles);
            end

            if(isempty(reflectivities))
                ptCloud=pointCloud(flipud(reshape(xyzPoints,numRows,[],3)));
            else
                ptCloud=pointCloud(flipud(reshape(xyzPoints,numRows,[],3)),...
                'Intensity',flipud(reshape(reflectivities,numRows,[],1)));
            end

            if(this.HasOrganizedOutput)
                clusters=flipud(reshape(clusters,numRows,[],2));
            else
                ptCloud=removeInvalidPoints(ptCloud);
                clusters(zeroRangeIndices,:)=[];
            end
        end

        function[xyznoise,r]=addNoise(this,xyztrue)
            xyznoise=xyztrue;
            xyzflat=reshape(xyznoise,[],3);
            if this.HasNoise
                [az,el,r]=cart2sph(xyzflat(:,1),xyzflat(:,2),xyzflat(:,3));
                rNoise=sampleNoise(this,size(r));
                r=r+rNoise;
                [xyzflat(:,1),xyzflat(:,2),xyzflat(:,3)]=sph2cart(az,el,r);
            end
            xyznoise(:)=xyzflat;

            function noise=sampleNoise(this,sampleSize)
                noise=this.RangeAccuracy*randn(sampleSize);
            end
        end


        function tf=isValidTime(this,time)






            elapsedInterval=time-this.pTimeLastUpdate;
            rate=1/this.UpdateRate;
            numInts=round(elapsedInterval*rate);
            timeOffset=elapsedInterval-numInts/rate;

            tf=~this.pHasFirstUpdate||...
            elapsedInterval>=-this.pSmallValue&&(abs(timeOffset)<=this.pSmallValue);

            this.pIsValidTime=tf;

        end

        function sensorConfig=getSensorConfig(this)

            sensorPos=[double(this.Position(1:3)'),deg2rad(double(this.Orientation(1:3)'))];
            azRange=deg2rad(double(this.AzimuthLimits));
            azRes=deg2rad(double(this.AzimuthResolution));
            elRange=deg2rad(double(this.ElevationLimits));
            elRes=deg2rad(double(this.ElevationResolution));
            if(isempty(this.ElevationAngles))
                sensorConfig=matlabshared.scenario.internal.utils.sensorConfigAZEL(this.SensorIndex,this.HostID,sensorPos,...
                double(this.UpdateRate),double(this.MaxRange),azRange(1),azRange(2),azRes,elRange(1),elRange(2),elRes);
            else
                sensorConfig=matlabshared.scenario.internal.utils.sensorConfigAZEL(this.SensorIndex,this.HostID,sensorPos,...
                double(this.UpdateRate),double(this.MaxRange),azRange(1),azRange(2),azRes,deg2rad(double(this.ElevationAngles)));
            end
        end

        function addSensor(this)

            if(isempty(this.pSSFObjectInternal))
                return;
            end
            sensorConfig=getSensorConfig(this);

            this.pSSFObjectInternal.addSensors(sensorConfig);
        end

        function updateSensorConfig(this)

            if(isempty(this.pSSFObjectInternal))
                return;
            end
            sensorConfig=getSensorConfig(this);

            this.pSSFObjectInternal.updateSensors(sensorConfig);
        end

        function resetScene(this)

            if(~isempty(this.pSSFObjectInternal))
                this.pSSFObjectInternal.reset();
            end
        end

        function intensities=computeReflectivity(~,surfaceNormals,rayRirections,targetReflectances)





            cosAngle=findCosAngle(surfaceNormals,rayRirections);
            if(nnz(targetReflectances)==0)
                targetReflectances=ones(size(cosAngle));
            end
            intensities=cosAngle.*targetReflectances;


            intensities=im2uint8(intensities);

            function cosAngle=findCosAngle(vec1,vec2)
                dims=ndims(vec1);
                v1dotv1=dot(vec1,vec1,dims);
                v2dotv2=dot(vec2,vec2,dims);
                den=sqrt(v1dotv1).*sqrt(v2dotv2);
                cosAngle=dot(vec1,vec2,dims)./den;
                cosAngle=abs(cosAngle);
            end
        end
    end

    methods(Hidden)
        function s=struct(this)
            s.SensorIndex=this.SensorIndex;
            s.HostID=this.HostID;
            s.UpdateRate=this.UpdateRate;
            s.Position=this.Position;
            s.Orientation=this.Orientation;
            s.MaxRange=this.MaxRange;
            s.RangeAccuracy=this.RangeAccuracy;
            s.HasNoise=this.HasNoise;
            s.HasOrganizedOutput=this.HasOrganizedOutput;
            s.AzimuthResolution=this.AzimuthResolution;
            s.ElevationResolution=this.ElevationResolution;
            s.AzimuthLimits=this.AzimuthLimits;
            s.ElevationLimits=this.ElevationLimits;
            s.ElevationAngles=this.ElevationAngles;
            s.ActorProfiles=this.ActorProfiles;
        end
        function delete(this)
            release(this);
            if(~isempty(this.pSSFObjectInternal))
                this.pSSFObjectInternal.reset();
                this.pSSFObjectInternal=[];
            end
        end
    end

    methods(Access='protected')





        function loadObjectImpl(this,s,wasInUse)
            if(isempty(s.ElevationAngles))
                s=rmfield(s,'ElevationAngles');
            end
            if(isempty(s.ActorProfiles))
                s=rmfield(s,'ActorProfiles');
            end
            loadObjectImpl@matlab.System(this,s,wasInUse);
        end




        function s=saveObjectImpl(this)

            s=saveObjectImpl@matlab.System(this);
        end
    end

end


function profiles=iValidateActorProfiles(profiles,hostID)

    actorPosesStructFields={'ActorID','ClassID','Length','Width','Height','MeshVertices','MeshFaces'};
    if(~all(isfield(profiles,actorPosesStructFields)))
        error(message('lidar:lidarSensor:wrongStructInput','ActorProfiles',...
        "{'ActorID', 'ClassID', 'Length', 'Width', 'Height', 'MeshVertices', 'MeshFaces'}"));
    end
    fn=mfilename;
    for i=1:numel(profiles)
        validateattributes(profiles(i).ActorID,{'numeric'},...
        {'nonempty','scalar','finite','integer','real','positive','nonsparse'},...
        fn,['''profiles(',mat2str(i),').ActorID''']);
        validateattributes(profiles(i).ClassID,{'numeric'},...
        {'nonempty','scalar','finite','integer','real','positive','nonsparse'},...
        fn,['''profiles(',mat2str(i),').ClassID''']);
        validateattributes(profiles(i).Length,{'single','double'},...
        {'nonempty','scalar','finite','real','positive','nonsparse'},...
        fn,['''profiles(',mat2str(i),').Length''']);
        validateattributes(profiles(i).Width,{'single','double'},...
        {'nonempty','scalar','finite','real','positive','nonsparse'},...
        fn,['''profiles(',mat2str(i),').Width''']);
        validateattributes(profiles(i).Height,{'single','double'},...
        {'nonempty','scalar','finite','real','positive','nonsparse'},...
        fn,['''profiles(',mat2str(i),').Height''']);
        validateattributes(profiles(i).MeshVertices,{'single','double'},...
        {'nonempty','finite','real','size',[NaN,3],'nonsparse'},...
        fn,['''profiles(',mat2str(i),').MeshVertices''']);
        try
            validateattributes(size(profiles(i).MeshVertices,1),{'single','double'},...
            {'>=',3});
        catch ME
            error(message('lidar:lidarSensor:invalidMeshVertices',['profiles(',mat2str(i),').MeshVertices']))
        end
        validateattributes(profiles(i).MeshFaces,{'numeric'},...
        {'nonempty','finite','real','positive','nonsparse','size',[NaN,3],'<=',max(size(profiles(i).MeshVertices,1))},...
        fn,['''profiles(',mat2str(i),').MeshFaces''']);


        if(isfield(profiles(i),'OriginOffset'))
            validateattributes(profiles(i).OriginOffset,{'single','double'},...
            {'nonempty','finite','real','size',[1,3],'nonsparse'},...
            fn,['''profiles(',mat2str(i),').OriginOffset''']);
        end

        if(isfield(profiles(i),'MeshTargetReflectances')&&~isempty(profiles(i).MeshTargetReflectances))
            validateattributes(profiles(i).MeshTargetReflectances,{'single','double'},...
            {'nonempty','finite','real','nonnegative','nonsparse','size',[size(profiles(i).MeshFaces,1),1],'<=',1},...
            fn,['''profiles(',mat2str(i),').MeshTargetReflectances''']);
        end

    end

    if(numel([profiles.ActorID])~=numel(unique([profiles.ActorID])))
        error(message('lidar:lidarSensor:duplicateActorsFound','profiles'));
    end


    if(~isfield(profiles,'OriginOffset'))
        for i=1:numel(profiles)
            profiles(i).OriginOffset=[0,0,0];
        end
    end
    if(isempty(find(hostID==[profiles.ActorID],1)))

        error(message('lidar:lidarSensor:hostActorNotFound',hostID))
    end


    if(~isfield(profiles,'MeshTargetReflectances'))
        for i=1:numel(profiles)
            profiles(i).MeshTargetReflectances=[];
        end
    end
end

function tgtPoses=iValidateActorPoses(tgtPoses,validActorIDs)

    actorPosesStructFields={'ActorID','Position'};
    if(~all(isfield(tgtPoses,actorPosesStructFields)))
        error(message('lidar:lidarSensor:wrongStructInput','tgtPoses',...
        "{'ActorID', 'Position'}"));
    end
    fn='step';
    for i=1:numel(tgtPoses)
        validateattributes(tgtPoses(i).ActorID,{'numeric'},...
        {'nonempty','nonnan','scalar','finite','integer','real','positive','nonsparse'},...
        fn,['''tgtPoses(',mat2str(i),').ActorID''']);
        if(~any(tgtPoses(i).ActorID==validActorIDs))

            error(message('lidar:lidarSensor:poseActorIDNotFound',...
            ['tgtPoses(',mat2str(i),').ActorID'],...
            tgtPoses(i).ActorID,mat2str(validActorIDs)));
        end
        validateattributes(tgtPoses(i).Position,{'single','double'},...
        {'nonempty','nonnan','finite','real','size',[1,3],'nonsparse'},...
        fn,['''tgtPoses(',mat2str(i),').Position''']);

        if(isfield(tgtPoses(i),'Roll'))
            validateattributes(tgtPoses(i).Roll,{'single','double'},...
            {'nonempty','nonnan','scalar','finite','real','nonsparse'},...
            fn,['''tgtPoses(',mat2str(i),').Roll''']);
        end
        if(isfield(tgtPoses(i),'Pitch'))
            validateattributes(tgtPoses(i).Pitch,{'single','double'},...
            {'nonempty','nonnan','scalar','finite','real','nonsparse'},...
            fn,['''tgtPoses(',mat2str(i),').Pitch''']);
        end
        if(isfield(tgtPoses(i),'Yaw'))
            validateattributes(tgtPoses(i).Yaw,{'single','double'},...
            {'nonempty','nonnan','scalar','finite','real','nonsparse'},...
            fn,['''tgtPoses(',mat2str(i),').Yaw''']);
        end
        if(isfield(tgtPoses(i),'Velocity'))
            validateattributes(tgtPoses(i).Velocity,{'single','double'},...
            {'nonempty','nonnan','finite','real','size',[1,3],'nonsparse'},...
            fn,['''tgtPoses(',mat2str(i),').Velocity''']);
        end
        if(isfield(tgtPoses(i),'AngularVelocity'))
            validateattributes(tgtPoses(i).AngularVelocity,{'single','double'},...
            {'nonempty','nonnan','finite','real','size',[1,3],'nonsparse'},...
            fn,['''tgtPoses(',mat2str(i),').AngularVelocity''']);
        end
    end

    if(numel([tgtPoses.ActorID])~=numel(unique([tgtPoses.ActorID])))
        error(message('lidar:lidarSensor:duplicateActorsFound','tgtPoses'));
    end


    if(~isfield(tgtPoses,'Velocity'))
        for i=1:numel(tgtPoses)
            tgtPoses(i).Velocity=[0,0,0];
        end
    end
    if(~isfield(tgtPoses,'AngularVelocity'))
        for i=1:numel(tgtPoses)
            tgtPoses(i).AngularVelocity=[0,0,0];
        end
    end

    if(~isfield(tgtPoses,'Roll'))
        for i=1:numel(tgtPoses)
            tgtPoses(i).Roll=0;
        end
    end

    if(~isfield(tgtPoses,'Pitch'))
        for i=1:numel(tgtPoses)
            tgtPoses(i).Pitch=0;
        end
    end

    if(~isfield(tgtPoses,'Yaw'))
        for i=1:numel(tgtPoses)
            tgtPoses(i).Yaw=0;
        end
    end

end


function iValidateUpdateRate(val)
    try
        validateattributes(val,{'single','double'},...
        {'nonempty','nonnan','finite','scalar','real','positive','nonsparse'});
    catch ME
        error(message('lidar:lidarSensor:invalidInput','UpdateRate',ME.message))
    end
end

function iValidateMaxRange(val)
    try
        validateattributes(val,{'numeric'},...
        {'nonempty','nonnan','finite','scalar','real','positive','nonsparse'});
    catch ME
        error(message('lidar:lidarSensor:invalidInput','MaxRange',ME.message))
    end
end

function iValidatePosition(val)
    fn=mfilename;
    try
        validateattributes(val,{'single','double'},...
        {'nonnan','finite','real','numel',3,'nonsparse'});
        validateattributes(val(3),{'single','double'},...
        {'nonnan','finite','real','nonnegative'},fn,'position(3)');
    catch ME
        error(message('lidar:lidarSensor:invalidInput','Position',ME.message))
    end
end

function iValidateOrientation(val)
    try
        validateattributes(val,{'single','double'},...
        {'nonnan','finite','real','numel',3,'nonsparse'});
    catch ME
        error(message('lidar:lidarSensor:invalidInput','Orientation',ME.message))
    end
end

function iValidateAngleLimitsInput(val,name)
    try
        validateattributes(val,{'single','double'},...
        {'nonnan','finite','real','numel',2,'increasing','nonsparse','>=',-180,'<=',180});
    catch ME
        error(message('lidar:lidarSensor:invalidInput',name,ME.message))
    end
end

function iValidateAngleResolution(val,angleLimits,name)
    try
        validateattributes(val,{'single','double'},...
        {'nonnan','finite','scalar','real','nonsparse','positive','<',angleLimits(2)-angleLimits(1)});
    catch ME
        error(message('lidar:lidarSensor:invalidInput',name,ME.message))
    end
end

function iValidateElevationAngles(val)
    try
        validateattributes(val,{'single','double'},...
        {'nonnan','finite','real','vector','increasing','nonsparse','>=',-180,'<=',180});
    catch ME
        error(message('lidar:lidarSensor:invalidInput','ElevationAngles',ME.message))
    end
end

function iValidateRangeAccuracy(val)
    try
        validateattributes(val,{'single','double'},...
        {'nonnan','finite','scalar','real','positive','nonsparse'});
    catch ME
        error(message('lidar:lidarSensor:invalidInput','RangeAccuracy',ME.message))
    end
end

function iValidateSensorIndex(val)
    try
        validateattributes(val,{'numeric'},...
        {'nonempty','nonnan','finite','scalar','real','positive','integer','nonsparse'});
    catch ME
        error(message('lidar:lidarSensor:invalidInput','SensorIndex',ME.message))
    end
end

function iValidateHostID(val)
    try
        validateattributes(val,{'numeric'},...
        {'nonempty','nonnan','finite','scalar','real','positive','integer','nonsparse'});
    catch ME
        error(message('lidar:lidarSensor:invalidInput','HostID',ME.message))
    end
end

function iValidateHasNoise(val)
    try
        validateattributes(val,{'logical'},{'scalar','nonempty','nonsparse'})
    catch ME
        error(message('lidar:lidarSensor:invalidInput','HasNoise',ME.message))
    end
end

function iValidateHasOrganizedOutput(val)
    try
        validateattributes(val,{'logical'},{'scalar','nonempty','nonsparse'})
    catch ME
        error(message('lidar:lidarSensor:invalidInput','HasOrganizedOutput',ME.message))
    end
end
