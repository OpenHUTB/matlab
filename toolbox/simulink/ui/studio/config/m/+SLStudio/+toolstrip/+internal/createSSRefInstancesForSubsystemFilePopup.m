
function gw=createSSRefInstancesForSubsystemFilePopup(cbinfo)

    graphHandle=cbinfo.model.handle;
    eventDataNamespace=cbinfo.EventData.namespace;
    eventDataType=cbinfo.EventData.type;
    gw=SLStudio.toolstrip.internal.createSubsystemReferenceInstancesPopup(graphHandle,eventDataNamespace,eventDataType,'subsystemFile');
end