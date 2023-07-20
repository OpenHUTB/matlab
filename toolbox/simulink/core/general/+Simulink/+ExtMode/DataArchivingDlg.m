classdef DataArchivingDlg<handle












    properties(Access=public)



        m_ctrlPanel=[];












        m_ExtModeArchiveMode;
        m_ExtModeArchiveDirName;
        m_ExtModeArchiveFileName;
        m_ExtModeIncDirWhenArm;
        m_ExtModeAutoIncOneShot;
        m_ExtModeAddSuffixToVar;
        m_ExtModeWriteAllDataToWs;





        m_theDialog=[];
        m_theDialogPos=[];
    end

    properties(Constant,Access=public)



        m_EMDAD_Dialog_Tag='ExtModeDataArchivingDlg_Dialog_Tag';
        m_EMDAD_Enable_Archiving_Tag='ExtModeDataArchivingDlg_Enable_Archiving_Tag';
        m_EMDAD_Data_Archiving_Tag='ExtModeDataArchivingDlg_Data_Archiving_Tag';
        m_EMDAD_Directory_Name_Tag='ExtModeDataArchivingDlg_Directory_Name_Tag';
        m_EMDAD_Directory_Browse_Tag='ExtModeDataArchivingDlg_Directory_Browse_Tag';
        m_EMDAD_File_Name_Tag='ExtModeDataArchivingDlg_File_Name_Tag';
        m_EMDAD_Inc_Dir_When_Armed_Tag='ExtModeDataArchivingDlg_Inc_Dir_When_Armed_Tag';
        m_EMDAD_Inc_File_After_OneShot_Tag='ExtModeDataArchivingDlg_Inc_File_After_OneShot_Tag';
        m_EMDAD_Append_File_Suffix_Tag='ExtModeDataArchivingDlg_Append_File_Suffix_Tag';
        m_EMDAD_Write_Int_Results_To_WS_Tag='ExtModeDataArchivingDlg_Write_Int_Results_To_WS_Tag';
        m_EMDAD_Edit_Directory_Note_Tag='ExtModeDataArchivingDlg_Edit_Directory_Note_Tag';
        m_EMDAD_Edit_File_Note_Tag='ExtModeDataArchivingDlg_Edit_File_Note_Tag';
    end









    methods(Access={?Simulink.ExtMode.CtrlPanel})
        function obj=DataArchivingDlg(parent)
            obj.m_ctrlPanel=parent;
            obj.showDialog();
        end

        function showDialog(obj)











            if isempty(obj.m_theDialog)



                bd=obj.getModelName();
                obj.m_ExtModeArchiveMode=get_param(bd,'ExtModeArchiveMode');
                obj.m_ExtModeArchiveDirName=get_param(bd,'ExtModeArchiveDirName');
                obj.m_ExtModeArchiveFileName=get_param(bd,'ExtModeArchiveFileName');
                obj.m_ExtModeIncDirWhenArm=get_param(bd,'ExtModeIncDirWhenArm');
                obj.m_ExtModeAutoIncOneShot=get_param(bd,'ExtModeAutoIncOneShot');
                obj.m_ExtModeAddSuffixToVar=get_param(bd,'ExtModeAddSuffixToVar');
                obj.m_ExtModeWriteAllDataToWs=get_param(bd,'ExtModeWriteAllDataToWs');




                obj.m_theDialog=DAStudio.Dialog(obj);
                assert(~isempty(obj.m_theDialog));
                if~isempty(obj.m_theDialogPos)
                    obj.m_theDialog.position=obj.m_theDialogPos;
                end
            end





            obj.m_theDialog.show;
        end
    end




    methods(Access={?Simulink.ExtMode.CtrlPanel})
        function modelName=getModelName(obj)
            modelName=obj.m_ctrlPanel.getModelName();
        end

        function title=createDialogTitle(obj)
            title=DAStudio.message('Simulink:dialog:ExtModeEnableDataArchiving',obj.getModelName());
        end
        function setDialogTitle(obj,title)
            if~isempty(obj.m_theDialog)
                obj.m_theDialog.setTitle(title);
            end
        end

        function deleteDialog(obj)
            if~isempty(obj.m_theDialog)
                obj.m_theDialogPos=obj.m_theDialog.position;
                obj.m_theDialog.delete;
                obj.m_theDialog=[];
            end
        end

        function val=isExtModeUploadStatusInactive(obj)
            val=strcmp(get_param(obj.getModelName(),'ExtModeUploadStatus'),'inactive');
        end

        function val=isExtModeArchivingEnabled(obj)
            val=~strcmp(obj.m_ExtModeArchiveMode,'off');
        end
    end




    methods(Access=public)
        function enableArchiveCheckBoxCB(obj,val)
            if val
                obj.m_ExtModeArchiveMode='auto';
            else
                obj.m_ExtModeArchiveMode='off';
            end
        end

        function directoryNameEditCB(obj,val)
            obj.m_ExtModeArchiveDirName=val;
        end

        function directoryNameBrowseCB(obj)
            dir=uigetdir;
            if~strcmpi(class(dir),'double')
                obj.m_theDialog.setWidgetValue(obj.m_EMDAD_Directory_Name_Tag,dir);
                directoryNameEditCB(obj,dir);
            end
        end

        function fileNameEditCB(obj,val)
            obj.m_ExtModeArchiveFileName=val;
        end

        function incDirWhenArmedCheckBoxCB(obj,val)
            obj.m_ExtModeIncDirWhenArm=slprivate('onoff',val);
        end

        function incFileAfterOneShotCheckBoxCB(obj,val)
            obj.m_ExtModeAutoIncOneShot=slprivate('onoff',val);
        end

        function appendFileSuffixCheckBoxCB(obj,val)
            obj.m_ExtModeAddSuffixToVar=slprivate('onoff',val);
        end

        function writeIntResultsToWSCheckBoxCB(obj,val)
            obj.m_ExtModeWriteAllDataToWs=slprivate('onoff',val);
        end

        function editDirNoteButtonCB(obj)
            bd=obj.getModelName();






            lastFileWritten=get_param(bd,'ExtModeLastArchiveFile');
            fileToEdit='';
            if~isempty(lastFileWritten),
                [dirName,~,~]=fileparts(lastFileWritten);
                fileToEdit=[dirName,filesep,'note.txt'];
            end

            if~isempty(fileToEdit)




                if~exist(fileToEdit,'file')
                    fid=fopen(fileToEdit,'w');
                    if fid==-1,
                        DAStudio.error('Simulink:dialog:ExtModeCouldNotCreateDirNoteFile',...
                        fileToEdit);
                    end
                    fclose(fid);
                end

                try
                    edit(fileToEdit);
                catch ME %#ok
                    MSLDiagnostic('Simulink:dialog:ExtModeCouldNotOpenDirNoteFile',...
                    fileToEdit).reportAsWarning;
                    try
                        edit;
                    catch ME
                        DAStudio.error('Simulink:dialog:ExtModeCouldNotOpenDefaultEditor');
                    end
                end
            else
                try
                    edit;
                catch ME
                    DAStudio.error('Simulink:dialog:ExtModeCouldNotOpenDefaultEditor');
                end
            end
        end

        function editFileNoteButtonCB(obj)
            bd=obj.getModelName();

            lastFileWritten=get_param(bd,'ExtModeLastArchiveFile');
            if~isempty(lastFileWritten),
                defFile=lastFileWritten;

                if isunix,
                    defFile(defFile=='\')='/';
                else
                    defFile(defFile=='/')='\';
                end
            else
                defFile='*.mat';
            end

            [fname,pname]=uigetfile(defFile,DAStudio.message('Simulink:dialog:ExtModeEditFileNote'));
            if fname==0

                return;
            end

            fileToEdit=[pname,fname];

            note='';
            try
                load(fileToEdit,'note');
            catch ME
                DAStudio.error('Simulink:dialog:ExtModeCouldNotLoadNote',fileToEdit,ME.message);
            end

            if~iscell(note)
                note={note};
            end

            note=inputdlg(DAStudio.message('Simulink:dialog:ExtModeEnterNoteFor',fileToEdit),...
            DAStudio.message('Simulink:dialog:ExtModeExternalMode'),15,note);
            if~isempty(note)
                save(fileToEdit,'-append','note');
            end
        end

        function closeCB(obj)
            obj.m_theDialogPos=obj.m_theDialog.position;
            obj.m_theDialog=[];
        end

        function[closeDlg,errmsg]=preApplyCB(obj)
            closeDlg=true;
            errmsg='';

            bd=obj.getModelName();
            try
                set_param(bd,'ExtModeArchiveMode',obj.m_ExtModeArchiveMode);
                set_param(bd,'ExtModeArchiveDirName',obj.m_ExtModeArchiveDirName);
                set_param(bd,'ExtModeArchiveFileName',obj.m_ExtModeArchiveFileName);
                set_param(bd,'ExtModeIncDirWhenArm',obj.m_ExtModeIncDirWhenArm);
                set_param(bd,'ExtModeAutoIncOneShot',obj.m_ExtModeAutoIncOneShot);
                set_param(bd,'ExtModeAddSuffixToVar',obj.m_ExtModeAddSuffixToVar);
                set_param(bd,'ExtModeWriteAllDataToWs',obj.m_ExtModeWriteAllDataToWs);
            catch ME




                closeDlg=false;
                errmsg=ME.message;
            end
        end
    end


    methods



        function dlg=getDialogSchema(obj,~)



            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeEnableArchiving');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMDAD_Enable_Archiving_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeEnableArchivingTooltip',obj.getModelName());
            widget.Value=obj.isExtModeArchivingEnabled();
            widget.ObjectMethod='enableArchiveCheckBoxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.isExtModeUploadStatusInactive();
            widget.RowSpan=[1,1];
            widget.ColSpan=[1,4];
            widget.DialogRefresh=true;

            EnableArchiveCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeDirectory');
            widget.Type='edit';
            widget.Tag=obj.m_EMDAD_Directory_Name_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeDirectoryTooltip');
            widget.Value=obj.m_ExtModeArchiveDirName;
            widget.ObjectMethod='directoryNameEditCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[2,2];
            widget.ColSpan=[1,3];

            DirectoryNameEdit=widget;

            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeDirectoryBrowse');
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMDAD_Directory_Browse_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeDirectoryBrowseTooltip');
            widget.ObjectMethod='directoryNameBrowseCB';
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[2,2];
            widget.ColSpan=[4,4];
            widget.DialogRefresh=true;

            DirectoryNameButton=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeFile');
            widget.Type='edit';
            widget.Tag=obj.m_EMDAD_File_Name_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeFileTooltip');
            widget.Value=obj.m_ExtModeArchiveFileName;
            widget.ObjectMethod='fileNameEditCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[3,3];
            widget.ColSpan=[1,4];

            FileNameEdit=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeIncDirWhenArmed');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMDAD_Inc_Dir_When_Armed_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeIncDirWhenArmedTooltip');
            widget.Value=slprivate('onoff',obj.m_ExtModeIncDirWhenArm);
            widget.ObjectMethod='incDirWhenArmedCheckBoxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[4,4];
            widget.ColSpan=[1,4];

            IncDirWhenArmedCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeIncFileAfterOneShot');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMDAD_Inc_File_After_OneShot_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeIncFileAfterOneShotTooltip');
            widget.Value=slprivate('onoff',obj.m_ExtModeAutoIncOneShot);
            widget.ObjectMethod='incFileAfterOneShotCheckBoxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[5,5];
            widget.ColSpan=[1,4];

            IncFileAfterOneShotCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeAppendFileSuffix');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMDAD_Append_File_Suffix_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeAppendFileSuffixTooltip');
            widget.Value=slprivate('onoff',obj.m_ExtModeAddSuffixToVar);
            widget.ObjectMethod='appendFileSuffixCheckBoxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[6,6];
            widget.ColSpan=[1,4];

            AppendFileSuffixCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeWriteIntResultsToWS');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMDAD_Write_Int_Results_To_WS_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeWriteIntResultsToWSTooltip');
            widget.Value=slprivate('onoff',obj.m_ExtModeWriteAllDataToWs);
            widget.ObjectMethod='writeIntResultsToWSCheckBoxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[7,7];
            widget.ColSpan=[1,4];

            WriteIntResultsToWSCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeEditDirectoryNote');
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMDAD_Edit_Directory_Note_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeEditDirectoryNoteTooltip');
            widget.ObjectMethod='editDirNoteButtonCB';
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[8,8];
            widget.ColSpan=[1,2];

            EditDirNoteButton=widget;




            widget=[];
            widget.Name=[DAStudio.message('Simulink:dialog:ExtModeEditFileNote'),' ...'];
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMDAD_Edit_File_Note_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeEditFileNoteTooltip');
            widget.ObjectMethod='editFileNoteButtonCB';
            widget.Enabled=obj.isExtModeUploadStatusInactive()&&obj.isExtModeArchivingEnabled();
            widget.RowSpan=[8,8];
            widget.ColSpan=[3,4];

            EditFileNoteButton=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeDataArchivingGroup');
            widget.Tag=obj.m_EMDAD_Data_Archiving_Tag;
            widget.Type='group';
            widget.Items={EnableArchiveCheckBox,DirectoryNameEdit,DirectoryNameButton,...
            FileNameEdit,IncDirWhenArmedCheckBox,IncFileAfterOneShotCheckBox,...
            AppendFileSuffixCheckBox,WriteIntResultsToWSCheckBox,...
            EditDirNoteButton,EditFileNoteButton};
            widget.LayoutGrid=[8,4];

            DataArchivingGroup=widget;




            dlg.DialogTitle=obj.createDialogTitle();
            dlg.DialogTag=obj.m_EMDAD_Dialog_Tag;
            dlg.HelpMethod='helpview';
            dlg.HelpArgs={fullfile(docroot,'toolbox','rtw','helptargets.map'),'rtw_data_archiving'};
            dlg.Items={DataArchivingGroup};
            dlg.StandaloneButtonSet={'OK','Cancel','Help','Apply'};
            dlg.CloseMethod='closeCB';
            dlg.PreApplyMethod='preApplyCB';
            dlg.Sticky=false;
        end
    end
end
