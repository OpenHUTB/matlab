classdef ActorSpecification<driving.internal.scenarioApp.Specification




    properties
        ActorID=0;
        ClassID=0;
        Length=4.7;
        Width=1.8;
        Height=1.4;
        Mesh=[];
        Position=[0,0,0];
        RCSPattern=[10,10;10,10];
        RCSAzimuthAngles=[-180,180];
        RCSElevationAngles=[-90,90];
        PlotColor=[];
        Roll=0;
        Pitch=0;
        Yaw=0;
        FrontOverhang=0.9;
        Wheelbase=2.8
        RearOverhang=1.0;
        BarrierType='None';

        Waypoints=[];
        Speed=driving.scenario.Path.DefaultSpeed;
        WaitTime=[];
        WaypointsYaw=[];
        AssetType;
        EntryTime{mustBeNumeric,double,mustBeFinite,mustBeNonnegative}=0
        ExitTime{mustBeNumeric,double,mustBePositive}=Inf
        IsVisible(1,1)logical=true
        IsSpawnValid(1,1)logical=true
        TrajectoryFcn=@trajectory
        IsSmoothTrajectory=false;
        Jerk=0.6
    end

    properties(Transient,Hidden)
        pWaypointsYaw=[];
        ActorSpawn(1,1)logical=false;
    end

    methods

        function this=ActorSpecification(varargin)
            this@driving.internal.scenarioApp.Specification(varargin{:});




            if isempty(this.AssetType)
                this.AssetType='Cuboid';
            end
        end

        function set.Roll(this,roll)
            this.Roll=driving.scenario.internal.fixAngle(roll);
        end

        function set.Pitch(this,pitch)
            this.Pitch=driving.scenario.internal.fixAngle(pitch);
        end

        function set.Yaw(this,yaw)
            this.Yaw=driving.scenario.internal.fixAngle(yaw);
        end

        function convertAxesOrientation(this,old,new)
            if strcmpi(old,'ned')&&strcmpi(new,'enu')||strcmpi(old,'enu')&&strcmpi(new,'ned')
                pos=this.Position.*[1,-1,-1];

                pos(pos==0)=0;
                this.Position=pos;
                waypoints=this.Waypoints;
                if isempty(waypoints)

                    if this.Pitch~=0
                        this.Pitch=-this.Pitch;
                    end
                    if this.Yaw~=0
                        this.Yaw=-this.Yaw;
                    end
                else
                    waypoints=waypoints.*[1,-1,-1];
                    waypoints(waypoints==0)=0;
                    this.Waypoints=waypoints;
                end
            end
        end

        function set.Waypoints(this,waypoints)
            if size(waypoints,2)==2
                waypoints=[waypoints,zeros(size(waypoints,1),1)];
            end
            this.Waypoints=waypoints;
        end

        function varargout=applyToScenario(this,scenario,classSpecs,varargin)
            isVehicle=getProperty(classSpecs,this.ClassID,'isVehicle');
            pvPairs=[toPvPairs(this,isVehicle),varargin];
            if isVehicle
                a=vehicle(scenario,pvPairs{:});
            else
                a=actor(scenario,pvPairs{:});
            end
            this.ActorID=a.ActorID;
            if~isempty(this.Waypoints)
                speed=this.Speed;
                waittime=this.WaitTime;
                waypointsYaw=this.WaypointsYaw;
                badIndex=speed==0;
                isGood=true;
                if numel(speed)>1


                    if any(diff(find(badIndex))==1)
                        isGood=false;
                    end
                elseif any(badIndex)
                    isGood=false;
                end
                if isGood
                    otherArgs={};

                    if isempty(waypointsYaw)||all(isnan(waypointsYaw))
                        if~isempty(waittime)
                            otherArgs=horzcat(otherArgs,{waittime});
                        end
                    else
                        if isempty(waittime)
                            otherArgs=horzcat(otherArgs,{'Yaw',waypointsYaw});
                        else
                            otherArgs=horzcat(otherArgs,{waittime,'Yaw',waypointsYaw});
                        end
                    end
                    if this.IsSmoothTrajectory
                        otherArgs=horzcat(otherArgs,{'Jerk',this.Jerk});
                    end
                    this.TrajectoryFcn(a,this.Waypoints,speed,otherArgs{:});
                end
            end


            if isempty(this.PlotColor)
                this.PlotColor=a.PlotColor;
            end


            if isempty(this.Mesh)
                this.Mesh=a.Mesh;
            end
            if nargout
                varargout={a};
            end
        end

        function pvPairs=toPvPairs(this,isVehicle)
            pvPairs={
            'ClassID',this.ClassID,...
            'Name',this.Name,...
            'Length',this.Length,...
            'Width',this.Width,...
            'Height',this.Height,...
            'Position',this.Position,...
            'RCSPattern',this.RCSPattern,...
            'RCSAzimuthAngles',this.RCSAzimuthAngles,...
            'RCSElevationAngles',this.RCSElevationAngles};


            color=this.PlotColor;
            if~isempty(color)
                pvPairs=[pvPairs,...
                {'PlotColor',color}];
            end


            mesh=this.Mesh;
            if~isempty(mesh)
                pvPairs=[pvPairs,...
                {'Mesh',mesh}];
            end

            entryTime=this.EntryTime;
            if~isempty(entryTime)
                pvPairs=[pvPairs,...
                {'EntryTime',entryTime}];
            end
            exitTime=this.ExitTime;
            if~isempty(exitTime)
                pvPairs=[pvPairs,...
                {'ExitTime',exitTime}];
            end
            if isempty(this.Waypoints)
                pvPairs=[pvPairs,{...
                'Roll',this.Roll,...
                'Pitch',this.Pitch,...
                'Yaw',this.Yaw}];
            end
            if isVehicle
                pvPairs=[pvPairs,{...
                'RearOverhang',this.RearOverhang,...
                'FrontOverhang',this.FrontOverhang}];
            end
        end

        function applyToActor(this,actor,classSpecs,varargin)
            pvPairs=toPvPairs(this,getProperty(classSpecs,this.ClassID,'isVehicle'));
            pvPairs=[pvPairs,varargin];
            for indx=1:2:numel(pvPairs)
                actor.(pvPairs{indx})=pvPairs{indx+1};
            end
            waypoints=this.Waypoints;
            speed=this.Speed;
            waitTime=this.WaitTime;
            waypointsYaw=this.WaypointsYaw;
            jerk=this.Jerk;
            otherArgs={};
            if this.IsSmoothTrajectory
                otherArgs={'Jerk',jerk};
            end
            if~isempty(waypoints)

                dupIndex=all(diff(waypoints)==[0,0,0],2);
                waypoints(dupIndex,:)=[];



                if numel(speed)>1&&length(speed)==length(this.Waypoints)
                    speed(dupIndex)=[];
                end

                if~isempty(waitTime)
                    waitTime(dupIndex,:)=[];
                end

                if~isempty(waypointsYaw)
                    waypointsYaw(dupIndex,:)=[];
                end
            end

            if size(waypoints,1)>1
                if all(isnan(waypointsYaw))||isempty(waypointsYaw)
                    if isempty(waitTime)
                        this.TrajectoryFcn(actor,waypoints,speed,otherArgs{:});
                    else
                        if size(waitTime,1)<size(waypoints,1)
                            waitTime=[waitTime;repmat(waitTime(end),size(waypoints,1)-size(waitTime,1),1)];
                        end
                        pauseIdxs=find(waitTime>0);
                        speedIdxs=find(speed==0,1);
                        if(isempty(speedIdxs)||any(speed(pauseIdxs)~=0))&&~isempty(pauseIdxs)
                            speed(pauseIdxs)=0;
                            this.Speed=speed;
                        end
                        this.TrajectoryFcn(actor,waypoints,speed,waitTime,otherArgs{:});
                    end
                else
                    if size(waypointsYaw,1)<size(waypoints,1)
                        waypointsYaw=[waypointsYaw;repmat(waypointsYaw(end),size(waypoints,1)-size(waypointsYaw,1),1)];
                    end
                    if isempty(waitTime)
                        this.TrajectoryFcn(actor,waypoints,speed,'Yaw',waypointsYaw,otherArgs{:});
                    else
                        if size(waitTime,1)<size(waypoints,1)
                            waitTime=[waitTime;repmat(waitTime(end),size(waypoints,1)-size(waitTime,1),1)];
                        end
                        pauseIdxs=find(waitTime>0);
                        speedIdxs=find(speed==0,1);
                        if(isempty(speedIdxs)||any(speed(pauseIdxs)~=0))&&~isempty(pauseIdxs)
                            speed(pauseIdxs)=0;
                            this.Speed=speed;
                        end
                        this.TrajectoryFcn(actor,waypoints,speed,waitTime,'Yaw',waypointsYaw,otherArgs{:});
                    end
                end
                pwaypointsYaw=actor.MotionStrategy.getWaypointsYaw;
                if size(pwaypointsYaw,1)~=size(this.Waypoints,1)
                    irepeated=find(all(this.Waypoints(1:end-1,:)==this.Waypoints(2:end,:),2));
                    for k=1:numel(irepeated)
                        repeatedIdx=irepeated(k);
                        pwaypointsYaw=[pwaypointsYaw(1:repeatedIdx-1,:);pwaypointsYaw(repeatedIdx,:);pwaypointsYaw(repeatedIdx:end,:)];
                    end
                end
                this.pWaypointsYaw=pwaypointsYaw;
            else
                actor.MotionStrategy=driving.scenario.Stationary(this);
            end
        end

        function str=generateMatlabCode(this,scenarioName,classSpecs,isEgo,overwriteProps)

            if nargin<4
                isEgo=false;
            end

            pvPairs="";
            if nargin<5
                overwriteProps=struct;
            end
            props={'ClassID','Length','Width','Height','Position',...
            'RCSPattern','RCSAzimuthAngles','RCSElevationAngles',...
            'EntryTime','ExitTime'};
            if isempty(this.Waypoints)
                props=[props,{'Yaw','Pitch','Roll'}];
            end
            if getProperty(classSpecs,this.ClassID,'isVehicle')
                functionName='vehicle';
                props=[props,{'RearOverhang','FrontOverhang','Wheelbase'}];
                isVehicle=true;
            else
                functionName='actor';
                isVehicle=false;
            end
            for indx=1:numel(props)
                propName=props{indx};
                propHandle=findprop(this,props{indx});

                if isfield(overwriteProps,propName)
                    value=overwriteProps.(propName);
                else
                    value=this.(propName);
                end
                if~isequal(value,propHandle.DefaultValue)
                    pvPairs=pvPairs+sprintf(", ...\n    '%s', %s",propName,mat2str(value));
                end
            end

            mesh=this.Mesh;
            if~isempty(mesh)






                dims=struct('Length',this.Length,'Width',this.Width,...
                'Height',this.Height,'RearOverhang',this.RearOverhang);
                meshStr=driving.internal.scenarioApp.ClassEditor.getMeshExpression(mesh,isVehicle,dims);
                if~(meshStr=="")
                    pvPairs=pvPairs+sprintf(", ...\n    'Mesh', %s",meshStr);
                end
            end

            color=this.PlotColor;
            if~isempty(color)&&~isequal(driving.scenario.Actor.getDefaultColorForActorID(this.ActorID),color)
                intColor=color*255;
                if abs(round(intColor)-intColor)<0.01
                    colorStr=[mat2str(round(intColor)),' / 255'];
                else
                    colorStr=mat2str(color);
                end
                pvPairs=pvPairs+sprintf(", ...\n    'PlotColor', %s",colorStr);
            end
            if~isempty(this.Name)
                pvPairs=pvPairs+sprintf(", ...\n    'Name', '%s'",getMatlabPrintName(this));
            end


            jerkStr="";
            if isequal(this.TrajectoryFcn,@trajectory)
                trajStr="\ntrajectory";
            else
                trajStr="\nsmoothTrajectory";
                if this.Jerk~=0.6
                    jerkStr=", 'Jerk', jerk";
                end
            end
            str=sprintf("%s(%s%s);",functionName,scenarioName,pvPairs);
            hasWaypoints=~isempty(this.Waypoints)&&any(this.Speed~=0);
            variableName='';
            if isEgo
                variableName='egoVehicle';
            elseif hasWaypoints
                variableName=getMatlabVariableName(this);
            end
            if~isempty(variableName)
                protectedName={'actor','vehicle',scenarioName};
                if~isEgo
                    protectedName=[protectedName,{'egoCar'}];
                end
                if hasWaypoints
                    protectedName=[protectedName,{'waypoints','speed'}];
                end
                if any(strcmp(variableName,protectedName))
                    variableName=['actor_',variableName];
                end
                str=variableName+" = "+str;
            end
            if hasWaypoints
                str=str+newline+"waypoints = ";
                str=str+strrep(mat2str(this.Waypoints),';',[';',newline,repmat(' ',1,13)])+';';
                str=str+newline+"speed = "+mat2str(this.Speed)+";";
                if jerkStr~=""
                    str=str+newline+"jerk = "+mat2str(this.Jerk)+";";
                end
                if all(isnan(this.WaypointsYaw))||isempty(this.WaypointsYaw)
                    if~isempty(this.WaitTime)
                        str=str+newline+"waittime = "+mat2str(this.WaitTime)+";";
                        str=str+sprintf(strcat(trajStr,"(%s, waypoints, speed, waittime",jerkStr,");"),variableName);
                    else
                        str=str+sprintf(strcat(trajStr,"(%s, waypoints, speed",jerkStr,");"),variableName);
                    end
                else
                    str=str+newline+"yaw =  "+mat2str(this.WaypointsYaw)+";";
                    if~isempty(this.WaitTime)&&any(this.WaitTime)
                        str=str+newline+"waittime = "+mat2str(this.WaitTime)+";";
                        str=str+sprintf(strcat(trajStr,"(%s, waypoints, speed, waittime, 'Yaw', yaw",jerkStr,");"),variableName);
                    else
                        str=str+sprintf(strcat(trajStr,"(%s, waypoints, speed, 'Yaw', yaw",jerkStr,");"),variableName);
                    end
                end
            end
        end

        function set.IsSmoothTrajectory(this,val)

            if val
                this.TrajectoryFcn=@smoothTrajectory;%#ok<*MCSUP>
            else
                this.TrajectoryFcn=@trajectory;
            end
            this.IsSmoothTrajectory=val;
        end
    end

    methods(Hidden)
        function pvPairs=addPVPair(this,pvPairs,propName,defaultValue)
            if~isequal(this.(propName),defaultValue)
                pvPairs=pvPairs+sprintf(", ...\n    '%s', %s",propName,mat2str(this.(propName)));
            end
        end

        function[id,str]=validateLength(this,value,isVehicle)
            id='';
            str='';
            if isempty(this.RearOverhang)
                this.RearOverhang=1;
            end
            if isempty(this.FrontOverhang)
                this.FrontOverhang=1;
            end
            if(this.EntryTime==this.ExitTime)
                this.ExitTime=Inf;
            end
            if numel(value)~=1||isnan(value)||...
                isVehicle&&(value-this.RearOverhang-this.FrontOverhang<=0||value>60)||...
                value>200||...
                value<=0
                if isVehicle
                    id='driving:scenarioApp:BadLengthVehicle';
                    str=getString(message(id,num2str(this.RearOverhang+this.FrontOverhang)));
                else
                    id='driving:scenarioApp:BadLengthActor';
                    str=getString(message(id));
                end
            end
        end

        function[id,str]=validateHeight(~,value,isVehicle)
            id='';
            str='';
            if numel(value)~=1||isnan(value)||...
                isVehicle&&value>20||...
                value>200||...
                value<=0
                if isVehicle
                    id='driving:scenarioApp:BadHeightVehicle';
                else
                    id='driving:scenarioApp:BadHeightActor';
                end
                str=getString(message(id));
            end
        end

        function[id,str]=validateWidth(~,value,isVehicle)
            id='';
            str='';
            if numel(value)~=1||isnan(value)||...
                isVehicle&&value>20||...
                value>200||...
                value<=0
                if isVehicle
                    id='driving:scenarioApp:BadWidthVehicle';
                else
                    id='driving:scenarioApp:BadWidthActor';
                end
                str=getString(message(id));
            end
        end

        function[id,str]=validateWaypointsYaw(~,value,~)
            id='';
            str='';
            isBad=false;
            if any(isinf(value))||any(isnan(value))
                isBad=true;
            end
            if isBad
                id='driving:scenarioApp:BadWaypointsYawActor';
                str=getString(message(id));
            end
        end
    end

    methods(Static)
        function actorSpecs=fromScenario(scenario,classes)
            actors=scenario.Actors;
            actorSpecs=driving.internal.scenarioApp.ActorSpecification.empty(numel(actors),0);
            if isempty(actors)
                return;
            end
            props={'ClassID','Position','Yaw','Pitch','Roll',...
            'Length','Width','Height','Mesh','PlotColor',...
            'RCSPattern','RCSAzimuthAngles','RCSElevationAngles'};
            validIds=getAllIds(classes);
            allErrors={};
            allWarnings={};
            countMap=containers.Map('KeyType','double','ValueType','double');
            actorTypeString='';
            vehicleTypeString='';
            format='%s%d (%s), ';
            for indx=1:numel(validIds)
                id=validIds(indx);
                countMap(id)=0;
                name=classes.getProperty(id,'name');
                if classes.getProperty(id,'isVehicle')
                    vehicleTypeString=sprintf(format,vehicleTypeString,id,name);
                else
                    actorTypeString=sprintf(format,actorTypeString,id,name);
                end
            end
            if~isempty(actorTypeString)
                actorTypeString(end-1:end)=[];
            end
            if~isempty(vehicleTypeString)
                vehicleTypeString(end-1:end)=[];
            end
            vehicleTypes=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetTypes(true);
            actorTypes=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetTypes(false);
            dims=struct;
            for indx=1:numel(vehicleTypes)
                dims.(vehicleTypes{indx})=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetDimensions(vehicleTypes{indx});
            end
            for indx=1:numel(actorTypes)
                dims.(actorTypes{indx})=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetDimensions(actorTypes{indx});
            end
            for indx=1:numel(actors)
                actor=actors(indx);
                classID=actor.ClassID;

                if any(classID==validIds)
                    info=classes.getSpecification(classID);
                    countMap(classID)=countMap(classID)+1;
                    name=getName(info.name,countMap(classID));
                    if~info.isMovable&&~isa(actor.MotionStrategy,'driving.scenario.Stationary')
                        allErrors{end+1}=getString(message('driving:scenarioApp:InvalidImportMovable',indx,classID));
                    elseif info.isVehicle&&~isa(actor,'driving.scenario.Vehicle')
                        if isempty(actorTypeString)
                            err=getString(message('driving:scenarioApp:InvalidImportTypeMismatch',indx,classID,'a vehicle'));
                        else
                            err=getString(message('driving:scenarioApp:InvalidImportType',indx,'actor',actorTypeString));
                        end
                        allErrors{end+1}=err;%#ok<*AGROW>
                    elseif~info.isVehicle&&isa(actor,'driving.scenario.Vehicle')
                        if isempty(vehicleTypeString)
                            err=getString(message('driving:scenarioApp:InvalidImportTypeMismatch',indx,classID,'an actor'));
                        else
                            err=getString(message('driving:scenarioApp:InvalidImportType',indx,'vehicle',vehicleTypeString));
                        end
                        allErrors{end+1}=err;
                    end

                    fields={'Length','Width','Height'};
                    for jndx=1:numel(fields)
                        f=fields{jndx};
                        if actor.(f)<info.(f)*0.5||actor.(f)>info.(f)*2
                            allWarnings{end+1}=getString(message('driving:scenarioApp:InconsistentImportProperty',indx,f,mat2str(info.(f)),classID,info.name));
                        end
                    end
                else
                    allErrors{end+1}=getString(message('driving:scenarioApp:InvalidImportID',indx,classID));
                    name='';
                end
                pvPairs=cell(1,numel(props)*2);
                pvPairs(1:2:numel(props)*2-1)=props;
                for jndx=1:numel(props)
                    pvPairs{jndx*2}=actor.(props{jndx});
                end
                if~(actor.Name=="")
                    name=actor.Name;
                end
                pvPairs=[pvPairs,{'Name',name}];
                motion=actor.MotionStrategy;

                if~isempty(motion)&&isprop(motion,'Waypoints')
                    pvPairs=[pvPairs,{...
                    'Waypoints',motion.Waypoints,...
                    'Speed',motion.Speed,...
                    'WaitTime',motion.WaitTime,...
                    'WaypointsYaw',rad2deg(motion.Yaw),...
                    'pWaypointsYaw',motion.getWaypointsYaw}];
                    if isa(motion,'driving.scenario.SmoothTrajectory')
                        pvPairs=[pvPairs,{'IsSmoothTrajectory',true,...
                        'Jerk',motion.Jerk}];
                    end
                end
                if isprop(actor,'FrontOverhang')
                    pvPairs=[pvPairs,{
                    'FrontOverhang',actor.FrontOverhang,...
                    'Wheelbase',actor.Wheelbase,...
                    'RearOverhang',actor.RearOverhang}];
                end

                if isprop(actor,'EntryTime')


                    if indx==1
                        actor.EntryTime=0;
                        actor.ExitTime=Inf;
                    end
                    pvPairs=[pvPairs,{
                    'EntryTime',actor.EntryTime,...
                    'ExitTime',actor.ExitTime,...
                    'IsVisible',actor.IsVisible,...
                    'IsSpawnValid',actor.IsSpawnValid}];

                end
                actorSpecs(indx)=driving.internal.scenarioApp.ActorSpecification(pvPairs{:});
                if getProperty(classes,actorSpecs(indx).ClassID,'isVehicle')
                    types=vehicleTypes;
                else
                    types=actorTypes;
                end


                assetType=getProperty(classes,actorSpecs(indx).ClassID,'AssetType');
                for jndx=1:numel(types)
                    tdims=dims.(types{jndx});
                    dprops=fieldnames(tdims);
                    if isempty(dprops)
                        continue;
                    end
                    same=true;
                    for kndx=1:numel(dprops)


                        if abs(actorSpecs(indx).(dprops{kndx})-tdims.(dprops{kndx}))>0.0001
                            same=false;
                            break;
                        end
                    end
                    if same
                        assetType=types{jndx};
                        break
                    end
                end
                actorSpecs(indx).AssetType=assetType;
            end
            if~isempty(allErrors)
                errorStr=sprintf('%s\n',allErrors{:});
                errorStr(end)=[];
                error('driving:scenarioApp:InvalidImport',errorStr);
            end
            if~isempty(allWarnings)
                warnStr=sprintf('%s\n',getString(message('driving:scenarioApp:InconsistentImportHeader')),allWarnings{:});
                warnStr(end)=[];
                warning('driving:scenarioApp:InconsistentImport',warnStr);
            end
        end

        function index=findDuplicateWaypoints(waypoints)

            waypoints(:,3:end)=[];
            index=find(sum(diff(waypoints),2)==0)+1;
        end
    end
end

function name=getName(name,index)
    if index>1
        name=sprintf('%s%d',name,index-1);
    end
end


