


function handleScopeMenuItem(cbinfo)
    btype=get_param(cbinfo.target.handle,'blockType');
    if strcmp(btype,'SubSystem')
        locHandleScopeMenuItemLegacy(cbinfo);
    else
        locHandleScopeMenuItemCoreBlock(cbinfo);
    end
end


function locHandleScopeMenuItemCoreBlock(cbinfo)
    switch cbinfo.userdata.action
    case{'NormalMode','ZoomMarquee','ZoomT','ZoomY','ZoomOut'...
        ,'FitToView','FitToViewInTime','FitToViewInY'}
        set_param(cbinfo.target.handle,'ZoomMode',cbinfo.userdata.action);
    case 'DataCursorNone'
        set_param(cbinfo.target.handle,'CursorMode','0');
    case 'DataCursorOne'
        set_param(cbinfo.target.handle,'CursorMode','1');
    case 'DataCursorTwo'
        set_param(cbinfo.target.handle,'CursorMode','2');
    otherwise
        assert(0);
    end
end


function locHandleScopeMenuItemLegacy(cbinfo)
    action=cbinfo.userdata.action;
    widget=locGetScopeWidget(cbinfo);
    clientIDs=locGetClientIDs(widget);
    switch action
    case 'NormalMode'
        locPan(clientIDs,widget);
    case 'ZoomMarquee'
        locZoom(clientIDs,widget);
    case 'ZoomT'
        locZoomT(clientIDs,widget);
    case 'ZoomY'
        locZoomY(clientIDs,widget);
    case 'ZoomOut'
        locZoomOut(clientIDs,widget);
    case 'FitToView'
        locFitToView(clientIDs,widget);
    case 'DataCursorOne'
        locDataCursorOne(clientIDs,widget);
    case 'DataCursorTwo'
        locDataCursorTwo(clientIDs,widget);
    case 'DataCursorNone'
        locDataCursorNone(clientIDs,widget);
    end
end


function locPan(clientIDs,widget)
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'NormalMode');
    end
    widget.setProperty('NormalMode',true);
end


function locZoom(clientIDs,widget)
    curVal=widget.getProperty('ZoomMarquee');
    curVal=~curVal;
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'ZoomMarquee',curVal);
    end
    widget.setProperty('ZoomMarquee',curVal);
end


function locZoomT(clientIDs,widget)
    curVal=widget.getProperty('ZoomT');
    curVal=~curVal;
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'ZoomT',curVal);
    end
    widget.setProperty('ZoomT',curVal);
end


function locZoomY(clientIDs,widget)
    curVal=widget.getProperty('ZoomY');
    curVal=~curVal;
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'ZoomY',curVal);
    end
    widget.setProperty('ZoomY',curVal);
end


function locZoomOut(clientIDs,widget)
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'ZoomOut');
    end
    widget.setProperty('NormalMode',true);
end


function locFitToView(clientIDs,~)
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'FitWindow');
    end
end


function locDataCursorOne(clientIDs,widget,~)
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'DataCursors',1);
    end
    widget.setProperty('DataCursors',1);
end


function locDataCursorTwo(clientIDs,widget)
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'DataCursors',2);
    end
    widget.setProperty('DataCursors',2);
end


function locDataCursorNone(clientIDs,widget)
    for clientIdx=1:length(clientIDs)
        clientId=clientIDs{clientIdx};
        Simulink.sdi.internal.setAxesOperationMode(clientId,'DataCursors',0);
    end
    widget.setProperty('DataCursors',0);
end


function widget=locGetScopeWidget(cbinfo)
    webBlockId=get(cbinfo.target.handle,'webBlockId');
    widget=utils.getWidget(cbinfo.model.Name,webBlockId);
end


function clientIDs=locGetClientIDs(widget)
    clientIDs=widget.ClientID;
end

