classdef VehSceneDoc<matlab.mixin.SetGet&matlab.mixin.Heterogeneous





    properties

Doc

        FigDoc matlab.ui.Figure

ProductCatalogData

licStatus

ConstrainedFeature

ScenParaChgs

TestPlanArray
    end

    properties(SetAccess=private)
Sim3dDropDownItems
Sim3dDropDownLabel

        DriveCycleDropDown matlab.ui.control.DropDown
        ScenarioDropDown matlab.ui.control.DropDown
        VehScenTestPlanTable matlab.ui.control.Table
        VehScenLabel matlab.ui.control.Label
        VehScenParaUITable matlab.ui.control.Table
        AddtoTestListButton matlab.ui.control.Button
        DriveCycleDropDownLabel matlab.ui.control.Label
        ScenarioDropDownLabel matlab.ui.control.Label
GridLayout1
GridLayout2
GridLayout3
TestPlanLyt
GridLayoutLabel
DeleteBtn
TestListLabel
GridLayoutScenPara
    end

    properties(Constant)


        DriveCycleItems={

        getString(message('autoblks_shared:autoblkDriveCycleNames:FTP72'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:FTP75'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:US06'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:SC03'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HWFET'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:NYCC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HUDDS'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:LA92'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:LA92Short'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:IM240'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:UDDS'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:WLTP1'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:WLTP2'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:WLTP3'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ECE1'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ECE4'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:EUDC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ECExtra'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:NEDC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ADAC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ArtemisU'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ArtemisR'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Artemis130'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Artemis150'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:JC08'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:JC08Hot'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Japanese10'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Japanese15'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Japanese1015'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:World'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Braunschweig'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Central'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:BusinessA'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:BusinessC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:City'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Neighborhood'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:NewY'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:NewYbus'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Manhattan'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HeavyCreep'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HeavyTrans'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HeavyCruise'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Orange'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:West'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:RTS'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ETC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:JE05'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCp'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCspc'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdMC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdNA'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdNB'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:dME'))
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdNC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdNCH'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Wide'));...


        };


    end

    methods

        function obj=VehSceneDoc(varargin)
            if~isempty(varargin)
                set(obj,varargin{:});
            end

            [doc,fig]=addDocumentFigures(obj,'Scenario and Test');
            obj.Doc=doc;
            obj.FigDoc=fig;

            if strcmp(obj.licStatus,'ptbs')
                obj.Sim3dDropDownItems=obj.DriveCycleItems;
                obj.Sim3dDropDownLabel='Drive cycle:';
            else
                obj.Sim3dDropDownItems={'Disabled','Enabled'};
                obj.Sim3dDropDownLabel='3D Simulation:';
            end

            obj.setupDocLyt();

        end

    end

    methods

        function setScenarioDropDownItems(obj,items)
            obj.ScenarioDropDown.Items=items;
            obj.ScenarioDropDown.Value=obj.ScenarioDropDown.Items{1};
            obj.ScenarioDropDownValueChanged();
        end

        function setScenarioDropDown(obj,value)
            index=find(strcmp(obj.ScenarioDropDown.Items,value),1);
            if isempty(index)
                obj.ScenarioDropDown.Value=obj.ScenarioDropDown.Items{1};
            else
                obj.ScenarioDropDown.Value=value;
            end
            obj.ScenarioDropDownValueChanged();
        end

        function setDriveCycleDropDownItems(obj,items)
            obj.DriveCycleDropDown.Items=items;
            obj.DriveCycleDropDown.Value=obj.DriveCycleDropDown.Items{1};

        end

        function setDriveCycleDropDown(obj,value)
            index=find(strcmp(obj.DriveCycleDropDown.Items,value),1);
            if isempty(index)
                obj.DriveCycleDropDown.Value=obj.DriveCycleDropDown.Items{1};
            else
                obj.DriveCycleDropDown.Value=value;
            end
        end

        function data=getTestPlanData(obj)
            if isgraphics(obj.VehScenTestPlanTable)&&~isempty(obj.VehScenTestPlanTable)
                data=obj.VehScenTestPlanTable.Data;
            else
                data=[];
            end
        end

        function setTestPlanData(obj,data)
            if~isempty(obj.VehScenTestPlanTable)
                obj.VehScenTestPlanTable.Data=data;
                obj.VehScenParaUITable.Data=[];
            end
        end

        function setDriveCycleDropDownLabel(obj,text)
            obj.DriveCycleDropDownLabel.Text=text;
        end

        function ScenarioDropDownValueChanged(obj)
            value=obj.ScenarioDropDown.Value;
            if strcmp(value,'Drive Cycle')
                obj.DriveCycleDropDownLabel.Text='Drive cycle:';
                obj.DriveCycleDropDown.Items=obj.DriveCycleItems;
            else
                obj.DriveCycleDropDownLabel.Text='3D Simulation:';
                obj.DriveCycleDropDown.Items=obj.Sim3dDropDownItems;
            end
            obj.ScenParaChgs=[];
        end

        function DriveCycleDropDownValueChanged(obj)
            if strcmp(obj.ScenarioDropDown.Value,'Drive Cycle')
                obj.ScenParaChgs=[];
            end

        end

        function updateScenData(obj)
            value=obj.ScenarioDropDown.Value;
            fdata_index=contains(obj.ProductCatalogData.Features,'Vehicle Scenario');
            fdata=obj.ProductCatalogData.FeatureParameters{fdata_index};
            index=find(strcmp(fdata.FeatureVariant,value));
            dataout=fdata.tocelldata(index);
            obj.VehScenParaUITable.Data=dataout(:,1:4);
        end

    end

    methods(Access=private)

        function setupDocLyt(obj)


            obj.GridLayout1=uigridlayout(obj.FigDoc);
            obj.GridLayout1.ColumnWidth={'1x'};
            obj.GridLayout1.RowHeight={'0.1x','1x','1x'};
            obj.GridLayout1.Padding=[10,10,10,10];
            obj.GridLayout1.BackgroundColor=[1,1,1];


            obj.GridLayout2=uigridlayout(obj.GridLayout1);
            obj.GridLayout2.RowHeight={'fit'};
            obj.GridLayout2.ColumnWidth={'0.3x','1x','0.1x','0.5x','1x','0.1x','1x'};
            obj.GridLayout2.Padding=[0,0,0,0];
            obj.GridLayout2.Layout.Row=1;
            obj.GridLayout2.Layout.Column=1;
            obj.GridLayout2.BackgroundColor=[1,1,1];


            obj.ScenarioDropDownLabel=uilabel(obj.GridLayout2);
            obj.ScenarioDropDownLabel.Layout.Row=1;
            obj.ScenarioDropDownLabel.Layout.Column=1;
            obj.ScenarioDropDownLabel.Text='Scenario:';
            obj.ScenarioDropDownLabel.FontWeight='bold';


            obj.ScenarioDropDown=uidropdown(obj.GridLayout2);
            obj.ScenarioDropDown.Items=obj.ConstrainedFeature.VehicleScenario.Options;
            obj.ScenarioDropDown.ValueChangedFcn=@(~,event)ScenarioDropDownValueChanged(obj);
            obj.ScenarioDropDown.BackgroundColor=[1,1,1];
            obj.ScenarioDropDown.Layout.Row=1;
            obj.ScenarioDropDown.Layout.Column=2;
            obj.ScenarioDropDown.Value=obj.ScenarioDropDown.Items{1};
            obj.ScenarioDropDown.Tag='ScenarioDropDown';


            obj.DriveCycleDropDownLabel=uilabel(obj.GridLayout2);
            obj.DriveCycleDropDownLabel.Layout.Row=1;
            obj.DriveCycleDropDownLabel.Layout.Column=4;
            obj.DriveCycleDropDownLabel.Text='Drive Cycle:';
            obj.DriveCycleDropDownLabel.FontWeight='bold';


            obj.DriveCycleDropDown=uidropdown(obj.GridLayout2);
            obj.DriveCycleDropDown.Items=obj.DriveCycleItems;
            obj.DriveCycleDropDown.BackgroundColor=[1,1,1];
            obj.DriveCycleDropDown.Layout.Row=1;
            obj.DriveCycleDropDown.Layout.Column=5;
            obj.DriveCycleDropDown.Value=obj.DriveCycleDropDown.Items{1};
            obj.DriveCycleDropDown.ValueChangedFcn=@(~,~)DriveCycleDropDownValueChanged(obj);
            obj.DriveCycleDropDown.Tag='DriveCycleDropDown';


            obj.AddtoTestListButton=uibutton(obj.GridLayout2,'push');
            obj.AddtoTestListButton.ButtonPushedFcn=@(~,~)AddtoTestListButtonPushed(obj);
            obj.AddtoTestListButton.Layout.Row=1;
            obj.AddtoTestListButton.Layout.Column=7;
            obj.AddtoTestListButton.Text='Add to Test Plans';
            obj.AddtoTestListButton.Tag='AddtoTestListButton';


            obj.GridLayout3=uigridlayout(obj.GridLayout1);
            obj.GridLayout3.ColumnWidth={'1x'};
            obj.GridLayout3.RowHeight={'fit','1x'};
            obj.GridLayout3.RowSpacing=5;
            obj.GridLayout3.Padding=[5,5,5,5];
            obj.GridLayout3.Layout.Row=2;
            obj.GridLayout3.Layout.Column=1;
            obj.GridLayout3.BackgroundColor=[1,1,1];


            obj.TestPlanLyt=uigridlayout(obj.GridLayout3);
            obj.TestPlanLyt.ColumnWidth={'1x','0.05x','0.05x'};
            obj.TestPlanLyt.RowHeight={'fit'};
            obj.TestPlanLyt.RowSpacing=0;
            obj.TestPlanLyt.Padding=[5,5,5,5];
            obj.TestPlanLyt.Layout.Row=1;
            obj.TestPlanLyt.Layout.Column=1;
            obj.TestPlanLyt.BackgroundColor=[1,1,1];

            obj.DeleteBtn=uibutton(obj.TestPlanLyt,'push');
            obj.DeleteBtn.ButtonPushedFcn=@(~,~)DeleteButtonPushed(obj);
            obj.DeleteBtn.Layout.Row=1;
            obj.DeleteBtn.Layout.Column=3;
            obj.DeleteBtn.Text='';
            obj.DeleteBtn.Tooltip='Delete';
            obj.DeleteBtn.Tag='DeleteTestPlanButton';
            obj.DeleteBtn.Icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Delete_24.png');


            obj.TestListLabel=uilabel(obj.TestPlanLyt);
            obj.TestListLabel.Layout.Row=1;
            obj.TestListLabel.Layout.Column=1;
            obj.TestListLabel.Text='Test Plans';
            obj.TestListLabel.FontWeight='bold';


            obj.VehScenTestPlanTable=uitable(obj.GridLayout3);
            obj.VehScenTestPlanTable.ColumnName={'Maneuvers';'Details'};
            obj.VehScenTestPlanTable.ColumnWidth={200,'auto'};
            obj.VehScenTestPlanTable.RowName='numbered';
            obj.VehScenTestPlanTable.Layout.Row=2;
            obj.VehScenTestPlanTable.Layout.Column=1;
            obj.VehScenTestPlanTable.SelectionType='row';
            obj.VehScenTestPlanTable.Tag='VehScenTestPlanTable';
            obj.VehScenTestPlanTable.Data={'Drive Cycle','FTP75'};
            obj.VehScenTestPlanTable.SelectionChangedFcn=@obj.ShowButtonPushed;


            obj.GridLayoutScenPara=uigridlayout(obj.GridLayout1);
            obj.GridLayoutScenPara.ColumnWidth={'1x'};
            obj.GridLayoutScenPara.RowHeight={'fit','1x'};
            obj.GridLayoutScenPara.RowSpacing=5;
            obj.GridLayoutScenPara.Padding=[5,5,5,5];
            obj.GridLayoutScenPara.Layout.Row=3;
            obj.GridLayoutScenPara.Layout.Column=1;
            obj.GridLayoutScenPara.BackgroundColor=[1,1,1];

            obj.GridLayoutLabel=uigridlayout(obj.GridLayoutScenPara);
            obj.GridLayoutLabel.ColumnWidth={'1x','0.05x','0.05x'};
            obj.GridLayoutLabel.RowHeight={'1x'};
            obj.GridLayoutLabel.RowSpacing=0;
            obj.GridLayoutLabel.Padding=[5,5,5,5];
            obj.GridLayoutLabel.Layout.Row=1;
            obj.GridLayoutLabel.Layout.Column=1;
            obj.GridLayoutLabel.BackgroundColor=[1,1,1];


            obj.VehScenLabel=uilabel(obj.GridLayoutLabel);
            obj.VehScenLabel.Layout.Row=1;
            obj.VehScenLabel.Layout.Column=1;
            obj.VehScenLabel.Text='Vehicle Scenario Parameters';
            obj.VehScenLabel.FontWeight='bold';


            obj.VehScenParaUITable=uitable(obj.GridLayoutScenPara);
            obj.VehScenParaUITable.ColumnName={'Parameter Name';'Description';'Unit';'Value'};
            obj.VehScenParaUITable.ColumnEditable=[false,false,false,true];
            obj.VehScenParaUITable.ColumnWidth={'auto','auto','auto','auto'};
            obj.VehScenParaUITable.RowName={};
            obj.VehScenParaUITable.Layout.Row=2;
            obj.VehScenParaUITable.Layout.Column=1;
            obj.VehScenParaUITable.SelectionType='row';
            obj.VehScenParaUITable.Tag='VehScenParaUITable';
            obj.VehScenParaUITable.CellEditCallback=@(~,event)updateVehScenario(obj,event);
        end

        function[doc,fig]=addDocumentFigures(obj,name)


            docOptions.Title=name;
            docOptions.DocumentGroupTag='Configuration';

            doc=matlab.ui.internal.FigureDocument(docOptions);
            doc.Closable=false;
            doc.Figure.AutoResizeChildren='on';
            doc.Tag='Scenario and Test';

            fig=doc.Figure;
            fig.Tag=name;
            fig.AutoResizeChildren='on';
            fig.Interruptible='off';
            fig.BusyAction='cancel';
        end


        function AddtoTestListButtonPushed(obj)
            data=obj.VehScenTestPlanTable.Data;
            NumofTest=getIdx(data);

            data{NumofTest,1}=obj.ScenarioDropDown.Value;
            data{NumofTest,2}=obj.DriveCycleDropDown.Value;

            obj.VehScenTestPlanTable.Data=data;

            obj.AddTestParas(NumofTest);

        end

        function AddTestParas(obj,NumofTest)

            list=VirtualAssemblyScenarioParaList(obj.ScenarioDropDown.Value);
            obj.ScenParaChgs=[list;obj.ScenParaChgs;];

            tp=struct('Num',NumofTest,...
            'Source','Scenario.sldd',...
            'Name',obj.ScenarioDropDown.Value,...
            'Cycle',obj.DriveCycleDropDown.Value,...
            'Data',{obj.ScenParaChgs});


            obj.TestPlanArray{NumofTest}=tp;

            obj.ScenParaChgs=[];
        end

        function DeleteButtonPushed(obj)
            row=obj.VehScenTestPlanTable.Selection;
            if isempty(row)
                warndlg('Select a row in the Test Plans to delete!','warning');
            else
                obj.DeleteMenuSelected(row);
            end
        end


        function DeleteMenuSelected(obj,row)
            obj.VehScenTestPlanTable.Data(row,:)=[];
            obj.TestPlanArray(row)=[];
            obj.clearTestParaTbl();
            if~isempty(obj.VehScenTestPlanTable.Data)
                obj.VehScenTestPlanTable.Selection=1;
                obj.ShowButtonPushed();
            end
        end

        function clearTestParaTbl(obj)
            obj.VehScenParaUITable.Data={};
            obj.VehScenLabel.Text='Vehicle Scenario Parameters';
        end

        function ShowButtonPushed(obj,~,~)
            row=obj.VehScenTestPlanTable.Selection;
            if~isempty(row)&&length(row)==1
                obj.ShowMenuSelected(row);
            end
        end

        function ShowMenuSelected(obj,row)

            value=obj.VehScenTestPlanTable.Data{row,1};
            obj.VehScenLabel.Text=['Vehicle Scenario Parameters ( Test Plan ',num2str(row),')'];
            obj.ScenarioDropDown.Value=value;
            if strcmp(value,'Drive Cycle')
                obj.DriveCycleDropDown.Items=obj.DriveCycleItems;
                cyclename=obj.VehScenTestPlanTable.Data{row,2};
                obj.DriveCycleDropDown.Value=cyclename;


                obj.updateScenData();

                simt=obj.getSimTime();
                obj.VehScenParaUITable.Data{2,4}=simt;


                data=obj.TestPlanArray{row}.Data;
                if~isempty(data)&&length(data)>5
                    for j=6:length(data)
                        var=data{j};
                        if strcmp(var{1},'ScnLongVelUnit')
                            obj.VehScenParaUITable.Data{1,4}=var{2};
                        elseif strcmp(var{1},'ScnSimTime')
                            obj.VehScenParaUITable.Data{2,4}=var{2};
                        end
                    end
                end
            else
                obj.DriveCycleDropDown.Items=obj.Sim3dDropDownItems;
                obj.DriveCycleDropDown.Value=obj.VehScenTestPlanTable.Data{row,2};
                obj.updateScenData();
                data=obj.TestPlanArray{row}.Data;
                if~isempty(data)
                    for j=1:length(data)
                        var=data{j};
                        index2=find(strcmp(obj.VehScenParaUITable.Data(:,1),var{1}),1);
                        if(~isempty(index2))
                            obj.VehScenParaUITable.Data{index2,4}=var{2};
                        end
                    end
                end
            end
        end

        function updateVehScenario(obj,event)


            olddata=str2num(event.PreviousData);
            newdata=str2num(event.NewData);

            row=event.Indices(1);
            name=obj.VehScenParaUITable.Data{row,1};

            if(isempty(newdata)&&isempty(olddata))||...
                (~isempty(newdata)&&~isempty(olddata)&&~isnan(newdata)&&~isnan(olddata))
                datachanged={obj.VehScenParaUITable.Data{row,1},event.NewData};
            elseif isempty(newdata)&&~isempty(olddata)
                errordlg(getString(message('autoblks_reference:autoerrVirtualAssembly:numericalDataType',name)));
                obj.VehScenParaUITable.Data{event.Indices(1),event.Indices(2)}=event.PreviousData;
            elseif~isempty(newdata)&&isempty(olddata)
                errordlg(getString(message('autoblks_reference:autoerrVirtualAssembly:charDataType',name)));
                obj.VehScenParaUITable.Data{event.Indices(1),event.Indices(2)}=event.PreviousData;
            end


            selected=obj.VehScenTestPlanTable.Selection;
            obj.TestPlanArray{selected}.Data=[obj.TestPlanArray{selected}.Data;{datachanged}];
        end

        function simTime=getSimTime(obj)
            Maneuver=obj.ScenarioDropDown.Value;
            ManeuverOption=obj.DriveCycleDropDown.Value;

            if strcmp(Maneuver,'Drive Cycle')
                try
                    cyclename=VirtualAssembly.getcyclename(ManeuverOption);
                    cycle=load(cyclename);
                    simTime=cycle.(cyclename).Time(end);
                catch
                    if strcmp(ManeuverOption,'Wide Open Throttle (WOT)')
                        simTime=40;
                    else
                        simTime=0;
                    end
                end
            else
                switch Maneuver
                case 'Double Lane Change'
                    simTime=25;
                case 'Increasing Steer'
                    simTime=60;
                case 'Swept Sine'
                    simTime=40;
                case 'Sine with Dwell'
                    simTime=25;
                case 'Constant Radius'
                    simTime=60;
                case 'Fishhook'
                    simTime=40;
                end
            end
            simTime=num2str(simTime);
        end
    end

end

function idx=getIdx(tb)
    if isempty(tb)
        idx=1;
    else
        idx=size(tb,1)+1;
    end
end