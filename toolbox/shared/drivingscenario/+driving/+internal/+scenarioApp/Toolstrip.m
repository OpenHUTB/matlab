classdef Toolstrip<matlab.ui.internal.toolstrip.TabGroup




    properties
Application
    end

    properties(SetAccess=protected,Hidden)
FileSection
ComponentsSection
SensorSection
PlacementSection
PropertiesSection
SimulateSection
RunSection
ViewSection
ExportSection
hAddRoad
hAddActor
hAddBarrier
hAddVision
hAddRadar
hAddLidar
hAddINS
hAddUltrasonic
hDisplayProperties
        hContributed=struct
        hContributedEgoView=struct
hExportMatlabCode
hExportOpenDriveFile
hExportScenarioFile
hExportSimulinkModel
hExportSimulinkModelSensor
hExport3dSimModel
hExportSensorData
hPlacementProperties
hAlignLeft
hAlignCenter
hAlignRight
hAlignTop
hAlignMiddle
hAlignBottom
hDistributeHorizontal
hDistributeVertical
hRun
hSimulator
SimulatorListener

VehicleCategory
BarrierCategory
OtherCategory
VehicleItems
BarrierItems
OtherItems

        AddingSensor=false
        IsEditorLoading=false
OldSimulatorSections
    end

    methods
        function this=Toolstrip(hApp,varargin)

            this@matlab.ui.internal.toolstrip.TabGroup();
            this.Tag='DrivingScenarioDesigner';
            this.Application=hApp;

            this.SimulatorListener=addStateChangedListener(hApp.Simulator,@this.onSimulatorStateChanged);

            mainTab=this.addTab(getString(message('driving:scenarioApp:ScenarioMainTabName')));
            mainTab.Tag='home';

            function s=addSection(tab,s)
                tab.add(s);
            end

            this.FileSection=addSection(mainTab,getFileSection(hApp));
            this.ComponentsSection=addSection(mainTab,createAddComponentsSection(this));

            if hApp.IsADTInstalled
                this.SensorSection=addSection(mainTab,createSensorSection(this));
            end

            if hApp.ShowPlacementSection
                this.PlacementSection=addSection(mainTab,createPlacementSection(this));
            end

            this.PropertiesSection=addSection(mainTab,createPropertiesSection(this));

            if hApp.ShowSimulators
                this.RunSection=addSection(mainTab,createRunSection(this));
            else
                this.SimulateSection=addSection(mainTab,driving.internal.scenarioApp.SimulateSection(hApp));
                attach(this.SimulateSection);
            end

            this.ViewSection=addSection(mainTab,createViewSection(this));
            this.ExportSection=addSection(mainTab,createExportSection(this));
        end

        function h=createSimulationManagerSection(this)
            import matlab.ui.internal.toolstrip.*;
            h=Section;
            h.Title=getString(message('driving:scenarioApp:SimulationManagerSectionTitle'));
            h.Tag='simulationManager';

            simulator=DropDownButton(getString(message('driving:scenarioApp:SimulatorText')));
            simulator.Description=getString(message('driving:scenarioApp:SimulatorDescription'));
            simulator.Tag='simulatorListbox';
            simulator.Icon=getIcon(this.Application.Simulator);

            popup=PopupList;

            scenarioSimulator = ListItem(getString(message('driving:scenarioApp:ScenarioSimulatorText')), Icon.MATLAB_24);
            scenarioSimulator.ShowDescription = false;
            simulinkSimulator=ListItem(getString(message('driving:scenarioApp:SimulinkSimulatorText')),Icon.SIMULINK_24);
            simulinkSimulator.ShowDescription=false;

            hApp=this.Application;
            scenarioSimulator.ItemPushedFcn=hApp.initCallback(@this.setSimulatorCallback,'driving.internal.scenarioApp.ScenarioSimulator');
            simulinkSimulator.ItemPushedFcn=hApp.initCallback(@this.setSimulatorCallback,'driving.internal.scenarioApp.SimulinkSimulator');

            popup.add(scenarioSimulator);
            popup.add(simulinkSimulator);

            simulator.Popup=popup;

            add(addColumn(h),simulator);
        end
    end

    methods(Hidden)

        function setSimulatorCallback(this,~,~,id)
            initSimulator(this.Application,id);
            this.SelectedTab=getChildByIndex(this,2);
        end

        function restoreDefaultLayoutCallback(this,~,~)
            updateView(this.Application,true);
        end

        function addRadarSensorCallback(this,~,~)
            addViaMouse(getSensorAdder(this.Application),'radar');
        end

        function addLidarSensorCallback(this,~,~)
            addViaMouse(getSensorAdder(this.Application),'lidar');
        end

        function addVisionSensorCallback(this,~,~)
            addViaMouse(getSensorAdder(this.Application),'vision');
        end

        function addINSSensorCallback(this,~,~)
            addViaMouse(getSensorAdder(this.Application),'ins');
        end

        function addUltrasonicSensorCallback(this,~,~)
            addViaMouse(getSensorAdder(this.Application),'ultrasonic');
        end

        function updatePlacement(this)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            alignEnab=false;
            distributeEnab=false;
            if isa(current,'driving.internal.scenarioApp.ActorSpecification')
                if numel(current)>1
                    alignEnab=true;
                    if numel(current)>2
                        distributeEnab=true;
                    end
                end
            end

            this.hAlignLeft.Enabled=alignEnab;
            this.hAlignCenter.Enabled=alignEnab;
            this.hAlignRight.Enabled=alignEnab;
            this.hAlignTop.Enabled=alignEnab;
            this.hAlignMiddle.Enabled=alignEnab;
            this.hAlignBottom.Enabled=alignEnab;

            this.hDistributeHorizontally.Enabled=distributeEnab;
            this.hDistributeVertically.Enabled=distributeEnab;
        end

        function updateExport(this)
            sensorSpecs=this.Application.SensorSpecifications;
            sensorSpecs=sensorSpecs([sensorSpecs.Enabled]);
            actorSpecs=this.Application.ActorSpecifications;
            roadSpecs=this.Application.RoadSpecifications;

            this.hExportSensorData.Enabled=~isempty(sensorSpecs);
            this.hExportSimulinkModelSensor.Enabled=this.hExportSensorData.Enabled;
            this.hExportSimulinkModel.Enabled=(~isempty(actorSpecs)||~isempty(roadSpecs));
            this.hExport3dSimModel.Enabled=~isempty(actorSpecs);
        end

        function updateRun(this)
            sim=this.Application.Simulator;
            run=this.hRun;
            if isRunning(sim)
                run.Icon=matlab.ui.internal.toolstrip.Icon.PAUSE_MATLAB_24;
                run.Text=getString(message('driving:scenarioApp:PauseText'));
                run.Description=getString(message('driving:scenarioApp:PauseDescription'));
            elseif isPaused(sim)&&getCurrentSample(sim)~=1
                run.Icon=matlab.ui.internal.toolstrip.Icon.CONTINUE_MATLAB_24;
                run.Text=getString(message('driving:scenarioApp:ContinueText'));
                run.Description=getString(message('driving:scenarioApp:ContinueDescription'));
            else
                run.Icon=matlab.ui.internal.toolstrip.Icon.RUN_24;
                run.Text=getString(message('driving:scenarioApp:RunText'));
                run.Description=getString(message('driving:scenarioApp:RunDescription'));
            end
            run.Enabled=canRun(sim);
        end

        function updateActorsGallery(this)
            import matlab.ui.internal.toolstrip.*;
            hBuilder=this.Application;
            classSpecs=hBuilder.ClassSpecifications;
            allIds=getAllIds(classSpecs);
            vehicleCategory=this.VehicleCategory;
            otherCategory=this.OtherCategory;
            barrierCategory=this.BarrierCategory;
            oldVehicles=this.VehicleItems;
            for indx=1:numel(oldVehicles)
                remove(vehicleCategory,oldVehicles(indx));
            end
            oldOthers=this.OtherItems;
            for indx=1:numel(oldOthers)
                remove(otherCategory,oldOthers(indx));
            end
            oldBarriers=this.BarrierItems;
            for indx=1:numel(oldBarriers)
                remove(barrierCategory,oldBarriers(indx));
            end
            vehicleItems=GalleryItem.empty;
            otherItems=GalleryItem.empty;
            barrierItems=GalleryItem.empty;
            iconPath=hBuilder.getPathToIcons;
            for indx=1:numel(allIds)
                spec=getSpecification(classSpecs,allIds(indx));
                desc=getString(message('driving:scenarioApp:AddActorItemDescription',lower(spec.name)));
                switch spec.name
                case getString(message('driving:scenarioApp:BicycleText'))
                    icon=Icon(fullfile(iconPath,'AddBicycle24.png'));
                case getString(message('driving:scenarioApp:CarText'))
                    icon=Icon(fullfile(iconPath,'AddCar24.png'));
                case getString(message('driving:scenarioApp:BarrierText'))
                    icon=Icon(fullfile(iconPath,'AddBarrier24.png'));
                case getString(message('driving:scenarioApp:TruckText'))
                    icon=Icon(fullfile(iconPath,'AddTruck24.png'));
                case getString(message('driving:scenarioApp:PedestrianText'))
                    icon=Icon(fullfile(iconPath,'AddPedestrian24.png'));
                case getString(message('driving:scenarioApp:JerseyBarrierText'))
                    icon=Icon(fullfile(iconPath,'AddBarrier24.png'));
                case getString(message('driving:scenarioApp:GuardrailBarrierText'))
                    icon=Icon(fullfile(iconPath,'AddGuardrail24.png'));
                otherwise
                    icon=Icon(fullfile(iconPath,'Actor24.png'));
                    desc=getString(message('driving:scenarioApp:AddCustomActorItemDescription',lower(spec.name)));
                end
                item=GalleryItem(spec.name,icon);
                item.Description=desc;
                item.ItemPushedFcn=matlabshared.application.makeCallback(@addActorCallback,this,spec);
                item.Tag=sprintf('addClassId%d',spec.id);
                if spec.isVehicle
                    vehicleItems(end+1)=item;%#ok<AGROW>
                    add(vehicleCategory,item);
                elseif~strcmp(spec.BarrierType,'None')
                    barrierItems(end+1)=item;%#ok<AGROW>
                    add(barrierCategory,item);
                    item.ItemPushedFcn=matlabshared.application.makeCallback(@addBarrierCallback,this,spec);
                else
                    otherItems(end+1)=item;%#ok<AGROW>
                    add(otherCategory,item);
                end
            end
            this.VehicleItems=vehicleItems;
            this.OtherItems=otherItems;
            this.BarrierItems=barrierItems;
        end





        function newClassCallback(this,~,~)
            if this.IsEditorLoading
                return
            end

            this.IsEditorLoading=true;
            spec=newClassSpecification(this.Application);
            if~isempty(spec)
                addActorCallback(this,spec);
            end
            if isvalid(this)
                this.IsEditorLoading=false;
            end
        end

        function editClassesCallback(this,~,~)
            if this.IsEditorLoading
                return
            end
            this.IsEditorLoading=true;
            editClassSpecifications(this.Application);
            this.IsEditorLoading=false;
        end

        function onSimulatorStateChanged(this,~,~)
            enable=isStopped(this.Application.Simulator);

            if this.Application.Scenario.IsOpenDRIVERoad
                this.hAddRoad.Enabled=false;
                this.hExportMatlabCode.Enabled=false;
                this.hExportScenarioFile.Enabled=true;
            else
                this.hAddRoad.Enabled=enable;
                this.hExportMatlabCode.Enabled=true;
            end
            this.hAddActor.Enabled=enable;
            this.hAddBarrier.Enabled=enable;
            this.hAddVision.Enabled=enable;
            this.hAddRadar.Enabled=enable;
            this.hAddLidar.Enabled=enable;
            this.hAddINS.Enabled=enable;
            if~isempty(this.hAddUltrasonic)
                this.hAddUltrasonic.Enabled=enable;
            end
            updateRun(this);
        end

        function addActorCallback(this,spec)
            hApp=this.Application;
            actorAdder=getActorAdder(hApp);
            setStatus(hApp,getString(message('driving:scenarioApp:AddActorMessage',lower(spec.name))));
            focusOnComponent(hApp.ScenarioView);
            hSensorCanvas=hApp.SensorCanvas;
            if~isempty(hSensorCanvas)
                hSensorCanvas.InteractionMode='move';
            end
            pause(0.1);

            actorAdder.addViaMouse(spec);
        end

        function alignActorsLeftCallback(this,~,~)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignLeft(ind);
        end

        function alignActorsRightCallback(this,~,~)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignRight(ind);
        end

        function alignActorsTopCallback(this,~,~)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignTop(ind);
        end

        function alignActorsHorizMiddleCallback(this,~,~)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignHorizMiddle(ind);
        end

        function alignActorsVertMiddleCallback(this,~,~)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignVertMiddle(ind);
        end

        function alignActorsBottomCallback(this,~,~)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignBottom(ind);
        end

        function distributeActorsVertCallback(this,~,~)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.distributeVert(ind);
        end

        function distributeActorsHorizCallback(this,~,~)
            canvas=this.Application.ScenarioView;
            current=canvas.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.distributeHoriz(ind);
        end


        function addBarrierCallback(this,classSpec)
            hApp=this.Application;
            barrierAdder=getBarrierAdder(hApp);

            spec=driving.internal.scenarioApp.BarrierSpecification;
            spec.initializePropertiesFromClassSpecification(classSpec);
            barrierAdder.addViaWaypoints(spec);
        end

        function addRoadCallback(this,~,~)
            addViaWaypoints(getRoadAdder(this.Application),driving.internal.scenarioApp.road.Arbitrary);
        end

        function exportMatlabCode(this,varargin)
            str=generateMatlabCode(this.Application,varargin{:});

            editorDoc=matlab.desktop.editor.newDocument(char(str));
            editorDoc.smartIndentContents;
        end

        function exportSimulinkModel(this,varargin)
            callbackHandler(this,@()generateSimulinkModel(this.Application,varargin{:}));
        end

        function export3dSimModel(this,varargin)
            app=this.Application;
            [~,w]=generate3dSimModel(app,varargin{:});
            if~isempty(w)
                moreInfo=numel(w)>2;
                w=sprintf('%s\n',w{:});
                w(end)=[];
                if moreInfo
                    moreInfo=w;
                    w=getString(message('driving:scenarioApp:Export3dSimMultipleWarnings'));
                else
                    moreInfo='';
                end
                app.ScenarioView.warningMessage(w,'3dSimExportWarnings','MoreInfoText',moreInfo);
            end
        end

        function callbackHandler(this,fcn)
            this.Application.callbackHandler(fcn,this.Application.ScenarioView);
        end

        function exportSimulinkModelSensor(this,varargin)
            callbackHandler(this,@()generateSimulinkModelSensor(this.Application,varargin{:}));
        end

        function exportSensorData(this)
            [~,okPressed]=export2wsdlg({getString(message('driving:scenarioApp:VariableName'))},...
            {''},{getSensorDataForExport(this.Application.BirdsEyePlot)},...
            getString(message('driving:scenarioApp:ExportDialogTitle')));%#ok<ASGLU>
        end

        function gamingEngineCallback(this,~,ev)
            app=this.Application;
            freezeUserInterface(app);
            open=ev.EventData.NewValue;
            v=getGamingEngineViewer(app,true);
            v.Visible=open;
            w=v.LastWarnings;
            if~isempty(w)&&open
                moreInfo=numel(w)>2;
                w=sprintf('%s\n',w{:});
                w(end)=[];
                if moreInfo
                    moreInfo=w;
                    w=getString(message('driving:scenarioApp:MultipleGamingEngineWarnings'));
                else
                    moreInfo='';
                end
                app.ScenarioView.warningMessage(w,'GamingEngineIncompatibility','MoreInfoText',moreInfo);
            end
        end

        function setCheckBoxProperty(this,prop,val,containerTag)
            if nargin>3
                contProp=['hContributed',containerTag];
            else
                contProp='hContributed';
            end
            this.(contProp).(prop).Value=logical(val);
        end

        function checkBoxChanged(~,hAction,~,contributor,prop)
            contributor.(prop)=hAction.Selected;
        end

        function contribute(this,contributor,targetTag,contributorTag,contributorProps,containerTag)
            import matlab.ui.internal.toolstrip.*;
            header=PopupListHeader(getString(message(['driving:scenarioApp:',contributorTag,'Title'])));
            header.Tag=[contributorTag,'Header'];
            targetProp=['h',targetTag];
            popup=this.(targetProp).Popup;
            popup.add(header);
            if nargin>5
                contProp=['hContributed',containerTag];
            else
                contProp='hContributed';
            end
            contributed=this.(contProp);
            for kndx=1:numel(contributorProps)
                prop=contributorProps{kndx};
                item=ListItemWithCheckBox(getString(message(['driving:scenarioApp:',prop,'Label'])));
                item.Tag=prop;
                item.Value=contributor.(prop);
                item.ShowDescription=false;
                item.ValueChangedFcn=@(src,evnt)this.checkBoxChanged(src,evnt,contributor,prop);
                contributed.(prop)=item;
                popup.add(item);
            end
            this.(contProp)=contributed;
        end

        function runCallback(this,~,~)
            sim=this.Application.Simulator;
            if isPaused(sim)||isStopped(sim)
                run(this.Application.Simulator);
            else
                pause(this.Application.Simulator);
            end
        end

    end

    methods(Access=protected)

        function h=createRunSection(this)
            import matlab.ui.internal.toolstrip.*;
            h=Section;
            h.Title=getString(message('driving:scenarioApp:RunSectionTitle'));
            h.Tag='run';

            run=Button(getString(message('driving:scenarioApp:RunText')),Icon.PLAY_24);
            run.ButtonPushedFcn=@this.runCallback;
            run.Description=getString(message('driving:scenarioApp:RunDescription'));
            run.Tag='run';

            this.hRun=run;

            add(addColumn(h,'Width',69,'HorizontalAlignment','center'),run);
            updateRun(this);
        end

        function h=createExportSection(this)

            import matlab.ui.internal.toolstrip.*;

            hApp=this.Application;
            h=Section;

            h.Title=getString(message('driving:scenarioApp:ExportSectionTitle'));
            h.Tag='export';
            export=DropDownButton(getString(message('driving:scenarioApp:ExportText')),Icon.CONFIRM_24);
            export.Description=getString(message('driving:scenarioApp:ExportDescription'));
            export.Tag='exportDropdown';

            export.Popup=PopupList;
            export.Popup.Tag='exportPopup';

            iconPath=hApp.getPathToIcons;
            add(export.Popup,PopupListHeader(getString(message('driving:scenarioApp:ExportMatlabPopupHeader'))));
            exportMatlabCode=ListItem(getString(message('driving:scenarioApp:ExportMatlabCodeText')),...
            Icon(fullfile(iconPath,'ExportMatlabCode24.png')));
            exportMatlabCode.Tag='exportMatlabCodeItem';
            exportMatlabCode.ItemPushedFcn=hApp.initCallback(@this.exportMatlabCodeCallback);
            exportMatlabCode.Description=getString(message('driving:scenarioApp:ExportMatlabCodeDescription'));

            export.Popup.add(exportMatlabCode);

            this.hExportMatlabCode=exportMatlabCode;

            if hApp.IsADTInstalled
                exportSensorData=ListItem(getString(message('driving:scenarioApp:ExportSensorDataText')),...
                Icon(fullfile(iconPath,'ExportSensorData24.png')));
                exportSensorData.Tag='exportSensorData';
                exportSensorData.ItemPushedFcn=hApp.initCallback(@this.exportSensorDataCallback);
                exportSensorData.Description=getString(message('driving:scenarioApp:ExportSensorDataDescription'));
                exportSensorData.Enabled=false;

                export.Popup.add(exportSensorData);
                this.hExportSensorData=exportSensorData;

                if builtin('license','test','simulink')
                    add(export.Popup,PopupListHeader(getString(message('driving:scenarioApp:ExportSimulinkPopupHeader'))));
                    exportSimulinkModel=ListItem(getString(message('driving:scenarioApp:ExportSimulinkModelText')),...
                    Icon(fullfile(iconPath,'ExportSimulinkModel24.png')));
                    exportSimulinkModel.Tag='exportSimulinkModelItem';
                    exportSimulinkModel.ItemPushedFcn=hApp.initCallback(@this.exportSimulinkModelCallback);
                    exportSimulinkModel.Description=getString(message('driving:scenarioApp:ExportSimulinkModelDescription'));

                    exportSimulinkModelSensor=ListItem(getString(message('driving:scenarioApp:ExportSimulinkModelSensorText')),...
                    Icon(fullfile(iconPath,'ExportSimulinkModel24.png')));
                    exportSimulinkModelSensor.Tag='exportSimulinkModelSensorItem';
                    exportSimulinkModelSensor.ItemPushedFcn=hApp.initCallback(@this.exportSimulinkModelSensorCallback);
                    exportSimulinkModelSensor.Description=getString(message('driving:scenarioApp:ExportSimulinkModelSensorDescription'));

                    if this.Application.ShowExport3dSim
                        export3dSimModel=ListItem('Unreal Engine Simulink Model',...
                        Icon(fullfile(iconPath,'ExportSimulinkModel24.png')));
                        export3dSimModel.Tag='export3DSimModelItem';
                        export3dSimModel.ItemPushedFcn=hApp.initCallback(@this.export3dSimModelCallback);
                        export3dSimModel.Description='Generate Simulink model for co-simulation with Unreal Engine';
                        export.Popup.add(export3dSimModel);
                        this.hExport3dSimModel=export3dSimModel;
                    end
                    export.Popup.add(exportSimulinkModel);
                    export.Popup.add(exportSimulinkModelSensor);

                    this.hExportSimulinkModel=exportSimulinkModel;
                    this.hExportSimulinkModelSensor=exportSimulinkModelSensor;
                end
                add(export.Popup,PopupListHeader(getString(message('driving:scenarioApp:ExternalStandardPopupHeader'))));

                exportOpenDrive=ListItem(getString(message('driving:scenarioApp:OpenDriveTitle')),...
                Icon(fullfile(iconPath,'Export_OpenDrive_24.png')));
                exportOpenDrive.Tag='exportOpenDriveFileItem';
                exportOpenDrive.ItemPushedFcn=hApp.initCallback(@this.exportOpenDriveFileCallback);
                exportOpenDrive.Description=getString(message('driving:scenarioApp:OpenDriveExportDescription'));
                export.Popup.add(exportOpenDrive);
                this.hExportOpenDriveFile=exportOpenDrive;

                exportOpenScenario=ListItem(getString(message('driving:scenarioApp:OpenScenarioButtonTitle')),...
                Icon(fullfile(iconPath,'OpenScenarioExport24.png')));
                exportOpenScenario.Tag='exportOSCItem';
                exportOpenScenario.ItemPushedFcn=hApp.initCallback(@this.exportScenarioFileCallback);
                exportOpenScenario.Description=getString(message('driving:scenarioApp:OpenScenarioButtonDescription'));
                export.Popup.add(exportOpenScenario);
                this.hExportScenarioFile=exportOpenScenario;
            end

            add(addColumn(h),export);
            h.CollapsePriority=20;

            updateExport(this);
        end

        function h=createAddComponentsSection(this)
            import matlab.ui.internal.toolstrip.*;

            hApp=this.Application;
            iconPath=hApp.getPathToIcons;
            h=Section;
            h.Title=getString(message('driving:scenarioApp:ComponentsSectionTitle'));
            h.Tag='components';

            addRoad=Button(getString(message('driving:scenarioApp:AddRoadText')),...
            Icon(fullfile(iconPath,'AddRoad24.png')));
            addRoad.Description=getString(message('driving:scenarioApp:AddRoadDescription'));
            addRoad.Tag='addRoad';
            addRoad.ButtonPushedFcn=hApp.initCallback(@this.addRoadCallback);


            vehicleCategory=GalleryCategory(getString(message('driving:scenarioApp:VehiclesCategoryTitle')));
            vehicleCategory.Tag='AddActorVehicleCategory';
            otherCategory=GalleryCategory(getString(message('driving:scenarioApp:OtherCategoryTitle')));
            otherCategory.Tag='AddActorOtherCategory';
            barrierCategory=GalleryCategory(getString(message('driving:scenarioApp:BarriersCategoryTitle')));
            barrierCategory.Tag='AddBarrierCategory';

            settingsCategory=GalleryCategory(getString(message('driving:scenarioApp:SettingsCategoryTitle')));

            newClass=GalleryItem(getString(message('driving:scenarioApp:NewClassGalleryItem')),Icon(fullfile(iconPath,'NewClass24.png')));
            newClass.Tag='AddNewActorClass';
            newClass.Description=getString(message('driving:scenarioApp:NewClassDescription'));
            newClass.ItemPushedFcn=hApp.initCallback(@this.newClassCallback);

            editClass=GalleryItem(getString(message('driving:scenarioApp:EditClassGalleryItem')),Icon(fullfile(iconPath,'EditClasses24.png')));
            editClass.Tag='EditActorClasses';
            editClass.Description=getString(message('driving:scenarioApp:EditClassDescription'));
            editClass.ItemPushedFcn=hApp.initCallback(@this.editClassesCallback);

            add(settingsCategory,newClass);
            add(settingsCategory,editClass);

            popup=GalleryPopup('DisplayState','list_view');
            popup.Tag='actorGalleryPopup';
            popup.add(vehicleCategory);
            popup.add(otherCategory);
            popup.add(barrierCategory);
            popup.add(settingsCategory);

            addActor=DropDownGalleryButton(popup,getString(message('driving:scenarioApp:AddActorText')),...
            Icon(fullfile(iconPath,'AddCar24.png')));
            addActor.Description=getString(message('driving:scenarioApp:AddActorDescription'));
            addActor.Tag='actorGallery';



            this.VehicleCategory=vehicleCategory;
            this.OtherCategory=otherCategory;
            this.BarrierCategory=barrierCategory;

            updateActorsGallery(this);

            add(addColumn(h),addRoad);
            add(addColumn(h),addActor);

            this.hAddRoad=addRoad;
            this.hAddActor=addActor;

        end

        function h=createSensorSection(this)
            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;
            h=Section;
            h.Title=getString(message('driving:scenarioApp:SensorSectionTitle'));
            h.Tag='sensors';

            addVision=Button(getString(message('driving:scenarioApp:AddVisionSensorText')),...
            Icon(fullfile(hApp.getPathToIcons,'AddCamera24.png')));
            addVision.Tag='AddVision';
            addVision.Description=getString(message('driving:scenarioApp:AddVisionSensorDescription'));
            addVision.ButtonPushedFcn=hApp.initCallback(@this.addVisionSensorCallback);

            addRadar=Button(getString(message('driving:scenarioApp:AddRadarSensorText')),...
            Icon(fullfile(hApp.getPathToIcons,'AddRadar24.png')));
            addRadar.Tag='AddRadar';
            addRadar.Description=getString(message('driving:scenarioApp:AddRadarSensorDescription'));
            addRadar.ButtonPushedFcn=hApp.initCallback(@this.addRadarSensorCallback);

            this.hAddVision=addVision;
            this.hAddRadar=addRadar;

            add(addColumn(h),addVision);
            add(addColumn(h),addRadar);

            addLidar=Button(getString(message('driving:scenarioApp:AddLidarSensorText')),...
            Icon(fullfile(hApp.getPathToIcons,'AddLidar24.png')));
            addLidar.Tag='AddLidar';
            addLidar.Description=getString(message('driving:scenarioApp:AddLidarSensorDescription'));
            addLidar.ButtonPushedFcn=hApp.initCallback(@this.addLidarSensorCallback);

            this.hAddLidar=addLidar;
            add(addColumn(h),addLidar);

            addINS=Button(getString(message('driving:scenarioApp:AddINSSensorText')),...
            Icon(fullfile(hApp.getPathToIcons,'AddINS24.png')));
            addINS.Tag='AddINS';
            addINS.Description=getString(message('driving:scenarioApp:AddINSSensorDescription'));
            addINS.ButtonPushedFcn=hApp.initCallback(@this.addINSSensorCallback);
            this.hAddINS=addINS;
            add(addColumn(h),addINS);

            addUltrasonic=Button(getString(message('driving:scenarioApp:AddUltrasonicSensorText')),...
            Icon(fullfile(hApp.getPathToIcons,'AddUltrasonic24.png')));
            addUltrasonic.Tag='AddUltrasonic';
            addUltrasonic.Description=getString(message('driving:scenarioApp:AddUltrasonicSensorDescription'));
            addUltrasonic.ButtonPushedFcn=hApp.initCallback(@this.addUltrasonicSensorCallback);
            this.hAddUltrasonic=addUltrasonic;
            add(addColumn(h),addUltrasonic);
        end
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

        function h=createPlacementSection(this)
            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;

            iconPath=hApp.getPathToIcons;

            h=Section;
            h.Title=getString(message('driving:scenarioApp:PlacementSectionTitle'));
            h.Tag='placement';

            alignCategory=PopupListHeader('Alignment Tools');

            sharedIcons=fullfile(toolboxdir('shared'),'spcuilib','applications','+matlabshared','+application');

            left=ListItem('Align Left',Icon(fullfile(sharedIcons,'AlignLeft16.png')));
            left.Tag='leftAlign';
            left.ShowDescription=false;
            left.ItemPushedFcn=hApp.initCallback(@this.alignActorsLeftCallback);

            right=ListItem('Align Right',Icon(fullfile(sharedIcons,'AlignRight16.png')));
            right.Tag='rightAlign';
            right.ShowDescription=false;
            right.ItemPushedFcn=hApp.initCallback(@this.alignActorsRightCallback);

            top=ListItem('Align Top',Icon(fullfile(sharedIcons,'AlignTop16.png')));
            top.Tag='topAlign';
            top.ShowDescription=false;
            top.ItemPushedFcn=hApp.initCallback(@this.alignActorsTopCallback);

            bottom=ListItem('Align Bottom',Icon(fullfile(sharedIcons,'AlignBottom16.png')));
            bottom.Tag='bottomAlign';
            bottom.ShowDescription=false;
            bottom.ItemPushedFcn=hApp.initCallback(@this.alignActorsBottomCallback);

            center=ListItem('Align Horizontal Middle',Icon(fullfile(sharedIcons,'AlignCenter16.png')));
            center.Tag='centerAlign';
            center.ShowDescription=false;
            center.ItemPushedFcn=hApp.initCallback(@this.alignActorsHorizMiddleCallback);

            middle=ListItem('Align Vertical Middle',Icon(fullfile(sharedIcons,'AlignMiddle16.png')));
            middle.Tag='middleAlign';
            middle.ShowDescription=false;
            middle.ItemPushedFcn=hApp.initCallback(@this.alignActorsVertMiddleCallback);

            distributeCategory=PopupListHeader('Distribution Tools');

            horizontal=ListItem('Distribute Horizontally',Icon(fullfile(sharedIcons,'DistributeHorizontal16.png')));
            horizontal.Tag='horizontalDistribute';
            horizontal.ShowDescription=false;
            horizontal.ItemPushedFcn=hApp.initCallback(@this.distributeActorsHorizCallback);

            vertical=ListItem('Distribute Vertically',Icon(fullfile(sharedIcons,'DistributeVertical16.png')));
            vertical.Tag='verticalDistribute';
            vertical.ShowDescription=false;
            vertical.ItemPushedFcn=hApp.initCallback(@this.distributeActorsVertCallback);

            popup=PopupList();
            popup.Tag='alignmentPopup';
            popup.add(alignCategory);
            popup.add(left);
            popup.add(center);
            popup.add(right);
            popup.add(top);
            popup.add(middle);
            popup.add(bottom);
            popup.add(distributeCategory);
            popup.add(horizontal);
            popup.add(vertical);

            placementProperties=DropDownButton('Align',Icon(fullfile(iconPath,'alignHorizontalCenter_24.png')));
            placementProperties.Popup=popup;
            placementProperties.Description=getString(message('driving:scenarioApp:DisplayPropertiesDescription'));
            placementProperties.Tag='placementProperties';

            this.hPlacementProperties=placementProperties;
            add(addColumn(h,'Width',64,'HorizontalAlignment','center'),placementProperties);

        end
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

        function h=createPropertiesSection(this)
            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;
            h=Section;
            h.Title=getString(message('driving:scenarioApp:PropertiesSectionTitle'));
            h.Tag='properties';
            displayProperties=DropDownButton(getString(message('driving:scenarioApp:DisplayPropertiesText')),...
            Icon(fullfile(hApp.getPathToIcons,'DisplayProperties24.png')));
            displayProperties.Popup=PopupList();
            displayProperties.Description=getString(message('driving:scenarioApp:DisplayPropertiesDescription'));
            displayProperties.Tag='displayProperties';
            this.hDisplayProperties=displayProperties;
            h.CollapsePriority=20;
            add(addColumn(h,'Width',round(64*getPixelRatio(this.Application.Window)),'HorizontalAlignment','center'),displayProperties);
        end

        function h=createViewSection(this)
            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;
            h=Section;
            h.Title=getString(message('Spcuilib:application:ViewSectionTitle'));
            h.Tag='view';

            restore=Button(getString(message('Spcuilib:application:DefaultLayoutLabel_24')),Icon.LAYOUT_24);
            restore.Tag='RestoreDefaultLayout';
            restore.Description=getString(message('Spcuilib:application:DefaultLayoutDescription'));
            restore.ButtonPushedFcn=hApp.initCallback(@this.restoreDefaultLayoutCallback);
            add(addColumn(h),restore);


            gaming=DropDownButton(getString(message('driving:scenarioApp:GamingEngineText')),Icon(fullfile(hApp.getPathToIcons,'GamingEngine24.png')));
            gaming.Tag='GamingEngine';
            gaming.Description=getString(message('driving:scenarioApp:GamingEngineDescription'));
            gaming.DynamicPopupFcn=@this.generateGamingEnginePopup;
            h.CollapsePriority=15;
            add(addColumn(h),gaming);
        end

        function popup=generateGamingEnginePopup(this,~,~)
            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;
            viewer=hApp.getGamingEngineViewer;
            if isempty(viewer)
                value=false;
            else
                value=viewer.Visible&&viewer.isWindowOpen;
                if~value
                    viewer.Visible=false;
                end
            end

            isStopped=~hApp.Simulator.isRunning;
            popup=PopupList;
            if ispc
                view=ListItemWithCheckBox(getString(message('driving:scenarioApp:GamingEngineViewText')));
                view.Tag='GamingEngineView';
                view.Value=value;
                hasActors=~isempty(hApp.ActorSpecifications);
                hasRoads=~isempty(hApp.RoadSpecifications);
                view.Enabled=value||(hasActors||hasRoads)&&isStopped;
                view.ValueChangedFcn=hApp.initCallback(@this.gamingEngineCallback);
                view.Description=getString(message('driving:scenarioApp:GamingEngineDescription'));
                popup.add(view);
            end
            head=PopupListHeader(getString(message('driving:scenarioApp:GamingEngineDimsHeader')));
            popup.add(head);
            dims=ListItemWithCheckBox(getString(message('driving:scenarioApp:GamingEngineDimsText')));
            dims.ValueChangedFcn=hApp.initCallback(@this.use3dSimDimsCallback);
            dims.Description=getString(message('driving:scenarioApp:GamingEngineDimsDescription'));
            dims.Tag='GamingEngineUseDims';
            dims.Value=hApp.Use3dSimDimensions;
            dims.Enabled=isStopped&&getCurrentSample(hApp.Simulator)==1;
            popup.add(dims);
        end

        function use3dSimDimsCallback(this,~,ev)
            app=this.Application;
            app.Use3dSimDimensions=ev.EventData.NewValue;
            update(app.ActorProperties);
        end

        function exportMatlabCodeCallback(this,~,~)
            exportMatlabCode(this);
        end

        function exportOpenDriveFileCallback(this,~,~)
            driving.internal.scenarioApp.export.exportOpenDriveFile(this.Application);
        end

        function exportScenarioFileCallback(this,~,~)
            driving.internal.scenarioApp.export.exportScenarioFile(this);
        end

        function export3dSimModelCallback(this,~,~)
            export3dSimModel(this);
        end

        function exportSimulinkModelCallback(this,~,~)
            exportSimulinkModel(this,'scenario');
        end

        function exportSimulinkModelSensorCallback(this,~,~)
            exportSimulinkModel(this,'sensor');
        end

        function exportSensorDataCallback(this,~,~)
            exportSensorData(this);
        end
    end
end


