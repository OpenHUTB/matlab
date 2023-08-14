function varargout=busddg_applyrevertcbs(h,varargin)







    warnState=warning('off','backtrace');
    cleanupWarning=onCleanup(@()warning(warnState));

    try
        loc_callbackSwitchYard(h,varargin{:});

    catch E


        varargout{1}=false;%#ok<NASGU>
        throwAsCaller(E);
    end
    varargout{1}=true;
    varargout{2}="";
end



function loc_callbackSwitchYard(h,varargin)

    action=varargin{1};
    dialogH=varargin{2};
    busObjectName=dialogH.getUserData('Editorbtn');
    dialogH.setUserData('MoveElementDownBtn',[]);

    switch action
    case 'postApply'
        i_doPostApply(h,dialogH,busObjectName);

    case 'postRevert'
        i_doPostRevert(h,dialogH);
    end

    dialogH.enableApplyButton(false);
end



function i_doPostApply(h,dialogH,busObjectName)

    actualBusObject=dialogH.getDialogSource;
    if~isa(actualBusObject,'Simulink.Bus')
        actualBusObject=actualBusObject.getForwardedObject;
    end
    DialogState=dialogH.getUserData('MoveElementUpBtn');
    tempBusObject=DialogState.tempBusObject;

    if isprop(tempBusObject,'TargetUserData')
        if~isequal(h.TargetUserData,tempBusObject.TargetUserData)
            for fields=fieldnames(h.TargetUserData)'
                tempBusObject.TargetUserData.(fields{1})=h.TargetUserData.(fields{1});
            end
        end
    end



    fields=fieldnames(tempBusObject);
    standardBusFieldNames={'HeaderFile','Alignment','DataScope','Description','Elements'};
    if sl('busUtils','NDIdxBusUI')
        standardBusFieldNames{end+1}='PreserveElementDimensions';
    end


    for i=1:length(fields)
        if~strcmp(fields{i},'TargetUserData')&&~any(strcmp(standardBusFieldNames,fields{i}))
            tempBusObject.(fields{i})=actualBusObject.(fields{i});
        end
    end


    loc_persistChangesToTheActualBusObject(dialogH,tempBusObject,busObjectName);

end



function i_doPostRevert(~,dialogH)

    DialogState=dialogH.getUserData('MoveElementUpBtn');
    busObjectFromPreviousApply=DialogState.busObjectAppliedState;



    DialogState.tempBusObject=busObjectFromPreviousApply;

    dialogH.setUserData('MoveElementUpBtn',DialogState);
    isSpreadsheetUpdating=true;
    dialogH.setUserData('BusObjectSpreadsheet',isSpreadsheetUpdating);

    w=dialogH.getWidgetInterface('BusObjectSpreadsheet');
    w.update();
end



function loc_persistChangesToTheActualBusObject(dialogH,tempBusObject,busObjectName)
    ddgSrc=dialogH.getDialogSource;
    if any(strcmp(methods(ddgSrc),"setEntryValue"))
        ddgSrc.setEntryValue(tempBusObject);
    else
        assignin('base',busObjectName,tempBusObject);
    end
end

