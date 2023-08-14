




function toggleSequenceDiagramBrowserCB(cbinfo)
    studio=cbinfo.studio;

    SDBrowserComp=studio.getComponent('GLUE2:Sequence Diagram Browser Component','SD Browser');
    if~isempty(SDBrowserComp)&&SDBrowserComp.isVisible()
        studio.hideComponent(SDBrowserComp);
    else
        sequencediagram.internal.openSdBrowser(studio);
    end

end

