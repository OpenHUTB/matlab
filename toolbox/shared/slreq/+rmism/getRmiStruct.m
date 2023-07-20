function rmiStruct=getRmiStruct(obj,oldStructType)
    assert(rmism.isSafetyManagerObj(obj),"This is not a valid Safety Manager object!");

    rmiStruct=rmi.createEmptyReqs(1);

    if oldStructType
        rmiStruct.reqsys='linktype_rmi_safetymanager';
        rmiStruct.doc=obj.getFileName();
    else
        rmiStruct=rmfield(rmiStruct,'reqsys');
        rmiStruct=rmfield(rmiStruct,'doc');
        rmiStruct.domain='linktype_rmi_safetymanager';
        rmiStruct.artifact=obj.getFileName();
    end

    rmiStruct.id=obj.uuid;
    rmiStruct.description=obj.getSummaryString();
end
