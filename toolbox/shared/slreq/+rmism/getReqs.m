function reqs=getReqs(safetyManagerObject)
    reqs=slreq.getReqs(safetyManagerObject.getFileName(),safetyManagerObject.uuid,'linktype_rmi_safetymanager');
end
