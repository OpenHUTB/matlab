function openRequirementsEditor(this)






    if isempty(this.requirementsEditor)
        this.init();

        slreq.internal.delayedLinksetLoader('load');

        this.requirementsEditor=slreq.internal.gui.Editor(this);
        this.updateRollupStatusAndChangeInformationIfNeeded({this.requirementsEditor});
        this.requirementsEditor.update();




        lsm=slreq.linkmgr.LinkSetManager.getInstance();
        lsm.scanMATLABPathOnSlreqInit(lsm.METADATA_SCAN_INIT_MODE_UI);
    end
    this.requirementsEditor.open();
end
