

function generateReport(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);

    modelH=slreq.toolstrip.getModelHandle(cbinfo);

    rmi('report',modelH,true);

end