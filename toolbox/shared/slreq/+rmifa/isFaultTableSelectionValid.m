function tf=isFaultTableSelectionValid(varargin)




    tf=false;
    try
        if nargin==1
            mdlH=varargin{1};
            mdlH=get_param(bdroot(mdlH),'handle');
        else


            mdlH=get_param(bdroot,'handle');
        end
        if safety.gui.GUIManager.getInstance.isTableOpen(mdlH)
            sel=safety.gui.GUIManager.getInstance.getFaultTableCurrentSelection(mdlH);
            dm=faultinfo.manager.getFaultInfoDataModel(mdlH);
            targetObj=dm.findElement(sel);
            if rmifa.isLinkingForFaultObjAllowed(targetObj)
                tf=true;
            end
        end
    catch


        return;
    end
end
