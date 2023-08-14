function modelCloseCallback(modelH)






    appmgr=slreq.app.MainManager.getInstance;
    if~isempty(appmgr.markupManager)


        appmgr.markupManager.removeClientContent(modelH);

        appmgr.markupManager.hideMarkupsAndConnectorsForModel(modelH);
    end

    if~isempty(appmgr.spreadsheetManager)
        appmgr.spreadsheetManager.deleteSpreadSheetObject(modelH);
    end

    if~isempty(appmgr.spreadSheetDataManager)

        appmgr.spreadSheetDataManager.deleteSpreadSheetDataObject(modelH);
    end

    if~isempty(appmgr.badgeManager)



        appmgr.badgeManager.removeBadgeMap(modelH);
    end

    if~isempty(appmgr.perspectiveManager)

        appmgr.perspectiveManager.removeFromPerspectiveMap(modelH);
    end

    if slreq.linkmgr.LinkSetManager.exists()


        filepath=get_param(modelH,'FileName');
        slreq.linkmgr.LinkSetManager.getInstance.onArtifactClose(filepath);
    end
end
