function checkConsistency(cbinfo)

    modelH=slreq.toolstrip.getModelHandle(cbinfo);
    rmi('check',modelH,'modeladvisor');

end
