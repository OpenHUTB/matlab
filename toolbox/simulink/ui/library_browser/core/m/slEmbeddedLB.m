function slEmbeddedLB(studio)

    LibraryBrowser.internal.isLBInitialized();
    bd_name=get_param(studio.App.blockDiagramHandle,'name');

    lbcomp=studio.getComponent('LibraryBrowser2 LibraryBrowserStudioComponent',bd_name);

    if isempty(lbcomp)
        msg=message('sl_lib_browse2:sl_lib_browse2:SLLB_StartingLibraryBrowser');
        SLStudio.internal.ScopedStudioBlocker(msg.getString());
        lbcomp=LibraryBrowser.LBStudioComponent(studio,bd_name);
        studio.registerComponent(lbcomp);
        title=message('sl_lib_browse2:sl_lib_browse2:SLLB_LibraryBrowserTabTitle').getString();
        studio.moveComponentToDock(lbcomp,title,'Left','Tabbed');
        studio.showComponent(lbcomp);
    else
        if studio.isComponentVisible(lbcomp)
            studio.hideComponent(lbcomp);
        else
            studio.showComponent(lbcomp);
        end
    end
end