

classdef CreateExportToPreviousDlg<handle
    properties
m_ddConn
m_dir
m_versions
    end

    methods(Access=protected)
        function obj=CreateExportToPreviousDlg(ddConn)
            obj.m_ddConn=ddConn;
            obj.m_versions=Simulink.dd.getSupportedReleases;
        end

    end

    methods
        function schema=getDialogSchema(thisObj)

            widget=[];
            widget.Name=message('SLDD:sldd:ExportToPreviousDialogDescription').getString;
            widget.Type='text';
            widget.Tag='tagDescription';
            widget.WordWrap=true;
            widget.RowSpan=[1,1];
            widget.ColSpan=[1,2];
            description_widget=widget;

            widget=[];
            widget.Name=message('SLDD:sldd:ExportToPreviousDialogVersion').getString;
            widget.Type='combobox';
            widget.Tag='ExportToPreviousVersion';

            widget.Value=thisObj.m_versions{1};
            widget.Entries=thisObj.m_versions;
            if~isempty(thisObj.m_dir)
                widget.Value=thisObj.m_dir;
            end
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag};
            widget.ArgDataTypes={'handle','string'};
            widget.RowSpan=[2,2];
            widget.ColSpan=[1,2];
            version_Widget=widget;

            widget=[];
            widget.Name=message('SLDD:sldd:ExportToPreviousDialogDirectory').getString;
            widget.Type='edit';
            widget.Tag='ExportToPreviousDirectory';
            if~isempty(thisObj.m_dir)
                widget.Value=thisObj.m_dir;


            end
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag};
            widget.ArgDataTypes={'handle','string'};
            directory_Widget=widget;


            widget=[];
            widget.Name=message('SLDD:sldd:ExportToPreviousDialogBrowse').getString;
            widget.Type='pushbutton';
            widget.Tag='ExportToPreviousBrowse';
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag};
            widget.ArgDataTypes={'handle','string'};
            directoryBrowse_Widget=widget;

            directory_Widget.ColSpan=[1,1];
            directoryBrowse_Widget.ColSpan=[2,2];

            directory_Widget.ColSpan=[1,1];
            directoryBrowse_Widget.ColSpan=[2,2];

            schema.DialogTitle=message('SLDD:sldd:ExportToPreviousDialogTitle').getString;
            schema.LayoutGrid=[3,2];

            schema.Items={description_widget,version_Widget,directory_Widget,directoryBrowse_Widget};
            schema.PostApplyCallback='postApplyCallback';
            schema.PostApplyArgs={thisObj,'%dialog'};
            schema.PostApplyArgsDT={'MATLAB array','string'};
            schema.StandaloneButtonSet={'OK','Cancel','Help'};


            schema.HelpMethod='helpview';
            schema.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};

        end

        function dialogCallback(thisObj,dlg,tag)
            switch tag
            case 'ExportToPreviousBrowse'
                tagExportToPreviousText='ExportToPreviousDirectory';
                currDir=getWidgetValue(dlg,tagExportToPreviousText);
                if isempty(currDir)
                    startDir=pwd;
                else
                    if exist(currDir,'dir')==7
                        startDir=currDir;
                    else
                        startDir=pwd;
                    end
                end
                newDir=uigetdir(startDir,'BrowseButton');
                if~isempty(newDir)
                    setWidgetValue(dlg,tagExportToPreviousText,newDir)
                end
            end
        end

        function[status,errMsg]=postApplyCallback(thisObj,dlg)
            status=true;
            errMsg='';
            try
                tagExportToPreviousText='ExportToPreviousDirectory';
                selectedDir=getWidgetValue(dlg,tagExportToPreviousText);
                thisObj.m_dir=selectedDir;

                tagExportToPreviousVersion='ExportToPreviousVersion';
                selectedVersion=thisObj.m_versions{getWidgetValue(dlg,tagExportToPreviousVersion)+1};

                thisObj.m_ddConn.exportToVersion(selectedDir,selectedVersion);

            catch me
                status=false;
                errMsg=me.message;
            end
        end
    end

    methods(Static,Access=public)
        function launch(ddConn)
            obj=Simulink.dd.CreateExportToPreviousDlg(ddConn);
            DAStudio.Dialog(obj,'','DLG_STANDALONE');
        end
    end

end
