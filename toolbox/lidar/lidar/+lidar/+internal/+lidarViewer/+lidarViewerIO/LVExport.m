





classdef LVExport<lidar.internal.lidarViewer.view.dialog.helper.OkCanceDialog

    properties(Access=private)
SignalInfo
    end

    properties(Access=private)

        SelectSignalText matlab.ui.control.Label
        SignalInfoTable matlab.ui.control.Table
        SelectFolderText matlab.ui.control.Label
        DestDirEditBox matlab.ui.control.EditField
        DestDirButton matlab.ui.control.Button
    end

    properties(Access=private)

        SelectSignalTextPos(1,4)int32
        SignalInfoTablePos(1,4)int32
        SelectFolderTextPos(1,4)int32
        DestDirEditBoxPos(1,4)int32
        DestDirButtonPos(1,4)int32
    end

    properties(Access=private)

        ToExport(1,1)logical=false;
        DestinationPath char='';
        ToExportSignal=[];
    end

    events
ExternalTrigger
    end

    methods



        function this=LVExport()
            this=this@lidar.internal.lidarViewer.view.dialog.helper.OkCanceDialog(...
            getString(message('lidar:lidarViewer:ExportDialogTitle')),[800,315]);

            this.calculatePosition();
            this.createUI();
        end




        function open(this,signalInfo)


            this.SignalInfo=signalInfo;
            this.populateTable();

            this.MainFigure.Visible='on';
        end




        function info=getUserInfo(this)

            info=struct();
            info.ToExport=this.ToExport;
            info.DestinationFolder=this.DestinationPath;
            info.ToExportSignal=this.ToExportSignal;
        end
    end




    methods(Access=private)
        function createUI(this)

            this.addInstructionText();
            this.addSignalInfoTable();
            this.addDestDirUI();
        end


        function calculatePosition(this)



            mainFigDim=this.Size;


            this.SelectSignalTextPos=...
            [mainFigDim(1)/20,mainFigDim(2)*0.9,mainFigDim(1)*.9,25];


            this.SignalInfoTablePos=...
            [mainFigDim(1)/20,mainFigDim(2)*0.45,mainFigDim(1)*.9,mainFigDim(2)*0.4];


            this.SelectFolderTextPos=...
            [mainFigDim(1)/20,mainFigDim(2)*0.25,mainFigDim(1)*.325,mainFigDim(2)*0.1];


            this.DestDirEditBoxPos=...
            [mainFigDim(1)*0.375,mainFigDim(2)*0.25,mainFigDim(1)*.45,mainFigDim(2)*0.075];

            this.DestDirButtonPos=...
            [mainFigDim(1)*0.85,mainFigDim(2)*0.25,mainFigDim(1)*.1,mainFigDim(2)*0.075];

        end


        function addSignalInfoTable(this)

            this.SignalInfoTable=uitable(this.MainFigure,...
            'Position',this.SignalInfoTablePos,...
            'Tag','exportDataTable',...
            'CellSelectionCallback',@(~,evt)this.userCellSelectionCB(evt));
        end


        function addInstructionText(this)

            this.SelectSignalText=uilabel(this.MainFigure,...
            'Text',getString(message('lidar:lidarViewer:ExportDialogInstText')),...
            'Position',this.SelectSignalTextPos,...
            'FontSize',14);

            this.SelectFolderText=uilabel(this.MainFigure,...
            'Text',getString(message('lidar:lidarViewer:ExportDialogDestText')),...
            'Position',this.SelectFolderTextPos,...
            'FontSize',14);
        end


        function addDestDirUI(this)


            this.DestDirEditBox=uieditfield(this.MainFigure,...
            'Position',this.DestDirEditBoxPos,...
            'Tag','destDirEB',...
            'Editable',true);

            this.DestDirButton=uibutton(this.MainFigure,...
            'Position',this.DestDirButtonPos,...
            'Text',getString(message('lidar:lidarViewer:Browse')),...
            'Tag','exportBrowseBttn',...
            'ButtonPushedFcn',@(~,~)this.browse());
        end
    end




    methods(Access=protected)

        function okClicked(this)

            if any(this.SignalInfoTable.Data.ToExport)&&...
                ~isempty(this.DestDirEditBox.Value)
                this.ToExport=true;
                this.DestinationPath=this.DestDirEditBox.Value;
                this.ToExportSignal=this.SignalInfoTable.Data.ToExport;
            else
                warningMessage=getString(message('lidar:lidarViewer:ExportWarningMessage'));
                warningTitle=getString(message('lidar:lidarViewer:Warning'));
                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',warningMessage,warningTitle);
            end


            this.close();
        end


        function browse(this)

            persistent lastUsedDirectory;

            if(isempty(lastUsedDirectory)||~isfolder(lastUsedDirectory))
                lastUsedDirectory=pwd;
            end

            chosenDirectory=uigetdir(lastUsedDirectory,'Pick a folder');



            lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
            this,'bringToFront');
            figure(this.MainFigure);

            if chosenDirectory==0
                return;
            end
            if~isfolder(chosenDirectory)
                return;

            end

            lastUsedDirectory=chosenDirectory;
            this.DestDirEditBox.Value=lastUsedDirectory;

        end


        function userCellSelectionCB(this,evt)
            if evt.Indices(2)~=1
                return;
            end
            this.SignalInfoTable.Data{evt.Indices(1),2}=...
            ~this.SignalInfoTable.Data{evt.Indices(1),2};
            this.SignalInfoTable.Selection=[];
        end
    end




    methods(Access=private)

        function populateTable(this)





            numSignals=height(this.SignalInfo);
            if numSignals<1

                return
            end


            isEdited=false(numSignals,1);


            this.SignalInfo.ToExport=isEdited;
            this.SignalInfoTable.ColumnEditable=[false,true];

            this.SignalInfoTable.Data=this.SignalInfo;
            this.SignalInfoTable.ColumnWidth={'auto',125};
            this.SignalInfoTable.ColumnName=...
            {getString(message('lidar:lidarViewer:ExportTableHeading1')),...
            getString(message('lidar:lidarViewer:ExportTableHeading2'))};
        end
    end
end