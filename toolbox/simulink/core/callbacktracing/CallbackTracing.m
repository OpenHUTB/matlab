
function varargout=CallbackTracing(varargin)

    persistent DIALOG_USERDATA;

    persistent HILITE_DATA

    mlock;


    Action=varargin{1};
    args=varargin(2:end);

    switch(Action)
    case 'Create'

        ModelHandle=args{1};
        ModelName=get_param(args{1},'Name');
        dialog_exists=0;


        if~isempty(DIALOG_USERDATA)
            idx=find([DIALOG_USERDATA.ModelHandle]==ModelHandle);
            if~isempty(idx)
                DialogHandle=DIALOG_USERDATA(idx).DialogHandle;
                DialogHandle.show;
                dialog_exists=1;
            end
        end

        if(dialog_exists==0)
            DialogHandle=CreateCallbackTracingReport(ModelName);
            DIALOG_USERDATA(end+1).ModelHandle=ModelHandle;
            DIALOG_USERDATA(end).DialogHandle=DialogHandle;
            SetDialogSize(ModelHandle);
            DialogHandle.show;
        end

        varargout{1}=DialogHandle;

    case{'Delete','Cancel','Close'}
        try
            if~bdIsLoaded(args{1})
                return;
            end
            ModelHandle=get_param(args{1},'Handle');


            if~isempty(DIALOG_USERDATA)
                idx=find([DIALOG_USERDATA.ModelHandle]==ModelHandle);
                if~isempty(idx)
                    DialogHandle=DIALOG_USERDATA(idx).DialogHandle;
                    if ishandle(DialogHandle)
                        DIALOG_USERDATA(idx)=[];
                        DialogHandle.delete();
                    end
                end
            end

            HILITE_DATA=i_Unhilite(HILITE_DATA);

            modelObj=get_param(ModelHandle,'Object');
            if modelObj.hasCallback('PreClose','CallbackTracing')
                Simulink.removeBlockDiagramCallback(ModelHandle,'PreClose','CallbackTracing')
            end
        catch ex %#ok
            return;
        end

    case 'Highlight'

        HILITE_DATA=i_Unhilite(HILITE_DATA);
        objPath=args{1};
        callbackType=args{2};
        isCallbackCode=strcmp(args{3},DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolCallbackCodeColumnName'));
        HILITE_DATA.Block=objPath;
        open_and_hilite_system(objPath,'find');
        if isCallbackCode
            paramName=args{4};
            openCallbackDialog(objPath,callbackType,paramName);
        end

    case 'GetDialogHandle'
        ModelHandle=args{1};
        DialogHandle=[];
        if~isempty(DIALOG_USERDATA)
            idx=find([DIALOG_USERDATA.ModelHandle]==ModelHandle);
            if~isempty(idx)
                DialogHandle=DIALOG_USERDATA(idx).DialogHandle;
            end
        end
        varargout{1}=DialogHandle;

    case 'Reset'
        model=args{1};
        ModelHandle=get_param(model,'Handle');
        dialogH=CallbackTracing('GetDialogHandle',ModelHandle);
        if ishandle(dialogH)
            resetCallbackSpreadsheet(dialogH,model);
        end
    end
end

function SetDialogSize(ModelHandle)
    dlg=CallbackTracing('GetDialogHandle',ModelHandle);
    PrefferedDialogSize=[1000,600];
    aScreenSize=get(0,'screenSize');
    xStart=(aScreenSize(3)-PrefferedDialogSize(1))/2;
    yStart=(aScreenSize(4)-PrefferedDialogSize(2))/2;
    dlg.position=[xStart,yStart,PrefferedDialogSize(1),PrefferedDialogSize(2)];
end

function DialogHandle=CreateCallbackTracingReport(model_name)
    obj=CallbackTracingReport(model_name);
    DialogHandle=DAStudio.Dialog(obj);
    obj.setProperties(DialogHandle);
    obj.applyDefaultFilters(DialogHandle);
end

function data=i_Unhilite(data)
    if~isempty(data)
        try
            hilite_system(data.Block,'none');
        catch
        end
        data=[];
    end
end

function resetCallbackSpreadsheet(dialogH,model)
    spreadsheetTag='CallbackTracingReportSpreadsheet';
    spreadsheetObj=dialogH.getUserData(spreadsheetTag);
    spreadsheetObj.resetSpreadSheet(model);
    dialogH.refresh();
    disableUIControls(dialogH);
end

function disableUIControls(dialogH)
    dialogH.setEnabled('CallbackTracingExportButton',false);
    dialogH.setEnabled('ClearCallbackLogButton',false);
    dialogH.setEnabled('CallbackTracingStageNameList',false);
    dialogH.setEnabled('CallbackTracingReportSpreadsheetFilter',false);
    dialogH.setEnabled('filterGroup',false);
    dialogH.setEnabled('includeGroup',false);
    dialogH.apply();
end

function openCallbackDialog(objPath,callbackType,paramName)
    if contains(callbackType,{'MaskParameterCallback','Mask Initialization'})
        openMaskEditor(objPath,paramName);
        return;
    end

    isBlock=any(objPath=='/');
    if isBlock
        openBlockProperties(objPath,callbackType);
    else
        openModelProperties(objPath,callbackType);
    end
end

function openMaskEditor(objPath,paramName)
    try
        model=split(objPath,'/');
        aModelName=model{1};

        aAlreadySelected=find_system(aModelName,'selected','on');
        if~iscell(aAlreadySelected)
            aAlreadySelected={aAlreadySelected};
        end

        for i=1:length(aAlreadySelected)
            set_param(aAlreadySelected{i},'selected','off');
        end
        aBlkHdl=get_param(objPath,'handle');
        set_param(aBlkHdl,'selected','on');

        parent=get_param(objPath,'Parent');
        parentH=get_param(parent,'Handle');
        slInternal('createOrEditMask',parentH);



        if isempty(paramName)
            paramName="Initialization";
        end



        waitUntilReady=true;
        dialog=maskeditor('Get',aBlkHdl,waitUntilReady);
        if~isempty(dialog)
            aMsgData=struct('Action','NavigateToCallback','WidgetName',paramName);
            maskeditor('SendMessage',aBlkHdl,aMsgData);
        end
    catch
    end
end

function openModelProperties(objPath,callbackType)
    model=split(objPath,'/');
    obj=get_param(model{1},'Object');
    d=loc_find_dialog(DAStudio.ToolRoot.getOpenDialogs(obj));
    if isempty(d)
        d=DAStudio.Dialog(obj);
    end
    assert(~isempty(d),'Dialog not found');
    try
        d.setActiveTab('Tabcont',1);




        d.setWidgetValue('CallbackFunctions',callbackType);
        d.setWidgetValue('CallbackFunctions',[callbackType,'*']);
        d.setFocus(callbackType);
        d.show;
    catch e %#ok<NASGU>
        return;
    end
end

function openBlockProperties(blk,callbackType)

    obj=get_param(blk,'Object');



    d=loc_find_dialog(DAStudio.ToolRoot.getOpenDialogs(obj));
    if isempty(d)
        open_system(blk,'property');
        d=loc_find_dialog(DAStudio.ToolRoot.getOpenDialogs(obj));
        assert(~isempty(d),'Dialog not found');
    end
    try
        d.setActiveTab('TabContainer',2);




        d.setWidgetValue('CallbackTree',callbackType);
        d.setWidgetValue('CallbackTree',[callbackType,'*']);
        d.setFocus(callbackType);
        d.show;
    catch e %#ok<NASGU>
        return;
    end
end


function d=loc_find_dialog(dlgs)


    d=[];
    if(length(dlgs)==1)
        if dlgs.isStandAlone
            d=dlgs;
        end
    else
        for i=1:length(dlgs)
            if dlgs{i}.isStandAlone
                d=dlgs{i};
                break;
            end
        end
    end
end