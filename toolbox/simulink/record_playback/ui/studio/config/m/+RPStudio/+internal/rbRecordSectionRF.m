


function schema=rbRecordSectionRF(fncname,userData,cbinfo,eventData)


    if~strcmp(class(cbinfo.uiObject),"Simulink.Record")
        return;
    end


    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==4
            fnc(userData,cbinfo,eventData);
        elseif nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function rbEnableRecordToWorkspaceRF(userData,cbinfo,action)
    enableRecordToWorkspace=get_param(cbinfo.uiObject.Handle,'RecordToWorkspace');
    if strcmp(userData,'EnableToWorkspace')
        action.enabled=true;
        if strcmp(enableRecordToWorkspace,'on')
            action.selected=true;
        else
            action.selected=false;
        end
    end
end

function rbLogWorkspaceLabelRF(~,cbinfo,action)
    action.enabled=strcmp(get_param(cbinfo.uiObject.Handle,'RecordToWorkspace'),'on');
end

function rbLogWorkspaceTextFieldRF(~,cbinfo,action)
    action.enabled=strcmp(get_param(cbinfo.uiObject.Handle,'RecordToWorkspace'),'on');
    action.text=get_param(cbinfo.uiObject.Handle,'VariableName');
end

function rbEnableRecordToFileRF(userData,cbinfo,action)
    enableRecordToFile=get_param(cbinfo.uiObject.Handle,'RecordToFile');
    fileName=get_param(cbinfo.uiObject.Handle,'Filename');
    [fileLocation,~,ext]=fileparts(fileName);
    switch userData
    case 'EnableToFile'
        action.enabled=true;
        if strcmp(enableRecordToFile,'on')
            action.selected=true;
        else
            action.selected=false;
        end
    case 'FileTypePopup'
        action.text=[DAStudio.message('record_playback:toolstrip:ToFileType'),' ',ext];
        if strcmp(enableRecordToFile,'on')
            action.enabled=true;
        else
            action.enabled=false;
        end
    case 'FileLocationPopup'
        if isempty(fileLocation)
            fileLocation=DAStudio.message('record_playback:toolstrip:ToFileCurrentFolder');
        end

        action.text=[DAStudio.message('record_playback:toolstrip:ToFileLocation'),' ',fileLocation];
        if strcmp(enableRecordToFile,'on')
            action.enabled=true;
        else
            action.enabled=false;
        end
    end
end

function rbLogToFileNameLabelRF(~,cbinfo,action)
    action.enabled=strcmp(get_param(cbinfo.uiObject.Handle,'RecordToFile'),'on');
end

function rbLogToFileNameTextFieldRF(~,cbinfo,action)
    action.enabled=strcmp(get_param(cbinfo.uiObject.Handle,'RecordToFile'),'on');
    action.text=utils.recordDialogUtils.getFileParts(cbinfo.uiObject.Handle).name;
    action.description=utils.recordDialogUtils.getFileParts(cbinfo.uiObject.Handle).fileLocation;
end

function rbLogToFileLocationRF(~,cbinfo,action)
    action.enabled=strcmp(get_param(cbinfo.uiObject.Handle,'RecordToFile'),'on');
end

function rbLogToFileTypeLabelRF(~,cbinfo,action)
    action.enabled=strcmp(get_param(cbinfo.uiObject.Handle,'RecordToFile'),'on');
end

function rbLogToFileAdSettingsRF(~,cbinfo,action)
    recordToFileEnabled=strcmp(get_param(cbinfo.uiObject.Handle,'RecordToFile'),'on');
    isExcelFileType=strcmp(utils.recordDialogUtils.getFileParts(cbinfo.uiObject.Handle).ext,'.xlsx');

    action.enabled=recordToFileEnabled&&isExcelFileType;
end

function rbLogToFileTypeRF(userData,cbinfo,action)
    action.enabled=strcmp(get_param(cbinfo.uiObject.Handle,'RecordToFile'),'on');
    newExt=utils.recordDialogUtils.getFileParts(cbinfo.uiObject.Handle).ext;
    switch newExt
    case '.mldatx'
        if strcmp(userData,'MldatxType')
            action.selected=1;
        else
            action.selected=0;
        end
    case '.mat'
        if strcmp(userData,'MatType')
            action.selected=1;
        else
            action.selected=0;
        end
    case '.xlsx'
        if strcmp(userData,'XlsxType')
            action.selected=1;
        else
            action.selected=0;
        end
    end
end

function rbRecordAdSettingsRF(userData,cbinfo,action)
    fileSettings=get_param(cbinfo.uiObject.Handle,'FileSettings');
    excelSettings=fileSettings.excelSettings;
    switch(excelSettings.time)
    case Streamout.ExcelTime.SHAREDCOLUMNS
        if strcmp(userData,'sharedTimeColumns')
            action.selected=1;
        end
    case Streamout.ExcelTime.INDIVIDUALCOLUMNS
        if strcmp(userData,'individualTimeColumns')
            action.selected=1;
        end
    end

    if strcmp(userData,'dataTypeCheck')&&excelSettings.dataType
        action.selected=1;
    end

    if strcmp(userData,'unitsCheck')&&excelSettings.units
        action.selected=1;
    end

    if strcmp(userData,'portIndexCheck')&&excelSettings.portIndex
        action.selected=1;
    end

    if strcmp(userData,'blockPathCheck')&&excelSettings.blockPath
        action.selected=1;
    end

    if strcmp(userData,'interpolationCheck')&&excelSettings.interpolation
        action.selected=1;
    end
end

