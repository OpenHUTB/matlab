classdef ActorProperties<driving.internal.scenarioApp.Properties

    properties
        ShowActorProperties=false;
        ShowRCSProperties=false;
        ShowPathProperties=false;
        ShowDynamicActor=false;
    end

    properties(Hidden)

        hTable

        hName
        hClassID
        hAgentModelLabel
        hAgentModel
        hLength
        hWidth
        hHeight
        hRoll
        hPitch
        hYaw
        hFrontOverhangLabel
        hFrontOverhang
        hRearOverhangLabel
        hRearOverhang
        hSpeed
        hColorPatch
        hAssetType
        hImportRCS;

        hRCSElevationAngles;
        hRCSAzimuthAngles;
        hRCSPattern;

        hShowActorProperties
        hShowRCSProperties
        hShowPathProperties

        hAddForwardWaypoints
        hAddReverseWaypoints
        hClearWaypoints

        hSetEgoCar

        hActorPanel
        hRCSPanel
        hPathPanel

        AllIDsCache
        ActorPropertiesLayout
        RCSPropertiesLayout
        PathPropertiesLayout
        AddingReverseMotion(1,1)logical=false
        UpdateTableColumnWidthsOnOpen=false;

        hEntryTime
        hExitTime
        DynamicActorCheckboxLayout
        hShowDynamicActor

        hIsSmoothTrajectory
        hJerk
    end


    methods

        function this=ActorProperties(varargin)

            this@driving.internal.scenarioApp.Properties(varargin{:});
            update(this);
        end


        function name=getName(~)
            name=getString(message('driving:scenarioApp:ActorPropertiesTitle'));
        end


        function tag=getTag(~)
            tag='ActorProperties';
        end


        function updateProperty(this,property)
            switch property
                case 'Waypoints'
                    updateWaypoints(this);
                case 'Yaw'
                    updateYaw(this);
            end
        end


        function updateYaw(this)
            spec=getCurrentSpecification(this);
            if numel(spec)>1
                spec=spec(1);
            end
            this.hYaw.String=spec.Yaw;
        end


        function updateWaypoints(this)
            if this.InteractiveMode
                app=this.Application;
                canvas=app.ScenarioView;

                if useAppContainer(app)&&strcmp(canvas.InteractionMode,'dragActorWaypoint')
                    return;
                end
                data=getTableData(canvas);
            else
                spec=getCurrentSpecification(this);
                if~isempty(spec)
                    if numel(spec)>1
                        spec=spec(1);
                    end
                    speeds=spec.Speed;
                    waypoints=spec.Waypoints;
                    waitTime=spec.WaitTime;
                    if isempty(waitTime)
                        waitTime=0;
                    end

                    nSpeeds=numel(speeds);
                    nWaypoints=size(waypoints,1);
                    nWaitTimes=numel(waitTime);
                    if nWaypoints==0
                        data=spec.Position;
                        if iscell(data)
                            data{end+1}=speeds;
                            data{end+1}=0;
                        else
                            data(end+1)=speeds;
                            data(end+1)=0;
                        end
                    else
                        if nSpeeds<nWaypoints
                            speeds=[speeds;repmat(speeds(end),nWaypoints-nSpeeds,1)];
                        elseif nSpeeds>nWaypoints
                            speeds(nWaypoints+1:end)=[];
                        end
                        if nWaitTimes<nWaypoints
                            waitTime=[waitTime;repmat(waitTime(end),nWaypoints-nWaitTimes,1)];
                        elseif nWaitTimes>nWaypoints
                            waitTime(nWaypoints+1:end)=[];
                        end
                        data=[waypoints,speeds(:),waitTime(:)];
                    end
                else
                    data=getTableData(this.Application.ScenarioView);
                end
            end
            this.hTable.Data=data;

        end


        function update(this)
            clearAllMessages(this);
            hApp=this.Application;
            allActorSpecs=hApp.ActorSpecifications;
            table=this.hTable;
            isAdd=false;
            canvas=hApp.ScenarioView;
            if this.InteractiveMode
                set(this.hSpecificationIndex,'Enable','off');
                if strcmp(canvas.InteractionMode,'addActor')
                    set(this.hSpecificationIndex,'String',{getString(message('driving:scenarioApp:AddActorSpecificationIndex'))},'Value',1);
                    currentActorSpec=canvas.CurrentActor;
                    isAdd=true;
                else
                    spec=getCurrentSpecification(this);
                    if isempty(spec)
                        return;
                    end
                    data=getTableData(canvas);

                    displayData=data;
                    if size(data,2)==6
                        for dRow=1:size(data,1)
                            if~ischar(data{dRow,1})&&~ischar(data{dRow,2})&&isnan(data{dRow,6})
                                displayData{dRow,6}='';
                            end
                        end
                    end
                    set(table,'Enable','on',...
                        'Data',displayData);
                    nCommitted=size(spec.Waypoints,1);
                    if nCommitted==0
                        nCommitted=1;
                    end

                    if~isempty(data)
                        committedData=data(1:nCommitted,:);
                        committedData=cell2mat(committedData);
                        if~isempty(spec.findDuplicateWaypoints(committedData))
                            id='driving:scenarioApp:RepeatedWaypoints';
                            errorMessage(this,getString(message(id)),id);
                            return;
                        end
                    end

                    nWaypoints=size(canvas.Waypoints,1);
                    if nWaypoints==0
                        nWaypoints=nCommitted;
                    end
                    if nWaypoints==nCommitted
                        enab='off';
                    else
                        enab='on';
                    end
                    if nWaypoints==0
                        nWaypoints=1;
                    end
                    if strcmp(canvas.InteractionMode,'addActorWaypoints')
                        if this.AddingReverseMotion
                            set(this.hAddReverseWaypoints,...
                                'Enable',enab,...
                                'CData',getIcon(hApp,'confirm16'),...
                                'TooltipString',getString(message('driving:scenarioApp:AcceptWaypointsDescription')));
                        else
                            set(this.hAddForwardWaypoints,...
                                'Enable',enab,...
                                'CData',getIcon(hApp,'confirm16'),...
                                'TooltipString',getString(message('driving:scenarioApp:AcceptWaypointsDescription')));
                        end
                    end
                    set(table,'RowName',1:nWaypoints);
                end
                set(this.hClearWaypoints,'Enable','off');
                set(this.hShowDynamicActor,'Enable','off');
                set(this.hIsSmoothTrajectory,'Enable','off');
                set(this.hEntryTime,'String','','Enable','off');
                set(this.hExitTime,'String','','Enable','off');
                set(this.hDelete,'Enable','off');
                if~isAdd
                    return;
                end
            elseif isempty(allActorSpecs)
                table.Data=[];
                set([this.hSpecificationIndex,this.hClassID,this.hAssetType],...
                    'String',{' '},...
                    'Value',1,...
                    'Enable','off');
                set([this.hName,this.hLength,this.hWidth...
                    ,this.hHeight,this.hRCSElevationAngles,this.hRCSAzimuthAngles...
                    ,this.hRoll,this.hPitch,this.hYaw,this.hFrontOverhang,this.hRearOverhang...
                    ,this.hSpeed,this.hEntryTime,this.hExitTime,this.hJerk],...
                    'String','',...
                    'Enable','off');
                set(this.hColorPatch,'BackgroundColor',get(0,'DefaultUIControlBackgroundColor'));
                set([this.hAddForwardWaypoints,this.hAddReverseWaypoints,this.hClearWaypoints...
                    ,this.hDelete,this.hImportRCS,this.hSetEgoCar,...
                    this.hShowDynamicActor,this.hIsSmoothTrajectory],'Enable','off');
                set(this.hRCSPattern,'Enable','off','RowName',[],'ColumnName',[],'Data',[]);
                return;

            elseif numel(this.SpecificationIndex)>1
                currentActorSpec=allActorSpecs(this.SpecificationIndex);
                info=[{currentActorSpec.ActorID};{currentActorSpec.Name}];
                displayData=sprintf('%d: %s; ',info{:});
                set(table,'Enable','off');
                if all(cellfun(@isempty,{currentActorSpec.Waypoints}))
                    set(this.hClearWaypoints,'Enable','off');
                else
                    set(this.hClearWaypoints,'Enable','on');
                end
                set(this.hShowDynamicActor,'Enable','off');
                set(this.hEntryTime,'String','','Enable','off');
                set(this.hExitTime,'String','','Enable','off');
                set(this.hSpecificationIndex,...
                    'String',displayData,...
                    'Value',1,...
                    'Enable','on');
                set([this.hClassID,this.hAssetType],...
                    'String',{' '},...
                    'Value',1,...
                    'Enable','off');
                set([this.hName,this.hLength,this.hWidth...
                    ,this.hHeight,this.hRCSElevationAngles,this.hRCSAzimuthAngles...
                    ,this.hRoll,this.hPitch,this.hYaw,this.hFrontOverhang,this.hRearOverhang...
                    ,this.hSpeed,this.hEntryTime,this.hExitTime,this.hJerk],...
                    'String','',...
                    'Enable','off');
                set(this.hColorPatch,'BackgroundColor',get(0,'DefaultUIControlBackgroundColor'));
                set([this.hAddForwardWaypoints,this.hAddReverseWaypoints...
                    ,this.hImportRCS,this.hSetEgoCar,...
                    this.hShowDynamicActor,this.hIsSmoothTrajectory],'Enable','off');
                set(this.hRCSPattern,'Enable','off','RowName',[],'ColumnName',[],'Data',[]);
                return;
            else
                if~isempty(this.SpecificationIndex)
                    currentActorSpec=allActorSpecs(this.SpecificationIndex);
                else
                    currentActorSpec=allActorSpecs(1);
                end
            end

            set(this.hAddForwardWaypoints,...
                'Enable',matlabshared.application.logicalToOnOff(~isAdd&&this.Enabled),...
                'CData',getIcon(hApp,'addForwardWaypoints16'),...
                'TooltipString',getString(message('driving:scenarioApp:AddWaypointsDescription')));
            set(this.hAddReverseWaypoints,...
                'Enable',matlabshared.application.logicalToOnOff(~isAdd&&this.Enabled),...
                'CData',getIcon(hApp,'addReverseWaypoints16'),...
                'TooltipString',getString(message('driving:scenarioApp:AddReverseWaypointsDescription')));
            classSpecs=hApp.ClassSpecifications;
            classSpec=classSpecs.getSpecification(currentActorSpec.ClassID);

            if isAdd
                if isfield(currentActorSpec,'PlotColor')
                    color=currentActorSpec.PlotColor;
                else
                    color=driving.scenario.Actor.getDefaultColorForActorID(numel(allActorSpecs)+1);
                end
                set(this.hColorPatch,'BackgroundColor',color);
                this.ShowDynamicActor=false;
                set(this.hShowDynamicActor,'Enable','off','Value',0);
                set(this.hEntryTime,'String','','Enable','off');
                set(this.hExitTime,'String','','Enable','off');
                set(this.hDelete,'Enable','off');
            else
                nActors=numel(allActorSpecs);
                allNames=cell(nActors,1);
                egoCarId=this.Application.EgoCarId;
                for indx=1:nActors
                    name=allActorSpecs(indx).Name;
                    allNames{indx}=sprintf('%d: %s',indx,name);
                    if isequal(indx,egoCarId)
                        allNames{indx}=sprintf('%s (%s)',allNames{indx},getString(message('driving:scenarioApp:EgoCarText')));
                    end
                end
                set(this.hSpecificationIndex,...
                    'String',allNames,...
                    'Value',this.SpecificationIndex,...
                    'Enable','on');
                if~isempty(currentActorSpec.PlotColor)
                    set(this.hColorPatch,'BackgroundColor',currentActorSpec.PlotColor);
                end
            end

            if~isAdd&&~currentActorSpec.ActorSpawn...
                    &&(~isscalar(currentActorSpec.EntryTime) ...
                    ||~(currentActorSpec.EntryTime==0 ...
                &&currentActorSpec.ExitTime==Inf))
                currentActorSpec.ActorSpawn=true;
            end
            enable=matlabshared.application.logicalToOnOff(this.Enabled);
            if~isAdd&&currentActorSpec.ActorSpawn&&~(isempty(currentActorSpec.Waypoints))&&...
                    ~isequal(this.Application.EgoCarId,this.SpecificationIndex)
                set(this.hShowDynamicActor,'Enable',enable,'Value',1);
                if~isempty(currentActorSpec.EntryTime)
                    set(this.hEntryTime,'String',mat2str(currentActorSpec.EntryTime),...
                        'Enable',enable);
                    if~isempty(currentActorSpec.ExitTime)
                        set(this.hExitTime,'String',mat2str(currentActorSpec.ExitTime),...
                            'Enable',enable);
                    end
                end
            elseif get(this.hEntryTime,'Visible')||isequal(this.Application.EgoCarId,this.SpecificationIndex)
                set(this.hEntryTime,'String','','Enable','off');
                set(this.hExitTime,'String','','Enable','off');
                set(this.hShowDynamicActor,'Enable','off','Value',0);
            end

            set(this.hName,...
                'String',currentActorSpec.Name,...
                'Enable',enable);
            allIds=getAllIds(classSpecs);

            idString={};
            if isstruct(currentActorSpec)
                waypoints=[];
                waitTime=[];
                waypointsYaw=[];
            else
                waypoints=currentActorSpec.Waypoints;
                waitTime=currentActorSpec.WaitTime;
                waypointsYaw=currentActorSpec.pWaypointsYaw;
            end
            onlyMovable=~isempty(waypoints);
            isVehicle=classSpec.isVehicle;
            indx=1;
            while indx<=numel(allIds)
                if(~onlyMovable||getProperty(classSpecs,allIds(indx),'isMovable'))&&...
                        isVehicle==getProperty(classSpecs,allIds(indx),'isVehicle')
                    idString{end+1}=getProperty(classSpecs,allIds(indx),'name');%#ok<AGROW>
                    indx=indx+1;
                else
                    allIds(indx)=[];
                end
            end


            idValue=find(strcmp(classSpec.name,idString),1,'first');
            if isempty(idValue)
                idString=[idString,{getString(message('driving:scenarioApp:CuboidText'))}];
                idValue=numel(idString);
            end


            this.AllIDsCache=allIds;
            set(this.hClassID,...
                'String',idString,...
                'Value',idValue,...
                'Enable',enable);


            assets=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetTypes(isVehicle);
            setupPopup(this,'AssetType',assets{:});
            if isfield(currentActorSpec,'AssetType')||isprop(currentActorSpec,'AssetType')
                asset=currentActorSpec.AssetType;
            else
                asset='Cuboid';
            end
            setPopupValue(this,'AssetType',asset);
            set(this.hAssetType,'Enable',enable);

            sim=hApp.Simulator;
            set(this.hAgentModel,'String',getAgentModelString(sim));

            if hApp.Use3dSimDimensions
                staticDims=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetDimensions(asset);
            else
                staticDims=struct;
            end

            setDimensionWidget(this,'Length',currentActorSpec,staticDims,enable);
            setDimensionWidget(this,'Width',currentActorSpec,staticDims,enable);
            setDimensionWidget(this,'Height',currentActorSpec,staticDims,enable);

            actorLayout=this.ActorPropertiesLayout;
            hFront=this.hFrontOverhang;
            hRear=this.hRearOverhang;
            hFrontLabel=this.hFrontOverhangLabel;
            hRearLabel=this.hRearOverhangLabel;
            if isVehicle&&isstruct(currentActorSpec)&&~isfield(currentActorSpec,'FrontOverhang')
                currentActorSpec.FrontOverhang=0.9;
                currentActorSpec.RearOverhang=1.0;
                canvas.CurrentActor=currentActorSpec;
            end
            if isVehicle
                if~contains(actorLayout,hFront)
                    insert(actorLayout,'row',3)
                    add(actorLayout,hFrontLabel,3,1);
                    add(actorLayout,hRearLabel,3,2);
                    insert(actorLayout,'row',4)
                    add(actorLayout,hFront,4,1);
                    add(actorLayout,hRear,4,2);
                end
                setDimensionWidget(this,'FrontOverhang',currentActorSpec,staticDims,enable);
                setDimensionWidget(this,'RearOverhang',currentActorSpec,staticDims,enable);
            elseif contains(actorLayout,hFront)
                remove(actorLayout,hFront);
                remove(actorLayout,hRear);
                remove(actorLayout,hFrontLabel);
                remove(actorLayout,hRearLabel);
                clean(actorLayout);
                update(actorLayout,'force');
            end
            set([hFront,hRear,hFrontLabel,hRearLabel],'Visible',isVehicle);
            if this.ShowActorProperties
                [~,h]=getMinimumSize(actorLayout);
                h=sum(h)+actorLayout.VerticalGap*(numel(h)+1);
                setConstraints(this.Layout,this.hActorPanel,...
                    'MinimumHeight',h);
                update(this.Layout,'force');
            end



            assets=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetTypes(isVehicle);
            setupPopup(this,'AssetType',assets{:});
            if isfield(currentActorSpec,'AssetType')||isprop(currentActorSpec,'AssetType')
                asset=currentActorSpec.AssetType;
            else
                asset='Cuboid';
            end
            setPopupValue(this,'AssetType',asset);
            set(this.hAssetType,'Enable',enable);


            hAzim=this.hRCSAzimuthAngles;
            hElev=this.hRCSElevationAngles;
            hPatt=this.hRCSPattern;
            driving.internal.scenarioApp.RCSHelper.updateWidgets(...
                hAzim,hElev,hPatt,currentActorSpec,enable);

            speeds=currentActorSpec.Speed;
            nSpeeds=numel(speeds);
            nWaypoints=size(waypoints,1);
            if classSpec.isMovable
                speedEnable=enable;
            else
                speeds=0;
                speedEnable='off';
                this.hAddForwardWaypoints.Enable=speedEnable;
                this.hAddReverseWaypoints.Enable=speedEnable;
            end
            try
                set(this.hIsSmoothTrajectory,'Enable',speedEnable,'Value',currentActorSpec.IsSmoothTrajectory);


                if isequal(this.Application.EgoCarId,this.SpecificationIndex)
                    if currentActorSpec.IsSmoothTrajectory
                        sensors=this.Application.SensorSpecifications;
                        if~isempty(sensors)
                            if any(string({sensors.Type})=='ins')
                                set(this.hIsSmoothTrajectory,'Enable','off');
                            end
                        end
                    end
                end
                if currentActorSpec.IsSmoothTrajectory
                    jerkEnable=speedEnable;
                    jerkVal=currentActorSpec.Jerk;
                else
                    jerkEnable='off';
                    jerkVal='';
                end
                set(this.hJerk,'Enable',jerkEnable,'String',jerkVal);
            catch E %#ok<NASGU>



            end
            if nWaypoints==0
                set(this.hSpeed,...
                    'String',abs(speeds(1)),...
                    'Enable',speedEnable);
            else
                absSpeeds=abs(speeds);
                absSpeeds(absSpeeds==0)=[];
                if all(absSpeeds(1)==absSpeeds)
                    speedStr=absSpeeds(1);
                else
                    speedStr='';
                end
                set(this.hSpeed,...
                    'String',speedStr,...
                    'Enable',speedEnable);
            end
            if isempty(waitTime)
                waitTime=0;
            end
            nwaitTime=numel(waitTime);
            if~classSpec.isMovable
                waitTime=0;
            end
            nwaypointsYaw=numel(waypointsYaw);
            this.hClearWaypoints.Enable=matlabshared.application.logicalToOnOff(~(isempty(waypoints)||~this.Enabled));
            if~isequal(this.Application.EgoCarId,this.SpecificationIndex)
                this.hShowDynamicActor.Enable=matlabshared.application.logicalToOnOff(~(isempty(waypoints)||~this.Enabled));
            end
            if nWaypoints==0
                if isstruct(currentActorSpec)&&~isfield(currentActorSpec,'Roll')
                    currentActorSpec.Roll=0;
                    currentActorSpec.Pitch=0;
                    currentActorSpec.Yaw=0;
                    currentActorSpec.Position={'','',0};
                    canvas.CurrentActor=currentActorSpec;
                end
                data=currentActorSpec.Position;
                if iscell(data)
                    data{end+1}=currentActorSpec.Speed;
                    data{end+1}=0;
                    data{end+1}=currentActorSpec.Yaw;
                else
                    data(end+1)=currentActorSpec.Speed;
                    data(end+1)=0;
                    data(end+1)=currentActorSpec.Yaw;
                end
                set(this.hRoll,...
                    'String',currentActorSpec.Roll,...
                    'Enable',enable);
                set(this.hPitch,...
                    'String',currentActorSpec.Pitch,...
                    'Enable',enable);
                set(this.hYaw,...
                    'String',currentActorSpec.Yaw,...
                    'Enable',enable);
            else
                updateRollPitchYawFromActor(this);
                if nSpeeds<nWaypoints
                    speeds=[speeds;repmat(speeds(end),nWaypoints-nSpeeds,1)];
                elseif nSpeeds>nWaypoints
                    speeds(nWaypoints+1:end)=[];
                end
                if nwaitTime<nWaypoints
                    waitTime=[waitTime;repmat(waitTime(end),nWaypoints-nwaitTime,1)];
                elseif nwaitTime>nWaypoints
                    waitTime(nWaypoints+1:end)=[];
                end

                if~isempty(waypointsYaw)
                    if nwaypointsYaw<nWaypoints
                        waypointsYaw=[waypointsYaw;repmat(waypointsYaw(end),nWaypoints-nwaypointsYaw,1)];
                    elseif nwaypointsYaw>nWaypoints
                        waypointsYaw(nWaypoints+1:end)=[];
                    end
                end
                data=[waypoints,speeds(:),waitTime(:),waypointsYaw(:)];
            end
            set(table,...
                'Data',data,...
                'RowName','numbered',...
                'Enable',enable);
            if isstruct(currentActorSpec)
                enable='off';
                setEgoEnable='off';
            elseif~isequal(egoCarId,this.SpecificationIndex)&&...
                    classSpec.isVehicle
                setEgoEnable=enable;
            else
                setEgoEnable='off';
            end
            this.hSetEgoCar.Enable=setEgoEnable;
            this.hSetEgoCar.Visible=classSpec.isVehicle;
            this.hDelete.Enable=enable;
            this.hImportRCS.Enable=enable;
        end

        function spec=getCurrentSpecification(this)
            hApp=this.Application;
            if this.InteractiveMode&&strcmp(hApp.ScenarioView.InteractionMode,'addActor')
                spec=hApp.ScenarioView.CurrentActor;
            else
                allSpecs=hApp.ActorSpecifications;
                index=this.SpecificationIndex;
                if numel(allSpecs)<index
                    spec=[];
                else
                    spec=allSpecs(index);
                end
            end
        end
    end

    methods(Hidden)
        function onKeyPress(this,~,ev)
            if this.InteractiveMode&&strcmp(ev.Key,'escape')
                exitInteractionMode(this.Application.ScenarioView);
            end
        end

        function onFocus(this)
            app=this.Application;
            spec=getCurrentSpecification(this);
            if~isempty(spec)
                app.ScenarioView.CurrentSpecification=spec;
            end
        end

        function updateLayout(this)
            layout=this.Layout;
            actorPanel=this.hActorPanel;
            rcsPanel=this.hRCSPanel;
            pathPanel=this.hPathPanel;
            offset=1;
            verticalWeights=[0,0,0,0];
            hasNoWeight=true;
            topInset=-3;
            rightInset=-5;
            agentModel=this.hAgentModel;
            sim=this.Application.Simulator;
            str=getAgentModelString(sim);
            if~isempty(str)
                verticalWeights=[verticalWeights,0];
                if~layout.contains(agentModel)
                    insert(layout,'row',4+offset);
                    add(layout,this.hAgentModelLabel,4+offset,1,...
                        'TopInset',3,...
                        'Fill','Both');
                    add(layout,agentModel,4+offset,2,...
                        'TopInset',3,...
                        'Fill','Both');
                end
                offset=offset+1;
                set(agentModel,'Visible','on');
                set(this.hAgentModelLabel,'Visible','on');
            elseif layout.contains(agentModel)
                remove(layout,agentModel);
                remove(layout,this.hAgentModelLabel);
                clean(layout);
                set(agentModel,'Visible','off');
                set(this.hAgentModelLabel,'Visible','off');
            end
            if this.ShowActorProperties
                verticalWeights=[verticalWeights,0,0];
                if~layout.contains(actorPanel)
                    insert(layout,'row',5+offset);
                    [~,h]=getMinimumSize(this.ActorPropertiesLayout);
                    add(layout,actorPanel,5+offset,[1,6],...
                        'RightInset',rightInset,...
                        'TopInset',topInset,...
                        'Fill','Both',...
                        'MinimumHeight',h);
                end
                actorPanel.Visible='on';
                offset=offset+1;
            else
                verticalWeights=[verticalWeights,0];
                if layout.contains(actorPanel)
                    actorPanel.Visible='off';
                    remove(layout,actorPanel);
                    clean(layout);
                end
            end
            if this.ShowRCSProperties
                verticalWeights=[verticalWeights,0,0];
                if~layout.contains(rcsPanel)
                    set(this.hImportRCS,'Visible','on');
                    insert(layout,'row',6+offset);
                    actor=getCurrentSpecification(this);
                    if isempty(actor)||(numel(actor)>1)
                        nRows=1;
                    else
                        nRows=size(actor.RCSPattern,1);
                    end
                    setConstraints(this.RCSPropertiesLayout,4,1,...
                        'MinimumHeight',20*(nRows+2));
                    [~,h]=getMinimumSize(this.RCSPropertiesLayout);
                    add(layout,rcsPanel,6+offset,[1,6],...
                        'RightInset',rightInset,...
                        'TopInset',topInset,...
                        'Fill','Both',...
                        'MinimumHeight',h);
                end
                rcsPanel.Visible='on';
                offset=offset+1;
            else
                verticalWeights=[verticalWeights,0];
                if layout.contains(rcsPanel)
                    set(this.hImportRCS,'Visible','off');
                    rcsPanel.Visible='off';
                    remove(layout,rcsPanel);
                    clean(layout);
                end
            end
            if this.ShowPathProperties
                verticalWeights=[verticalWeights,0,1];
                hasNoWeight=false;
                callUpdateWidths=false;
                if~layout.contains(pathPanel)
                    layout.insert('row',7+offset);
                    [~,h]=getMinimumSize(this.PathPropertiesLayout);
                    layout.add(pathPanel,7+offset,[1,6],...
                        'TopInset',topInset,...
                        'RightInset',rightInset,...
                        'Fill','Both',...
                        'MinimumHeight',h);

                    if this.UpdateTableColumnWidthsOnOpen
                        callUpdateWidths=true;
                    end

                end
                if callUpdateWidths
                    update(layout,'force');
                    drawnow
                    updateTableColumnWidths(this);
                end
                pathPanel.Visible='on';
            else
                verticalWeights=[verticalWeights,0];
                if layout.contains(pathPanel)
                    pathPanel.Visible='off';
                    remove(layout,pathPanel);
                    clean(layout);
                end
            end
            if hasNoWeight
                verticalWeights=[verticalWeights,1];
            else
                verticalWeights=[verticalWeights,0];
            end
            layout.VerticalWeights=verticalWeights;
            matlabshared.application.setToggleCData(this.hShowRCSProperties);
            matlabshared.application.setToggleCData(this.hShowActorProperties);
            matlabshared.application.setToggleCData(this.hShowPathProperties);
        end

        function updateTableColumnWidths(this)
            if~this.ShowPathProperties
                this.UpdateTableColumnWidthsOnOpen=true;
                return;
            end
            this.UpdateTableColumnWidthsOnOpen=false;

            maxWidth=80;
            minWidth=49;
            nCols=6;
            t=this.hTable;
            t.ColumnWidth=repmat({maxWidth},1,nCols);
            e=t.Extent;
            p=getpixelposition(t);
            w=e(3)-p(3)+4;
            if w>0
                w=maxWidth-ceil(w/nCols);
            else
                w=maxWidth;
            end
            if w<minWidth
                w=minWidth;
            end

            t.ColumnWidth=repmat({floor(w)},1,nCols);
        end

        function edit=createEdit(this,varargin)
            hApp=this.Application;
            hSpec=hApp.ActorSpecifications(this.SpecificationIndex);
            edit=driving.internal.scenarioApp.undoredo.SetActorProperty(...
                hApp,hSpec,varargin{:});
        end

        function setReverseMotion(this,value)

            this.AddingReverseMotion=value;
            updateAddWaypointButtons(this);
        end
    end

    methods(Access='protected')
        function setDimensionWidget(this,prop,spec,staticDims,enable)
            if isfield(staticDims,prop)
                value=staticDims.(prop);
                enable='off';
            else
                value=spec.(prop);
            end
            set(this.(['h',prop]),...
                'String',value,...
                'Enable',enable);
        end

        function event=getIndexEventName(~)
            event='CurrentActorChanged';
        end

        function[id,str]=validateDoubleProperty(this,name,value)
            spec=getCurrentSpecification(this);
            if isstruct(spec)
                pvPairs=matlabshared.application.structToPVPairs(spec);
                spec=driving.internal.scenarioApp.ActorSpecification(pvPairs{:});
            end
            cs=this.Application.ClassSpecifications;
            isVehicle=getProperty(cs,spec.ClassID,'isVehicle');
            id='';
            str='';
            if strcmp(name,'Speed')
                nSpeeds=numel(value);
                if nSpeeds~=1&&nSpeeds~=size(this.getCurrentSpecification.Waypoints,1)
                    isBad=true;
                else
                    badIndex=value==0;
                    isBad=false;
                    if numel(value)>1


                        if any(diff(find(badIndex))==1)
                            isBad=true;
                        end
                    elseif any(badIndex)
                        isBad=true;
                    end
                end
                try
                    driving.scenario.Path.validateSpeed(value);
                catch E %#ok<NASGU>
                    isBad=true;
                end
                if isBad
                    id='driving:scenarioApp:BadSpeedError';
                    str=getErrorMessageString(this,'Speed');
                end
            elseif strcmp(name,'WaitTime')
                nWaitTime=numel(value);
                if nWaitTime~=1&&nWaitTime~=size(this.getCurrentSpecification.Waypoints,1)
                    isBad=true;
                elseif any(value<0)
                    isBad=true;
                else
                    badIndex=value>0;
                    isBad=false;
                    if nWaitTime>1


                        if any(diff(find(badIndex))==1)
                            isBad=true;
                        end
                    elseif any(badIndex)
                        isBad=true;
                    end
                end
                if isBad
                    id='driving:scenarioApp:BadWaitTime';
                    str=getErrorMessageString(this,'WaitTime');
                end
            elseif strcmp(name,'WaypointsYaw')
                [id,str]=spec.validateWaypointsYaw(value,isVehicle);
            elseif strcmp(name,'FrontOverhang')
                spec=getCurrentSpecification(this);
                if spec.Length-spec.RearOverhang-value<=0
                    id='driving:scenarioApp:BadFrontOverhang';
                    str=getString(message(id));
                end
            elseif strcmp(name,'RearOverhang')
                spec=getCurrentSpecification(this);
                if spec.Length-value-spec.FrontOverhang<=0
                    id='driving:scenarioApp:BadRearOverhang';
                    str=getString(message(id));
                    return;
                end
            elseif strcmp(name,'Length')
                [id,str]=spec.validateLength(value,isVehicle);
            elseif strcmp(name,'Width')
                [id,str]=spec.validateWidth(value,isVehicle);
            elseif strcmp(name,'Height')
                [id,str]=spec.validateHeight(value,isVehicle);
            elseif strcmp(name,'Jerk')
                try
                    validateattributes(value,{'numeric'},{'scalar','real','finite','>=',0.1},'smoothTrajectory','Jerk');
                catch E
                    id=E.identifier;
                    str=E.message;
                end
            end
            if isempty(id)
                [id,str]=validateDoubleProperty@driving.internal.scenarioApp.Properties(this,name,value);
            end
        end

        function updateRollPitchYawFromActor(this)
            index=this.SpecificationIndex;
            actors=this.Application.Scenario.Actors;
            if isempty(index)||index>numel(actors)


                return;
            end
            actor=this.Application.Scenario.Actors(index);
            if numel(actor)>1


                actor=actor(1);
            end
            set(this.hRoll,...
                'String',formatDoubleToString(actor.Roll,2),...
                'Enable','off');
            set(this.hPitch,...
                'String',formatDoubleToString(actor.Pitch,2),...
                'Enable','off');
            set(this.hYaw,...
                'String',formatDoubleToString(actor.Yaw,2),...
                'Enable','off');

            function str=formatDoubleToString(num,places)
                if abs(num)<10^(-places-1)
                    str='0';
                else
                    format=sprintf('%%.%df',places);
                    str=sprintf(format,num);
                    indx=regexp(str,'\.0*$');
                    str(indx:end)=[];
                end
            end
        end

        function updateScenario(this)
            updateActorInScenario(this.Application,this.SpecificationIndex);
        end

        function p=createFigure(this,varargin)
            p=createFigure@matlabshared.application.Component(this,varargin{:});

            app=this.Application;
            icons=getIcon(app);

            createEditbox(this,p,'SpecificationIndex',[],'popup');

            this.hColorPatch=uipanel('Parent',p,...
                'BorderType','none',...
                'Tag','ColorPatch',...
                'AutoResizeChildren','off',...
                'BackgroundColor',[0.5,0.5,0.5],...
                'Interruptible','off',...
                'ButtonDownFcn',@this.colorCallback);

            hNameLabel=createLabelEditPair(this,p,...
                'Name',@this.nameCallback);

            createPushButton(this,p,'SetEgoCar',@this.setEgoCarCallback,...
                'TooltipString',getString(message('driving:scenarioApp:SetEgoCarDescription')),...
                'String',getString(message('driving:scenarioApp:SetEgoCarLabel')));

            [hClassIDLabel,this.hClassID]=createLabelEditPair(this,p,...
                'ActorClass',@this.classIdCallback,'popupmenu');

            hAssetTypeLabel=createLabelEditPair(this,p,'AssetType',...
                @this.assetTypeCallback,'popupmenu',...
                'TooltipString',getString(message('driving:scenarioApp:AssetTypeDescription')));

            createLabelEditPair(this,p,'AgentModel',[],'text');

            createToggle(this,p,'ShowActorProperties');
            panelProps={'Units','pixels',...
                'Visible','off',...
                'BorderType','none'};
            if useAppContainer(app)
                panelProps=[panelProps,{'AutoResizeChildren','off'}];
            end
            actorPanel=uipanel(p,'Tag','ActorPropertiesPanel',panelProps{:});

            hLengthLabel=createLabelEditPair(this,actorPanel,'Length');
            hWidthLabel=createLabelEditPair(this,actorPanel,'Width');
            hHeightLabel=createLabelEditPair(this,actorPanel,'Height');

            createLabelEditPair(this,actorPanel,'FrontOverhang',[],'edit','Visible','off',...
                'TooltipString',getString(message('driving:scenarioApp:FrontOverhangDescription')));
            createLabelEditPair(this,actorPanel,'RearOverhang',[],'edit','Visible','off',...
                'TooltipString',getString(message('driving:scenarioApp:RearOverhangDescription')));

            hRollLabel=createLabelEditPair(this,actorPanel,'Roll');
            hPitchLabel=createLabelEditPair(this,actorPanel,'Pitch');
            hYawLabel=createLabelEditPair(this,actorPanel,'Yaw');

            this.hActorPanel=actorPanel;

            spacing=3;
            labelInset=3;
            labelHeight=20-labelInset;
            actorLayout=matlabshared.application.layout.GridBagLayout(actorPanel,...
                'VerticalGap',spacing,...
                'HorizontalGap',spacing);
            labelWidth=actorLayout.getMinimumWidth([hLengthLabel...
                ,hWidthLabel,hHeightLabel,this.hFrontOverhangLabel,this.hRearOverhangLabel...
                ,hRollLabel,hPitchLabel,hYawLabel]);
            labelWidth=labelWidth+20;

            labelInset=-spacing;
            add(actorLayout,hLengthLabel,1,1,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal')
            add(actorLayout,hWidthLabel,1,2,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal')
            add(actorLayout,hHeightLabel,1,3,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal')
            add(actorLayout,this.hLength,2,1,...
                'Fill','Horizontal')
            add(actorLayout,this.hWidth,2,2,...
                'Fill','Horizontal')
            add(actorLayout,this.hHeight,2,3,...
                'Fill','Horizontal')

            setConstraints(actorLayout,this.hFrontOverhangLabel,...
                'BottomInset',labelInset,...
                'Fill','Horizontal',...
                'MinimumWidth',labelWidth,...
                'MinimumHeight',labelHeight-2);
            setConstraints(actorLayout,this.hRearOverhangLabel,...
                'BottomInset',labelInset,...
                'Fill','Horizontal',...
                'MinimumWidth',labelWidth,...
                'MinimumHeight',labelHeight-2);
            setConstraints(actorLayout,this.hFrontOverhang,...
                'Fill','Horizontal');
            setConstraints(actorLayout,this.hRearOverhang,...
                'Fill','Horizontal');

            add(actorLayout,hRollLabel,3,1,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal');
            add(actorLayout,hPitchLabel,3,2,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal');
            add(actorLayout,hYawLabel,3,3,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal');
            add(actorLayout,this.hRoll,4,1,...
                'Fill','Horizontal');
            add(actorLayout,this.hPitch,4,2,...
                'Fill','Horizontal');
            add(actorLayout,this.hYaw,4,3,...
                'Fill','Horizontal');

            this.hActorPanel=actorPanel;
            this.ActorPropertiesLayout=actorLayout;

            createToggle(this,p,'ShowRCSProperties');

            rcsPanel=uipanel(p,'Tag','ActorProperties.rcsPanel',panelProps{:});

            hAzimLabel=createLabelEditPair(this,rcsPanel,'RCSAzimuthAngles',@this.azimuthAnglesCallback,...
                'TooltipString',getString(message('driving:scenarioApp:RCSAzimuthAnglesDescription')));
            hElevLabel=createLabelEditPair(this,rcsPanel,'RCSElevationAngles',@this.elevationAnglesCallback,...
                'TooltipString',getString(message('driving:scenarioApp:RCSElevationAnglesDescription')));
            hPattLabel=createLabelEditPair(this,rcsPanel,'RCSPattern',@this.patternCallback,'table','Tag','ActorProperties.RCSTable');

            createPushButton(this,p,'ImportRCS',@this.importRcsCallback,...
                'Visible','off',...
                'String',getString(message('driving:scenarioApp:ImportRCSPattern')),...
                'TooltipString',getString(message('driving:scenarioApp:ImportRCSPatternDescription')));

            rcsLayout=matlabshared.application.layout.GridBagLayout(rcsPanel,...
                'VerticalGap',spacing,...
                'HorizontalGap',spacing,...
                'HorizontalWeights',[0,1],...
                'VerticalWeights',[0,0,0,1]);

            labelConstraints={...
                'MinimumWidth',rcsLayout.getMinimumWidth([hAzimLabel,hElevLabel,hPattLabel]),...
                'Anchor','SouthWest',...
                'TopInset',labelInset,...
                'MinimumHeight',labelHeight};

            add(rcsLayout,hAzimLabel,1,1,labelConstraints{:});
            add(rcsLayout,hElevLabel,2,1,labelConstraints{:});
            add(rcsLayout,hPattLabel,3,1,labelConstraints{:},'TopInset',3);

            add(rcsLayout,this.hRCSAzimuthAngles,1,2,'Fill','Horizontal');
            add(rcsLayout,this.hRCSElevationAngles,2,2,'Fill','Horizontal');
            add(rcsLayout,this.hRCSPattern,4,[1,2],'Fill','Both',...
                'BottomInset',-spacing,...
                'MinimumHeight',80);

            this.RCSPropertiesLayout=rcsLayout;
            this.hRCSPanel=rcsPanel;

            createToggle(this,p,'ShowPathProperties');


            waypointPanel=uipanel(p,'Tag','WaypointsButtonPanel',panelProps{:},'Visible','on');

            createPushButton(this,waypointPanel,'AddForwardWaypoints',@this.addWaypointsCallback,...
                'CData',icons.addForwardWaypoints16,...
                'TooltipString',getString(message('driving:scenarioApp:AddWaypointsDescription')));

            createPushButton(this,waypointPanel,'AddReverseWaypoints',@(src,evnt)this.addWaypointsCallback(src,evnt,true),...
                'CData',icons.addReverseWaypoints16,...
                'TooltipString',getString(message('driving:scenarioApp:AddReverseWaypointsDescription')));

            createPushButton(this,waypointPanel,'ClearWaypoints',@this.clearWaypointsCallback,...
                'CData',icons.clear16,...
                'TooltipString',getString(message('driving:scenarioApp:ClearWaypointsDescription')));

            pathPanel=uipanel(p,'Tag','WaypointsPanel',panelProps{:});


            createCheckbox(this,pathPanel,'IsSmoothTrajectory',@this.smoothTrajectoryCheckboxCallback,...
                'TooltipString',getString(message('driving:scenarioApp:IsSmoothTrajectoryDescription')));


            createCheckbox(this,pathPanel,'ShowDynamicActor',@this.dynamicActorCheckboxCallback,...
                'TooltipString',getString(message('driving:scenarioApp:AddingDynamicActorTooltip')));
            hEntryTimeLabel=createLabelEditPair(this,pathPanel,'EntryTime',@this.actorSpawnEntryEditboxCallback);
            hExitTimeLabel=createLabelEditPair(this,pathPanel,'ExitTime',@this.actorSpawnExitEditboxCallback);

            hSpeedLabel=createLabelEditPair(this,pathPanel,'Speed',@this.speedEditboxCallback);
            hSpeedLabel.String=getString(message('driving:scenarioApp:ActorSpeedLabel'));

            hJerkLabel=createLabelEditPair(this,pathPanel,'Jerk',@this.jerkEditboxCallback);

            columnNames={...
                getString(message('driving:scenarioApp:XColumnName')),...
                getString(message('driving:scenarioApp:YColumnName')),...
                getString(message('driving:scenarioApp:ZColumnName')),...
                getString(message('driving:scenarioApp:VColumnName')),...
                getString(message('driving:scenarioApp:WColumnName')),...
                getString(message('driving:scenarioApp:YawColumnName'))};
            colWidth(1:6)={49};

            [hWaypointsLabel,this.hTable]=createLabelEditPair(this,pathPanel,...
                'Waypoints',@this.cellEditCallback,'table',...
                'Data',[0,0,0,0,0,NaN],...
                'ColumnName',columnNames,...
                'ColumnWidth',colWidth,...
                'Tag','ActorTable');
            hWaypointsLabel.String=getString(message('driving:scenarioApp:ActorWaypointsTableLabel'));

            this.hPathPanel=pathPanel;
            pathLayout=matlabshared.application.layout.GridBagLayout(pathPanel,...
                'HorizontalGap',spacing,...
                'VerticalGap',spacing,...
                'HorizontalWeights',[0,1],...
                'VerticalWeights',[0,0,1,0,0,0,0,0]);

            add(pathLayout,hSpeedLabel,1,1,...
                'TopInset',labelInset,...
                'Anchor','West',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',pathLayout.getMinimumWidth(hSpeedLabel));

            add(pathLayout,this.hSpeed,1,2,'Fill','Horizontal');
            add(pathLayout,hWaypointsLabel,2,[1,2],'Fill','Horizontal',...
                'MinimumHeight',labelHeight);
            add(pathLayout,this.hTable,3,[1,2],'Fill','Both',...
                'BottomInset',5,...
                'MinimumWidth',150,...
                'MinimumHeight',100);

            add(pathLayout,this.hIsSmoothTrajectory,4,[1,2],...
                'TopInset',labelInset,...
                'Anchor','West',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',pathLayout.getMinimumWidth(this.hIsSmoothTrajectory)+20);

            add(pathLayout,hJerkLabel,5,1,...
                'TopInset',labelInset,...
                'LeftInset',20,...
                'Anchor','West',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',pathLayout.getMinimumWidth(hJerkLabel));
            add(pathLayout,this.hJerk,5,2,'Fill','Horizontal');

            add(pathLayout,this.hShowDynamicActor,6,[1,2],...
                'TopInset',labelInset,...
                'Anchor','West',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',pathLayout.getMinimumWidth(this.hShowDynamicActor)+20);

            add(pathLayout,hEntryTimeLabel,7,1,...
                'TopInset',labelInset,...
                'LeftInset',20,...
                'Anchor','West',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',pathLayout.getMinimumWidth(hEntryTimeLabel));
            add(pathLayout,this.hEntryTime,7,2,'Fill','Horizontal');
            add(pathLayout,hExitTimeLabel,8,1,...
                'TopInset',labelInset,...
                'LeftInset',20,...
                'Anchor','West',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',pathLayout.getMinimumWidth(hExitTimeLabel));
            add(pathLayout,this.hExitTime,8,2,'Fill','Horizontal');

            this.PathPropertiesLayout=pathLayout;

            createPushButton(this,p,'Delete',@this.removeActorCallback,...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'CData',icons.delete16,...
                'TooltipString',getString(message('driving:scenarioApp:DeleteActorDescription')));



            layout=matlabshared.application.layout.ScrollableGridBagLayout(p,...
                'HorizontalGap',spacing,...
                'VerticalGap',spacing,...
                'HorizontalWeights',[0,1,0,0,0,0],...
                'VerticalWeights',[0,0,0,0,0,0,1]);

            row=1;
            layout.add(this.hSpecificationIndex,row,[1,5],...
                'Fill','Horizontal');

            layout.add(this.hColorPatch,row,6,...
                'Fill','Both');

            labelProps={'TopInset',labelInset,...
                'Anchor','SouthWest',...
                'MinimumHeight',labelHeight};

            row=row+1;
            width=layout.getMinimumWidth([hNameLabel,hClassIDLabel,hAssetTypeLabel]);
            layout.add(hNameLabel,row,1,labelProps{:},...
                'MinimumWidth',width);
            layout.add(this.hName,row,2,'Fill','Horizontal');

            layout.add(this.hSetEgoCar,row,[3,6],...
                'MinimumWidth',layout.getMinimumWidth(this.hSetEgoCar),...
                'Fill','Horizontal');

            row=row+1;
            layout.add(hClassIDLabel,row,1,labelProps{:},...
                'MinimumWidth',width);
            layout.add(this.hClassID,row,2,'Fill','Horizontal',...
                'MinimumWidth',50);

            row=row+1;
            layout.add(hAssetTypeLabel,row,1,labelProps{:},...
                'MinimumWidth',width);
            layout.add(this.hAssetType,row,2,'Fill','Horizontal',...
                'MinimumWidth',50);

            row=row+1;
            layout.add(this.hShowActorProperties,row,[1,5],...
                'Anchor','West',...
                'Fill','Horizontal',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',layout.getMinimumWidth(this.hShowActorProperties)+20);

            layout.setConstraints(actorPanel,'BottomInset',-3);

            row=row+1;
            layout.add(this.hShowRCSProperties,row,[1,2],...
                'Anchor','West',...
                'Fill','Horizontal',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',layout.getMinimumWidth(this.hShowRCSProperties)+20);
            add(layout,this.hImportRCS,row,[3,6],'Anchor','East',...
                'MinimumWidth',layout.getMinimumWidth(this.hImportRCS)+20);

            row=row+1;
            add(layout,this.hShowPathProperties,row,[1,2],...
                'Anchor','NorthWest',...
                'Fill','Horizontal',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',layout.getMinimumWidth(this.hShowPathProperties)+20);

            buttonWidth=21;

            set(this.hAddForwardWaypoints,'Position',[1,1,buttonWidth,buttonWidth]);
            set(this.hAddReverseWaypoints,'Position',[buttonWidth+spacing,1,buttonWidth,buttonWidth]);
            set(this.hClearWaypoints,'Position',[2*buttonWidth+2*spacing,1,buttonWidth,buttonWidth]);

            panelWidth=3*buttonWidth+2*spacing;
            layout.add(waypointPanel,row,[3,6],...
                'Anchor','NorthEast',...
                'MinimumHeight',buttonWidth,...
                'MaximumWidth',panelWidth,...
                'MinimumWidth',panelWidth);

            row=row+1;
            layout.add(this.hDelete,row,6,...
                'Anchor','SouthEast',...
                'MinimumHeight',buttonWidth,...
                'MinimumWidth',buttonWidth);

            this.Layout=layout;
            if useAppContainer(app)
                update(layout,'force');
            end
        end

        function actorSpawnEntryEditboxCallback(this,hSrc,~)
            str=get(hSrc,'String');
            newValue=str2double(str);
            if isnan(newValue)
                newValue=this.strToNum(str);
            end
            negative=any(newValue(newValue<0));
            if isempty(newValue)||negative||any(isnan(newValue))
                update(this);
                errorMessage(this,getString(message('driving:scenario:InvalidEntryTime')),...
                    'InvalidEntryTime');
                return;
            end
            hApp=this.Application;
            hSpec=hApp.ActorSpecifications(this.SpecificationIndex);
            exitTime=hSpec.ExitTime;
            isSpawnValid=true;
            if size(newValue,2)~=size(exitTime,2)
                isSpawnValid=false;
            end
            edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                hApp,hSpec,{'EntryTime','IsSpawnValid'},{newValue,isSpawnValid});
            try
                applyEdit(hApp,edit);
            catch ME
                update(this);
                errorMessage(this,getString(message('driving:scenario:InvalidEntryTime')),ME.identifier);
                return;
            end
            update(this);
        end

        function actorSpawnExitEditboxCallback(this,hSrc,~)
            str=get(hSrc,'String');
            newValue=str2double(str);
            if isnan(newValue)
                newValue=this.strToNum(str);
            end
            negative=any(newValue(newValue<0));
            if isempty(newValue)||negative||any(isnan(newValue))
                update(this);
                errorMessage(this,getString(message('driving:scenario:InvalidExitTime')),...
                    'InvalidExitTime');
                return;
            end
            hApp=this.Application;
            hSpec=hApp.ActorSpecifications(this.SpecificationIndex);
            entryTime=hSpec.EntryTime;
            if size(newValue,2)~=size(entryTime,2)
                errorMessage(this,getString(message('driving:scenarioApp:ExitTimeEntryTimeMismatch')),...
                    'ExitTimeEntryTimeMismatch');
                return;
            else
                isSpawnValid=true;
            end

            edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                hApp,hSpec,{'ExitTime','IsSpawnValid'},{newValue,isSpawnValid});
            try
                applyEdit(hApp,edit);
            catch ME
                update(this);
                errorMessage(this,getString(message('driving:scenario:InvalidExitTime')),ME.identifier);
                return;
            end
            update(this);
        end


        function speedEditboxCallback(this,hSrc,~)
            propName=getPropertyFromTag(this,hSrc.Tag);
            str=get(hSrc,'String');
            newValue=str2double(str);
            if isnan(newValue)
                newValue=this.strToNum(str);
            end
            id='';
            str='';


            if isa(newValue,'double')
                [id,str]=validateDoubleProperty(this,propName,newValue);
            end
            if~isempty(id)
                update(this);
                errorMessage(this,str,id);
                return;
            end


            hApp=this.Application;
            hSpec=hApp.ActorSpecifications(this.SpecificationIndex);
            if~isscalar(hSpec.Speed)
                val=hSpec.Speed;
                val(val>0)=abs(newValue);
                val(val<0)=-abs(newValue);
                newValue=val;
            end
            if this.InteractiveMode
                setPropertyForInteractiveMode(this,propName,newValue)
            else
                setPropertyForNonInteractiveMode(this,propName,newValue);
            end
        end

        function jerkEditboxCallback(this,hSrc,~)
            propName=getPropertyFromTag(this,hSrc.Tag);
            str=get(hSrc,'String');
            newValue=str2double(str);
            if isnan(newValue)
                newValue=this.strToNum(str);
            end
            id='';
            str='';


            if isa(newValue,'double')
                [id,str]=validateDoubleProperty(this,propName,newValue);
            end
            if~isempty(id)
                update(this);
                errorMessage(this,str,id);
                return;
            end
            if this.InteractiveMode
                setPropertyForInteractiveMode(this,propName,newValue)
            else
                setPropertyForNonInteractiveMode(this,propName,newValue);
            end
        end

        function waitTimeCheckboxCallback(this,src,~)
            hApp=this.Application;
            data=this.hTable.Data;
            if isempty(data)
                return;
            end
            hSpec=hApp.ActorSpecifications(this.SpecificationIndex);
            if src.Value==0
                waitTime=[];
            else
                waitTime=zeros(size(hSpec.Waypoints,1),1);
                speed=hSpec.Speed;
                if isscalar(speed)&&length(speed)~=size(hSpec.Waypoints,1)
                    speed=repmat(speed,size(hSpec.Waypoints,1),1);
                    applyEdit(hApp,createEdit(this,'Speed',speed));
                end
            end
            [id,msg]=validateDoubleProperty(this,'WaitTime',waitTime);
            if~isempty(id)
                update(this);
                errorMessage(this,msg,id);
                return
            end
            applyEdit(hApp,createEdit(this,'WaitTime',waitTime));
            update(this);
            if this.InteractiveMode
                canvas=hApp.ScenarioView;
                createActorWaypointsLine(canvas);
                updateWaypointLine(canvas);
                updateCursorLine(canvas,[]);
            end
        end
        function azimuthAnglesCallback(this,hAzimuth,~)

            current=getCurrentSpecification(this);
            try
                [newAzim,newPattern]=driving.internal.scenarioApp.RCSHelper.parseAzimuth(...
                    hAzimuth.String,current.RCSPattern);
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return
            end
            hApp=this.Application;
            edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                hApp,current,{'RCSAzimuthAngles','RCSPattern'},{newAzim,newPattern});
            try
                applyEdit(hApp,edit);
            catch ME
                update(this);
                errorMessage(this,getErrorMessageString(this,'RCSAzimuthAngles'),ME.identifier);
                return;
            end
            update(this);
        end
        function elevationAnglesCallback(this,hElevation,~)
            current=getCurrentSpecification(this);
            try
                [newElev,newPattern]=driving.internal.scenarioApp.RCSHelper.parseElevation(...
                    hElevation.String,current.RCSPattern);
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return
            end
            hApp=this.Application;
            edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                hApp,current,{'RCSElevationAngles','RCSPattern'},{newElev,newPattern});
            try
                applyEdit(hApp,edit);
            catch ME
                update(this);
                errorMessage(this,getErrorMessageString(this,'RCSElevationAngles'),ME.identifier);
                return;
            end
            update(this);
        end

        function patternCallback(this,src,~)
            data=src.Data;
            if any(isnan(data(:)))
                update(this);
                return;
            end
            setProperty(this,'RCSPattern',data);
        end

        function classIdCallback(this,src,~)
            newValue=this.AllIDsCache(src.Value);
            spec=getCurrentSpecification(this);
            oldValue=spec.ClassID;
            if isequal(newValue,oldValue)
                return;
            end

            hApp=this.Application;
            classSpecs=hApp.ClassSpecifications;
            oldDefaults=classSpecs.getSpecification(oldValue);
            newDefaults=classSpecs.getSpecification(newValue);



            newDefaults=rmfield(newDefaults,{'name','id','isVehicle','isMovable','PlotColor'});
            fields=fieldnames(newDefaults);
            for indx=1:numel(fields)
                f=fields{indx};
                if isequal(oldDefaults.(f),newDefaults.(f))
                    newDefaults=rmfield(newDefaults,f);
                end
            end




            fields=fieldnames(newDefaults);
            properties=[{'ClassID'},repmat({[]},1,numel(fields))];
            values=[{newValue},repmat({[]},1,numel(fields))];
            conflicts={};

            conflictExceptions={'Mesh'};
            for indx=1:numel(fields)
                f=fields{indx};
                if~any(strcmp(f,conflictExceptions))&&~isequal(spec.(f),oldDefaults.(f))
                    conflicts{end+1}=f;%#ok<AGROW>
                end
                properties{indx+1}=f;
                values{indx+1}=newDefaults.(f);
            end



            if~isempty(conflicts)
                propString='';
                for indx=1:numel(conflicts)
                    propString=sprintf('%s\n%s',propString,getString(message(['driving:scenarioApp:',conflicts{indx},'Text'])));
                end
                keep=getString(message('driving:scenarioApp:KeepChangesText'));
                useNew=getString(message('driving:scenarioApp:UseNewDefaultsText'));
                b=uiconfirm(hApp,getString(message('driving:scenarioApp:ClassConflictText',propString)),...
                    getString(message('driving:scenarioApp:ClassConflictTitle')),...
                    {keep,useNew},keep);


                if isempty(b)
                    update(this);
                    return;
                elseif strcmp(b,keep)
                    [properties,indx]=setdiff(properties,conflicts);
                    values=values(indx);
                elseif strcmp(b,useNew)

                end
            end
            lengthIndx=find(strcmp(properties,'Length'),1,'first');
            if~isempty(lengthIndx)&&~isstruct(spec)||isfield(spec,'FrontOverhang')
                if isempty(lengthIndx)
                    newLength=spec.Length;
                else
                    newLength=values{lengthIndx};
                end
                if spec.FrontOverhang+spec.RearOverhang>newLength
                    ratio=newLength/spec.Length;
                    newFront=spec.FrontOverhang*ratio;
                    newRear=spec.RearOverhang*ratio;
                    properties=[properties,{'FrontOverhang','RearOverhang'}];
                    values=[values,{newFront,newRear}];
                end
            end

            if this.InteractiveMode&&strcmp(hApp.ScenarioView.InteractionMode,'addActor')
                for indx=1:numel(properties)
                    spec.(properties{indx})=values{indx};
                end
                hApp.ScenarioView.CurrentActor=spec;
            else
                e=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                    hApp,spec,properties,values);

                applyEdit(hApp,e);
            end
            update(this);
            notify(this,'PropertyChanged');
        end

        function assetTypeCallback(this,~,~)
            value=getPopupValue(this,'AssetType');
            setPropertyForInteractiveMode(this,'AssetType',value);
        end

        function importRcsCallback(this,~,~)

            spec=getCurrentSpecification(this);
            app=this.Application;
            if useAppContainer(app)
                app=app.Window.AppContainer;
            else
                app=getToolGroupName(app);
            end
            [az,el,pattern]=driving.internal.scenarioApp.RCSHelper.import(...
                numel(spec.RCSAzimuthAngles),numel(spec.RCSElevationAngles),app);
            props={};
            values={};
            if isempty(el)
                el=spec.RCSElevationAngles;
            else
                props={'RCSElevationAngles'};
                values={el};
            end
            if isempty(az)
                az=spec.RCSAzimuthAngles;
            else
                props=[props,{'RCSAzimuthAngles'}];
                values=[values,{az}];
            end
            if isempty(pattern)
                [pattern,wasResized]=driving.internal.scenarioApp.RCSHelper.resizePattern(spec.RCSPattern,numel(el),numel(az));
                if wasResized
                    props=[props,{'RCSPattern'}];
                    values=[values,{pattern}];
                end
            else
                props=[props,{'RCSPattern'}];
                values=[values,{pattern}];
            end
            if isempty(props)
                return;
            end

            hApp=this.Application;


            if numel(props)==1
                edit=driving.internal.scenarioApp.undoredo.SetActorProperty(...
                    hApp,spec,props{1},values{1});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                    hApp,spec,props,values);
            end

            try
                applyEdit(hApp,edit);
            catch ME
                update(this);
                errorMessage(this,getErrorMessageString(this,'RCSAzimuthAngles'),ME.identifier);
                return
            end
            update(this);
        end

        function colorCallback(this,h,~)
            c=uisetcolor(h.BackgroundColor);
            if isequal(c,h.BackgroundColor)
                return;
            end
            h.BackgroundColor=c;
            setPropertyForInteractiveMode(this,'PlotColor',c);
        end

        function removeActorCallback(this,~,~)
            hApp=this.Application;
            if this.SpecificationIndex>numel(hApp.ActorSpecifications)
                return;
            end
            transaction=driving.internal.scenarioApp.undoredo.DeleteActor(hApp,this.SpecificationIndex);
            applyEdit(hApp,transaction);
            this.SpecificationIndex=1;
            update(this);
        end

        function addWaypointsCallback(this,~,~,addingReverse)
            if nargin<4
                addingReverse=false;
            end
            hApp=this.Application;
            if this.InteractiveMode


                if this.AddingReverseMotion~=addingReverse
                    this.AddingReverseMotion=addingReverse;
                    updateAddWaypointButtons(this);
                else
                    commitWaypoints(hApp.ScenarioView);
                end
            else
                this.AddingReverseMotion=addingReverse;
                actorAdder=getActorAdder(hApp);
                addWaypoints(actorAdder,this.SpecificationIndex);
            end
        end

        function updateAddWaypointButtons(this)

            hApp=this.Application;
            canvas=hApp.ScenarioView;
            nWaypoints=size(canvas.Waypoints,1);
            if nWaypoints<=1
                enab='off';
            else
                enab='on';
            end
            if this.AddingReverseMotion
                set(this.hAddReverseWaypoints,...
                    'Enable',enab,...
                    'CData',getIcon(hApp,'confirm16'),...
                    'TooltipString',getString(message('driving:scenarioApp:AcceptWaypointsDescription')));
                set(this.hAddForwardWaypoints,...
                    'Enable','on',...
                    'CData',getIcon(hApp,'addForwardWaypoints16'),...
                    'TooltipString',getString(message('driving:scenarioApp:AddWaypointsDescription')));
            else
                set(this.hAddForwardWaypoints,...
                    'Enable',enab,...
                    'CData',getIcon(hApp,'confirm16'),...
                    'TooltipString',getString(message('driving:scenarioApp:AcceptWaypointsDescription')));
                set(this.hAddReverseWaypoints,...
                    'Enable','on',...
                    'CData',getIcon(hApp,'addReverseWaypoints16'),...
                    'TooltipString',getString(message('driving:scenarioApp:AddReverseWaypointsDescription')));
            end
        end

        function clearWaypointsCallback(this,~,~)
            app=this.Application;
            if isa(app.ScenarioView.CurrentSpecification,'driving.internal.scenarioApp.ActorSpecification')
                app.ScenarioView.clearWaypointsCallback();
            end
        end

        function setEgoCarCallback(this,~,~)
            hApp=this.Application;
            hApp.EgoCarId=this.SpecificationIndex;
            this.ShowDynamicActor=false;
            actor=getCurrentSpecification(this);
            actor.ActorSpawn=false;
            setDefaultSpawnTimes(this);
            setDirty(hApp);
            update(this);
        end

        function smoothTrajectoryCheckboxCallback(this,h,~)
            actor=getCurrentSpecification(this);
            actor.IsSmoothTrajectory=h.Value;
            try
                updateScenario(this);
            catch E

                actor.IsSmoothTrajectory=false;
                updateScenario(this);
                id=E.identifier;
                errorMessage(this,getString(message(id)),id);
            end
        end

        function dynamicActorCheckboxCallback(this,h,~)
            this.ShowDynamicActor=h.Value;
            actor=getCurrentSpecification(this);
            actor.ActorSpawn=h.Value;
            setDefaultSpawnTimes(this);
        end

        function setDefaultSpawnTimes(this)
            hApp=this.Application;
            hSpec=hApp.ActorSpecifications(this.SpecificationIndex);
            edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                hApp,hSpec,{'EntryTime','ExitTime'},{0,Inf});
            applyEdit(hApp,edit);
        end

        function cellEditCallback(this,~,~)
            table=this.hTable;
            data=table.Data;
            hApp=this.Application;
            canvas=hApp.ScenarioView;
            isInteractive=this.InteractiveMode;
            if isInteractive&&strcmp(canvas.InteractionMode,'addActor')
                canvas.CurrentActor.Position=data;
                data{end,1}=str2double(data{end,1});
                data{end,2}=str2double(data{end,2});
                if size(data,2)==6
                    data{end,6}=str2double(data{end,6});
                end
                data=[data{:}];

                if~any(isnan(data(1:5)))
                    actor=rmfield(canvas.CurrentActor,'Position');
                    pvPairs=matlabshared.application.structToPVPairs(actor);
                    edit=driving.internal.scenarioApp.undoredo.AddActor(hApp,...
                        'Position',data(1:3),pvPairs{:});
                    applyEdit(hApp,edit);
                    exitInteractionMode(canvas);
                end
                return
            end
            spec=hApp.ActorSpecifications(this.SpecificationIndex);
            waypoints=spec.Waypoints;
            if isempty(waypoints)
                nCommitted=1;
            else
                nCommitted=size(waypoints,1);
            end
            committed=data(1:nCommitted,:);

            if isInteractive
                committed(cellfun(@ischar,committed))={nan};
                committed=cell2mat(committed);
            end

            if size(committed,1)>0
                position=committed(1,1:3);
            else
                position=spec.Position;
            end
            if~isempty(spec.findDuplicateWaypoints(committed))
                update(this);
                id='driving:scenarioApp:RepeatedWaypoints';
                errorMessage(this,getString(message(id)),id);
                return;
            end
            committedNoYaw=committed(:,1:5);
            if any(isnan(committedNoYaw(:)))||any(isinf(committedNoYaw(:)))
                update(this);
                return;
            end
            properties={};
            values={};
            if~isequal(position,spec.Position)
                properties={'Position'};
                values={position};
            end

            if isscalar(spec.Speed)
                nowSpeed=repmat(spec.Speed,size(waypoints,1),1);
            else
                nowSpeed=spec.Speed(:);
            end
            waypoints=[waypoints,nowSpeed];
            if size(committed,2)>=5
                if isempty(spec.WaitTime)
                    waypoints=[waypoints,zeros(size(waypoints,1),1)];
                else
                    waypoints=[waypoints,spec.WaitTime(:)];
                end
                if size(committed,2)==6
                    if isempty(spec.pWaypointsYaw)
                        waypoints=[waypoints,NaN(size(waypoints,1),1)];
                    else
                        waypoints=[waypoints,spec.pWaypointsYaw(:)];
                    end
                end
            end

            if size(committed,1)>1&&~isequal(committed(:,1:5),waypoints(:,1:5))
                properties=[properties,{'Waypoints'}];
                values=[values,{committed(:,1:3)}];
            end

            if size(committed,2)>3
                speed=committed(:,4);



                if(any(speed<0)&&any(speed>0))
                    signDiff=(sign(speed)~=sign(spec.Speed));
                    signDiff((spec.Speed==0)|(speed==0))=[];
                    if any(signDiff)
                        speed=spec.Speed;
                    end
                end
                [id,str]=validateDoubleProperty(this,'Speed',speed);
                if~isempty(id)
                    update(this);
                    errorMessage(this,str,id);
                    return;
                end
                if~isequal(speed,spec.Speed)
                    properties=[properties,{'Speed'}];
                    values=[values,{speed}];
                end

                if size(committed,2)>=5
                    waitTime=committed(:,5);
                    [id,str]=validateDoubleProperty(this,'WaitTime',waitTime);
                    if~isempty(id)
                        update(this);
                        errorMessage(this,str,id);
                        return;
                    end
                    if~isequal(waitTime,spec.WaitTime)
                        properties=[properties,{'WaitTime'}];
                        values=[values,{waitTime}];
                        speed(waitTime>0)=0;
                        if any(speed(2:end)==0&speed(1:end-1)==0)||isscalar(speed)&&speed==0
                            update(this);
                            errorMessage(this,getString(message('driving:scenarioApp:RepeatedSpeeds')),...
                                'driving:scenarioApp:RepeatedSpeeds');
                            return;
                        end
                        properties=[properties,{'Speed'}];
                        values=[values,{speed}];
                    end


                    if size(committed,2)==6
                        pWaypointsYaw=committed(:,6);
                        [id,str]=validateDoubleProperty(this,'WaypointsYaw',pWaypointsYaw);
                        if~isempty(id)
                            update(this);
                            errorMessage(this,str,id);
                            return;
                        end
                        if isempty(spec.pWaypointsYaw)
                            oldpWaypointsYaw=NaN(size(spec.Waypoints,1),1);
                        else
                            oldpWaypointsYaw=spec.pWaypointsYaw;
                        end
                        waypointsYaw=spec.WaypointsYaw;
                        if isempty(waypointsYaw)
                            waypointsYaw=NaN(size(spec.Waypoints,1),1);
                        end
                        if size(oldpWaypointsYaw,1)~=size(pWaypointsYaw,1)
                            errorMessage(this,getString(message('driving:scenarioApp:WaypointsYawMismatch')),...
                                'driving:scenarioApp:WaypointsYawMismatch');
                        end
                        idxModified=oldpWaypointsYaw~=pWaypointsYaw;
                        waypointsYaw(idxModified,:)=pWaypointsYaw(idxModified,:);

                        if~isempty(idxModified)
                            if idxModified(1)

                                properties=[properties,{'Yaw'}];
                                if(spec.Speed(1)<0)
                                    nYaw=pWaypointsYaw(1)-180;
                                else
                                    nYaw=pWaypointsYaw(1);
                                end
                                values=[values,{nYaw}];
                            end
                        end
                        if~isequal(isnan(pWaypointsYaw),isnan(spec.pWaypointsYaw))
                            properties=[properties,{'pWaypointsYaw'}];
                            values=[values,{pWaypointsYaw}];
                        else
                            if~isequal(pWaypointsYaw(~isnan(pWaypointsYaw)),spec.pWaypointsYaw(~isnan(spec.pWaypointsYaw)))
                                properties=[properties,{'pWaypointsYaw'}];
                                values=[values,{pWaypointsYaw}];
                            end
                        end

                        if~isequal(isnan(waypointsYaw),isnan(spec.WaypointsYaw))
                            properties=[properties,{'WaypointsYaw'}];
                            values=[values,{waypointsYaw}];
                        else
                            if~isequal(waypointsYaw(~isnan(waypointsYaw)),spec.WaypointsYaw(~isnan(spec.WaypointsYaw)))
                                properties=[properties,{'WaypointsYaw'}];
                                values=[values,{waypointsYaw}];
                            end
                        end
                    end
                end
            end

            if isempty(properties)
                edit=[];
            elseif numel(properties)==1
                edit=driving.internal.scenarioApp.undoredo.SetActorProperty(...
                    hApp,spec,properties{1},values{1});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                    hApp,spec,properties,values);
            end

            shouldUpdate=false;
            if isInteractive
                canvas=hApp.ScenarioView;


                if ischar(data{end,1})
                    data{end,1}=str2double(data{end,1});
                    data{end,2}=str2double(data{end,2});
                    if size(data,2)==6
                        data{end,6}=str2double(data{end,6});
                    end
                end


                if strcmp(canvas.InteractionMode,'addActorWaypoints')
                    waypoints=cellfun(@lcl_str2double,data);
                    dupes=spec.findDuplicateWaypoints(waypoints);
                    if~isempty(dupes)
                        id='driving:scenarioApp:RepeatedWaypoints';
                        set(table,'Data',canvas.getTableData);
                        errorMessage(this,getString(message(id)),id);
                        return
                    end
                end

                if size(data,2)==6
                    for dRow=1:size(data,1)
                        if~ischar(data{dRow,1})&&~ischar(data{dRow,2})&&isempty(data{dRow,6})
                            data{dRow,6}=NaN;
                        end
                    end
                end
                data=cell2mat(data);
                shouldUpdate=true;
                if isnan(data(end,1))||isnan(data(end,2))
                    shouldUpdate=false;
                    data(end,:)=[];
                end
                datawithoutyaw=data(:,1:5);
                if any(isnan(datawithoutyaw(:)))||any(isinf(datawithoutyaw(:)))
                    shouldUpdate=true;
                else


                    try
                        driving.scenario.Path.validateSpeed(data(:,4));
                    catch E
                        update(this);
                        errorMessage(this,E.message,E.identifier);
                        return;
                    end
                    canvas.Waypoints=data;
                end
            end
            if~isempty(edit)
                try
                    applyEdit(hApp,edit);
                catch E
                    update(this);
                    errorMessage(this,E.message,E.identifier);
                    return;
                end
                notify(this,'PropertyChanged');
            end
            if isInteractive
                if nCommitted==0
                    actor=getActorFromScenario(canvas);
                    actor.Position=data(1,:);
                    update(canvas.ScenarioView);
                end
                createActorWaypointsLine(canvas);
                updateWaypointLine(canvas);
                updateCursorLine(canvas,[]);
                if shouldUpdate
                    update(this);
                end
            end
        end

        function setPropertyForInteractiveMode(this,propName,newValue)
            canvas=this.Application.ScenarioView;
            if strcmp(canvas.InteractionMode,'addActor')
                canvas.CurrentActor.(propName)=newValue;
            else
                setPropertyForNonInteractiveMode(this,propName,newValue);
            end
        end
    end
end

function v=lcl_str2double(v)

if ischar(v)
    v=str2double(v);
end
end


