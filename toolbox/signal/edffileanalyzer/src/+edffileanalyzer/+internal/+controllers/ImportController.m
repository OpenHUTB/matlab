

classdef ImportController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
ImportComplete
PlotSignals
OpenFileBrowserComplete
    end

    properties(Constant)
        ControllerID="ImportController";
    end


    methods
        function this=ImportController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"import",'callback',@this.cb_Import);
            struct('messageID',"openfilebrowser",'callback',@this.cb_OpenFileBrowser);
            ];
        end
    end


    methods(Hidden)
        function cb_Import(this,args)

            if args.data.importFromDialog
                fileName=args.data.fileName;
                [validFileNameFlag,errorMsg]=this.Model.setFileInfo(fileName,true);
            else
                fileName=this.Model.getFileName();
                validFileNameFlag=fileName~="";
            end

            if validFileNameFlag


                this.Model.createSignalIDs();


                tableData=this.Model.getDataForSignalsTable();
                isFileHasSignals=~isempty(tableData);
                if isFileHasSignals

                    axesData.messageID="addAxes";
                    axesData.data.xLabel=this.Model.getXLabel();
                    this.notify("ImportComplete",sigwebappsutils.internal.EventData(axesData));


                    signalsTableData.messageID="signalsTable";
                    signalsTableData.data=tableData;
                    this.notify("ImportComplete",sigwebappsutils.internal.EventData(signalsTableData));


                    this.notify("PlotSignals",sigwebappsutils.internal.EventData(this.Model.getSignalData(fileName)));


                    multiplierData.messageID="updateMultiplier";
                    multiplierData.data.xMultiplier=this.Model.getXMulitplier();
                    this.notify("ImportComplete",sigwebappsutils.internal.EventData(multiplierData));
                end


                tableData=this.Model.getDataForHeaderPropertiesTable();
                if~isempty(tableData)
                    headerPropertiesTableData.messageID="headerPropertiesTable";
                    headerPropertiesTableData.data=tableData;
                    this.notify("ImportComplete",sigwebappsutils.internal.EventData(headerPropertiesTableData));
                end


                tableData=this.Model.getDataForSignalPropertiesTable();
                if~isempty(tableData)
                    signalPropertiesTableData.messageID="signalPropertiesTable";
                    signalPropertiesTableData.data=tableData;
                    this.notify("ImportComplete",sigwebappsutils.internal.EventData(signalPropertiesTableData));
                end


                tableData=this.Model.getDataForAnnotationsTable();
                if~isempty(tableData)
                    annotationsTableData.messageID="annotationsTable";
                    annotationsTableData.data=tableData;
                    this.notify("ImportComplete",sigwebappsutils.internal.EventData(annotationsTableData));
                end


                toolstripData.messageID="setToolstrip";
                toolstripData.data=isFileHasSignals;
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(toolstripData));


                importFileWidgetData.messageID="closeDialog";
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(importFileWidgetData));
            elseif args.data.importFromDialog

                importFileWidgetData.messageID="setNameTextFieldInErrorState";
                importFileWidgetData.data.errorMsg=errorMsg;
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(importFileWidgetData));
            end

            if~validFileNameFlag||~isFileHasSignals

                busyOverLayData.messageID="hideBusyOverlay";
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(busyOverLayData));
            end
        end

        function cb_OpenFileBrowser(this,~)

            fileFilter=["*.edf","EDF-files (*.edf)"];
            [filename,pathname]=uigetfile(fileFilter,...
            getString(message('signal_edffileanalyzer:dialog:importDialogTitle')),...
            'MultiSelect',"off");
            if~isequal(filename,0)&&~isequal(pathname,0)



                importFileWidgetData.messageID="setValueInNameTextField";
                importFileWidgetData.data=fullfile(pathname,filename);
                this.notify("OpenFileBrowserComplete",sigwebappsutils.internal.EventData(importFileWidgetData));
            end
        end
    end
end