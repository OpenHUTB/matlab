
function ret=highlightSignal(sid,bpath,portIdx,metaData)
    interface=Simulink.sdi.internal.Framework.getFramework();
    ret=interface.highlightSignal(sid,bpath,portIdx,metaData);
end