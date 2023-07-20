function result=closeAll(isForce)





    if nargin<1
        isForce=false;
    end

    try
        result=true;


        if isempty(which('com.mathworks.mlservices.MLEditorServices'))
            return;
        end


        if~rmi.isInstalled()||~slreq.data.ReqData.exists()
            return;
        end


        allOpenFiles=rmiut.RangeUtils.getOpenFilePaths();
        for i=1:length(allOpenFiles)
            rmiml.close(allOpenFiles{i},isForce);
        end


        if ddlinkIsLoaded()
            rmide.closeAll(isForce);
        end


        if rmi.isInstalled()
            slreq.utils.closeAll(isForce);
        end

    catch ex

        rmiut.warnNoBacktrace('Error in rmiml.closeAll(): %s',ex.message);
        pause(2);
        result=false;
    end
end



function yesno=ddlinkIsLoaded()
    linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
    yesno=any(strcmp({linkSets.domain},'linktype_rmi_data'));
end


