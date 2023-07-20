function SequenceViewer(fncname,cbinfo,action)

    fcn=str2func(fncname);
    if nargin==3
        fcn(cbinfo,action);
    else
        fcn(cbinfo);
    end
end



function LogEventsCB(cbinfo)


    modelName=cbinfo.model.Name;
    isEventLoggingOn=strcmpi(cbinfo.model.EventLogging,'on');
    if(isEventLoggingOn)
        set_param(modelName,'EventLogging','off');
    else
        set_param(modelName,'EventLogging','on');
    end
end


function ShowSequenceViewer(cbinfo,action)
















    isEventLoggingOn=strcmpi(cbinfo.model.EventLogging,'on');
    seqViewer=MessageViewerRegistry.getInstance().findViewerOnToolstripWithModelHandler(cbinfo.model.handle);
    if(isEventLoggingOn)
        action.selected=true;
        if isempty(seqViewer)
            seqViewer=SequenceDiagramViewer.createSingletonSDV(cbinfo.model.Name,false);
            seqViewer.isOnToolstrip=true;
            seqViewer.initializeSingleton();
        end
    else
        action.selected=false;
    end
    MessageViewerRegistry.getInstance().manageEventLogging(cbinfo.model.handle,isEventLoggingOn);
end


function ShowSequenceViewerCB(cbinfo)


    seqViewer=MessageViewerRegistry.getInstance().findViewerOnToolstripWithModelHandler(cbinfo.model.handle);
    if isempty(seqViewer)
        seqViewer=SequenceDiagramViewer.createSingletonSDV(cbinfo.model.Name,false);
        seqViewer.isOnToolstrip=true;
    end
    seqViewer.openSingleton();
    seqViewer.dialogH.bringToFront;
end


function SetEventLoggingDataAvailable(cbinfo,action)















    if strcmpi(cbinfo.model.EventLoggingDataAvailable,'on')
        action.icon='resultSequenceViewerActive';
    else
        action.icon='resultSequenceViewer';
    end
end