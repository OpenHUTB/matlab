function exportToWebCB(cbinfo)



    ed=cbinfo.studio.App.getActiveEditor();
    hid=ed.getHierarchyId;
    slreportgen.webview.ui.Exporter.showDialog(hid);
end