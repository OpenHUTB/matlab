classdef VirtualAppContainer<matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties

        FeatureBrowserPanel matlab.ui.internal.FigurePanel

        FeatureBrowserFigure matlab.ui.Figure

StartFigDoc

VehDataDoc

VehDataFigDoc

VehScene

VehScenFigDoc
VehDataLog

DataLogFigDoc

VehSetupFigDoc

        qabHelpBtn matlab.ui.internal.toolstrip.qab.QABHelpButton

App

        ProductCatalogFile=''

        Features=[];

        ConfigInfos=[];

        isNewSession=true;

        ConstrainedFeature=[];

        SelectedSignals=[];

        ModelPath='';

        licStatus=[];

        ProjPath='';

VehSetupDoc

        ConflictUpdateComponent;

StatusBar

        EngRzResult=[]

        MotRzResult=[]

        GtorRzResult=[]
    end

    properties(Access=private)

        DocGroupTag='Configuration';

        GridLayout_tree=[];

        FeatureTree=[];

SimModel

        FeatureDataModified=[];

        FeatureVariantSelectedMap=[];

TemplateModel

Model

        ProductCatalogData=[];

        Constraints=[];

        AppConfiguration=[];

        busy=false;

        TestPlanArray=[];

        VehDynValue='Vehicle Body 3DOF Longitudinal';

        VehArct='Conventional Vehicle';

        PlantModelType='Simulink';

VehClass
        AppTag='VVCApp'

        nodechanging=true;
    end

    properties(Constant)
        DefaultSignals=["Driver.SteerFdbk","Driver.AccelFdbk","Driver.DecelFdbk",...
        "Driver.GearFdbk","Body.BdyFrm.Cg.Vel.xdot","Body.BdyFrm.Cg.Acc.ax",...
        "Body.BdyFrm.Cg.Acc.ay","Body.BdyFrm.Cg.Acc.az","Battery.BattSoc",...
        "Battery.BattVolt","Battery.BattCurr","EM.EMTrq","Driveline.EMSpd",...
        "Engine.EngTrq","Engine.EngSpdOut"];
    end

    events

PassengerCarSelected
MotorcycleSelected

    end

    methods
        function obj=VirtualAppContainer()
            createApp(obj);
        end

        function set.App(obj,app)
            obj.App=app;
            addlistener(obj.App,'PropertyChanged',@(~,data)obj.handleAppPropertyChange(data));
        end

        function addTabs(obj,tabs)
            addTabGroup(obj.App,tabs);
        end

        function openApp(obj)

            obj.App.Visible=true;
            addAppComponents(obj);
            addButtons(obj);
            drawnow();
        end

        function closeApp(obj)
            obj.App.delete();
        end

        function setFeatureTreeVisibility(obj,status)
            if status
                obj.FeatureTree.Visible='on';
                expand(obj.FeatureTree,'all');
            else
                obj.FeatureTree.Visible='off';
            end
        end

        function[doc,fig]=addDocumentFigures(obj,name)


            docOptions.Title=name;
            docOptions.DocumentGroupTag=obj.DocGroupTag;

            doc=matlab.ui.internal.FigureDocument(docOptions);

            doc.Closable=false;

            doc.Figure.AutoResizeChildren='on';

            obj.App.add(doc);
            drawnow();

            fig=doc.Figure;
            fig.Tag=name;
            fig.AutoResizeChildren='on';
            fig.Interruptible='off';
            fig.BusyAction='cancel';
        end

        function openNewSession(obj)


            obj.isNewSession=true;


            obj.clearDocs();

            fig=obj.FeatureBrowserFigure;
            d=uiprogressdlg(fig,'Title','Please Wait',...
            'Message','Preparing Vehicle Data...');
            d.Value=.1;


            [~,~,topLevelProjectRoot]=matlab.internal.project.example.projectDemoSetUp(...
            fullfile(matlabroot,'toolbox','autoblks','autoblksreference','VirtualVehicle.zip'),obj.ProjPath,false);
            openProject(topLevelProjectRoot);

            obj.App.bringToFront();

            obj.ProjPath=pwd;
            obj.ModelPath=[obj.ProjPath,filesep,'System'];

            obj.setVehTreePanel();
            obj.Initilization();
            d.Value=.8;

            obj.setVehScenFigDoc();
            obj.setDataLogFigDoc();
            d.Value=.9;
            obj.SelectedSignals=obj.VehDataLog.SelectedSignals;
            obj.selectVehDataDocFig();

            d.Value=1;
            close(d);
        end

        function selectVehDataDocFig(obj)

            tag=obj.VehDataDoc.Tag;
            obj.App.SelectedChild.tag=tag;
            obj.setFeatureTreeVisibility(true);
        end


        function setVehTreePanel(obj)


            if~isempty(obj.GridLayout_tree)
                obj.setFeatureTreeVisibility(true);
            end
            obj.readProductCatalog();
            obj.setPanelTreeContents(true);

            [doc,fig]=addDocumentFigures(obj,'Data and Calibration');
            obj.VehDataFigDoc=fig;
            obj.VehDataDoc=doc;

            if strcmp(obj.VehClass,'PassengerCar')
                obj.FeatureVariantSelectedMap('Vehicle Architecture')=obj.VehArct;
                [~]=obj.setVehDataFigDoc(1);

                obj.FeatureVariantSelectedMap('Chassis')=obj.VehDynValue;
                [~]=obj.setVehDataFigDoc(2);
            else
                [~]=obj.setVehDataFigDoc(1);
            end

        end

        function readProductCatalog(obj)

            obj.ProductCatalogData=VirtualAssembly.ProductCatalogReader(...
            'ProductCatalogFile',obj.ProductCatalogFile,...
            'ModelPath',obj.ModelPath,'PlantModel',obj.PlantModelType);
            obj.ConstrainedFeature=obj.ProductCatalogData.ConstrainedFeature;
            obj.Constraints=obj.ProductCatalogData.Constraints;

            obj.Features=obj.ProductCatalogData.Features;


            index1=find(obj.Features=='Vehicle Scenario');
            obj.Features(index1)=[];



            for i=1:size(obj.Features,1)
                FeatureName=convertStringsToChars(obj.Features(i));
                FeatureNameNoSpace=VirtualAssembly.NameFilter(FeatureName);
                obj.AppConfiguration.licStatus=obj.licStatus;
                obj.AppConfiguration.(FeatureNameNoSpace).Name=obj.Features(i);
                obj.AppConfiguration.(FeatureNameNoSpace).Variants=obj.ProductCatalogData.FeatureParameters{i}.FeatureVariant;
                obj.AppConfiguration.(FeatureNameNoSpace).VariantValue{1}=obj.AppConfiguration.(FeatureNameNoSpace).Variants{1};
                obj.AppConfiguration.(FeatureNameNoSpace).VariantValue{2}=1;
                if findnode(obj.Constraints.ComponentAdjacency,FeatureName)~=0
                    obj.AppConfiguration.(FeatureNameNoSpace).Path=obj.Constraints.(FeatureNameNoSpace).Path;
                else
                    obj.AppConfiguration.(FeatureNameNoSpace).Path=[];
                end
            end

            ConstraintsFields=fieldnames(obj.Constraints);

            for i=1:numel(ConstraintsFields)
                if~isfield(obj.AppConfiguration,ConstraintsFields{i})
                    if isa(obj.Constraints.(ConstraintsFields{i}),'VirtualAssembly.VirtualAssemblyComponents')
                        obj.AppConfiguration.(ConstraintsFields{i}).Name=ConstraintsFields{i};
                        obj.AppConfiguration.(ConstraintsFields{i}).Variants=obj.Constraints.(ConstraintsFields{i}).Options;
                        if~isempty(obj.AppConfiguration.(ConstraintsFields{i}).Variants)
                            obj.AppConfiguration.(ConstraintsFields{i}).VariantValue{1}=string(obj.AppConfiguration.(ConstraintsFields{i}).Variants{1});
                        else
                            obj.AppConfiguration.(ConstraintsFields{i}).VariantValue{1}=[];
                        end
                        obj.AppConfiguration.(ConstraintsFields{i}).VariantValue{2}=1;
                        obj.AppConfiguration.(ConstraintsFields{i}).Path=obj.Constraints.(ConstraintsFields{i}).Path;
                    end
                end
            end

        end


        function Initilization(obj)
            if~strcmp(obj.VehClass,'Motorcycle')
                obj.updateOptions('License',obj.licStatus);
                obj.ConstrainedFeature.VehicleArchitecture.Value=obj.VehArct;
                obj.ConstrainedFeature.Chassis.Value=obj.VehDynValue;
                obj.FeatureVariantSelectedMap('Vehicle Architecture')=obj.VehArct;
                obj.FeatureVariantSelectedMap('Chassis')=obj.VehDynValue;
                obj.updateOptionsInit();
                if strcmp(obj.VehDynValue,'Vehicle Body 6DOF Longitudinal and Lateral')
                    obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 6DOF Longitudinal and Lateral'};
                else
                    obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 3DOF Longitudinal';'Vehicle Body 1DOF Longitudinal'};
                end
                obj.nodechangeforupdate('Chassis');
            end

        end

        function updateOptionsInit(obj)
            OriginalFeature=obj.Features;
            for i=1:size(OriginalFeature)

                if~strcmp(OriginalFeature{i},'License')
                    if any(strcmp(obj.Features,OriginalFeature{i}))
                        feature=OriginalFeature{i};
                        if~obj.isNewSession&&~isempty(obj.FeatureVariantSelectedMap)&&isKey(obj.FeatureVariantSelectedMap,feature)
                            value=obj.FeatureVariantSelectedMap(feature);
                        else
                            component=VirtualAssembly.NameFilter(feature);
                            value=obj.ConstrainedFeature.(component).Value;
                        end
                        obj.updateFeatureVariantChanged2(value,feature);
                    end
                end
            end

        end

        function setVehScenFigDoc(obj)
            obj.setFeatureTreeVisibility(false);
            if isempty(obj.VehScenFigDoc)||obj.isNewSession
                obj.openVehScenFigDoc();
            end
            obj.VehScene.setScenarioDropDown('Drive Cycle');

            list=VirtualAssemblyScenarioParaList('Drive Cycle');

            if obj.isNewSession
                tp=struct('Num',1,...
                'Source','Scenario.sldd',...
                'Name','Drive Cycle',...
                'Cycle','FTP75',...
                'Data',{list});
                obj.VehScene.TestPlanArray{end+1}=tp;

            elseif~isempty(obj.TestPlanArray)
                obj.VehScene.TestPlanArray=obj.TestPlanArray;
                len=length(obj.TestPlanArray);
                tpdata=cell(len,2);
                for i=1:len
                    para={obj.TestPlanArray{i}.Name,obj.TestPlanArray{i}.Cycle};
                    tpdata(i,:)=para;
                end

                obj.VehScene.setTestPlanData(tpdata);

            end
        end

        function setDataLogFigDoc(obj)
            obj.setFeatureTreeVisibility(false);
            if isempty(obj.DataLogFigDoc)||obj.isNewSession
                obj.VehDataLog=VirtualAssembly.VehDataLogDoc('AppContainer',obj.App,...
                'SelectedSignals',obj.SelectedSignals);

                obj.DataLogFigDoc=obj.VehDataLog.FigDoc;
            end

        end


        function generateTestScript(obj,type)

            if strcmp(type,'New')||isempty(obj.ConfigInfos)
                name='TestScript';
            else
                name='TestScript1';
            end

            path=[obj.ProjPath,filesep,'Scripts'];
            cd(path);


            ManeuverPath=convertContainedStringsToChars(obj.Constraints.VehicleScenario.Path);
            ManeuverPathIndex1=find(ManeuverPath=='/',1,'last')-1;
            ManeuverPathIndex2=find(ManeuverPath=='/',2,'last')+1;
            ManeuverBlkName=ManeuverPath(ManeuverPathIndex2:ManeuverPathIndex1);


            DriverTypePath=convertContainedStringsToChars(obj.Constraints.Driver.Path);
            DriverTypePathIndex1=find(DriverTypePath=='/',1,'last')-1;
            DriverTypePathIndex2=find(DriverTypePath=='/',2,'last')+1;
            DriverTypeBlkName=DriverTypePath(DriverTypePathIndex2:DriverTypePathIndex1);


            filename=[pwd,'/',name,'.m'];
            fileID=fopen(filename,'w');
            fprintf(fileID,'mdl = ''%s'';\n',obj.SimModel);

            fprintf(fileID,'open_system(mdl);\n');

            for i=1:length(obj.VehScene.TestPlanArray)
                data=obj.VehScene.getTestPlanData;
                Maneuver=data{i,1};
                ManeuverOption=data{i,2};
                Driver=string(obj.AppConfiguration.Driver.VariantValue{1});
                fprintf(fileID,'\n%%%%\n');
                fprintf(fileID,'\n%%Test %d \n',i);
                fprintf(fileID,'in(%d) = Simulink.SimulationInput(mdl); \n',i);
                fprintf(fileID,'in(%d) = setParamforManeuverAndDriver(''%s'',''%s'', ''%s'', ''%s'',''%d'',in(%d));\n',...
                i,obj.SimModel,Maneuver,ManeuverOption,Driver{1},i,i);
            end

            if length(obj.VehScene.TestPlanArray)==1
                fprintf(fileID,'out = sim(in, ''ShowSimulationManager'', ''on'');\n');
            else
                fprintf(fileID,'out = parsim(in, ''ShowSimulationManager'', ''on'');\n');
            end

            fclose(fileID);

        end

        function setProjPath(obj,path)
            obj.ProjPath=path;
            obj.ModelPath=[obj.ProjPath,filesep,'System'];
        end

        function generateVirtualVehicleModel(obj,type)

            bdclose all;

            if strcmp(type,'New')||isempty(obj.ConfigInfos)
                cd(obj.ModelPath);

                name=obj.SimModel;
                if isfolder(name)
                    delpath=[name,'\*'];
                    delete(delpath);
                else
                    eval(['mkdir ',name]);
                end
                cd(obj.ModelPath);

                obj.ConfigInfos.SimModel=name;

                if isempty(obj.ProjPath)
                    obj.ProjPath=pwd;
                end

                txt='Configuring a new model...';

                fig=obj.FeatureBrowserFigure;
                d=uiprogressdlg(fig,'Title','Please Wait',...
                'Message',txt);
                d.Value=.1;

                obj.saveNewSession();
                obj.setTemplateVariants();
                d.Value=0.5;

                obj.setVirtualVehicleData();

                obj.generateTestScript('New');
                d.Value=.8;

                save_system(obj.SimModel,'SaveDirtyReferencedModels','on');
                d.Value=1;
                close(d);

            else
                txt='Configuring current model...';
                fig=obj.FeatureBrowserFigure;
                d=uiprogressdlg(fig,'Title','Please Wait',...
                'Message',txt);
                d.Value=.1;
                name=obj.ConfigInfos.SimModel;
                CurrentModel=[obj.ModelPath,name];


                cd(obj.ModelPath);
                d.Value=.2;
                if isfolder(CurrentModel)
                    rmdir(CurrentModel,'s');
                end
                mkdir(CurrentModel);

                cd(obj.ModelPath);

                obj.setTemplateVariants();
                d.Value=.5;
                obj.setVirtualVehicleData();
                obj.saveNewSession();
                obj.generateTestScript('Old');
                d.Value=.8;
                save_system(obj.SimModel,'SaveDirtyReferencedModels','on');
                d.Value=1.0;
                close(d);

            end

            curproj=currentProject;
            addFolderIncludingChildFiles(curproj,fullfile(obj.ModelPath,name));
        end

        function manageDataVariants(obj)


            if~strcmp(obj.FeatureVariantSelectedMap('Vehicle Architecture'),'Conventional Vehicle')
                paraname={'Energy Storage'};

                if strcmp(obj.FeatureVariantSelectedMap('Vehicle Architecture'),'Hybrid Electric Vehicle IPS')||strcmp(obj.FeatureVariantSelectedMap('Vehicle Architecture'),'Hybrid Electric Vehicle MM')
                    if~isempty(obj.MotRzResult)&&~obj.MotRzResult.MotorResizedFlag&&~isempty(obj.GtorRzResult)&&~obj.GtorRzResult.GtorResizedFlag
                        paraname{end+1}='Electric Machine (Motor)';
                        paraname{end+1}='Electric Machine (Generator)';

                    elseif~isempty(obj.MotRzResult)&&obj.MotRzResult.MotorResizedFlag
                        paraname{end+1}='Electric Machine (Generator)';
                    elseif~isempty(obj.GtorRzResult)&&obj.GtorRzResult.GtorResizedFlag
                        paraname{end+1}='Electric Machine (Motor)';
                    end
                else
                    if~isempty(obj.MotRzResult)&&~obj.MotRzResult.MotorResizedFlag
                        paraname{end+1}='Electric Machine (Motor)';
                    end

                end
                for k=1:length(paraname)
                    addParaVariants(obj,paraname{k});
                end
            end


            if~strcmp(obj.FeatureVariantSelectedMap('Vehicle Architecture'),'Electric Vehicle 1EM')&&...
                ~strcmp(obj.FeatureVariantSelectedMap('Vehicle Architecture'),'Hybrid Electric Vehicle IPS')&&...
                ~strcmp(obj.FeatureVariantSelectedMap('Vehicle Architecture'),'Hybrid Electric Vehicle MM')

                addParaVariants(obj,'Vehicle Architecture');
            end


            addParaVariants(obj,'Tire Data');
        end

        function addParaVariants(obj,paraname)
            index=find(strcmp(obj.ProductCatalogData.Features,paraname),1);
            fdata=obj.ProductCatalogData.FeatureParameters{index};
            variants=fdata.FeatureVariant;
            var=obj.FeatureVariantSelectedMap(paraname);
            index1=find(strcmp(variants,var),1);
            data=fdata.FeatureParameter{index1};
            for i=1:length(data)
                if isempty(obj.FeatureDataModified)||(~isempty(obj.FeatureDataModified)&&isempty(find(strcmp(obj.FeatureDataModified(:,1),data{i}.VarName),1)))
                    obj.FeatureDataModified{end+1,1}=data{i}.VarName;
                    obj.FeatureDataModified{end,2}=data{i}.Value;
                    obj.FeatureDataModified{end,3}=data{i}.DataSource;
                    obj.FeatureDataModified{end,4}=data{i}.Name;
                    obj.FeatureDataModified{end,5}=var;
                    obj.FeatureDataModified{end,6}=paraname;
                end
            end
        end



        function saveNewSession(obj)
            obj.manageDataVariants();
            path=[obj.ProjPath,filesep,'Scripts'];
            name='ConfigInfo';

            obj.saveSessionData(name);
            obj.ConfigInfos.version=version;
            ConfigInfos=obj.ConfigInfos;
            f=fullfile(path,obj.ConfigInfos.SessionID);
            save(f,'ConfigInfos');
        end


        function ok=openSavedSession(obj)

            obj.isNewSession=false;

            ok=false;

            [file,path]=uigetfile('*.prj');

            if isequal(file,0)||~ischar(path)
                ok=false;
                obj.App.bringToFront();
                return;

            else
                ok=obj.isValidSession(path);

                if ok

                    obj.clearDocs();

                    fig=obj.FeatureBrowserFigure;

                    d=uiprogressdlg(fig,'Title','Please Wait',...
                    'Message','Preparing Vehicle Data...');
                    d.Value=.1;


                    [~]=openProject(path);

                    d.Value=.25;

                    obj.openSessionData();
                    d.Value=.5;


                    obj.openVehSetup();

                    obj.VehSetupDoc.ProjNameText='';
                    obj.VehSetupDoc.ProjFolderText=obj.ConfigInfos.ProjFolderText;
                    obj.VehSetupDoc.ModelNameText=obj.ConfigInfos.ModelNameText;

                    obj.VehSetupDoc.setProjSettings(false);

                    obj.VehSetupDoc.selectVehClass(obj.ConfigInfos.VehClass);
                    obj.VehSetupDoc.selectVehArchitecture(obj.ConfigInfos.VehArch);
                    obj.VehSetupDoc.selectModelLanguage(obj.ConfigInfos.PlantModel);

                    if strcmp(obj.ConfigInfos.PlantModel,'Simulink')
                        obj.VehSetupDoc.selectVehDyn(obj.ConfigInfos.VehDyn);
                    end

                    obj.setVehTreePanel();
                    obj.Initilization();
                    d.Value=.8;
                    obj.setVehScenFigDoc();
                    obj.setDataLogFigDoc();
                    obj.selectVehDataDocFig();

                    close(d);

                end
            end
        end

        function openVehClassFigDoc(obj)

            if isgraphics(obj.VehSetupFigDoc)
                try
                    proj=currentProject;
                    message='Creating a new project closes all open tabs and projects.';
                    answer=questdlg(message,'Create a New Project','Yes','Cancel','Cancel');
                    if strcmp(answer,'Yes')
                        close(proj);
                    else
                        return
                    end
                catch
                    message='Creating a new project closes all open tabs.';
                    answer=questdlg(message,'Create a New Project','Yes','Cancel','Cancel');
                    if strcmp(answer,'Cancel')
                        return
                    end
                end

                close(obj.VehSetupFigDoc);
                obj.VehSetupFigDoc=[];
            end


            obj.clearDocs();


            obj.isNewSession=true;



            obj.FeatureVariantSelectedMap=containers.Map;

            obj.FeatureVariantSelectedMap('Vehicle Architecture')='Conventional Vehicle';
            obj.FeatureVariantSelectedMap('Chassis')='Vehicle Body 3DOF Longitudinal';

            obj.FeatureDataModified=[];
            obj.FeatureTree=[];
            obj.GridLayout_tree=[];
            obj.TestPlanArray=[];
            obj.openVehSetup();

        end

        function VehArctChangedFcn(obj,src,event)
            obj.MotRzResult.MotorResizedFlag=false;
            obj.GtorRzResult.GtorResizedFlag=false;
            obj.EngRzResult.EngineResizedFlag=false;
            obj.FeatureDataModified=[];
            obj.VehArct=event.NewData.Powertrain;
            obj.FeatureVariantSelectedMap('Vehicle Architecture')=obj.VehArct;

            if isgraphics(obj.VehDataFigDoc)
                message='This action changes current vehicle configuration.';
                answer=questdlg(message,'Warning','Yes','Cancel','Cancel');
                switch answer
                case 'Yes'
                    obj.VehArct=event.NewData.Powertrain;
                    obj.FeatureVariantSelectedMap('Vehicle Architecture')=obj.VehArct;
                    obj.ConstrainedFeature.VehicleArchitecture.Value=obj.VehArct;
                    obj.updateOptions('Vehicle Architecture',obj.VehArct);
                    obj.updateFeatureVariantChanged2(obj.VehArct,'Vehicle Architecture');

                    obj.updateOptions('Chassis',obj.VehDynValue);
                    obj.updateFeatureVariantChanged2(obj.VehDynValue,'Chassis');
                    if isempty(obj.FeatureTree.SelectedNodes)
                        obj.nodechangeforupdate('Chassis');
                    else
                        obj.nodechangeforupdate(obj.FeatureTree.SelectedNodes.Text);
                    end
                otherwise
                    obj.VehArct=event.NewData.PreviousPowertrain;
                    obj.FeatureVariantSelectedMap('Vehicle Architecture')=obj.VehArct;
                    obj.VehSetupDoc.selectVehArchitecture(obj.VehArct);
                end
            end
        end


        function PlantModelSetupChangedFcn(obj,src,event)

            if isgraphics(obj.VehDataFigDoc)
                message='Changing model template referes all open tabs.';
                answer=questdlg(message,'Change model template','Yes','Cancel','Cancel');

                switch answer
                case 'Yes'
                    obj.PlantModelType=event.NewData.PlantModel;
                    if event.NewData.VehDyn==1
                        obj.VehDynValue='Vehicle Body 6DOF Longitudinal and Lateral';
                        obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 6DOF Longitudinal and Lateral'};
                    else
                        obj.VehDynValue='Vehicle Body 3DOF Longitudinal';
                        obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 3DOF Longitudinal';'Vehicle Body 1DOF Longitudinal'};
                    end

                    obj.clearDocs();
                    obj.isNewSession=true;


                    obj.FeatureVariantSelectedMap=containers.Map;

                    obj.FeatureVariantSelectedMap('Vehicle Architecture')=obj.VehArct;
                    obj.FeatureVariantSelectedMap('Chassis')=obj.VehDynValue;
                    obj.FeatureDataModified=[];
                    obj.FeatureTree=[];
                    obj.GridLayout_tree=[];
                    obj.TestPlanArray=[];

                    txt='Preparing Vehicle Data...';
                    fig=obj.FeatureBrowserFigure;
                    d=uiprogressdlg(fig,'Title','Please Wait',...
                    'Message',txt);
                    d.Value=.1;

                    obj.setVehTreePanel();
                    obj.Initilization();
                    obj.setVehScenFigDoc();
                    obj.setDataLogFigDoc();
                    d.Value=0.5;
                    obj.SelectedSignals=obj.VehDataLog.SelectedSignals;
                    obj.selectVehDataDocFig();
                    d.Value=1;
                    close(d);
                otherwise
                    obj.VehSetupDoc.selectModelLanguage(obj.PlantModelType);
                    if strcmp(obj.PlantModelType,'Simulink')
                        if strcmp(obj.VehDynValue,'Vehicle Body 6DOF Longitudinal and Lateral')
                            obj.VehSetupDoc.setVehDynVisibility(true);
                        else
                            obj.VehSetupDoc.setVehDynVisibility(false);
                        end
                    end
                end
            else
                obj.PlantModelType=event.NewData.PlantModel;
                if event.NewData.VehDyn==1
                    obj.VehDynValue='Vehicle Body 6DOF Longitudinal and Lateral';
                    obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 6DOF Longitudinal and Lateral'};
                else
                    obj.VehDynValue='Vehicle Body 3DOF Longitudinal';
                    obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 3DOF Longitudinal';'Vehicle Body 1DOF Longitudinal'};
                end
                obj.FeatureVariantSelectedMap('Chassis')=obj.VehDynValue;
            end
        end

        function VehDynSetupFcn(obj,src,event)
            VehDyn=event.NewData.VehDyn;
            if VehDyn==1
                obj.VehDynValue='Vehicle Body 6DOF Longitudinal and Lateral';
                obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 6DOF Longitudinal and Lateral'};
            else
                obj.VehDynValue='Vehicle Body 3DOF Longitudinal';
                obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 3DOF Longitudinal';'Vehicle Body 1DOF Longitudinal'};

                if~isempty(obj.VehScene)&&~isempty(obj.TestPlanArray)
                    data=obj.VehScene.getTestPlanData;
                    if~isempty(data)
                        index=find(~strcmp(data(:,1),'Drive Cycle'));
                        while(~isempty(index))
                            data(index(end),:)=[];
                            obj.VehScene.TestPlanArray(index(end))=[];
                            index=find(~strcmp(data(:,1),'Drive Cycle'));
                        end

                        obj.VehScene.setTestPlanData(data);
                    end
                end

            end
            obj.FeatureVariantSelectedMap('Chassis')=obj.VehDynValue;

            if isgraphics(obj.VehDataFigDoc)
                message='This action will change your existing vehicle data setups.';
                answer=questdlg(message,'Warning','Yes','Cancel','Cancel');
                switch answer
                case 'Yes'

                    VehDyn=event.NewData.VehDyn;
                    if VehDyn==1
                        obj.VehDynValue='Vehicle Body 6DOF Longitudinal and Lateral';
                        obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 6DOF Longitudinal and Lateral'};
                    else
                        obj.VehDynValue='Vehicle Body 3DOF Longitudinal';
                        obj.ConstrainedFeature.Chassis.Options={'Vehicle Body 3DOF Longitudinal';'Vehicle Body 1DOF Longitudinal'};
                    end
                    obj.FeatureVariantSelectedMap('Chassis')=obj.VehDynValue;
                    obj.ConstrainedFeature.Chassis.Value=obj.VehDynValue;
                    obj.updateOptions('Chassis',obj.VehDynValue);
                    obj.updateFeatureVariantChanged2(obj.VehDynValue,'Chassis');
                    if isempty(obj.FeatureTree.SelectedNodes)
                        obj.nodechangeforupdate('Chassis');
                    else
                        obj.nodechangeforupdate(obj.FeatureTree.SelectedNodes.Text);
                    end
                otherwise
                    obj.VehDynValue=event.NewData.PrevVehDyn;
                    obj.FeatureVariantSelectedMap('Chassis')=obj.VehDynValue;
                    if strcmp(obj.VehDynValue,'Vehicle Body 6DOF Longitudinal and Lateral')
                        obj.VehSetupDoc.setVehDynVisibility(true);
                    else
                        obj.VehSetupDoc.setVehDynVisibility(false);
                    end

                end
            end
        end

        function nodechangeforupdate(obj,feature)
            index=find(strcmp(obj.ProductCatalogData.Features,feature),1);
            [~]=obj.setVehDataFigDoc(index);

        end

        function openVehScenFigDoc(obj)

            obj.VehScene=VirtualAssembly.VehSceneDoc(...
            'licStatus',obj.licStatus,...
            'ProductCatalogData',obj.ProductCatalogData,...
            'ConstrainedFeature',obj.ConstrainedFeature,...
            'TestPlanArray',obj.TestPlanArray);

            obj.App.add(obj.VehScene.Doc);
            drawnow();

            obj.VehScenFigDoc=obj.VehScene.FigDoc;
        end

        function setDefaultLayout(obj)

            s=obj.getDefaultLayout();

            if isempty(s)
                return;
            end

            obj.App.Layout=s;
            drawnow();
        end


        function openVehSetup(obj)
            obj.setFeatureTreeVisibility(false);
            if isempty(obj.VehSetupFigDoc)||obj.isNewSession
                obj.VehSetupDoc=VirtualAssembly.VehSetupDoc('HAppContainer',obj);
                obj.VehSetupFigDoc=obj.VehSetupDoc.FigDoc;
                obj.App.add(obj.VehSetupDoc.Doc);

                addlistener(obj.VehSetupDoc,'CreateNewButtClicked',@(src,evnt)CreateNewButtClickedFcn(obj,src,evnt));
                addlistener(obj.VehSetupDoc,'VehDynBoxSetup',@(src,evnt)VehDynSetupFcn(obj,src,evnt));
                addlistener(obj.VehSetupDoc,'VehArctChanged',@(src,evnt)VehArctChangedFcn(obj,src,evnt));
                addlistener(obj.VehSetupDoc,'PlantModelSetup',@(src,evnt)PlantModelSetupChangedFcn(obj,src,evnt));
                drawnow();

            else
                tag=obj.VehSetupFigDoc.Tag;
                obj.App.SelectedChild.tag=tag;
            end
        end

        function setBusyState(obj,~,st)
            if(st)
                obj.App.Busy=true;
            else
                obj.App.Busy=false;
            end
        end

    end

    methods(Access=private)
        function appTag=makeAppTag(obj)
            appTag=obj.AppTag+"_"+matlab.lang.internal.uuid;
        end

        function createApp(obj)

            appOptions.Tag=makeAppTag(obj);
            appOptions.Title='Virtual Vehicle Composer';
            appOptions.Product="autoblks Toolbox";
            appOptions.Scope="Virtual Vehicle";

            obj.App=matlab.ui.container.internal.AppContainer(appOptions);

            obj.App.WindowMaximized=true;


        end

        function addButtons(obj)

            helpBtn=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            helpBtn.ButtonPushedFcn=@(~,~)cbHelp(obj);
            obj.qabHelpBtn=helpBtn;
            obj.App.add(obj.qabHelpBtn);
        end


        function addAppComponents(obj)



            [panel,panelFigure]=addPanelFigure(obj,...
            "Virtual Vehicle",'featuretree','left',0.25,true);
            obj.FeatureBrowserPanel=panel;
            obj.FeatureBrowserFigure=panelFigure;


            obj.addDocumentGroup();
            startdoc=VirtualAssembly.StartDoc(obj.App);

            obj.StartFigDoc=startdoc.FigDoc;

            obj.App.add(startdoc.Doc);
            drawnow();

        end

        function CreateNewButtClickedFcn(obj,src,event)
            obj.VehClass=event.NewData.VehClass;
            obj.PlantModelType=event.NewData.PlantModel;
            if strcmp(obj.VehClass,'PassengerCar')
                obj.PassengerCarSelectedFcn(src,event);
            else
                obj.MotorcycleSelectedFcn(src,event);
            end
        end

        function PassengerCarSelectedFcn(obj,src,event)
            obj.VehClass='PassengerCar';
            obj.ProductCatalogFile=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'PassengerCar.xlsx');

            obj.SimModel=event.NewData.ModelName;
            obj.TemplateModel=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'projectsrc','VirtualVehicle','System','VirtualVehicleTemplate.slx');
            obj.Model='VirtualVehicleTemplate';
            obj.ProjPath=event.NewData.ProjDir;
            notify(obj,'PassengerCarSelected');
        end

        function MotorcycleSelectedFcn(obj,src,event)
            obj.VehClass='Motorcycle';
            obj.ProductCatalogFile=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'Motorcycle.xlsx');
            obj.SimModel='VirtualVehicleConfigRef';
            obj.TemplateModel=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'projectsrc','VirtualVehicle','System','VirtualVehicleTemplate.slx');
            obj.Model='VirtualVehicleTemplate';

            notify(obj,'MotorcycleSelected');
        end


        function[panel,panelFig]=addPanelFigure(obj,title,tag,region,...
            width,isVisible)



            panelOptions.Title=title;
            panelOptions.Tag=tag;
            panelOptions.Region=region;
            panelOptions.PreferredWidth=width;

            panel=matlab.ui.internal.FigurePanel(panelOptions);

            panel.Closable=false;
            panel.Maximizable=false;
            panel.Collapsible=false;
            panel.Opened=isVisible;

            obj.App.add(panel);
            drawnow();

            panelFig=panel.Figure;
            panelFig.AutoResizeChildren='on';

        end


        function addDocumentGroup(obj)

            figDocGrp=matlab.ui.internal.FigureDocumentGroup();
            figDocGrp.Tag=obj.DocGroupTag;
            figDocGrp.Maximizable=false;

            obj.App.add(figDocGrp);
            drawnow();
        end


        function setPanelTreeContents(obj,status)
            if status
                obj.GridLayout_tree=uigridlayout(obj.FeatureBrowserFigure);
                obj.GridLayout_tree.ColumnWidth={'1x'};
                obj.GridLayout_tree.RowHeight={'1x'};
                obj.GridLayout_tree.BackgroundColor=[1,1,1];
                obj.GridLayout_tree.Padding=[0,0,0,0];
                obj.FeatureTree=uitree(obj.GridLayout_tree);
                obj.FeatureTree.SelectionChangedFcn=@(src,event)nodechange(obj,src,event);
                parent=uitreenode(obj.FeatureTree,'Text',obj.VehClass);

                parent.Tag=obj.VehClass;

                for i=1:length(obj.Features)
                    FeatureWithSpace=obj.Features{i};
                    FeatureNoSpace=VirtualAssembly.NameFilter(FeatureWithSpace);
                    if~strcmp(obj.Features{i},'License')&&~strcmp(obj.Features{i},'Vehicle Architecture')
                        if~strcmp(obj.Constraints.(FeatureNoSpace).VariantType,'internal')
                            if findnode(obj.Constraints.ComponentAdjacency,obj.Features{i})~=0
                                InDeg=indegree(obj.Constraints.ComponentAdjacency,obj.Features{i});
                                if InDeg<=0
                                    setHierarchicalTree(obj,parent,obj.Features{i});
                                end
                            else
                                Children=uitreenode(parent,'Text',obj.Features{i});
                                Children.Tag=obj.Features{i};
                                drawnow();
                            end
                        end
                    end
                end
                expand(obj.FeatureTree,'all');
                drawnow();
            end
        end

        function setHierarchicalTree(obj,parent,feature)
            parent=uitreenode(parent,'Text',feature);
            parent.Tag=feature;
            sucIDs=successors(obj.Constraints.ComponentAdjacency,feature);
            if~isempty(sucIDs)
                for i=1:size(sucIDs,1)
                    FeatureWithSpace=sucIDs{i};
                    FeatureNoSpace=VirtualAssembly.NameFilter(FeatureWithSpace);
                    if~strcmp(obj.Constraints.(FeatureNoSpace).VariantType,'internal')
                        setHierarchicalTree(obj,parent,sucIDs{i});
                    end
                end
            end
        end



        function nodechange(obj,src,~)
            if~isempty(src.SelectedNodes)
                if obj.nodechanging
                    obj.nodechanging=false;
                    feature=src.SelectedNodes.Text;
                    index=find(strcmp(obj.ProductCatalogData.Features,feature),1);
                    [~]=obj.setVehDataFigDoc(index);
                    obj.selectVehDataDocFig();
                    obj.nodechanging=true;
                end
            end

        end


        function FTab=setVehDataFigDoc(obj,k)


            FTab=[];

            if isempty(k)
                return;
            end

            fdata=obj.ProductCatalogData.FeatureParameters{k};
            featurename=fdata.Feature;
            FD=fdata.FeatureParameter;


            F=VirtualAssembly.Feature(featurename);
            variants=fdata.FeatureVariant;

            F.FeatureVariants=variants;
            F.FeatureVariantsDes=fdata.Label;
            F.FeatureIcons=fdata.Icon;
            F.FeatureOptionImages=fdata.Image;

            CF=obj.ConstrainedFeature;

            if isempty(obj.ProductCatalogData.FeatureParameters{k}.Image)||isempty(obj.ProductCatalogData.FeatureParameters{k}.Image{1})
                NumofFig=0;
            else
                NumofFig=length(obj.ProductCatalogData.FeatureParameters{k}.Image(1));
            end
            delete(obj.VehDataFigDoc.Children);

            if strcmp(featurename,'Engine')

                FTab=VirtualAssembly.FeatureDoc(...
                'HAppContainer',obj,...
                'Parent',obj.VehDataFigDoc,...
                'FeatureVar',F,...
                'FeatureData',FD,...
                'ConstrainedFeaturesDoc',CF,...
                'NumofFig',NumofFig,...
                'EngRzResult',obj.EngRzResult);
            elseif strcmp(featurename,'Electric Machine (Motor)')
                FTab=VirtualAssembly.FeatureDoc(...
                'HAppContainer',obj,...
                'Parent',obj.VehDataFigDoc,...
                'FeatureVar',F,...
                'FeatureData',FD,...
                'ConstrainedFeaturesDoc',CF,...
                'NumofFig',NumofFig,...
                'MotRzResult',obj.MotRzResult);
            elseif strcmp(featurename,'Electric Machine (Generator)')
                FTab=VirtualAssembly.FeatureDoc(...
                'HAppContainer',obj,...
                'Parent',obj.VehDataFigDoc,...
                'FeatureVar',F,...
                'FeatureData',FD,...
                'ConstrainedFeaturesDoc',CF,...
                'NumofFig',NumofFig,...
                'MotRzResult',obj.GtorRzResult);
            else

                FTab=VirtualAssembly.FeatureDoc(...
                'Parent',obj.VehDataFigDoc,...
                'FeatureVar',F,...
                'FeatureData',FD,...
                'ConstrainedFeaturesDoc',CF,...
                'NumofFig',NumofFig);

            end


            if~isempty(obj.FeatureVariantSelectedMap)&&isKey(obj.FeatureVariantSelectedMap,featurename)
                var=obj.FeatureVariantSelectedMap(featurename);
            else
                var=[];
            end

            FTab.setNewFeatureDoc(var);

            if strcmp(featurename,'Powertrain')
                FTab.enableFeatureDropDown(false);

            end

            if~isempty(obj.FeatureDataModified)
                index=find(strcmp(obj.FeatureDataModified(:,6),featurename));
                for i=1:length(index)
                    FTab.updateFeatureDataByName(obj.FeatureDataModified{index(i),4},obj.FeatureDataModified{index(i),2},obj.FeatureDataModified{index(i),5});
                end
            end


            addlistener(FTab,'FeatureDropDownValueChanged',@(src,evnt)FeatureVariantChangedFcn(obj,src,evnt));


            if~isempty(FD)
                addlistener(FTab,'FeatureDataValueChanged',@(src,evnt)FeatureDataValueChangedFcn(obj,src,evnt));
                addlistener(FTab,'ParameterDefaultBtnPushed',@(src,evnt)ParaDefaultBtnPushedFcn(obj,src,evnt));
            end

        end


        function setTemplateVariants(obj)
            bdclose(obj.SimModel);
            bdclose('VirtualVehicleTemplate.slx');

            eval(['copyfile ','VirtualVehicleTemplate.slx ',obj.SimModel])
            if strcmp(obj.PlantModelType,'Simulink')
                eval(['copyfile ','SimulinkPlantModels.slx ',obj.SimModel]);
            else
                eval(['copyfile ','SimscapePlantModels.slx ',obj.SimModel]);
            end
            eval(['cd ',obj.SimModel]);

            addpath([obj.ModelPath,filesep,obj.SimModel]);

            loadModel=fullfile(obj.ModelPath,obj.SimModel,obj.Model);

            load_system(loadModel);

            AppFeature=fieldnames(obj.AppConfiguration);
            n_AppFeature=length(AppFeature);












            for i=1:n_AppFeature
                if isfield(obj.Constraints,AppFeature{i})
                    if strcmp(obj.Constraints.(AppFeature{i}).VariantType,'mask')
                        if~strcmp(AppFeature{i},'Driver')&&~strcmp(AppFeature{i},'VehicleScenario')
                            for k=1:size(obj.AppConfiguration.(AppFeature{i}).Path,2)
                                BlkPath=convertStringsToChars(extractBetween(obj.AppConfiguration.(AppFeature{i}).Path(k),'{','}'));
                                BlkNameIndex=find(BlkPath=='/',1,'last')+1;
                                BlkName=BlkPath(BlkNameIndex:end);
                                DropdownParam=extractBetween(obj.AppConfiguration.(AppFeature{i}).Path(k),'(',')');
                                DropdownValue=string(obj.AppConfiguration.(AppFeature{i}).VariantValue{1});
                                ButtonParam=extractBetween(obj.AppConfiguration.(AppFeature{i}).Path(k),'[',']');
                                try
                                    load_system(BlkPath);
                                    set_param(BlkPath,DropdownParam,DropdownValue);
                                    if~isempty(ButtonParam)&&~strcmp(obj.FeatureVariantSelectedMap('Tire'),'MF Tires Longitudinal')
                                        [~]=vehdynicon('vehdynlibtire',BlkPath,6);
                                    end
                                    close_system(BlkPath);
                                catch
                                    continue;
                                end
                            end
                        end
                    end
                end
            end






















            ReduceTool=true;
            if ReduceTool
                for i=1:n_AppFeature
                    if isfield(obj.Constraints,AppFeature{i})
                        if~strcmp(obj.Constraints.(AppFeature{i}).VariantType,'mask')
                            if isfield(obj.AppConfiguration.(AppFeature{i}),'Path')
                                if~isempty(obj.AppConfiguration.(AppFeature{i}).Path)
                                    for k=1:size(obj.AppConfiguration.(AppFeature{i}).Path,2)
                                        BlkPath=obj.AppConfiguration.(AppFeature{i}).Path(k);
                                        VariantValue=string(obj.AppConfiguration.(AppFeature{i}).VariantValue{1});
                                        if contains(VariantValue,'(')
                                            ind=strfind(VariantValue,'(');
                                            VariantValue=extractBefore(VariantValue,ind-1);
                                            VariantIndex=contains(obj.Constraints.(AppFeature{i}).Options,VariantValue);
                                        else
                                            VariantIndex=strcmp(obj.Constraints.(AppFeature{i}).Options,VariantValue);
                                        end
                                        VariantLabel=VariantValue;
                                        try
                                            set_param(BlkPath,'OverrideUsingVariant',VariantLabel);
                                            BlockToDelete=obj.Constraints.(AppFeature{i}).Variants;
                                            BlockToDelete(VariantIndex)=[];
                                            if~isempty(BlockToDelete)
                                                for j=1:size(BlockToDelete,2)
                                                    if contains(BlockToDelete(j).BlockName,'(')
                                                        if strcmp(AppFeature{i},'EnergyStorage')
                                                            ind=strfind(BlockToDelete(j).BlockName,'(');
                                                            BlockToDelete(j).BlockName=extractBefore(BlockToDelete(j).BlockName,ind-1);
                                                        end
                                                    end
                                                    delete_block(BlockToDelete(j).BlockName);
                                                end
                                            end
                                        catch
                                            continue;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            ModelInfo.SubSys='VirtualVehicleTemplate/Visualization/DataLogging';
            ModelInfo.BusBlk='Bus Selector';
            VirtualAssembly.sdiLogging(obj.SelectedSignals,ModelInfo);
            Simulink.BlockDiagram.arrangeSystem(ModelInfo.SubSys);
            save_system(obj.Model,'OverwriteIfChangedOnDisk',true,'SaveDirtyReferencedModels',true);
            close_system(obj.Model);

            eval(['copyfile ','VirtualVehicleTemplate.slx ',obj.SimModel,'.slx']);
            if strcmp(obj.PlantModelType,'Simulink')
                eval(['copyfile ','SimulinkPlantModels.slx ','ConfiguredSimulinkPlantModels.slx']);
                delete SimulinkPlantModels.slx;
                delete VirtualVehicleTemplate.slx;
                open_system(obj.SimModel);
                set_param([obj.SimModel,'/Vehicle/Plant Models/Simulink Models'],'ReferencedSubsystem','ConfiguredSimulinkPlantModels');
                set_param([obj.SimModel,'/Vehicle/Plant Models'],'OverrideUsingVariant','SimulinkModels');
                delete_block([obj.SimModel,'/Vehicle/Plant Models/Simscape Models']);
            else
                eval(['copyfile ','SimscapePlantModels.slx ','ConfiguredSimscapePlantModels.slx']);
                delete SimscapePlantModels.slx;
                delete VirtualVehicleTemplate.slx;
                open_system(obj.SimModel);
                set_param([obj.SimModel,'/Vehicle/Plant Models/Simscape Models'],'ReferencedSubsystem','ConfiguredSimscapePlantModels');
                set_param([obj.SimModel,'/Vehicle/Plant Models'],'OverrideUsingVariant','SimscapeModels');
                delete_block([obj.SimModel,'/Vehicle/Plant Models/Simulink Models']);
            end


            configset=getActiveConfigSet(obj.SimModel);
            if strcmp(obj.PlantModelType,'Simscape')
                configset.sourceName='VehicleVariableDae';
            else
                configset.sourceName='VehicleVariable';
            end



            obj.setTestPlanOne();


            save_system(obj.SimModel,'SaveDirtyReferencedModels','on');

        end

        function setVirtualVehicleData(obj)

            DictionaryObj=Simulink.data.dictionary.open('VirtualVehicleTemplate.sldd');
            dDataSectObj=getSection(DictionaryObj,'Design Data');
            if~isempty(obj.FeatureDataModified)
                for i=1:size(obj.FeatureDataModified,1)
                    varObj=getEntry(dDataSectObj,obj.FeatureDataModified{i,1});
                    setValue(varObj,str2num(obj.FeatureDataModified{i,2}));
                end
            end
            saveChanges(DictionaryObj);
        end


        function setTestPlanOne(obj)


            ManeuverType='manType';

            ManeuverMaskPath=[obj.SimModel,'/Reference Generator'];
            DriverTypePath=[obj.SimModel,'/Driver Commands'];
            DriverType='driverType';

            Driver=obj.FeatureVariantSelectedMap('Driver');

            data=obj.VehScene.getTestPlanData;
            Maneuver=data{1,1};
            ManeuverOption=data{1,2};

            set_param(ManeuverMaskPath,'manOverride','off',...
            'defaultPos','User-specified',...
            ManeuverType,Maneuver);

            set_param(DriverTypePath,DriverType,Driver);
            if strcmp(Maneuver,'Drive Cycle')
                set_param(ManeuverMaskPath,'cycleVar',ManeuverOption);

                try
                    cyclename=VirtualAssembly.getcyclename(ManeuverOption);
                    cycle=load(cyclename);
                    simTime=cycle.(cyclename).Time(end);
                catch
                    if strcmp(ManeuverOption,'Wide Open Throttle (WOT)')
                        drivecycleblock=[ManeuverMaskPath,'/Reference Generator/Drive Cycle/Drive Cycle Source'];
                        dt=autoblksgetparam(drivecycleblock,'dt','Output sample period',[1,1],'autoerrDrivecycle',{'gte',0});
                        cycleData=obj.processWOT(drivecycleblock,dt);
                        simTime=length(cycleData);
                    else
                        simTime=0;
                    end
                end

            else
                set_param(ManeuverMaskPath,'engine3D',ManeuverOption);

                switch Maneuver
                case 'Double Lane Change'
                    simTime=25;
                    set_param(ManeuverMaskPath,'SceneDesc','Double lane change');
                case 'Increasing Steer'
                    simTime=60;
                    set_param(ManeuverMaskPath,'SceneDesc','Open surface');
                case 'Swept Sine'
                    simTime=40;
                    set_param(ManeuverMaskPath,'SceneDesc','Open surface');
                case 'Sine with Dwell'
                    simTime=25;
                    set_param(ManeuverMaskPath,'SceneDesc','Open surface');
                case 'Constant Radius'
                    simTime=60;
                    set_param(ManeuverMaskPath,'SceneDesc','Open surface');
                case 'Fishhook'
                    simTime=40;
                    set_param(ManeuverMaskPath,'SceneDesc','Open surface');
                end
            end

            dictionaryObj=Simulink.data.dictionary.open('VirtualVehicleTemplate.sldd');
            dDataSectObj=getSection(dictionaryObj,'Design Data');
            ddObj=getEntry(dDataSectObj,'ScnSimTime');
            setValue(ddObj,simTime);



            maskparamap={'ScnSteerDir','steerDir';...
            'ScnLongVelUnit','xdotUnit';...
            'ScnISLatAccStop','ay_stop';...
            };

            testdata=obj.TestPlanArray{1}.Data;
            if~isempty(testdata)
                for i=1:length(testdata)
                    var=testdata{i};

                    index=find(strcmp(var{1},maskparamap(:,1)),1);

                    if~isempty(index)

                        set_param(ManeuverMaskPath,maskparamap{index,2},var{2});
                    else

                        ddObj=getEntry(dDataSectObj,var{1});


                        newvalue=str2double(var{2});
                        if isnan(newvalue)
                            setValue(ddObj,var{2});

                        else
                            setValue(ddObj,newvalue);

                        end
                    end
                end
            end

            saveChanges(dictionaryObj);
        end


        function cycleData=processWOT(obj,block,dt)


            ParamList={'xdot_woto',[1,1],{};...
            't_wot1',[1,1],{'gt',0;'lt','t_wot2';'lt','t_wotend'};...
            'xdot_wot1',[1,1],{};...
            't_wot2',[1,1],{'gt','t_wot1';'lt','t_wotend'};...
            'xdot_wot2',[1,1],{};...
            't_wotend',[1,1],{'gt','t_wot2';'gt','t_wot1'};...
            };

            wotParams=autoblkscheckparams(block,ParamList);
            wotParams.t_wotend=ceil(wotParams.t_wotend);




            if dt<=0
                dtWOT=0.1;
            else
                dtWOT=dt;
            end
            tvec=0:dtWOT:wotParams.t_wotend;
            xdotvec=interp1([0,wotParams.t_wot1,wotParams.t_wot1+dtWOT,...
            wotParams.t_wot2,wotParams.t_wot2+dtWOT,wotParams.t_wotend],...
            [wotParams.xdot_woto,wotParams.xdot_woto,wotParams.xdot_wot1,...
            wotParams.xdot_wot1,wotParams.xdot_wot2,wotParams.xdot_wot2],tvec,'linear');
            cycleData=[tvec',xdotvec'];

        end






        function result=isDataDictionary(~,filename)
            dd=strsplit(filename,'.');
            if length(dd)>=2&&strcmp(dd{end},'sldd')
                result=true;
            else
                result=false;
            end
        end


        function setVehicleScenarioAndDriverMask(obj)





















            obj.setTestPlanOne();













        end



        function saveSessionData(obj,name)

            obj.SelectedSignals=obj.VehDataLog.SelectedSignals;
            obj.ConfigInfos.SessionID=name;
            obj.ConfigInfos.SimModel=obj.SimModel;
            obj.ConfigInfos.Model=obj.Model;
            obj.ConfigInfos.Features=obj.Features;
            obj.ConfigInfos.FeatureVariantMap=obj.FeatureVariantSelectedMap;
            obj.ConfigInfos.FeatureData=obj.FeatureDataModified;
            obj.TestPlanArray=obj.VehScene.TestPlanArray;
            obj.ConfigInfos.TestPlanArray=obj.TestPlanArray;
            obj.ConfigInfos.SelectedSignals=obj.SelectedSignals;
            obj.ConfigInfos.EngRzResult=obj.EngRzResult;
            obj.ConfigInfos.MotRzResult=obj.MotRzResult;
            obj.ConfigInfos.GtorRzResult=obj.GtorRzResult;
            obj.ConfigInfos.PlantModel=obj.PlantModelType;
            obj.ConfigInfos.ProjFolderText=obj.VehSetupDoc.ProjFolderText;
            obj.ConfigInfos.ModelNameText=obj.VehSetupDoc.ModelNameText;
            obj.ConfigInfos.VehClass=obj.VehSetupDoc.VehClass;
            obj.ConfigInfos.VehArch=obj.VehSetupDoc.VehArch;
            obj.ConfigInfos.VehDyn=obj.VehSetupDoc.VehDyn;

        end

        function writeselections(obj)
            import matlab.internal.project.util.generateFolderGroupNames;

            FolderRoot=[obj.ProjPath,'/Scripts'];

            file=dir(FolderRoot);
            filenames={file.name};
            num=sum(~cellfun(@isempty,strfind(filenames,'VehicleInfo')));
            num=num+1;

            fileID=fopen([FolderRoot,'/VehicleInfo',num2str(num),'.m'],'w');
            fprintf(fileID,'%%%% %s\n\n','This file contains virtual vehicle configuration information.');
            fprintf(fileID,'%30s = %s\n','SessionId',['VehicleInfo',num2str(num)]);
            fprintf(fileID,'%30s = %s\n','Configured Model',obj.VehSetupDoc.ModelNameText);
            fprintf(fileID,'%30s = %s\n','Template Model',obj.Model);
            fprintf(fileID,'%30s = %s\n','Project Folder',obj.VehSetupDoc.ProjFolderText);
            fprintf(fileID,'%30s = %s\n','Project Path',obj.ProjPath);

            fprintf(fileID,'%30s = %s\n','Vehicle Class',obj.VehSetupDoc.VehClass);

            if obj.VehSetupDoc.VehDyn
                fprintf(fileID,'%30s = %s\n','Vehicle Dynamics','Combined Longitudinal and Lateral Vehicle Dynamics');
            else
                fprintf(fileID,'%30s = %s\n','Vehicle Dynamics','Longitudinal Vehicle Dynamics');
            end
            fprintf(fileID,'%30s = %s\n','Plant Model',obj.PlantModelType);


            fprintf(fileID,'%%%% %s\n','Vehicle Configuration');
            for i=1:length(obj.Features)
                try
                    key=obj.Features{i};
                    v=obj.FeatureVariantSelectedMap(key);
                    fprintf(fileID,'%30s = %s\n',key,char(v));
                catch
                    continue;
                end
            end


            fprintf(fileID,'\n%%%% %s\n','Modified Component Parameters');
            if~isempty(obj.FeatureDataModified)
                for i=1:size(obj.FeatureDataModified,1)
                    fprintf(fileID,'\n%30s = %s\n','VariableName',obj.FeatureDataModified{i,1});
                    fprintf(fileID,'%30s = %s\n','Value',num2str(obj.FeatureDataModified{i,2}));
                    fprintf(fileID,'%30s = %s\n','DataSource',obj.FeatureDataModified{i,3});
                    fprintf(fileID,'%30s = %s\n','Parameter',obj.FeatureDataModified{i,4});
                    fprintf(fileID,'%30s = %s\n','VariantName',obj.FeatureDataModified{i,5});
                    fprintf(fileID,'%30s = %s\n','FeatureName',obj.FeatureDataModified{i,6});
                end
            end


            fprintf(fileID,'\n%%%% %s\n','Test Plan');
            if~isempty(obj.TestPlanArray)
                for i=1:length(obj.TestPlanArray)
                    testplan=obj.TestPlanArray{i};
                    fprintf(fileID,'\n%30s = %d\n','Test Plan Number',i);
                    fprintf(fileID,'%30s = %s\n','Test Plan Name',testplan.Name);
                    fprintf(fileID,'%30s = %s\n','Cycle',testplan.Cycle);
                    data=testplan.Data;
                    for j=1:size(data,1)
                        fprintf(fileID,'%30s = %s\n',data{j}{1},char(data{j}{2}));
                    end
                end
            end


            fprintf(fileID,'\n%%%% %s\n','Selected Logging Signals');
            fprintf(fileID,'%s = {\n','Selected Logging Signals');
            for i=1:length(obj.SelectedSignals)
                fprintf(fileID,'%30s,...\n',obj.SelectedSignals{i});
            end

            fprintf(fileID,'};\n');


            fprintf(fileID,'\n%%%% %s\n','Engine Resize Result');
            if~isempty(obj.EngRzResult)&&isfield(obj.EngRzResult,'EngineResizedFlag')&&obj.EngRzResult.EngineResizedFlag
                inputname=fieldnames(obj.EngRzResult.EngRzIn);
                for i=1:length(inputname)
                    val=obj.EngRzResult.EngRzIn.(inputname{i});
                    fprintf(fileID,'%30s = %s\n',['EngRzIn.',inputname{i}],string(val));
                end

                fprintf(fileID,'\n');

                for i=1:size(obj.EngRzResult.EngRzOut,1)
                    val=obj.EngRzResult.EngRzOut{i,4};
                    name=['EngRzOut.',obj.EngRzResult.EngRzOut{i,1}];
                    fprintf(fileID,'%30s = %s\n',name,string(val));
                end
            end


            fprintf(fileID,'\n%%%% %s\n','Motor Resize Result');
            MotorBlockNames={'w_t','T_t','T_eff_bp','efficiency_table'};
            if~isempty(obj.MotRzResult)&&obj.MotRzResult.MotorResizedFlag
                for i=1:length(obj.MotRzResult.BlockParams)
                    fprintf(fileID,'%30s = %s\n',MotorBlockNames{i},obj.MotRzResult.BlockParams{i});
                end
            end


            fprintf(fileID,'\n%%%% %s\n','Generator Resize Result');
            if~isempty(obj.GtorRzResult)&&obj.GtorRzResult.GtorResizedFlag
                for i=1:length(obj.GtorRzResult.BlockParams)
                    fprintf(fileID,'%30s = %s\n',MotorBlockNames{i},obj.GtorRzResult.BlockParams{i});
                end
            end

            fprintf(fileID,'\n%%%% Finish\n');

            fclose(fileID);

        end


        function FeatureVariantChangedFcn(obj,~,event)
            obj.isNewSession=true;
            value=event.NewData.Value;
            featurename=event.NewData.BlockName;
            source=event.NewData.Source;

            obj.FeatureVariantSelectedMap(featurename)=value;
            obj.updateFeatureVariantChanged(value,featurename,source);


            featurenameNoSpace=VirtualAssembly.NameFilter(featurename);
            if isfield(obj.Constraints,featurenameNoSpace)
                if~strcmp(obj.Constraints.(featurenameNoSpace).VariantType,'none')
                    obj.updateOptions(featurename,value);
                end
            end


            if~isempty(obj.FeatureDataModified)
                if strcmp(featurename,'Vehicle Architecture')
                    if~isempty(obj.FeatureDataModified)
                        para={'Electric Machine','Energy Storage','Vehicle Architecture'};
                        for k=1:length(para)
                            index=find(strcmp(obj.FeatureDataModified(:,6),para{k}));
                            if~isempty(index)
                                obj.FeatureDataModified(index,:)=[];
                            end
                        end
                    end
                else
                    index1=find(strcmp(obj.FeatureDataModified(:,6),featurename),1);
                    while(~isempty(index1))
                        if~strcmp(obj.FeatureDataModified(index1(1),5),value)
                            obj.FeatureDataModified(index1,:)=[];
                        end
                        index1=find(strcmp(obj.FeatureDataModified(:,6),featurename),1);
                    end
                end
            end













        end

        function updateFeatureVariantChanged2(obj,value,featurename)

            AppFeature=VirtualAssembly.NameFilter(featurename);
            obj.AppConfiguration.(AppFeature).VariantValue{1}=value;
            obj.AppConfiguration.(AppFeature).VariantValue{2}=find(strcmp(obj.AppConfiguration.(AppFeature).Variants,value));

            obj.ConstrainedFeature.(AppFeature).Value=value;
            obj.FeatureVariantSelectedMap(featurename)=value;

            featurenameNoSpace=VirtualAssembly.NameFilter(featurename);
            if isfield(obj.Constraints,featurenameNoSpace)
                obj.applyConstraints(featurenameNoSpace,featurename,value);
                ActDep=obj.Constraints.(featurenameNoSpace).ActivationDependency;
                obj.updateVehTree(ActDep,value,featurename);
                if~strcmp(obj.Constraints.(featurenameNoSpace).VariantType,'none')
                    obj.updateOptions(featurename,value);
                end
            end

        end


        function updateFeatureVariantChanged(obj,value,featurename,source)

            AppFeature=VirtualAssembly.NameFilter(featurename);
            obj.AppConfiguration.(AppFeature).VariantValue{1}=string(value);
            obj.AppConfiguration.(AppFeature).VariantValue{2}=find(strcmp(obj.AppConfiguration.(AppFeature).Variants,string(value)));

            obj.ConstrainedFeature.(AppFeature).Value=value;
            obj.FeatureVariantSelectedMap(featurename)=value;

            featurenameNoSpace=VirtualAssembly.NameFilter(featurename);
            if isfield(obj.Constraints,featurenameNoSpace)
                obj.applyConstraints(featurenameNoSpace,featurename,value);
                ActDep=obj.Constraints.(featurenameNoSpace).ActivationDependency;
                obj.updateVehTree(ActDep,value,featurename);
            end
            source.update(value);
        end

        function applyConstraints(obj,featurenameNoSpace,featurename,value)
            if isfield(obj.Constraints,featurenameNoSpace)
                if~strcmp(obj.Constraints.(featurenameNoSpace).VariantType,'none')
                    obj.updateOptions(featurename,value);
                end
                sucIDs=successors(obj.Constraints.ConstraintAdjacency,featurename);
                if~isempty(sucIDs)
                    for i=1:size(sucIDs,1)
                        F=sucIDs{i};
                        FNoSpace=VirtualAssembly.NameFilter(F);
                        V=obj.ConstrainedFeature.(FNoSpace).Value;
                        applyConstraints(obj,FNoSpace,F,V)
                    end
                end
            end
        end

        function updateVehTree(obj,ActDep,value,featurename)
            if~strcmp(ActDep,'none')

                ActDep=strsplit(ActDep,', ');
                for i=1:size(ActDep,2)
                    DepComp=ActDep{i};
                    DepCompName=char(extractBetween(DepComp,'[',']'));
                    mode=char(extractBetween(DepComp,'<','>'));
                    DepValues=char(extractBetween(DepComp,'{','}'));
                    AdjList=obj.Constraints.ComponentAdjacency;
                    if strcmp(mode,'exclude')
                        if strcmp(DepValues,value)
                            obj.deleteVehTreeNode(DepCompName);
                        else
                            if~any(strcmp(obj.Features,DepCompName))
                                ParentFeature=predecessors(AdjList,DepCompName);
                                parent=findobj(obj.FeatureTree.Children,'Tag',ParentFeature{1,1});
                                if~isempty(parent)
                                    obj.addVehTreeNode(parent,DepCompName);
                                end
                            end
                        end
                    else
                        if strcmp(DepValues,value)
                            if~any(strcmp(obj.Features,DepCompName))
                                ParentFeature=predecessors(AdjList,DepCompName);
                                if isempty(ParentFeature)
                                    parent=obj.FeatureTree.Children;
                                else
                                    parent=findobj(obj.FeatureTree.Children,'Tag',ParentFeature{1,1});
                                end
                                addednode=uitreenode(parent,'Text',DepCompName);
                                addednode.Tag=DepCompName;

                                obj.Features{end+1}=DepCompName;
                            end

                        else
                            obj.deleteVehTreeNode(DepCompName);
                        end
                    end


                    if findnode(AdjList,featurename)~=0
                        suc=successors(AdjList,featurename);
                        if~isempty(suc)
                            for j=1:size(suc,1)
                                ActDepChild=obj.Constraints.(VirtualAssembly.NameFilter(suc{j})).ActivationDependency;
                                if~strcmp(ActDepChild,'none')
                                    ChildValue=string(obj.AppConfiguration.(VirtualAssembly.NameFilter(suc{j})).VariantValue{1});
                                    obj.updateVehTree(ActDepChild,ChildValue,suc{j});
                                end
                            end
                        end
                    end
                end

                ActDepIndex=[];
                for i=1:size(ActDep,2)
                    DepComp=ActDep{i};
                    DepValues=char(extractBetween(DepComp,'{','}'));
                    if strcmp(DepValues,value)
                        ActDepIndex=[ActDepIndex,i];
                    end
                end
                if~isempty(ActDepIndex)
                    for i=ActDepIndex
                        DepComp=ActDep{i};
                        DepCompName=char(extractBetween(DepComp,'[',']'));
                        mode=char(extractBetween(DepComp,'<','>'));
                        DepValues=char(extractBetween(DepComp,'{','}'));
                        AdjList=obj.Constraints.ComponentAdjacency;
                        if strcmp(mode,'exclude')
                            if contains(DepValues,value)
                                obj.deleteVehTreeNode(DepCompName);
                            else
                                if~any(strcmp(obj.Features,DepCompName))
                                    ParentFeature=predecessors(AdjList,DepCompName);
                                    parent=findobj(obj.FeatureTree.Children,'Tag',ParentFeature{1,1});
                                    obj.addVehTreeNode(parent,DepCompName);
                                end
                            end
                        else
                            if contains(DepValues,value)
                                if~any(strcmp(obj.Features,DepCompName))
                                    ParentFeature=predecessors(AdjList,DepCompName);
                                    parent=findobj(obj.FeatureTree.Children,'Tag',ParentFeature{1,1});
                                    addednode=uitreenode(parent,'Text',DepCompName);
                                    addednode.Tag=DepCompName;

                                    obj.Features{end+1}=DepCompName;
                                end

                            else
                                obj.deleteVehTreeNode(DepCompName);
                            end
                        end


                        if findnode(AdjList,featurename)~=0
                            suc=successors(AdjList,featurename);
                            if~isempty(suc)
                                for j=1:size(suc,1)
                                    ActDepChild=obj.Constraints.(VirtualAssembly.NameFilter(suc{j})).ActivationDependency;
                                    if~strcmp(ActDepChild,'none')
                                        ChildValue=string(obj.AppConfiguration.(VirtualAssembly.NameFilter(suc{j})).VariantValue{1});
                                        obj.updateVehTree(ActDepChild,ChildValue,suc{j});
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        function FilterForConstraintImplementedFcn(obj,~,event)

            value=event.NewData.Value;
            featurename=event.NewData.BlockName;

            featurenameNoSpace=VirtualAssembly.NameFilter(featurename);
            if isfield(obj.Constraints,featurenameNoSpace)
                if~strcmp(obj.Constraints.(featurenameNoSpace).VariantType,'none')
                    obj.updateOptions(featurename,value);
                end
            end

        end

        function updateOptions(obj,featurename,option)
            componentname=VirtualAssembly.NameFilter(featurename);
            FilterConstraints=obj.Constraints;
            AdjList=FilterConstraints.ConstraintAdjacency;
            if findnode(AdjList,featurename)~=0
                OD=outdegree(AdjList,featurename);
                suc=successors(AdjList,featurename);
                component=FilterConstraints.(componentname);
                for i=1:size(suc,1)
                    sucNoSpace{i}=VirtualAssembly.NameFilter(suc{i});
                end
                delsucIndex=[];
                for i=1:size(suc,1)
                    if strcmp(obj.Constraints.(sucNoSpace{i}).VariantType,'none')
                        delsucIndex=[delsucIndex,i];
                    end
                end
                suc(delsucIndex)=[];
                if~isempty(find(ismember(component.Options,option),1))
                    index=ismember(component.Options,option);
                    constraints=component.Constraints{index};
                else
                    error(message('autoblks_reference:autoerrVirtualAssembly:invalidOptionInputs'));
                end
                if OD>0
                    if~isempty(constraints.RequiredComponents)
                        CompCategData=categorical(constraints.RequiredComponents);
                        CompCateg=categories(CompCategData);
                        CompCategCount=countcats(CompCategData);
                        for j=1:size(constraints.RequiredComponents,2)
                            if~isempty(find(ismember(suc,constraints.RequiredComponents{j}),1))


                                if~strcmp(constraints.ReqConflitResolution{j},'none')
                                    exeFlag=obj.exeFlagFun(constraints.ReqConflitResolution{j});
                                    if exeFlag
                                        obj.enableRequiredOption(constraints.RequiredComponents{j},constraints.RequiredOptionIndex(j));
                                    end
                                else
                                    obj.enableRequiredOption(constraints.RequiredComponents{j},constraints.RequiredOptionIndex(j));
                                end

                                if strcmp(featurename,'License')
                                    ReqCom=constraints.RequiredComponents{j};
                                    ReqComWithNoSpace=VirtualAssembly.NameFilter(ReqCom);
                                    obj.ConstrainedFeature.(ReqComWithNoSpace).default.Options=obj.ConstrainedFeature.(ReqComWithNoSpace).Options;
                                end
                                counts=CompCategCount(ismember(CompCateg,constraints.RequiredComponents{j}));
                                if counts==1
                                    suc(find(ismember(suc,constraints.RequiredComponents{j}),1))=[];
                                else
                                    CompCategCount(ismember(CompCateg,constraints.RequiredComponents{j}))=CompCategCount(ismember(CompCateg,constraints.RequiredComponents{j}))-1;
                                end
                            end
                        end
                    end

                    if~isempty(constraints.ExclusiveComponents)
                        for j=1:size(constraints.ExclusiveComponents,2)
                            if~isempty(find(ismember(suc,constraints.ExclusiveComponents{j}),1))


                                if j==find(strcmp(constraints.ExclusiveComponents,constraints.ExclusiveComponents{j}),1,'first')
                                    flag=true;
                                else
                                    flag=false;
                                end
                                if~strcmp(constraints.ExcConflitResolution{j},'none')
                                    exeFlag=obj.exeFlagFun(constraints.ExcConflitResolution{j});
                                    if exeFlag
                                        obj.disableExclusiveOption(constraints.ExclusiveComponents{j},constraints.ExclusiveOptionIndex(j),flag);
                                    end
                                else
                                    obj.disableExclusiveOption(constraints.ExclusiveComponents{j},constraints.ExclusiveOptionIndex(j),flag);
                                end
                                if strcmp(featurename,'License')
                                    ExcCom=constraints.ExclusiveComponents{j};
                                    ExcComWithNoSpace=VirtualAssembly.NameFilter(ExcCom);
                                    obj.ConstrainedFeature.(ExcComWithNoSpace).default.Options=obj.ConstrainedFeature.(ExcComWithNoSpace).Options;
                                end
                                if length(strcmp(constraints.ExclusiveComponents,constraints.ExclusiveComponents{j}))==1
                                    suc(find(ismember(suc,constraints.ExclusiveComponents{j}),1))=[];
                                else
                                    if j==find(strcmp(constraints.ExclusiveComponents,constraints.ExclusiveComponents{j}),1,'last')
                                        suc(find(ismember(suc,constraints.ExclusiveComponents{j}),1))=[];
                                    end
                                end
                            end
                        end
                    end

                    if~isempty(suc)
                        for j=1:size(suc,1)
                            obj.enableDefaultOptions(suc{j});
                        end
                    end
                end


                if~strcmp(component.ConflictDependency,'none')
                    nodes=strsplit(component.ConflictDependency,', ');
                    if~strcmp(featurename,obj.ConflictUpdateComponent)
                        for i=1:length(nodes)
                            obj.ConflictUpdateComponent=featurename;
                            optionvalue=obj.ConstrainedFeature.(VirtualAssembly.NameFilter(nodes{i})).Value;
                            obj.updateOptions(nodes{i},optionvalue);
                            if i==length(nodes)
                                obj.ConflictUpdateComponent=[];
                            end
                        end
                    end
                end

            end

        end

        function enableDefaultOptions(obj,component)
            component=VirtualAssembly.NameFilter(component);
            ComponentWithSpace=obj.ComponentStr(component);
            obj.ConstrainedFeature.(component).Options=obj.ConstrainedFeature.(component).default.Options;
            if obj.isNewSession
                obj.ConstrainedFeature.(component).Value=obj.ConstrainedFeature.(component).Options{1};
                obj.AppConfiguration.(component).VariantValue{1}=obj.ConstrainedFeature.(component).Value;
                obj.AppConfiguration.(component).VariantValue{2}=find(strcmp(obj.AppConfiguration.(component).Variants,obj.ConstrainedFeature.(component).Value));
                obj.FeatureVariantSelectedMap(ComponentWithSpace)=obj.ConstrainedFeature.(component).Value;
            elseif~isempty(obj.FeatureVariantSelectedMap)&&isKey(obj.FeatureVariantSelectedMap,ComponentWithSpace)

                var=obj.FeatureVariantSelectedMap(ComponentWithSpace);
                obj.ConstrainedFeature.(component).Value=var;
                obj.AppConfiguration.(component).VariantValue{1}=string(var);
                obj.AppConfiguration.(component).VariantValue{2}=find(strcmp(obj.AppConfiguration.(component).Variants,string(var)));

            end
            if~strcmp(ComponentWithSpace,'License')
                obj.updateOptions(ComponentWithSpace,obj.ConstrainedFeature.(component).Value);
            end
        end

        function enableRequiredOption(obj,component,option_index)
            component=VirtualAssembly.NameFilter(component);
            constraints=obj.Constraints;
            obj.ConstrainedFeature.(component).Options=constraints.(component).Options(option_index);

            ComponentWithSpace=obj.ComponentStr(component);
            if obj.isNewSession
                obj.ConstrainedFeature.(component).Value=obj.ConstrainedFeature.(component).Options{1};
                obj.FeatureVariantSelectedMap(ComponentWithSpace)=obj.ConstrainedFeature.(component).Value;
            else
                try
                    obj.ConstrainedFeature.(component).Value=obj.FeatureVariantSelectedMap(ComponentWithSpace);
                catch

                    obj.ConstrainedFeature.(component).Value=obj.ConstrainedFeature.(component).Options{1};
                    obj.FeatureVariantSelectedMap(ComponentWithSpace)=obj.ConstrainedFeature.(component).Options{1};

                end
            end
            AppFeature=component;
            obj.AppConfiguration.(AppFeature).VariantValue{1}=obj.ConstrainedFeature.(component).Value;
            obj.AppConfiguration.(AppFeature).VariantValue{2}=find(strcmp(obj.AppConfiguration.(AppFeature).Variants,obj.ConstrainedFeature.(component).Value));
            if~strcmp(ComponentWithSpace,'License')
                obj.updateOptions(component,obj.ConstrainedFeature.(component).Value);
            end
        end

        function disableExclusiveOption(obj,component,option_index,flag)
            component=VirtualAssembly.NameFilter(component);
            constraints=obj.Constraints;
            if flag
                obj.ConstrainedFeature.(component).Options=constraints.(component).Options;
                optiondel_index=[];
                for i=1:numel(obj.ConstrainedFeature.(component).Options)
                    if~any(matches(obj.ConstrainedFeature.(component).Options{i},obj.ConstrainedFeature.(component).default.Options))
                        optiondel_index=[optiondel_index,i];
                    end
                end
                obj.ConstrainedFeature.(component).Options(optiondel_index)=[];
            end
            index_delete=strcmp(obj.ConstrainedFeature.(component).Options,constraints.(component).Options(option_index));
            obj.ConstrainedFeature.(component).Options(index_delete)=[];
            if isempty(find(strcmp(obj.ConstrainedFeature.(component).Options,obj.ConstrainedFeature.(component).Value),1))
                obj.ConstrainedFeature.(component).Value=obj.ConstrainedFeature.(component).Options{1};
            end
            ComponentWithSpace=obj.ComponentStr(component);
            if obj.isNewSession
                obj.FeatureVariantSelectedMap(ComponentWithSpace)=obj.ConstrainedFeature.(component).Value;
            end
            AppFeature=component;
            obj.AppConfiguration.(AppFeature).VariantValue{1}=char(obj.ConstrainedFeature.(component).Value);
            obj.AppConfiguration.(AppFeature).VariantValue{2}=find(strcmp(obj.AppConfiguration.(AppFeature).Variants,obj.ConstrainedFeature.(component).Value));
            if~strcmp(ComponentWithSpace,'License')
                obj.updateOptions(component,obj.ConstrainedFeature.(component).Value);
            end
        end

        function exeFlag=exeFlagFun(obj,ConflitResolution)
            ResComponent=char(extractBetween(ConflitResolution,'[',']'));
            ResMode=char(extractBetween(ConflitResolution,'<','>'));
            ResValue=char(extractBetween(ConflitResolution,'{','}'));
            if strcmp(ResMode,'require')
                if strcmp(obj.ConstrainedFeature.(VirtualAssembly.NameFilter(ResComponent)).Value,ResValue)
                    exeFlag=true;
                else
                    exeFlag=false;
                end
            else
                if~strcmp(obj.ConstrainedFeature.(VirtualAssembly.NameFilter(ResComponent)).Value,ResValue)
                    exeFlag=true;
                else
                    exeFlag=false;
                end
            end
        end

        function ComponentNameStr=ComponentStr(obj,component)
            ComponentNameStr=obj.ConstrainedFeature.(component).Name;
        end

        function addVehTreeNode(obj,parent,DepCompName)
            if~strcmp(obj.Constraints.(VirtualAssembly.NameFilter(DepCompName)).VariantType,'internal')
                addednode=uitreenode(parent,'Text',DepCompName);
                addednode.Tag=DepCompName;

                obj.Features{end+1}=DepCompName;
                if findnode(obj.Constraints.ComponentAdjacency,DepCompName)~=0
                    suc=successors(obj.Constraints.ComponentAdjacency,DepCompName);
                    if~isempty(suc)
                        for i=1:size(suc,1)
                            obj.addVehTreeNode(addednode,suc{i});
                        end
                    end
                end
            end
        end

        function deleteVehTreeNode(obj,featurename)
            tree=obj.FeatureTree.Children.Children;
            treenode=findobj(tree,'Tag',featurename);
            if~isempty(treenode)
                delete(treenode);
            end
            index=find(strcmp(obj.Features,featurename));
            if~isempty(index)
                obj.Features(index)=[];
            end
            AdjList=obj.Constraints.ComponentAdjacency;
            if findnode(AdjList,featurename)~=0
                suc=successors(AdjList,featurename);
                if~isempty(suc)
                    for i=1:size(suc,1)
                        indexchild=find(strcmp(obj.Features,suc{i}));
                        if~isempty(indexchild)
                            obj.Features(indexchild)=[];
                        end
                    end
                end
            end
            drawnow();
        end


        function name=generateFileName(obj,type)
            if strcmp(type,'VirtualVehicleConfigRef')
                file=[obj.ProjPath,filesep,'VirtualVehicle',filesep,'System'];
            else
                file=dir(obj.ProjPath);
            end
            filenames={file.name};
            num=sum(contains(filenames,type));
            name=[type,num2str(num+1)];
        end


        function openSessionData(obj)
            obj.SimModel=obj.ConfigInfos.SimModel;
            obj.Model=obj.ConfigInfos.Model;
            obj.FeatureVariantSelectedMap=obj.ConfigInfos.FeatureVariantMap;
            obj.FeatureDataModified=obj.ConfigInfos.FeatureData;
            obj.TestPlanArray=obj.ConfigInfos.TestPlanArray;
            obj.SelectedSignals=obj.ConfigInfos.SelectedSignals;
            obj.EngRzResult=obj.ConfigInfos.EngRzResult;
            obj.MotRzResult=obj.ConfigInfos.MotRzResult;
            obj.GtorRzResult=obj.ConfigInfos.GtorRzResult;
            obj.PlantModelType=obj.ConfigInfos.PlantModel;
            obj.VehClass=obj.ConfigInfos.VehClass;
            obj.VehArct=obj.ConfigInfos.VehArch;
        end

        function FeatureDataValueChangedFcn(obj,~,event)

            if~isempty(obj.FeatureDataModified)
                index=find(strcmp(obj.FeatureDataModified(:,1),event.NewData.VariableName),1);
            else
                index=[];
            end

            if isempty(index)
                obj.FeatureDataModified{end+1,1}=event.NewData.VariableName;
                obj.FeatureDataModified{end,2}=event.NewData.Value;
                obj.FeatureDataModified{end,3}=event.NewData.Source;
                obj.FeatureDataModified{end,4}=event.NewData.Parameter;
                obj.FeatureDataModified{end,5}=event.NewData.VariantName;
                obj.FeatureDataModified{end,6}=event.NewData.FeatureName;
            else
                obj.FeatureDataModified{index,1}=event.NewData.VariableName;
                obj.FeatureDataModified{index,2}=event.NewData.Value;
                obj.FeatureDataModified{index,3}=event.NewData.Source;
                obj.FeatureDataModified{index,4}=event.NewData.Parameter;
                obj.FeatureDataModified{index,5}=event.NewData.VariantName;
                obj.FeatureDataModified{index,6}=event.NewData.FeatureName;
            end

        end

        function ParaDefaultBtnPushedFcn(obj,~,event)
            if~isempty(obj.FeatureDataModified)
                para=event.NewData.BlockName;
                index=find(strcmp(obj.FeatureDataModified(:,6),para));
                if~isempty(index)
                    obj.FeatureDataModified(index,:)=[];
                end
            end
        end


        function Out=isValidSession(obj,path)
            Out=false;
            newdir=[path,'Scripts'];
            configfile=[newdir,filesep,'ConfigInfo.mat'];

            try
                SessionData=load(configfile);
                obj.ConfigInfos=SessionData.ConfigInfos;

                obj.isNewSession=false;
                obj.ProjPath=path;
                obj.ModelPath=[path,'System'];
                Out=true;
            catch
                obj.App.bringToFront();
                errordlg('Cannot find the Configuration mat file.','Open Errors','modal');
            end
        end

        function handleAppPropertyChange(obj,data)
            if strcmp(data.PropertyName,'SelectedChild')
                if~isempty(obj.App.SelectedChild)&&strcmp(obj.App.SelectedChild.title,'Data and Calibration')
                    if~isempty(obj.FeatureTree)
                        obj.setFeatureTreeVisibility(true);
                        expand(obj.FeatureTree,'all');
                    end
                elseif strcmp(obj.App.SelectedChild.title,'Setup')||strcmp(obj.App.SelectedChild.title,'Scenario and Test')||strcmp(obj.App.SelectedChild.title,'Logging')
                    obj.setFeatureTreeVisibility(false);
                    if strcmp(obj.App.SelectedChild.title,'Scenario and Test')
                        obj.VehScene.setScenarioDropDownItems(obj.ConstrainedFeature.VehicleScenario.Options);
                    end

                end
            end
        end

        function cbHelp(obj)


            helpdir=docroot;
            if~isempty(helpdir)

                switch obj.licStatus
                case 'vdbs'
                    mapfile=fullfile(helpdir,'autoblks','helptargets.map');
                case 'ptbs'
                    mapfile=fullfile(helpdir,'vdynblks','helptargets.map');
                case 'vdbs and ptbs'
                    mapfile=fullfile(helpdir,'autoblks','helptargets.map');
                otherwise
                    mapfile='';
                end
            end


            try
                helpview(mapfile,'virtualvehiclecomposer');
            catch
                fprintf('Help is currently not avaliable for this topic.\n');
            end
        end


        function s=getDefaultLayout(obj)

            if strcmp(obj.App.SelectedChild.title,'Start')
                layoutFileName='VVCDefStartLayout.json';
            else
                layoutFileName='VVCDefLayout.json';
            end


            layoutJSON=fileread(fullfile(matlabroot,'toolbox',...
            'autoblks','autoblksreference',layoutFileName));

            s=jsondecode(layoutJSON);

        end

        function clearDocs(obj)
            if isgraphics(obj.StartFigDoc)
                close(obj.StartFigDoc);
                obj.StartFigDoc=[];
            end

            if isgraphics(obj.VehDataFigDoc)
                close(obj.VehDataFigDoc);
                obj.VehDataFigDoc=[];
            end

            if isgraphics(obj.VehScenFigDoc)
                close(obj.VehScenFigDoc);
                obj.VehScenFigDoc=[];
            end

            if isgraphics(obj.DataLogFigDoc)
                close(obj.DataLogFigDoc);
                obj.DataLogFigDoc=[];
            end

        end

    end
end

