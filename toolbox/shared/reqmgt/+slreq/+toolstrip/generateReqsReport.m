

function generateReqsReport(cbinfo)

    reqdata=slreq.data.ReqData.getInstance;
    allreqsets=reqdata.getLoadedReqSets;
    mgr=slreq.app.MainManager.getInstance;
    reqroot=mgr.reqRoot;
    slreq.report.utils.openOptionDlg(allreqsets,reqroot.children);

end