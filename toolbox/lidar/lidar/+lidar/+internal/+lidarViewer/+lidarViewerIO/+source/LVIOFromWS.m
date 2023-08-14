







classdef LVIOFromWS<lidar.internal.lidarViewer.lidarViewerIO.LVIOSource



    properties(Constant)
        IOSourceName=getString(message('lidar:lidarViewer:FromWorkspace'));
    end
    properties(Constant)
        SupportedClass='pointCloud'
    end
    properties(Access=private,Hidden)
ParentPanel
    end

    properties(Access=private,Hidden)

SourceMessageText
SelectedMessageText
SourceTable
SelectedTable
DescriptionText
    end

    properties(Access=private,Hidden)

SourceMessageTextPos
SelectedMessageTextPos
SourceTablePos
SelectedTablePos
DescriptionTextPos
    end

    properties(Constant,Hidden)
        MARGIN=25;
    end

    properties
        SignalIndex=0;
    end

    properties

SelectedVariable
    end

    properties(Dependent)

AvailableVariables
    end




    methods
        function configureImportPanel(this,panel)


            this.ParentPanel=panel;
            this.computePosition();
            this.createUI();
            this.populateTable();
        end


        function[dataPath,dataParams,dataName]=getLoadPanelData(this)
            dataPath='';

            dataParams=[];

            dataName=this.getUniqueName(strcat('PointCloud','_',num2str(this.SignalIndex)));
        end
    end




    methods
        function data=readData(this,index)

            data=this.createDataStruct();
            data.PointCloud=evalin('base',this.SelectedVariable{index}');

            assert(data.PointCloud.Count>0,...
            getString(message('lidar:lidarViewer:InvalidPointCloudObjError')))

            data.ScalarData.Name=this.Scalars;
            data.ScalarData.Value=[];
        end
    end




    methods
        function loadData(this,dataName,dataParams,dataPath)
            assert(~isempty(this.SelectedVariable),...
            getString(message('lidar:lidarViewer:ImportWSErrorNoSelection')));
            this.TimeVector=seconds(0:1:numel(this.SelectedVariable)-1)';
            this.DataName=dataName;
            this.DataParams=dataParams;
            this.DataPath=dataPath;
            this.Scalars={};
        end
    end




    methods(Access=private)
        function computePosition(this)
            panelPos=this.ParentPanel.Position;

            this.DescriptionTextPos=[this.MARGIN,panelPos(4)*0.85...
            ,panelPos(3)-2*this.MARGIN-this.MARGIN,20];

            this.SourceMessageTextPos=[this.MARGIN,panelPos(4)*0.7...
            ,panelPos(3)*0.5-this.MARGIN,20];

            this.SelectedMessageTextPos=[panelPos(3)*0.5+this.MARGIN/2...
            ,panelPos(4)*0.7,panelPos(3)*0.5-this.MARGIN,20];

            this.SourceTablePos=[this.MARGIN,panelPos(4)*0.05...
            ,panelPos(3)*0.5-this.MARGIN,panelPos(4)*0.65];

            this.SelectedTablePos=[panelPos(3)*0.5+this.MARGIN/2...
            ,panelPos(4)*0.05,panelPos(3)*0.5-this.MARGIN,panelPos(4)*0.65];

        end


        function createUI(this)
            this.addDescriptionText();

            this.addMesageText();

            this.addTables();
        end


        function addDescriptionText(this)
            this.DescriptionText=uilabel(...
            'Parent',this.ParentPanel,...
            'Position',this.DescriptionTextPos,...
            'FontSize',14,...
            'Text',getString(message('lidar:lidarViewer:ImportDescWS')));
        end


        function createDialog(this)
            this.MainFigure=uifigure(...
            'Name',this.Title,...
            'Position',this.MainFigurePos,...
            'IntegerHandle','off',...
            'NumberTitle','off',...
            'MenuBar','none',...
            'WindowStyle','modal',...
            'Visible','on',...
            'Resize','off',...
            'Tag','getNameDlg');
        end


        function addMesageText(this)
            this.SourceMessageText=uilabel(...
            'Parent',this.ParentPanel,...
            'Position',this.SourceMessageTextPos,...
            'Text',getString(message('lidar:lidarViewer:ImportWSMess1')),...
            'FontSize',14);

            this.SelectedMessageTextPos=uilabel(...
            'Parent',this.ParentPanel,...
            'Position',this.SelectedMessageTextPos,...
            'Text',getString(message('lidar:lidarViewer:ImportWSMess2')),...
            'FontSize',14);
        end


        function addTables(this)
            this.SourceTable=uitable(...
            'Parent',this.ParentPanel,...
            'Position',this.SourceTablePos,...
            'Tag','importTable',...
            'CellEditCallback',@(~,evt)this.userSelectionCB(evt),...
            'CellSelectionCallback',@(~,evt)this.userCellSelectionCB(evt));

            this.SelectedTable=uitable(...
            'Parent',this.ParentPanel,...
            'Position',this.SelectedTablePos,...
            'Tag','selectTable');

            this.SelectedTable.RowName=[];
            this.SelectedTable.ColumnName=[];
            this.SourceTable.ColumnName=[];
            this.SourceTable.RowName=[];
        end
    end




    methods(Access=private)
        function userSelectionCB(this,evt)
            selectedName=this.AvailableVariables(evt.Indices(1)).name;
            if evt.NewData

                this.SelectedVariable{end+1}=selectedName;
            else

                index=find(strcmp(this.SelectedVariable,selectedName));
                this.SelectedVariable(index)=[];
            end


            this.SelectedTable.Data=this.SelectedVariable';
        end


        function userCellSelectionCB(this,evt)
            selectedName=this.AvailableVariables(evt.Indices(1)).name;
            if~this.SourceTable.Data.Var2(evt.Indices(1))

                this.SelectedVariable{end+1}=selectedName;
                this.SourceTable.Data.Var2(evt.Indices(1))=true;
            else

                index=find(strcmp(this.SelectedVariable,selectedName));
                this.SelectedVariable(index)=[];
                this.SourceTable.Data.Var2(evt.Indices(1))=false;
            end


            this.SelectedTable.Data=this.SelectedVariable';
            this.SourceTable.Selection=[];
        end
    end




    methods(Access=private)

        function[screenWidth,screenHeight]=getScreenDim(this)

            screenSize=get(0,'ScreenSize');
            screenWidth=screenSize(3);
            screenHeight=screenSize(4);
        end


        function populateTable(this)

            data=cell2table({this.AvailableVariables.name}');
            data.Var2=false(height(data),1);
            this.SourceTable.Data=data;

            this.SourceTable.ColumnEditable=[false,true];
        end
    end




    methods
        function availableVariables=get.AvailableVariables(this)
            vars=evalin('base','whos');
            validVars=strcmp({vars.class},this.SupportedClass);
            availableVariables=vars(validVars);
        end
    end
end