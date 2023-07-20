function createLinkDialog(srcUuid,dstUuid)
    import slreq.report.internal.rtmx.*
    dlg=CreateLinkInRTMX(srcUuid,dstUuid);
    dlg.show();
end