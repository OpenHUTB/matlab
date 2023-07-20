function discard(artifact)




    if slreq.data.ReqData.exists()
        slreq.discardLinkSet(artifact,true);


    end

    if isnumeric(artifact)


        modelH=artifact;


        rmidata.storageModeCache('remove',modelH);


        if rmi.isInstalled()&&strcmp(get_param(modelH,'ReqHilite'),'on')
            rmi.Informer.closeModel(get_param(modelH,'Name'));
        end
    end

end


