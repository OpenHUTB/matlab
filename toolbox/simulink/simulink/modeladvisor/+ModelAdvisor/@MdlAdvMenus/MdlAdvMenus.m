classdef MdlAdvMenus<handle
    methods(Static=true)
        schema=settingsMenu(callbackInfo)
        schema=contextMenu(callbackInfo)
        schema=commonFcn(callbackInfo,tag,label,childrenflag)
        schema=contextMenuStateflow(callbackInfo);
    end
end