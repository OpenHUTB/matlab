function updateRequirementsForHarness(this,ownerHandle,harnessHandle,eventName)




    bmgr=this.badgeManager;
    mmgr=this.markupManager;
    ownerModel=bdroot(ownerHandle);
    harnessModel=bdroot(harnessHandle);
    switch lower(eventName)
    case 'postactivate'







        bmgr.enableBadges(ownerHandle);


        mmgr.showMarkupsAndConnectorsForHarnessModel(harnessHandle);





        mmgr.getClientContent(harnessModel);

    case 'predeactivate'












        this.markupManager.removeClientContent(ownerModel);
        this.markupManager.removeClientContent(harnessModel);

        mmgr.hideMarkupsAndConnectorsForHarnessModel(harnessHandle);







        mmgr.hideMarkupsAndConnectorsForModel(ownerModel);
    case 'postdeactivate'

        bmgr.enableBadges(ownerModel);
        mmgr.showMarkupsAndConnectorsForModel(ownerModel);
        this.markupManager.getClientContent(ownerModel);

        smgr=this.spreadsheetManager;



        smgr.update;
    otherwise

    end
end
