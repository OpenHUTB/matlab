function changed=resolve(ref,srcPath,loadReqs)


    changed=false;
    reqData=slreq.data.ReqData.getInstance();
    for idx=1:numel(ref)
        reqData.resolveReference(ref(idx),srcPath,loadReqs);
    end
