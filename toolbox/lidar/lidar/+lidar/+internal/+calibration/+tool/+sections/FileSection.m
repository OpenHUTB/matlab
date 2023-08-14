classdef FileSection<handle




    properties
        Tab;
        NewSessionBtn;
        OpenSessionBtn;

        ImportDataDDBtn;
        ImportDataListItem;
        AddDataListItem;

        SaveSessionSplitBtn;
        SaveSessionListItem;
        SaveSessionAsListItem;

        ColumnWidth=40;
    end

    methods
        function this=FileSection(tab)
            this.Tab=tab;
            addColumns(this);
            setEnableState(this,false);
        end

        function setEnableState(this,value)

            this.NewSessionBtn.Enabled=value;

            this.SaveSessionSplitBtn.Enabled=value;
            this.SaveSessionListItem.Enabled=value;
            this.SaveSessionAsListItem.Enabled=value;



            this.OpenSessionBtn.Enabled=true;
        end

        function addColumns(this)

            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:fileSectionName'))));
            section.Tag='sec_file';

            column1=section.addColumn('Width',this.ColumnWidth+20);

            button=Button(string(message('lidar:lidarCameraCalibrator:newSessionBtnName')),Icon.NEW_24);
            button.Tag='pBtnNewSession';
            button.Description=string(message('lidar:lidarCameraCalibrator:newSessionBtnDesc'));
            column1.add(button);
            this.NewSessionBtn=button;

            column2=section.addColumn('Width',this.ColumnWidth+20);

            button=Button(string(message('lidar:lidarCameraCalibrator:openSessionBtnName')),Icon.OPEN_24);
            button.Tag='pBtnOpenSession';
            button.Description=string(message('lidar:lidarCameraCalibrator:openSessionBtnDesc'));
            column2.add(button);
            this.OpenSessionBtn=button;

            addSaveControls(this,section);
            addImportControls(this,section);
        end

        function addSaveControls(this,section)
            import matlab.ui.internal.toolstrip.*
            columnSave=section.addColumn('Width',this.ColumnWidth);
            this.SaveSessionSplitBtn=matlab.ui.internal.toolstrip.SplitButton(string(message('lidar:lidarCameraCalibrator:saveSessionBtnName')),Icon.SAVE_24);
            this.SaveSessionSplitBtn.Tag='sBtnSaveSession';
            this.SaveSessionSplitBtn.Description=string(message('lidar:lidarCameraCalibrator:saveSessionBtnDesc'));

            popup=matlab.ui.internal.toolstrip.PopupList;
            this.SaveSessionSplitBtn.Popup=popup;
            this.SaveSessionListItem=matlab.ui.internal.toolstrip.ListItem(...
            string(message('lidar:lidarCameraCalibrator:saveSessionBtnName')),Icon.SAVE_24);
            this.SaveSessionListItem.Tag='item_saveSession';
            this.SaveSessionAsListItem=matlab.ui.internal.toolstrip.ListItem(...
            string(message('lidar:lidarCameraCalibrator:saveSessionAsBtnName')),Icon.SAVE_AS_24);
            this.SaveSessionAsListItem.Tag='item_saveSessionAs';

            popup.add(this.SaveSessionListItem);
            popup.add(this.SaveSessionAsListItem);
            columnSave.add(this.SaveSessionSplitBtn);
        end

        function addImportControls(this,section)
            import matlab.ui.internal.toolstrip.*
            columnImport=section.addColumn('Width',this.ColumnWidth);
            this.ImportDataDDBtn=matlab.ui.internal.toolstrip.DropDownButton(string(message('lidar:lidarCameraCalibrator:importDataBtnName')),Icon.IMPORT_24);
            this.ImportDataDDBtn.Tag='ddBtnImport';
            this.ImportDataDDBtn.Description=string(message('lidar:lidarCameraCalibrator:importDataBtnDesc'));

            popup=matlab.ui.internal.toolstrip.PopupList;
            this.ImportDataDDBtn.Popup=popup;
            this.ImportDataListItem=matlab.ui.internal.toolstrip.ListItem(...
            string(message('lidar:lidarCameraCalibrator:importDataListBtnName')),Icon.IMPORT_24);
            this.ImportDataListItem.Tag='item_Import';
            this.ImportDataListItem.Description=string(message('lidar:lidarCameraCalibrator:importDataListBtnDesc'));

            this.AddDataListItem=matlab.ui.internal.toolstrip.ListItem(...
            string(message('lidar:lidarCameraCalibrator:addDataListBtnName')),Icon.ADD_24);
            this.AddDataListItem.Tag='item_AddData';
            this.AddDataListItem.Description=string(message('lidar:lidarCameraCalibrator:addDataListBtnDesc'));

            popup.add(this.ImportDataListItem);
            popup.add(this.AddDataListItem);
            columnImport.add(this.ImportDataDDBtn);


            this.ImportDataDDBtn.Enabled=true;
            this.ImportDataListItem.Enabled=true;
            this.AddDataListItem.Enabled=false;
        end
    end

end
