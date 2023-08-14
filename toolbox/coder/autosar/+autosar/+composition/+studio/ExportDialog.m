classdef ExportDialog<handle




    properties(Hidden,Constant)
        ExportDialogTag='AutosarExportDialogTag';
        ExportARXMLFolderTag='ExportARXMLFolder';
        BrowseButtonTag='BrowseButton';
        CreatePackageCheckBoxTag='CreatePackageCheckBox';
        ZipFileNameTag='ZipFileName';
        ExportECUExtractCheckBoxTag='ExportECUExtractCheckBoxTag';
    end

    properties(SetAccess=immutable,GetAccess=private)
        RootModelName;
        SystemPathToExport;
        ExportDialogTitleID;
        ExportDialogDescriptionID;
        IsCompositionExport;
        CloseModelListener;
    end

    properties(Access=private)
        OkButtonClicked;
        CreateZipFile;
    end

    methods(Static,Access=public)
        function launchDialog(sysH,isCompositionExport)

            exportDialog=autosar.composition.studio.ExportDialog(sysH,isCompositionExport);
            dlg=DAStudio.Dialog(exportDialog);
            dlg.show();
        end
    end

    methods

        function this=ExportDialog(sysH,isCompositionExport)
            this.RootModelName=get_param(bdroot(sysH),'Name');
            this.SystemPathToExport=getfullname(sysH);
            this.OkButtonClicked=false;
            this.CreateZipFile=true;
            this.IsCompositionExport=isCompositionExport;
            if this.IsCompositionExport
                this.ExportDialogTitleID='autosarstandard:editor:ExportCompositionDialogTitle';
                this.ExportDialogDescriptionID='autosarstandard:editor:ExportCompositionDialogDescription';
            else
                this.ExportDialogTitleID='autosarstandard:editor:ExportComponentDialogTitle';
                this.ExportDialogDescriptionID='autosarstandard:editor:ExportComponentDialogDescription';
            end


            this.CloseModelListener=Simulink.listener(get_param(this.RootModelName,'handle'),...
            'CloseEvent',@CloseModelCB);
        end


        function schema=getDialogSchema(this)


            autosar.api.Utils.autosarlicensed(true);

            row=1;
            col=1;

            numCols=3;
            numRows=3;


            desc.Type='text';
            desc.Tag='txtDesc';
            desc.RowSpan=[row,row];
            desc.ColSpan=[col,numCols];
            desc.Name=message(this.ExportDialogDescriptionID).getString();
            desc.WordWrap=true;

            row=row+1;




            arxmlFolderLabel.Type='text';
            arxmlFolderLabel.Tag='ARXMLFolderLabel';
            arxmlFolderLabel.Name=message('autosarstandard:editor:ExportDialogArxmlFolderText').getString();
            arxmlFolderLabel.RowSpan=[row,row];
            arxmlFolderLabel.ColSpan=[col,col];
            arxmlFolderLabel.Visible=this.IsCompositionExport;

            col=col+1;


            arxmlFolderEdit.Type='edit';
            arxmlFolderEdit.HideName=true;
            arxmlFolderEdit.Tag=this.ExportARXMLFolderTag;
            arxmlFolderEdit.Source=this;
            arxmlFolderEdit.Graphical=true;
            arxmlFolderEdit.Mode=true;
            arxmlFolderEdit.RowSpan=[row,row];
            arxmlFolderEdit.ColSpan=[col,col];
            arxmlFolderEdit.ToolTip=message('autosarstandard:editor:ExportDialogArxmlFolderTooltip').getString();
            arxmlFolderEdit.Visible=this.IsCompositionExport;


            arxmlFolderEdit.Value=message('autosarstandard:editor:ExportDialogArxmlFolderPlaceholder').getString();

            col=col+1;
            browseButton.Type='pushbutton';
            browseButton.Tag=this.BrowseButtonTag;
            browseButton.Source=this;
            browseButton.ObjectMethod='browseARXMLFolderCB';
            browseButton.MethodArgs={'%dialog'};
            browseButton.ArgDataTypes={'handle'};
            browseButton.RowSpan=[row,row];
            browseButton.ColSpan=[col,col];
            browseButton.Enabled=true;
            browseButton.ToolTip='';
            browseButton.FilePath='';
            browseButton.Name=message('autosarstandard:editor:Browse').getString();
            browseButton.Visible=this.IsCompositionExport;


            row=row+1;
            col=1;
            createZipFileCheckBox.Type='checkbox';
            createZipFileCheckBox.Tag=this.CreatePackageCheckBoxTag;
            createZipFileCheckBox.RowSpan=[row,row];
            createZipFileCheckBox.ColSpan=[col,col];
            createZipFileCheckBox.ObjectMethod='createZipFileCheckboxCB';
            createZipFileCheckBox.MethodArgs={'%dialog'};
            createZipFileCheckBox.ArgDataTypes={'handle'};
            createZipFileCheckBox.Enabled=true;
            createZipFileCheckBox.ToolTip='';
            createZipFileCheckBox.Value=1;
            createZipFileCheckBox.Name=message('autosarstandard:editor:ExportDialogCreatePackageText').getString();
            createZipFileCheckBox.ToolTip=message('autosarstandard:editor:ExportDialogCreatePackageTooltip').getString();

            col=col+1;
            zipFileName.Type='edit';
            zipFileName.Tag=this.ZipFileNameTag;
            zipFileName.RowSpan=[row,row];
            zipFileName.ColSpan=[col,col];
            zipFileName.Enabled=this.CreateZipFile;
            zipFileName.ToolTip='';
            zipFileName.Name=message('autosarstandard:editor:ExportDialogZipFileNameText').getString();
            zipFileName.ToolTip=message('autosarstandard:editor:ExportDialogZipFileNameTooltip').getString();


            zipFileName.Value=[get_param(this.SystemPathToExport,'Name'),'.zip'];

            col=1;
            row=row+1;
            createECUExtractCheckBox.Type='checkbox';
            createECUExtractCheckBox.Tag=this.ExportECUExtractCheckBoxTag;
            createECUExtractCheckBox.RowSpan=[row,row];
            createECUExtractCheckBox.ColSpan=[col,col];
            createECUExtractCheckBox.Enabled=true;
            createECUExtractCheckBox.Value=0;
            createECUExtractCheckBox.Name=message('autosarstandard:editor:ExportDialogExportEcuExtractText').getString();
            createECUExtractCheckBox.ToolTip=message('autosarstandard:editor:ExportDialogExportEcuExtractTooltip').getString();
            createECUExtractCheckBox.Visible=slfeature('AUTOSAREcuExtract');

            group.Type='group';
            group.Name='';
            if this.IsCompositionExport
                group.Items={desc,arxmlFolderLabel,arxmlFolderEdit,...
                browseButton,createZipFileCheckBox,zipFileName,...
                createECUExtractCheckBox};
            else
                group.Items={desc,browseButton,createZipFileCheckBox,...
                zipFileName};
            end
            group.LayoutGrid=[1,col+1];

            group.RowSpan=[1,1];
            group.ColSpan=[1,numCols];

            panel.Type='panel';
            panel.Tag='ExportCompositionMainPanel';
            panel.Items={group};
            panel.LayoutGrid=[numCols,numRows];
            panel.Enabled=true;

            schema.DialogTitle=message(this.ExportDialogTitleID).getString();
            schema.Items={panel};
            schema.DialogTag=this.ExportDialogTag;
            schema.Source=this;
            schema.SmartApply=true;
            schema.PreApplyCallback='preApplyCB';
            schema.PreApplyArgs={this,'%dialog'};
            schema.CloseCallback='closeCB';
            schema.CloseArgs={this,'%dialog'};
            schema.StandaloneButtonSet={'Ok','Cancel'};
            schema.MinMaxButtons=true;
            schema.ShowGrid=1;
            schema.DisableDialog=false;
            schema.Sticky=true;
        end


        function[isValid,msg]=preApplyCB(exportDlg,dlg)%#ok<INUSD>
            isValid=true;
            msg='';



            exportDlg.OkButtonClicked=true;
        end



        function closeCB(exportDlg,dlg)

            if exportDlg.OkButtonClicked

                exportDlg.OkButtonClicked=false;

                try

                    systemToExportName=get_param(exportDlg.RootModelName,'Name');
                    msg=DAStudio.message('RTW:buildProcess:Build');
                    stage=sldiagviewer.createStage(msg,'ModelName',systemToExportName);%#ok<NASGU>


                    slMsgViewer=slmsgviewer.Instance(exportDlg.RootModelName);
                    if~isempty(slMsgViewer)
                        slMsgViewer.show();
                        slmsgviewer.selectTab(systemToExportName);
                    end


                    if exportDlg.IsCompositionExport
                        arxmlFolder=dlg.getWidgetValue(exportDlg.ExportARXMLFolderTag);
                        if strcmp(arxmlFolder,message('autosarstandard:editor:ExportDialogArxmlFolderPlaceholder').getString())



                            arxmlFolder=RTW.getBuildDir(exportDlg.RootModelName).CodeGenFolder;%#ok<NASGU>
                        end

                        exportECUExtract=dlg.getWidgetValue(exportDlg.ExportECUExtractCheckBoxTag);%#ok<NASGU>
                    else
                        arxmlFolder='';%#ok<NASGU>
                        exportECUExtract=false;%#ok<NASGU>
                    end
                    systemPathToExport=exportDlg.SystemPathToExport;%#ok<NASGU>
                    if exportDlg.CreateZipFile
                        zipFileName=dlg.getWidgetValue(exportDlg.ZipFileNameTag);%#ok<NASGU>
                    else
                        zipFileName='';%#ok<NASGU>
                    end

                    cmd=['autosar.api.export(systemPathToExport, '...
                    ,'''ExportedARXMLFolder'', arxmlFolder, '...
                    ,'''PackageCodeAndARXML'', zipFileName, '...
                    ,'''OkayToPushNags'', true, '...
                    ,'''ExportECUExtract'', exportECUExtract);'];
                    Simulink.output.evalInContext(cmd);
                catch me

                    sldiagviewer.reportError(me);
                end
            end
        end

        function createZipFileCheckboxCB(exportDlg,dlg)
            exportDlg.CreateZipFile=dlg.getWidgetValue(exportDlg.CreatePackageCheckBoxTag);
            dlg.setEnabled(exportDlg.ZipFileNameTag,exportDlg.CreateZipFile);
        end


        function browseARXMLFolderCB(exportDlg,dlg)
            folderName=uigetdir(pwd,...
            message('autosarstandard:editor:SelectARXMLFolderDialogTitle').getString());
            if~isequal(folderName,0)
                dlg.setWidgetValue(exportDlg.ExportARXMLFolderTag,folderName);
            end
        end
    end
end


function CloseModelCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    arDialog=root.getOpenDialogs.find('dialogTag',...
    autosar.composition.studio.ExportDialog.ExportDialogTag);
    for i=1:length(arDialog)
        dlgSrc=arDialog.getDialogSource();
        modelH=get_param(dlgSrc.RootModelName,'Handle');
        if modelH==eventSrc.Handle
            dlgSrc.delete;
            break;
        end
    end
end



