function showSubsystemPopup(badgeType,isGraph,hConfigBlock,evalLatency)




    popup=dfs.SubsystemPopup(badgeType,isGraph,hConfigBlock,evalLatency);
    dlg=DAStudio.Dialog(popup);
    popup.show(dlg);

end
