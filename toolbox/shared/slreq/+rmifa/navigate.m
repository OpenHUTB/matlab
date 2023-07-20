function navigate(doc,location)

    [faultInfoObj,mdlH]=rmifa.getFaultInfoObj(doc,location);
    safety.gui.GUIManager.getInstance.setFaultTableCurrentSelection(mdlH,faultInfoObj.Uuid);
end