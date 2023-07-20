function dlgstruct=getDialogSchema(h,name)%#ok




    persistent DIALOG_USERDATA;%#ok
    userData=[];%#ok

    if isempty(h.savemodel)
        oldParams=rmisl.model_settings(h.modelH,'get');
        h.surrogatepath=oldParams.doors.surrogatepath;
        h.surrogateId=oldParams.doors.surrogateId;
        h.savemodel=oldParams.doors.savemodel;
        h.savesurrogate=oldParams.doors.savesurrogate;
        h.doorsLinks2sl=oldParams.doors.doorsLinks2sl;
        h.slLinks2Doors=oldParams.doors.slLinks2Doors;
        h.purgeSimulink=oldParams.doors.purgeSimulink;
        h.purgeDoors=oldParams.doors.purgeDoors;
        h.detaillevel=oldParams.doors.detaillevel;
        h.synctime=oldParams.doors.synctime;
        h.updateLinks=oldParams.doors.updateLinks;
    end



    bPathEdit.Type='edit';
    bPathEdit.Tag='bPathEdit';
    bPathEdit.RowSpan=[1,1];
    bPathEdit.ColSpan=[1,3];
    bPathEdit.Value=h.surrogatepath;
    bPathEdit.MatlabMethod='feval';
    bPathEdit.MatlabArgs={@doPathEdit,'%source','%dialog'};

    bBrowse.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:Browse'));
    bBrowse.Tag='bBrowse';
    bBrowse.Type='pushbutton';
    bBrowse.RowSpan=[1,1];
    bBrowse.ColSpan=[4,4];
    bBrowse.MatlabMethod='feval';
    bBrowse.MatlabArgs={@doDoorsBrowse,'%source','%dialog'};

    tDescDoors.Type='text';
    tDescDoors.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:ModelNameMacro','$ModelName$'));
    tDescDoors.RowSpan=[2,2];
    tDescDoors.ColSpan=[1,4];

    gSurrogateName.Type='group';
    gSurrogateName.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DoorsSurrogatePath'));
    gSurrogateName.LayoutGrid=[2,4];
    gSurrogateName.Items={tDescDoors,bPathEdit,bBrowse};
    gSurrogateName.RowSpan=[1,1];
    gSurrogateName.ColSpan=[1,4];



    tDescDetails.Type='text';
    tDescDetails.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:ExtraMappingLabel'));

    bDetailsBox.Type='combobox';
    bDetailsBox.Tag='bDetailsBox';
    optionTable=detailLevelOptions();
    bDetailsBox.Entries=optionTable(:,1)';
    bDetailsBox.MatlabMethod='feval';
    for tableIdx=1:length(optionTable)
        tableValue=optionTable(tableIdx,2);
        if tableValue{1}==h.detaillevel
            bDetailsBox.Value=tableIdx-1;
            break;
        end
    end
    bDetailsBox.MatlabArgs={@doDetailsBox,'%source','%dialog'};
    bDetailsBox.ToolTip=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:ExtraMappingTip'));

    gDescDetails.Type='group';
    gDescDetails.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:ExtraMappingTitle'));
    gDescDetails.RowSpan=[2,2];
    gDescDetails.ColSpan=[1,4];
    gDescDetails.Items={tDescDetails,bDetailsBox};



    bUpdateLinks.Type='checkbox';
    bUpdateLinks.Tag='bUpdateLinks';
    bUpdateLinks.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:UpdateLinks'));
    bUpdateLinks.RowSpan=[1,1];
    bUpdateLinks.ColSpan=[1,4];
    bUpdateLinks.Value=h.updateLinks;
    bUpdateLinks.MatlabMethod='feval';
    bUpdateLinks.MatlabArgs={@doUpdateLinks,'%source','%dialog'};

    rCopyLinks.Type='radiobutton';
    rCopyLinks.Tag='rCopyLinks';
    rCopyLinks.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:CopyUnmatched'));
    rCopyLinks.RowSpan=[2,2];
    rCopyLinks.ColSpan=[1,2];
    rCopyLinks.Values=[0,1];
    if h.slLinks2Doors
        rCopyLinks.Value=0;
        h.doorsLinks2sl=0;
    elseif h.doorsLinks2sl
        rCopyLinks.Value=1;
    else
        rCopyLinks.Value=0;
        bUpdateLinks.Value=0;
    end
    rCopyLinks.Enabled=bUpdateLinks.Value;
    rCopyLinks.Entries={...
    getString(message('Slvnv:reqmgt:Doors:getDialogSchema:FromSimulinkToDoors')),...
    getString(message('Slvnv:reqmgt:Doors:getDialogSchema:FromDoorsToSimulink'))};
    rCopyLinks.MatlabMethod='feval';
    rCopyLinks.MatlabArgs={@doCopyLinks,'%source','%dialog'};

    bPurgeInDoors.Type='checkbox';
    bPurgeInDoors.Tag='bPurgeInDoors';
    bPurgeInDoors.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:RemoveUnmatchedInDoors'));
    bPurgeInDoors.Value=h.purgeDoors;
    bPurgeInDoors.MatlabMethod='feval';
    bPurgeInDoors.MatlabArgs={@doPurgeInDoors,'%source','%dialog'};
    bPurgeInDoors.Enabled=bUpdateLinks.Value==1&&rCopyLinks.Value==0;

    bPurgeInSimulink.Type='checkbox';
    bPurgeInSimulink.Tag='bPurgeInSimulink';
    bPurgeInSimulink.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:RemoveUnmatchedInSimulink'));
    bPurgeInSimulink.Value=h.purgeSimulink;
    bPurgeInSimulink.MatlabMethod='feval';
    bPurgeInSimulink.MatlabArgs={@doPurgeInSimulink,'%source','%dialog'};
    bPurgeInSimulink.Enabled=bUpdateLinks.Value==1&&rCopyLinks.Value==1;

    pDeleteLinks.Type='group';
    pDeleteLinks.Tag='pDeleteLinks';
    pDeleteLinks.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DeleteUnmatched'));
    pDeleteLinks.RowSpan=[2,2];
    pDeleteLinks.ColSpan=[3,4];
    pDeleteLinks.LayoutGrid=[2,1];
    pDeleteLinks.Items={bPurgeInDoors,bPurgeInSimulink};

    pUpdateLinks.Type='group';
    pUpdateLinks.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:SynchronizingLinks'));
    pUpdateLinks.RowSpan=[3,3];
    pUpdateLinks.ColSpan=[1,4];
    pUpdateLinks.LayoutGrid=[2,4];
    pUpdateLinks.Items={bUpdateLinks,rCopyLinks,pDeleteLinks};



    bSaveSurgCheck.Type='checkbox';
    bSaveSurgCheck.Tag='bSaveSurgCheck';
    bSaveSurgCheck.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:SaveSurrogate'));
    bSaveSurgCheck.Value=h.savesurrogate;
    bSaveSurgCheck.MatlabMethod='feval';
    bSaveSurgCheck.MatlabArgs={@doSaveSurgCheck,'%source','%dialog'};

    bSaveModelBox.Type='checkbox';
    bSaveModelBox.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:SaveModel'));
    bSaveModelBox.Value=h.savemodel;
    bSaveModelBox.Tag='bSaveModelBox';
    bSaveModelBox.MatlabMethod='feval';
    bSaveModelBox.MatlabArgs={@doSaveModelBox,'%source','%dialog'};

    gSave.Type='group';
    gSave.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:AfterSynchronizationTitle'));
    gSave.LayoutGrid=[2,1];
    gSave.Items={bSaveSurgCheck,bSaveModelBox};
    gSave.RowSpan=[4,4];
    gSave.ColSpan=[1,4];

    bSyncButton.Type='pushbutton';
    bSyncButton.Tag='bSyncButton';
    bSyncButton.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:Synchronize'));
    bSyncButton.RowSpan=[5,5];
    bSyncButton.ColSpan=[2,2];
    bSyncButton.MatlabMethod='feval';
    bSyncButton.MatlabArgs={@doSyncNow,'%source','%dialog'};

    bCancelButton.Type='pushbutton';
    bCancelButton.Tag='bCancelButton';
    bCancelButton.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:Cancel'));
    bCancelButton.RowSpan=[5,5];
    bCancelButton.ColSpan=[3,3];
    bCancelButton.MatlabMethod='feval';
    bCancelButton.MatlabArgs={@doCancel,'%source','%dialog'};

    bApplyButton.Type='pushbutton';
    bApplyButton.Tag='bApplyButton';
    bApplyButton.Name=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:SaveSettings'));
    bApplyButton.RowSpan=[5,5];
    bApplyButton.ColSpan=[4,4];
    bApplyButton.MatlabMethod='feval';
    bApplyButton.MatlabArgs={@ReqSync.rmidlg_doors_apply,'%source','%dialog'};

    if isempty(h.modelH)
        modelName='???';
    else
        modelName=get_param(h.modelH,'Name');
    end
    dlgstruct.DialogTitle=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DoorsSyncSettingsDlgTitle',modelName));
    dlgstruct.LayoutGrid=[5,4];
    dlgstruct.Items={gSurrogateName,...
    gDescDetails,...
    pUpdateLinks,...
    gSave,...
    bSyncButton,bCancelButton,bApplyButton};
    dlgstruct.SmartApply=true;
    dlgstruct.PreApplyCallback='ReqSync.rmidlg_doors_apply';
    dlgstruct.PreApplyArgs={h};
    dlgstruct.StandaloneButtonSet={''};
end


function doCancel(h,dialogH)%#ok
    delete(dialogH);
end

function doDoorsBrowse(h,dialogH)
    if~rmidoors.isAppRunning()
        return;
    end

    hDoors=rmidoors.comApp();




    ReqMgr.activeDlgUtil(dialogH);
    fullPath=rmidoors.selectModulePath(hDoors);
    ReqMgr.activeDlgUtil('clear');

    if~isempty(fullPath)
        h.surrogatepath=fullPath;
    end
    dialogH.refresh();
    dialogH.enableApplyButton(true);
end

function doCopyLinks(h,dialogH)
    value=dialogH.getWidgetValue('rCopyLinks');
    if value==0
        h.slLinks2Doors=1;
        h.doorsLinks2sl=0;
    else
        h.slLinks2Doors=0;
        h.doorsLinks2sl=1;
    end
    dialogH.refresh();
end

function doUpdateLinks(h,dialogH)
    h.updateLinks=dialogH.getWidgetValue('bUpdateLinks');
    if h.updateLinks
        if~h.doorsLinks2sl&&~h.slLinks2Doors
            h.slLinks2Doors=true;
        end
    end
    dialogH.refresh();
end

function doPurgeInDoors(h,dialogH)
    h.purgeDoors=dialogH.getWidgetValue('bPurgeInDoors');
    dialogH.refresh();
end

function doPurgeInSimulink(h,dialogH)
    h.purgeSimulink=dialogH.getWidgetValue('bPurgeInSimulink');
    dialogH.refresh();
end

function doSaveSurgCheck(h,dialogH)
    h.savesurrogate=dialogH.getWidgetValue('bSaveSurgCheck');
    dialogH.refresh();
end

function doSaveModelBox(h,dialogH)
    h.savemodel=dialogH.getWidgetValue('bSaveModelBox');
    dialogH.refresh();
end

function doDetailsBox(h,dialogH)
    detailIndex=dialogH.getWidgetValue('bDetailsBox');
    optionTable=detailLevelOptions();
    detailValue=optionTable(detailIndex+1,2);
    h.detaillevel=detailValue{1};
    dialogH.refresh();
end

function doSyncNow(h,dialogH)

    if~isempty(h.modelH)


        isLocked=strcmpi(get_param(h.modelH,'lock'),'on');
        if isLocked
            selection=questdlg(...
            getString(message('Slvnv:reqmgt:Doors:getDialogSchema:CannotSyncWithLockedLibrary')),...
            getString(message('Slvnv:reqmgt:Doors:getDialogSchema:LibraryIsLocked')),...
            getString(message('Slvnv:reqmgt:Doors:getDialogSchema:Unlock')),...
            getString(message('Slvnv:reqmgt:Doors:getDialogSchema:Cancel')),...
            getString(message('Slvnv:reqmgt:Doors:getDialogSchema:Unlock')));
            if isempty(selection)
                selection=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:Cancel'));
            end
            if strcmp(selection,getString(message('Slvnv:reqmgt:Doors:getDialogSchema:Unlock')))
                set_param(h.modelH,'lock','off');
            else
                return;
            end
        end


        ReqSync.rmidlg_doors_apply(h,dialogH);
        delete(dialogH)


        rmidoors.sync(h.modelH);

    else
        warning(message('Slvnv:reqmgt:Doors:getDialogSchema:EmptyModelHandle'));
    end
end

function doPathEdit(h,dialogH)
    h.surrogatepath=dialogH.getWidgetValue('bPathEdit');
    dialogH.refresh();
    dialogH.enableApplyButton(true);
end

function optionsTable=detailLevelOptions()

    optionsTable={...
    getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DetailsNone')),1,'none';...
    getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DetailsMinimal')),2,'minimal';...
    getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DetailsModerate')),3,'moderate';...
    getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DetailsAverage')),4,'average';...
    getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DetailsExtensive')),5,'extensive';...
    getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DetailsComplete')),6,'complete'};
end

