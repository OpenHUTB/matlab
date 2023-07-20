

function dlg=getBaseDialogSchema(obj)

    utils.rebindWidgetForDlg(obj);
    parentObj=get_param(bdroot(get(obj.blockObj,'handle')),'Object');
    model=get_param(bdroot(get(obj.blockObj,'handle')),'Name');
    simStatus=get_param(model,'SimulationStatus');

    if Simulink.HMI.isLibrary(model)||...
        utils.isLockedLibrary(model)
        enabled=false;
    else
        L(1)=Simulink.listener(parentObj,'SelectionChangeEvent',...
        @(bd,lo)onModelSelection(obj,lo));
        obj.listeners=L;
        enabled=true;
    end


    htmlPath='toolbox/simulink/hmi/web/Dialogs/ParameterDialog/ParameterDialog.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,'&widgetType='...
    ,obj.widgetType,'&enabled=',num2str(enabled),'&isLibWidget=',num2str(obj.isLibWidget)];
    webbrowser.Type='webbrowser';
    webbrowser.Tag='sl_hmi_webbrowser';
    webbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    webbrowser.DisableContextMenu=true;
    webbrowser.MatlabMethod='slDialogUtil';
    webbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};


    dlg.Items={webbrowser};
    dlg.StandaloneButtonSet={'Ok','Cancel','Help','Apply'};
    dlg.IsScrollable=false;
    dlg.IgnoreESCClose=false;

    dlg.CloseMethod='closeDialogCB';
    dlg.CloseMethodArgs={'%dialog','%closeaction'};
    dlg.CloseMethodArgsDT={'handle','string'};
end


function onModelSelection(obj,~)

    throttleBindingTable(obj);
end


function throttleBindingTable(obj)

    if isempty(obj.getOpenDialogs)
        return
    end
    if isempty(obj.timer)||~isvalid(obj.timer)
        obj.timer=timer('Name','HMISelContTimer','StartDelay',0.15);
        obj.timer.TimerFcn=@(o,e)populateBindingTable(obj,gsb(gcs,1));
        obj.timer.StopFcn=@(o,e)clearTimer(obj);
        start(obj.timer);
    end
end


function populateBindingTable(obj,currSelectedBlks)









    try
        blkHandle=get(obj.blockObj,'handle');
    catch ME
        return
    end


    filtered_blocks=[];
    for index=1:length(currSelectedBlks)
        block=currSelectedBlks(index);
        isCoreWebBlock=get_param(block,'isCoreWebBlock');
        if~strcmp(isCoreWebBlock,'on')
            filtered_blocks=[filtered_blocks,block];
        end
    end

    mdl=get_param(bdroot(blkHandle),'Name');

    bCoreBlock=get_param(blkHandle,'isCoreWebBlock');
    if strcmp(bCoreBlock,'on')
        binding=get_param(blkHandle,'Binding');
        if~isempty(binding)
            boundElem=binding;
        else
            boundElem={};
        end
    else
        boundElem=utils.getBoundElement(mdl,obj.widgetId,obj.isLibWidget);
    end

    rowInfo=utils.getParameterRows(mdl,obj.widgetId,filtered_blocks,boundElem,obj.widgetType);
    channel=hmiblockdlg.ParameterDlg.getChannel();
    message.publish([channel,'repopulateParametersInModelSelection'],...
    rowInfo);
    hmiblockdlg.ParameterDlg.clearCacheParamSelection(obj.widgetId,mdl);
end


function clearTimer(obj)
    delete(obj.timer);
end




