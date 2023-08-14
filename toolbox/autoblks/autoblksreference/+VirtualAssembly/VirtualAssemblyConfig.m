classdef VirtualAssemblyConfig<matlab.mixin.SetGet&matlab.mixin.Heterogeneous



    properties

        Name=''

        ProductCatalog=''

        ConfigInfos=''


        ProjPath=''
    end

    properties(Access=private)

        ProductCatalogFile=''

        TemplateModel='VirtualVehicleTemplate';

        SimModel='VirtualVehicleConfigRef';

        TestScenarioBlks=[];

        ScenarioItems={
        'DoubleLaneChange',...
        'IncreasingSteer',...
        'SweptSine',...
        'SinewithDwell',...
        'ConstantRadius',...
        'Fishhook',...
        'DriveCycle',...
        };

        DriveCycleItems={'FTP75','FTP72','US06','SC03',...
        'HWFET','NYCC','HUDDS','LA92','LA92Short','IM240','UDDS','WLTP Class1','WLTP Class2','WLTP Class3',...
        'ECE R15(single cycle)',...
        'ECE R15(four cycles)',...
        'EUDC',...
        'ECE Extra-Urban Driving Cycle (Low Powered Vehicles)','NEDC','ADAC BAB 130','Artemis Urban','Artemis Rural Road','Artemis Motorway 130 kmph','Artemis Motorway 150 kmph',...
        'JC08','JC08 Hot','Japanese 10 Mode','Japanese 15 Mode','Japanese 10-15 Mode','World Harmonized Vehicle Cycle','Braunschweig City Driving Cycle','Central Business District(CBD) Cycle','Business Arterial Commuter(BAC)-Arterial Cycle','Business Arterial Commuter(BAC)-Commuter Cycle',...
        'CSC','NRTC','NYComp','NYBus','ManBus','HHDDTCreep','HHDDTTrans',...
        'HHDDTCruise','OCBus','WVU5Peak','RTS95','ETCFIGE4','JE05','CUEDCP','CUEDCPS','CUEDCMC',...
        'CUEDCNA','CUEDCNB','CUEDCME','CUEDCNC','CUEDCNCH','Wide Open Throttle(WOT)','Workspace Variable',',mat,.xls,.xlsx or .txt file'};

        ProductCatalogData=[];
    end

    methods
        function obj=VirtualAssemblyConfig(varargin)
            if~isempty(varargin)
                if ischar(varargin{1})

                    varargin=[{'Name'},varargin];
                end
                set(obj,varargin{:});
            end

            if isempty(obj.ProjPath)
                obj.ProjPath=pwd;
            end

            if isempty(obj.Name)


                obj.Name='PassengerCar';

            end
            obj.ProductCatalogFile=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            [obj.Name,'.xlsx']);
            obj.ProductCatalogData=VirtualAssembly.ProductCatalogReader(obj.ProductCatalogFile);
            features=obj.ProductCatalogData.getFeatures();

            if isempty(obj.ConfigInfos)
                filename=obj.generateConfigFileName();
                obj.ConfigInfos=VirtualAssembly.ConfigResult(filename,...
                'Features',features);
            end
        end

    end

    methods
        function generateVirtualVehicleModel(obj)

            obj.saveSession();

            newmodel=fullfile(obj.ProjPath,[obj.SimModel,'.slx']);
            if isempty(obj.ConfigInfos.TestPlan)
                obj.ConfigInfos.TestPlan={1,'DriveCycle','FTP75'};
            end


            obj.setTemplateVariants();




            if length(obj.TestScenarioBlks)>1
                testplan=obj.TestScenarioBlks(2:end);
            else
                testplan=[];
            end


            coudntDelete=VirtualAssembly.removeInactiveVariants('VirtualVehicleTemplate',newmodel,testplan);
            obj.setVirtualVehicleData();
        end

        function selectFeatureVariant(obj,pairs)
            if isempty(obj.ConfigInfos.FeatureVariantMap)
                obj.ConfigInfos.FeatureVariantMap=containers.Map;
            end

            for i=1:floor(length(pairs)/2)
                obj.ConfigInfos.FeatureVariantMap(pairs{i*2-1})=pairs{i*2};
            end
        end

        function selectTestScenario(obj,pairs)
            for i=1:floor(length(pairs)/2)
                if isempty(obj.ConfigInfos.TestPlan)&&i==1
                    obj.ConfigInfos.TestPlan={1,pairs{1,:}};
                else
                    index=size(obj.ConfigInfos.TestPlan,1);
                    obj.ConfigInfos.TestPlan(index+1,:)={index+1,pairs{i,:}};
                end

                value=pairs{i,1};


                if isempty(obj.TestScenarioBlks)

                    obj.TestScenarioBlks={value};
                elseif~any(strcmp(obj.TestScenarioBlks,value))
                    tt=length(obj.TestScenarioBlks);
                    obj.TestScenarioBlks{tt+1}=value;
                end

                value1=pairs{i,2};
                if strcmp(value1,'Enable')
                    tt=length(obj.TestScenarioBlks);
                    obj.TestScenarioBlks{tt+1}=value1;
                end
            end
        end

        function modifyFeatureData(obj,pairs)
            for i=1:floor(length(pairs)/6)
                if isempty(obj.ConfigInfos.FeatureData)&&i==1
                    obj.ConfigInfos.FeatureData={1,pairs{1,:}};
                else
                    index=size(obj.ConfigInfos.FeatureData,1);
                    obj.ConfigInfos.FeatureData(index+1,:)={index+1,pairs{i,:}};
                end
            end
        end

        function modifyVehicleScenarioData(obj,pairs)
            for i=1:floor(length(pairs)/4)
                if isempty(obj.ConfigInfos.VehicleScenarioData)&&i==1
                    obj.ConfigInfos.VehicleScenarioData={1,pairs{1,:}};
                else
                    index=size(obj.ConfigInfos.VehicleScenarioData,1);
                    obj.ConfigInfos.VehicleScenarioData(index+1,:)={index+1,pairs{i,:}};
                end
            end
        end



        function generateTestScript(obj)
            filename=[obj.ProjPath,'/TestforVirtualVehicleConfigRef.m'];
            fileID=fopen(filename,'w');
            fprintf(fileID,'mdl = ''%s'';\n','VirtualVehicleConfigRef');
            fprintf(fileID,'open_system(mdl);\n');
            fprintf(fileID,'block = [mdl ''/VehicleSenario''];\n');
            fprintf(fileID,'mdlWks = get_param(mdl,''ModelWorkspace'');\n');
            fprintf(fileID,'in = Simulink.SimulationInput(mdl);\n');
            fclose(fileID);

            for i=1:size(obj.ConfigInfos.TestPlan,1)
                if strcmp(obj.ConfigInfos.TestPlan{i,2},'DriveCycle')
                    obj.testscriptfordrivecycle(filename,i,obj.ConfigInfos.TestPlan{i,3});
                else
                    obj.testscriptforothers(filename,i,obj.ConfigInfos.TestPlan{i,2},obj.ConfigInfos.TestPlan{i,3});
                end
            end
        end

        function setConfigModelName(obj,type)
            obj.SimModel=['VirtualVehicleConfigRef',type];
        end

    end

    methods(Access=private)

        function name=generateConfigFileName(obj)
            file=dir(obj.ProjPath);
            filenames={file.name};
            num=sum(contains(filenames,'ConfigInfo'));
            name=['ConfigInfo',num2str(num+1)];
        end

        function saveSession(obj)
            Data=obj.ConfigInfos;
            f=fullfile(obj.ProjPath,obj.ConfigInfos.SessionID);
            save(f,'Data');
        end


        function setTemplateVariants(obj)


            if~isempty(obj.ConfigInfos.TestPlan)
                ScenarioIndex=find(strcmp(obj.ScenarioItems,obj.ConfigInfos.TestPlan{1,2}));
                DriveCycleIndex=find(strcmp(obj.DriveCycleItems,obj.ConfigInfos.TestPlan{1,3}));
                obj.setVehicleScenarioVariants(ScenarioIndex,DriveCycleIndex);
            end
        end


        function setVehicleScenarioVariants(obj,ScenarioIndex,DriveCycleIndex)
            load_system(obj.TemplateModel);
            mdlWks=get_param(obj.TemplateModel,'ModelWorkspace');
            mdlWks.assignin('VehScenarioType',ScenarioIndex-1);


            if~isempty(DriveCycleIndex)
                mdlWks.assignin('EnableEngine3D',DriveCycleIndex-1)
            end
        end

        function setVirtualVehicleData(obj)

            if~isempty(obj.ConfigInfos.FeatureData)
                for i=1:size(obj.ConfigInfos.FeatureData,1)
                    isDD=obj.isDataDictionary(obj.ConfigInfos.FeatureData{i,3});

                    if isDD
                        DictionaryObj=Simulink.data.dictionary.open(obj.ConfigInfos.FeatureData{i,3});
                        dDataSectObj=getSection(DictionaryObj,'Design Data');
                        var=obj.findstructname(obj.ConfigInfos.FeatureData{i,1});
                        if isempty(var)
                            varObj=getEntry(dDataSectObj,obj.ConfigInfos.FeatureData{i,1});
                            setValue(varObj,str2double(obj.ConfigInfos.FeatureData{i,2}));
                        else
                            varObj=getEntry(dDataSectObj,var{1});
                            temp=getValue(varObj);
                            temp.(var{2})=str2double(obj.ConfigInfos.FeatureData{i,2});
                            setValue(varObj,temp);
                        end

                    else
                        tf=slreportgen.utils.isModelLoaded(obj.ConfigInfos.FeatureData{i,3});
                        if~tf
                            load_system(obj.ConfigInfos.FeatureData{i,3});
                        end
                        mdlWks=get_param(obj.ConfigInfos.FeatureData{i,3},'ModelWorkspace');
                        mdlWks.assignin(obj.ConfigInfos.FeatureData{i,1},str2double(obj.ConfigInfos.FeatureData{i,2}));
                    end
                end
            end
        end



        function testscriptfordrivecycle(~,filename,num,DriveCycle)
            fileID=fopen(filename,'a');
            fprintf(fileID,'\n%%Test %d \n',num);
            fprintf(fileID,'assignin(mdlWks,''VehScenarioType'',6); \n');
            fprintf(fileID,'DriveCycle=''%s'';\n',DriveCycle);
            fprintf(fileID,'block=[mdl ''/VehicleSenario/Reference Generator/DriveCycle/Drive Cycle Source''];\n');
            fprintf(fileID,'set_param(block, ''cycleVar'', DriveCycle);\n');
            fprintf(fileID,'time=get_param(block,''tfinal'');\n');
            fprintf(fileID,'stoptime=strsplit(time,'' '');\n');
            fprintf(fileID,'set_param(mdl,''StopTime'',stoptime{1});\n');
            fprintf(fileID,'output%d = sim(in);\n',num);
            fclose(fileID);
        end


        function testscriptforothers(~,filename,num,Scenario,enable)
            switch Scenario
            case 'Double Lane Change'
                index=0;
            case 'Increasing Steer'
                index=1;
            case 'Swept Sine'
                index=2;
            case 'Sine with Dwell'
                index=3;
            case 'Constant Radius'
                index=4;
            case 'Fishhook'
                index=5;
            otherwise
                index=0;
            end

            if strcmp(enable,'Enable')
                index1=1;
            else
                index1=0;
            end

            fileID=fopen(filename,'a');
            fprintf(fileID,'\n%%Test %d \n',num);
            fprintf(fileID,'assignin(mdlWks,''VehScenarioType'',%d); \n',index);
            fprintf(fileID,'assignin(mdlWks,''EnableEngine3D'',%d);\n',index1);
            fprintf(fileID,'output%d =sim(in);\n',num);
            fclose(fileID);
        end
    end
end