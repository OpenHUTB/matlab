




classdef SSChoicesToSSRefChoicesConvertDlg<handle

    methods(Static,Access='public')


        function createAndLaunchSSChoicesToSSRefChoicesConvertDlg(blkHandle,vssDlgHandle)
            try
                convertDlgHandle=Simulink.variant.vas.SSChoicesToSSRefChoicesConvertDlg.createDialog(...
                blkHandle,vssDlgHandle);
                convertDlgHandle.show();
            catch ex
                throwAsCaller(ex);
            end
        end








        function conversionDlgHandle=createDialog(vssBlkHandle,vssDlgHandle)
            import Simulink.variant.vas.*


            staticData=SSChoicesToSSRefChoicesConvertDlg.getStaticDialogData();
            if~isempty(staticData.Handles)
                index=SSChoicesToSSRefChoicesConvertDlg.getDialogDataIndex(staticData,vssBlkHandle);
                if~isempty(index)
                    conversionDlgHandle=staticData.Handles(index).DialogHandle;
                    return;
                end
            end


            obj=SSChoicesToSSRefChoicesConvertDlg(vssBlkHandle,vssDlgHandle);
            conversionDlgHandle=DAStudio.Dialog(obj);


            staticData.Handles(end+1).BlockHandle=vssBlkHandle;
            staticData.Handles(end).DialogHandle=conversionDlgHandle;
        end


    end

    properties(Access='private')
        m_vssBlkHandle;
        m_vssDlgHandle;
        m_blockRemoveListener;
        m_modelCloseListener;
    end

    methods(Access='public')


        function dlg=getDialogSchema(this)
            import Simulink.variant.vas.*

            dlg.DialogTitle=this.m_dialogTitle;
            dlg.DialogTag=this.m_dialogTag;


            textConvertToVASDesc.Name=...
            DAStudio.message('Simulink:VariantBlockPrompts:ConversionDialogDesc',getfullname(this.m_vssBlkHandle));
            textConvertToVASDesc.Tag=this.m_convertToVASDescTextTag;
            textConvertToVASDesc.Type='text';
            textConvertToVASDesc.WordWrap=true;





            textFolderPathPrompt.Name=DAStudio.message('Simulink:VariantBlockPrompts:NewSSRefFolderPath');
            textFolderPathPrompt.Type='text';
            textFolderPathPrompt.Tag=this.m_folderPathPromptTextTag;
            textFolderPathPrompt.RowSpan=[1,1];
            textFolderPathPrompt.ColSpan=[1,1];
            textFolderPathPrompt.WordWrap=true;
            textFolderPathPrompt.Bold=false;


            editFolderPath.HideName=true;
            editFolderPath.Type='edit';
            editFolderPath.Tag=this.m_folderPathEditTag;
            editFolderPath.RowSpan=[1,1];
            editFolderPath.ColSpan=[1,1];
            editFolderPath.Value=this.getFolderPathDefaultValue();
            editFolderPath.ObjectMethod='folderPathEditCallback';
            editFolderPath.MethodArgs={'%dialog'};
            editFolderPath.ArgDataTypes={'handle'};


            pushbuttonBrowse.Name=DAStudio.message('Simulink:VariantBlockPrompts:BrowseFolder');
            pushbuttonBrowse.Type='pushbutton';
            pushbuttonBrowse.Tag=this.m_browseButtonTag;
            pushbuttonBrowse.RowSpan=[1,1];
            pushbuttonBrowse.ColSpan=[2,2];
            pushbuttonBrowse.ObjectMethod='browseFolderForNewSSRefFiles';
            pushbuttonBrowse.MethodArgs={'%dialog'};
            pushbuttonBrowse.ArgDataTypes={'handle'};

            panelFolderPathEdit.Type='panel';
            panelFolderPathEdit.LayoutGrid=[1,2];
            panelFolderPathEdit.Items={editFolderPath,pushbuttonBrowse};
            panelFolderPathEdit.RowSpan=[2,2];
            panelFolderPathEdit.ColSpan=[1,1];
            panelFolderPathEdit.Tag=this.m_folderPathEditPanelTag;




            textAbsPathPrompt.Type='text';
            textAbsPathPrompt.Tag=this.m_absPathPromptTextTag;
            textAbsPathPrompt.Name=this.m_absPathText;
            textAbsPathPrompt.RowSpan=[3,3];
            textAbsPathPrompt.ColSpan=[1,1];

            textAbsPathValue.Type='text';
            textAbsPathValue.Tag=this.m_absPathValueTextTag;
            textAbsPathValue.Name=this.getAbsolutePathWrtCurrentBdFolder(editFolderPath.Value);
            textAbsPathValue.RowSpan=[4,4];
            textAbsPathValue.ColSpan=[1,1];
            textAbsPathValue.WordWrap=true;
            textAbsPathValue.BackgroundColor=255*ones(1,3);


            textNewSSRefFilenamesPrompt.Type='text';
            textNewSSRefFilenamesPrompt.Tag=this.m_newSSRefFilenamesPromptTextTag;
            textNewSSRefFilenamesPrompt.Name=DAStudio.message('Simulink:VariantBlockPrompts:ListNewSSRef');
            textNewSSRefFilenamesPrompt.RowSpan=[5,5];
            textNewSSRefFilenamesPrompt.ColSpan=[1,1];
            textNewSSRefFilenamesPrompt.WordWrap=true;
            textNewSSRefFilenamesPrompt.Bold=false;

            textNewSSRefFilenamesValue.Type='text';
            textNewSSRefFilenamesValue.Tag=this.m_newSSRefFilenamesValueTextTag;
            textNewSSRefFilenamesValue.Name=char(join(this.getListOfNewSSRefFileNames(),newline));
            textNewSSRefFilenamesValue.RowSpan=[6,6];
            textNewSSRefFilenamesValue.ColSpan=[1,1];
            textNewSSRefFilenamesValue.WordWrap=true;
            textNewSSRefFilenamesValue.Italic=0;
            textNewSSRefFilenamesValue.BackgroundColor=textAbsPathValue.BackgroundColor;





            textDialogSizeSpacer.Type='text';
            textDialogSizeSpacer.Tag=this.m_dialogSizeSpacerTextTag;
            textDialogSizeSpacer.Name=this.m_spaceTextForSpacer;
            textDialogSizeSpacer.RowSpan=[7,7];
            textDialogSizeSpacer.ColSpan=[1,1];

            groupConversion.Type='group';
            groupConversion.Tag=this.m_conversionGroupTag;
            groupConversion.LayoutGrid=[7,1];
            groupConversion.Items={textFolderPathPrompt,panelFolderPathEdit,...
            textAbsPathPrompt,textAbsPathValue,...
            textNewSSRefFilenamesPrompt,textNewSSRefFilenamesValue,...
            textDialogSizeSpacer};
            groupConversion.RowStretch=[0,0,0,0,0,0,1];


            dlg.Items={textConvertToVASDesc,groupConversion};



            pushbuttonConvert.Name=DAStudio.message('Simulink:SubsystemReference:SRConvert');
            pushbuttonConvert.Type='pushbutton';
            pushbuttonConvert.Tag=this.m_convertButtonTag;
            pushbuttonConvert.ColSpan=[1,1];
            pushbuttonConvert.RowSpan=[1,1];
            pushbuttonConvert.ObjectMethod='convertButtonCallback';
            pushbuttonConvert.MethodArgs={'%dialog',this.m_convertButtonTag};
            pushbuttonConvert.ArgDataTypes={'handle','string'};

            pushbuttonCancel.Name=DAStudio.message('Simulink:SubsystemReference:SRCancel');
            pushbuttonCancel.Type='pushbutton';
            pushbuttonCancel.Tag=this.m_cancelButtonTag;
            pushbuttonCancel.ColSpan=[2,2];
            pushbuttonCancel.RowSpan=[1,1];
            pushbuttonCancel.ObjectMethod='cancelButtonCallback';
            pushbuttonCancel.MethodArgs={'%dialog'};
            pushbuttonCancel.ArgDataTypes={'handle'};

            panelBottomButtons.Type='panel';
            panelBottomButtons.Items={pushbuttonConvert,pushbuttonCancel};
            panelBottomButtons.Tag=this.m_bottomButtonsPanelTag;
            panelBottomButtons.LayoutGrid=[1,2];



            dlg.StandaloneButtonSet=panelBottomButtons;

            dlg.CloseCallback='onDialogCloseCallback';
            dlg.CloseArgs={this,'%dialog'};
            dlg.Sticky=true;

        end



        function folderPathEditCallback(this,dlg)
            folderPathValue=getWidgetValue(dlg,this.m_folderPathEditTag);
            absPathToFolder=this.getAbsolutePathWrtCurrentBdFolder(folderPathValue);
            setWidgetValue(dlg,this.m_absPathValueTextTag,absPathToFolder);
        end



        function browseFolderForNewSSRefFiles(this,dlg)
            absPathToCurrBdFolder=this.getAbsPathToCurrentBdFolder();
            absPathToSelectedFolder=Simulink.variant.vas.VASUtils.browseFolder(absPathToCurrBdFolder,...
            DAStudio.message('Simulink:VariantBlockPrompts:VASBrowseBtnFolderSelectorDlgTitle'));

            if isempty(absPathToSelectedFolder)
                return;
            end

            pathToSetInEditbox=slInternal('VASFilesystemHelper_GetRelativeWrtBaseAbsolute',...
            absPathToSelectedFolder,pwd);

            setWidgetValue(dlg,this.m_folderPathEditTag,pathToSetInEditbox);

            folderPathEditCallback(this,dlg);
        end



        function convertButtonCallback(this,dlg,~)

            absFolderPathToKeepNewSSRefFiles=this.getAbsolutePathWrtCurrentBdFolder(dlg.getWidgetValue(this.m_folderPathEditTag));

            toProceed=this.displayQuestDlgIfOverwritingExistingFiles(absFolderPathToKeepNewSSRefFiles);
            if~toProceed
                return;
            end

            if isfolder(absFolderPathToKeepNewSSRefFiles)
                toProceed=Simulink.variant.vas.VASUtils.displayQuestDialogIfFolderNotOnPath(absFolderPathToKeepNewSSRefFiles);
                if~toProceed
                    return;
                end
            end

            this.enableDisableActionsOnDialog(dlg,false);
            this.showConversionMessageOnDialog(dlg);

            errMsg='';
            try
                Simulink.VariantManager.convertToVariantAssemblySubsystem(this.m_vssBlkHandle,absFolderPathToKeepNewSSRefFiles);
            catch ex
                errMsg=Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(ex);
            end

            cleanupAndErrorHandling(this,dlg,errMsg);

        end



        function cleanupAndErrorHandling(this,dlg,errMsg)
            this.hideConversionMessageOnDialog(dlg);

            if isempty(errMsg)
                dlg.delete();


                if~isempty(this.m_vssDlgHandle)


                    source=this.m_vssDlgHandle.getSource;
                    source.UserData=[];
                    this.m_vssDlgHandle.refresh;
                end

                return;
            end

            errMsg=slprivate('removeHyperLinksFromMessage',errMsg);
            errDlg=errordlg(errMsg,...
            DAStudio.message('Simulink:VariantBlockPrompts:ConversionDialogTitle'),'modal');
            waitfor(errDlg);

            this.enableDisableActionsOnDialog(dlg,true);
        end



        function showConversionMessageOnDialog(this,dlg)
            convertingText=DAStudio.message('Simulink:SubsystemReference:ConvertingText');
            spaceText=this.m_spaceTextForSpacer;
            spaceText(1:length(convertingText))=[];
            convertingText=[convertingText,spaceText];
            dlg.setWidgetValue(this.m_dialogSizeSpacerTextTag,convertingText)
        end



        function hideConversionMessageOnDialog(this,dlg)
            dlg.setWidgetValue(this.m_dialogSizeSpacerTextTag,this.m_spaceTextForSpacer);
        end



        function enableDisableActionsOnDialog(this,dlg,enablestate)
            dlg.setEnabled(this.m_folderPathEditPanelTag,enablestate);
            dlg.setEnabled(this.m_bottomButtonsPanelTag,enablestate);
        end



        function cancelButtonCallback(~,dlg)
            dlg.delete();
        end



        function onDialogCloseCallback(~,conversionDlgHandle)
            staticData=Simulink.variant.vas.SSChoicesToSSRefChoicesConvertDlg.getStaticDialogData();
            index=find([staticData.Handles.DialogHandle]==conversionDlgHandle);
            if~isempty(index)
                staticData.Handles(index)=[];
            end
        end



        function onBlockRemoveCallback(this,~,event,~,~)
            if isequal(event.BlockHandle,this.m_vssBlkHandle)
                dlgHandle=this.getDialogHandle(this.m_vssBlkHandle);
                if ishandle(dlgHandle)
                    dlgHandle.delete();
                end
            end
        end



        function onModelCloseCallback(this,~,event,~,~)
            if is_simulink_handle(this.m_vssBlkHandle)
                if isequal(event.Source.Name,get_param(bdroot(this.m_vssBlkHandle),'Name'))
                    dlgHandle=this.getDialogHandle(this.m_vssBlkHandle);
                    if ishandle(dlgHandle)
                        dlgHandle.delete();
                    end
                end
            end
        end


    end

    methods(Static,Access='private')


        function obj=SSChoicesToSSRefChoicesConvertDlg(vssBlkHandle,vssDlgHandle)
            obj.m_vssBlkHandle=vssBlkHandle;
            obj.m_vssDlgHandle=vssDlgHandle;

            bdHandle=bdroot(vssBlkHandle);
            bdCosObj=get_param(bdHandle,'InternalObject');

            obj.m_blockRemoveListener=addlistener(bdCosObj,...
            'SLGraphicalEvent::REMOVE_BLOCK_MODEL_EVENT',...
            @(src,evnt)obj.onBlockRemoveCallback(src,evnt,'',''));

            obj.m_modelCloseListener=addlistener(bdCosObj,...
            'SLGraphicalEvent::DESTROY_MODEL_EVENT',...
            @(src,evnt)obj.onModelCloseCallback(src,evnt,'',''));
        end





        function dialogData=getStaticDialogData()
            persistent static_dialog_data;
            if isempty(static_dialog_data)
                static_dialog_data=Simulink.variant.vas.SSChoicesToSSRefChoicesConvertDlgData;
            end
            dialogData=static_dialog_data;
        end




        function index=getDialogDataIndex(dlgData,blkHandle)
            if~isempty(dlgData.Handles)
                index=find([dlgData.Handles.BlockHandle]==blkHandle);
            else
                index=[];
            end
        end



        function dlgHandle=getDialogHandle(blkHandle)
            staticDlgData=Simulink.variant.vas.SSChoicesToSSRefChoicesConvertDlg.getStaticDialogData();
            if~isempty(staticDlgData.Handles)
                index=Simulink.variant.vas.SSChoicesToSSRefChoicesConvertDlg.getDialogDataIndex(staticDlgData,blkHandle);
                if~isempty(index)
                    dlgHandle=staticDlgData.Handles(index).DialogHandle;
                    return;
                end
            end
            dlgHandle=[];
        end


    end

    methods(Access='private')


        function defaultVal=getFolderPathDefaultValue(this)
            defaultVal=[Simulink.variant.vas.VASUtils.getAllowedName(get_param(this.m_vssBlkHandle,'Name'))...
            ,DAStudio.message('Simulink:VariantBlockPrompts:NewSSRefFolderNamePostFix')];
        end



        function newSSRefFilenames=getListOfNewSSRefFileNames(this)
            choices=get_param(this.m_vssBlkHandle,'Variants');
            nChoices=length(choices);
            newSSRefFilenames=cell(nChoices,1);
            ssCounter=0;
            for idx=1:nChoices
                choiceBlkPath=choices(idx).BlockName;
                if strcmp(get_param(choiceBlkPath,'BlockType'),'SubSystem')&&...
                    isempty(get_param(choiceBlkPath,'ReferencedSubsystem'))
                    choiceBlkName=get_param(choiceBlkPath,'Name');
                    ssCounter=ssCounter+1;
                    newSSRefFilenames{ssCounter}=...
                    [Simulink.variant.vas.VASUtils.getAllowedName(choiceBlkName),'.',get_param(0,'ModelFileFormat')];
                end
            end
            newSSRefFilenames(ssCounter+1:end)=[];
        end




        function absPath=getAbsolutePathWrtCurrentBdFolder(this,folderPath)
            if slInternal('VASFilesystemHelper_IsRelativePath',folderPath)
                absPath=fullfile(this.getAbsPathToCurrentBdFolder(),folderPath);
            else
                absPath=folderPath;
            end
        end




        function absPathToCurrBdFolder=getAbsPathToCurrentBdFolder(this)
            absPathToCurrBdFolder=fileparts(get_param(bdroot(this.m_vssBlkHandle),'FileName'));
            if isempty(absPathToCurrBdFolder)
                absPathToCurrBdFolder=pwd;
            end
        end



        function toProceed=displayQuestDlgIfOverwritingExistingFiles(this,absPathToFolder)
            newSSRefFilenames=this.getListOfNewSSRefFileNames();

            nNewSSRefs=length(newSSRefFilenames);
            filesToGetOverwritten=cell(nNewSSRefs,1);
            fileCounter=0;
            for idx=1:nNewSSRefs
                if isfile(fullfile(absPathToFolder,newSSRefFilenames{idx}))
                    fileCounter=fileCounter+1;
                    filesToGetOverwritten{fileCounter}=newSSRefFilenames{idx};
                end
            end
            filesToGetOverwritten(fileCounter+1:end)=[];

            if isempty(filesToGetOverwritten)
                toProceed=true;
                return;
            end

            questDlgMsg=DAStudio.message('Simulink:VariantBlockPrompts:FilesExist',...
            absPathToFolder,char(join(filesToGetOverwritten,newline)));
            yes=message('Simulink:editor:DialogYes').getString;
            no=message('Simulink:editor:DialogNo').getString;
            userChoice=questdlg(questDlgMsg,this.m_dialogTitle,yes,no,yes);

            switch userChoice
            case yes
                toProceed=true;
            otherwise
                toProceed=false;
            end
        end

    end

    properties(Constant,Access='private')
        m_spaceTextForSpacer=char(32*ones(1,120));
        m_absPathText=DAStudio.message('Simulink:VariantBlockPrompts:AbsPathPrompt');
        m_dialogTitle=DAStudio.message('Simulink:VariantBlockPrompts:ConversionDialogTitle');


        m_dialogTag='ConvertSSChoicesToSSRefDialog';
        m_convertToVASDescTextTag='ConvertToVASHelpText';
        m_folderPathPromptTextTag='FolderPathPromptText';
        m_folderPathEditTag='FolderPathEdit';
        m_folderPathEditPanelTag='FolderPathEditPanel';
        m_browseButtonTag='BrowseButton';
        m_absPathPromptTextTag='AbsPathPromptText';
        m_absPathValueTextTag='AbsPathValueText';
        m_newSSRefFilenamesPromptTextTag='NewSSRefFilenamesPromptText';
        m_newSSRefFilenamesValueTextTag='NewSSRefFilenamesValueText';
        m_msgDuringConvertTextTag='MsgDuringConvertText';
        m_conversionGroupTag='ConversionGroup';
        m_convertButtonTag='ConvertButton';
        m_cancelButtonTag='CancelButton';
        m_bottomButtonsPanelTag='BottomButtonsPanel';
        m_dialogSizeSpacerTextTag='DialogSizeSpacerText';
    end

end


