function mdlRefSyncReqs(src,destination)

    if ischar(src)

        [~,srcName]=fileparts(src);

        try
            get_param(srcName,'Handle');
        catch ex %#ok<NASGU>
            load_system(src);
        end
        reqs=rmi.getReqs(srcName);
    else
        reqs=rmi.getReqs(src);
    end

    if isempty(reqs)||all(~[reqs.linked])
        return;
    end

    if ischar(destination)

        reqStr=rmi.reqs2str(reqs);
        newMdlH=get_param(destination,'Handle');
        rmi.objCopy(newMdlH,reqStr,newMdlH,false);
        set_param(newMdlH,'hasReqInfo','on');
        rmidata.storageModeCache('set',newMdlH,false);
    else
        dstMdlH=rmisl.getmodelh(destination);
        if rmidata.isExternal(dstMdlH)
            rmidata.objCopy(destination,reqs,dstMdlH,false);
        else
            reqStr=rmi.reqs2str(reqs);
            rmi.objCopy(destination,reqStr,dstMdlH,false);
        end
    end
end
