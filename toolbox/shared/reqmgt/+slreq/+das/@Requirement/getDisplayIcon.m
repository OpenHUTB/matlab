function icon=getDisplayIcon(this)




    mgr=slreq.app.MainManager.getInstance;
    ctmgr=mgr.changeTracker;
    cView=mgr.getCurrentView;



    if(reqmgt('rmiFeature','ChangeTrackingSltest')||(reqmgt('rmiFeature','MLChangeTracking')))&&...
        slreq.utils.isValidView(cView)&&cView.displayChangeInformation&&...
        ctmgr.hasLinksWithSourceChangeIssue(this.dataUuid)

        sourceChangeDetected=true;
    else
        sourceChangeDetected=false;
    end
    this.setDisplayIcon(sourceChangeDetected);

    icon=this.iconPath;
end
