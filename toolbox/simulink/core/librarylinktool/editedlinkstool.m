
function varargout=editedlinkstool(varargin)

    persistent DIALOG_USERDATA;

    persistent HILITE_DATA

    mlock;


    narginchk(1,Inf);


    Action=varargin{1};
    args=varargin(2:end);

    switch(Action)
    case 'Create'
        model=args{1};
        validTabsIndex=[0,1];
        activeTab=0;
        if nargin>2
            tabNo=args{2};
            if isnumeric(tabNo)&&ismember(tabNo,validTabsIndex)
                activeTab=args{2};
            end
        end
        ModelHandle=get_param(model,'Handle');
        dialog_exists=0;


        if~isempty(DIALOG_USERDATA)
            idx=find([DIALOG_USERDATA.ModelHandle]==ModelHandle);
            if~isempty(idx)
                DialogHandle=DIALOG_USERDATA(idx).DialogHandle;
                updateAllSpreadsheets(DialogHandle);
                SetActiveTab(DialogHandle,activeTab);
                DialogHandle.show;
                dialog_exists=1;
            end
        end

        if(dialog_exists==0)
            DialogHandle=CreateLibraryLinksTool(model,activeTab);
            DIALOG_USERDATA(end+1).ModelHandle=ModelHandle;
            DIALOG_USERDATA(end).DialogHandle=DialogHandle;
            SetDialogSize(ModelHandle);
            SetActiveTab(DialogHandle,activeTab);
        end

    case{'Delete','Cancel','Close'}
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
        if modelObj.hasCallback('PreClose','editedlinkstool')
            Simulink.removeBlockDiagramCallback(ModelHandle,'PreClose','editedlinkstool')
        end

    case 'Highlight'

        HILITE_DATA=i_Unhilite(HILITE_DATA);
        model=args{1};
        objPath=args{2};
        open_system(model);
        HILITE_DATA.Block=objPath;
        hilite_system(objPath,'find');

    case 'RefreshAllSpreadsheets'
        ModelHandle=args{1};
        updateAllSpreadsheets(ModelHandle);

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
    end
end

function SetDialogSize(ModelHandle)
    dlg=editedlinkstool('GetDialogHandle',ModelHandle);
    original_pos=dlg.position;
    original_pos(3)=original_pos(3)+550;
    original_pos(4)=original_pos(4)+40;
    dlg.position=original_pos;
end

function SetActiveTab(dialogHandle,activeTab)
    parameterizedLinksObj=dialogHandle.getUserData('ParameterizedLinksSpreadsheet');
    disabledLinksObj=dialogHandle.getUserData('LinksToolSpreadsheet');

    if isempty(disabledLinksObj.m_Children)&&...
        ~isempty(parameterizedLinksObj.m_Children)
        activeTab=1;
    end

    dialogHandle.setActiveTab('LibraryLinkToolTabContainer',activeTab);

end

function DialogHandle=CreateLibraryLinksTool(model,activeTab)

    obj=LibraryLinkTool(model,activeTab);
    DialogHandle=DAStudio.Dialog(obj);

end

function updateAllSpreadsheets(dialogHandle)
    disabledSpreadsheetTag='LinksToolSpreadsheet';
    parameterizedSpreadsheetTag='ParameterizedLinksSpreadsheet';

    disabledSpreadsheet=dialogHandle.getUserData(disabledSpreadsheetTag);
    parameterizedSpreadsheet=dialogHandle.getUserData(parameterizedSpreadsheetTag);

    updatedDisabledSpreadsheetObj=disabledSpreadsheet.updateSpreadsheetChildren();
    updatedParameterizedSpreadsheetObj=parameterizedSpreadsheet.updateSpreadsheetChildren();

    dialogHandle.setEnabled('PushButton',false);
    dialogHandle.setEnabled('RestoreButton',false);
    dialogHandle.setEnabled('ParameterizedRestoreButton',false);
    dialogHandle.setEnabled('ParameterizedPushButton',false);


    dialogHandle.setUserData(disabledSpreadsheetTag,updatedDisabledSpreadsheetObj);
    disabledSpreadsheet.updateUI(dialogHandle,disabledSpreadsheetTag);

    dialogHandle.setUserData(parameterizedSpreadsheetTag,updatedParameterizedSpreadsheetObj);
    parameterizedSpreadsheet.updateUI(dialogHandle,parameterizedSpreadsheetTag);
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