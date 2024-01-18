function yesno=isFaultTableOpen(obj)

    yesno=false;

    topMdlH=rmifa.getTopModelFromObj(obj);
    if topMdlH==-1
        return;
    end
    yesno=safety.gui.GUIManager.getInstance.isTableOpen(topMdlH);
end