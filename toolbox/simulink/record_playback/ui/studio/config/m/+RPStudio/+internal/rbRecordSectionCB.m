function schema=rbRecordSectionCB(fncname,cbinfo,eventData)


    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function rbLogWorkspaceEnableActionCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'RecordToWorkspace','on');
    else
        set_param(cbinfo.uiObject.Handle,'RecordToWorkspace','off');
    end
end

function rbLogWorkspaceTextFieldCB(cbinfo)
    variableName=strtrim(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'VariableName',variableName);
end

function rbLogToFileButtonActionCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'RecordToFile','on');
    else
        set_param(cbinfo.uiObject.Handle,'RecordToFile','off');
    end
end

function setFileExtenstion(blkHdl,ext)
    toFileValue=get_param(blkHdl,'Filename');
    [fileLocation,name,~]=fileparts(toFileValue);
    toFileValue=fullfile(fileLocation,strcat(name,ext));
    set_param(blkHdl,'Filename',toFileValue);
    utils.recordDialogUtils.updateFileHistory(blkHdl,toFileValue);
end

function rbLogToFileMldatxCB(cbinfo)
    ext='.mldatx';
    setFileExtenstion(cbinfo.uiObject.Handle,ext);
end

function rbLogToFileMatCB(cbinfo)
    ext='.mat';
    setFileExtenstion(cbinfo.uiObject.Handle,ext);
end

function rbLogToFileXlsxCB(cbinfo)
    ext='.xlsx';
    setFileExtenstion(cbinfo.uiObject.Handle,ext);
end

function rbLogToFileNameTextFieldCB(cbinfo)
    fileName=strtrim(cbinfo.EventData);
    fileName=utils.recordDialogUtils.formatFileName(cbinfo.uiObject.Handle,fileName);
    set_param(cbinfo.uiObject.Handle,'Filename',fileName);

    utils.recordDialogUtils.updateFileHistory(cbinfo.uiObject.Handle,fileName);
end

function rbLogToFileLocationButtonCB(blkHdl)
    fileName=get_param(blkHdl,'Filename');
    [~,name,ext]=fileparts(fileName);
    selpath=uigetdir('',DAStudio.message('record_playback:toolstrip:ToFileSelectFolder'));

    path_FileName=fullfile(selpath,strcat(name,ext));
    set_param(blkHdl,'Filename',path_FileName);

    utils.recordDialogUtils.updateFileHistory(blkHdl,path_FileName);
end

function gw=generateOpenRecentLocationsPopupList(cbinfo)
    view=get_param(cbinfo.uiObject.Handle,'view');
    recordFileHistory=view.fileHistory;

    gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);


    actionName='rbLogToFileLocationButtonAction';
    action=gw.createAction(actionName);
    action.text=DAStudio.message('record_playback:toolstrip:ToFileLocationLabel');
    action.description=DAStudio.message('record_playback:toolstrip:BrowseTooltip');
    action.enabled=true;
    action.optOutBusy=true;
    action.optOutLocked=true;
    blockHdl=cbinfo.uiObject.Handle;

    action.setCallbackFromArray(@(m)rbLogToFileLocationButtonCB(blockHdl),dig.model.FunctionType.Action);
    action.icon='set_path';

    itemName='rbOpenFileLocationListItem';
    item=gw.Widget.addChild('ListItem',itemName);
    item.ActionId=[gw.Namespace,':',actionName];

    if~isempty(recordFileHistory)
        header1=gw.Widget.addChild('PopupListHeader','recentLocsHeader');
        header1.Label=DAStudio.message('record_playback:toolstrip:ToFileRecentLocationsLabel');

        createRecentLocationItems(gw,recordFileHistory,cbinfo.uiObject.Handle);

        header2=gw.Widget.addChild('PopupListHeader','recentFilsHeader');
        header2.Label=DAStudio.message('record_playback:toolstrip:ToFileRecentFilesLabel');

        createRecentFileItems(gw,recordFileHistory,cbinfo.uiObject.Handle);
    end
end

function createRecentLocationItems(gw,recordFileHistory,blockHdl)
    locationArray=strings(recordFileHistory.Size());

    for index=1:recordFileHistory.Size()
        [fileLocation,~,~]=fileparts(recordFileHistory(index));
        if isempty(fileLocation)
            fileLocation=DAStudio.message('record_playback:toolstrip:ToFileCurrentFolder');
        end
        locationArray(index)=fileLocation;
    end
    locationArray=unique(locationArray,'stable');
    fileName=get_param(blockHdl,'Filename');
    [~,name,ext]=fileparts(fileName);

    for index=1:size(locationArray)

        actionName=['recent','Location','Action_',num2str(index)];
        action=gw.createAction(actionName);
        action.description=locationArray(index);
        action.enabled=true;
        action.optOutBusy=true;
        action.optOutLocked=true;

        if strcmp(locationArray(index),DAStudio.message('record_playback:toolstrip:ToFileCurrentFolder'))
            filepath=strcat(name,ext);
        else
            filepath=fullfile(locationArray(index),strcat(name,ext));
        end

        action.setCallbackFromArray(@(m)setFilePathFromHistory(blockHdl,filepath),dig.model.FunctionType.Action);


        itemName=['recent','Location','Item_',num2str(index)];
        item=gw.Widget.addChild('ListItem',itemName);
        item.ActionId=[gw.Namespace,':',actionName];
    end
end

function createRecentFileItems(gw,recordFileHistory,blockHdl)
    for index=1:recordFileHistory.Size()
        filepath=recordFileHistory(index);
        [fileLocation,name,ext]=fileparts(filepath);


        actionName=['recent','File','Action_',num2str(index)];
        action=gw.createAction(actionName);
        action.text=[name,ext];
        if isempty(fileLocation)
            action.description=DAStudio.message('record_playback:toolstrip:ToFileCurrentFolder');
        else
            action.description=fileLocation;
        end

        action.enabled=true;
        action.optOutBusy=true;
        action.optOutLocked=true;

        action.setCallbackFromArray(@(m)setFilePathFromHistory(blockHdl,filepath),dig.model.FunctionType.Action);


        itemName=['recent','File','Item_',num2str(index)];
        item=gw.Widget.addChild('ListItem',itemName);
        item.ActionId=[gw.Namespace,':',actionName];
    end
end

function setFilePathFromHistory(blockHdl,filepath)
    set_param(blockHdl,'Filename',string(filepath));
    view=get_param(blockHdl,'View');
    recordFileHistory=view.fileHistory;
    for index=1:recordFileHistory.Size()
        if string(recordFileHistory(index))==string(filepath)
            recordFileHistory.removeAt(index);
            break;
        end
    end
    recordFileHistory.insertAt(string(filepath),int32(1));
end

function DataTypeCheckCB(cbinfo)
    fileSettings=locGetExcelSettings(cbinfo.uiObject.Handle);
    fileSettings.excelSettings.dataType=cbinfo.EventData;
    locSetModelDirty(cbinfo);
end

function UnitsCheckCB(cbinfo)
    fileSettings=locGetExcelSettings(cbinfo.uiObject.Handle);
    fileSettings.excelSettings.units=cbinfo.EventData;
    locSetModelDirty(cbinfo);
end

function PortIndexCheckCB(cbinfo)
    fileSettings=locGetExcelSettings(cbinfo.uiObject.Handle);
    fileSettings.excelSettings.portIndex=cbinfo.EventData;
    locSetModelDirty(cbinfo);
end

function BlockPathCheckCB(cbinfo)
    fileSettings=locGetExcelSettings(cbinfo.uiObject.Handle);
    fileSettings.excelSettings.blockPath=cbinfo.EventData;
    locSetModelDirty(cbinfo);
end

function InterpolationCheckCB(cbinfo)
    fileSettings=locGetExcelSettings(cbinfo.uiObject.Handle);
    fileSettings.excelSettings.interpolation=cbinfo.EventData;
    locSetModelDirty(cbinfo);
end

function SharedTimeColumnsCB(cbinfo)
    fileSettings=locGetExcelSettings(cbinfo.uiObject.Handle);
    fileSettings.excelSettings.time=Streamout.ExcelTime.SHAREDCOLUMNS;
    locSetModelDirty(cbinfo);
end

function IndividualTimeColumnsCB(cbinfo)
    fileSettings=locGetExcelSettings(cbinfo.uiObject.Handle);
    fileSettings.excelSettings.time=Streamout.ExcelTime.INDIVIDUALCOLUMNS;
    locSetModelDirty(cbinfo);
end

function fileSettings=locGetExcelSettings(blkHandle)
    fileSettings=get_param(blkHandle,'FileSettings');
end

function locSetModelDirty(cbinfo)
    handles=cbinfo.studio.App.getBlockDiagramHandles;
    for i=1:numel(handles)
        set_param(handles(i),'dirty','on');
    end
end