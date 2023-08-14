classdef ExportSection<handle




    properties
        Tab;
        ExportBtn;
        ToWorkspace;
        ToFile;
        GenerateScript;

        ColumnWidth=40;
    end

    methods
        function this=ExportSection(tab)
            this.Tab=tab;

            addColumns(this);

            setEnableState(this,false);
        end

        function setEnableState(this,value)
            this.ExportBtn.Enabled=value;
        end

        function addColumns(this)

            import matlab.ui.internal.toolstrip.*

            section=this.Tab.addSection(upper(string(message('lidar:lidarCameraCalibrator:exportSectionName'))));
            section.Tag='sec_export';

            columnExport=section.addColumn('Width',this.ColumnWidth);
            this.ExportBtn=matlab.ui.internal.toolstrip.SplitButton(string(message('lidar:lidarCameraCalibrator:exportBtnName')),Icon.EXPORT_24);
            this.ExportBtn.Tag='sBtnExport';
            this.ExportBtn.Description=string(message('lidar:lidarCameraCalibrator:exportBtnDesc'));

            popup=matlab.ui.internal.toolstrip.PopupList;
            this.ExportBtn.Popup=popup;
            this.ToWorkspace=matlab.ui.internal.toolstrip.ListItem(string(message('lidar:lidarCameraCalibrator:exportToWSBtnName')));
            this.ToWorkspace.Tag='item_toWS';
            this.ToFile=matlab.ui.internal.toolstrip.ListItem(string(message('lidar:lidarCameraCalibrator:exportToFileBtnName')));
            this.ToFile.Tag='item_toFile';
            this.GenerateScript=matlab.ui.internal.toolstrip.ListItem(string(message('lidar:lidarCameraCalibrator:generateMATLABScriptBtnName')));
            this.GenerateScript.Tag='item_genScript';
            popup.add(this.ToWorkspace);
            popup.add(this.ToFile);
            popup.add(this.GenerateScript);
            columnExport.add(this.ExportBtn);

        end
    end

end
