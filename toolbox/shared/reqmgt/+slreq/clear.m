








function clear()


    errorIfReqTableOpened();

    slreq.analysis.ChangeTracker.clearCache();


    if slreq.app.MainManager.exists()

        appmgr=slreq.app.MainManager.getInstance();

        appmgr.disengageAndReset();

        slreq.das.Requirement.onSetSectionNumber('clear');

    elseif slreq.data.ReqData.exists()


        rdata=slreq.data.ReqData.getInstance();
        rdata.reset();

    end


    if slreq.internal.isSharedSlreqInstalled()&&slreq.linkmgr.LinkSetManager.exists()
        slreq.linkmgr.LinkSetManager.getInstance.reset();
        slreq.linkmgr.LinkSetUpdateMgr.clear();
    end
    rmiml.RmiMUnitData.reset();
    slreq.uri.ReqSetLocator.reset();


    slreq.utils.closeLinkEditorDlg();
    slreq.utils.CleanupDialogs.clearChangeIssues();
    if dig.isProductInstalled('Requirements Toolbox')


        slreq.gui.FilterEditor.closeDlg();
        slreq.report.OptionDlg.getOptionDlg('clear');
        slreq.import.ui.dlg_mgr('clear');
        slreq.mleditor.moveBookmark([]);

        slreq.gui.OutdatedProfileDialog.closeOutdatedProfileDialog();


        slreq.import('clearcache');


        rmiprj.currentProject();

        slreq.gui.ExternalEditor.cleanCachedDirs();
        slreq.report.rtmx.utils.MatrixWindow.closeWindows();
        slreq.report.rtmx.utils.RTMXReqDataExporter.getInstance.reset();
        slreq.internal.tracediagram.utils.DiagramManager.closeAllWindows();
        slreq.internal.tracediagram.data.ArtifactDependencyDepot.clearData();
    end
end

function errorIfReqTableOpened()

    reqsets=slreq.data.ReqData.getInstance.getLoadedReqSets();
    for i=1:length(reqsets)
        parentMdl=reqsets(i).parent;
        if~isempty(parentMdl)

            error(message('Slvnv:slreq:EmbeddedReqSetOpened',parentMdl,reqsets(i).name));
        end
    end
end
