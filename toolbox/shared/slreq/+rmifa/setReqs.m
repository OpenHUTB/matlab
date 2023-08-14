function id=setReqs(obj,reqs)




    [fPath,id]=rmifa.resolve(obj);

    src=slreq.utils.getRmiStruct(fPath,id,'linktype_rmi_simulink');
    slreq.internal.setLinks(src,reqs);
end
