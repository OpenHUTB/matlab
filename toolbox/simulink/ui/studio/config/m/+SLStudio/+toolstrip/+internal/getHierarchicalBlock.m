



function obj=getHierarchicalBlock(cbinfo)
    handle=SLStudio.Utils.getSLHandleForSelectedHierarchicalBlock(cbinfo);
    obj=get_param(handle,'object');
end