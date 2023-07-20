function trueOrFalse=isCreatingMarkup(objHandle)

















    trueOrFalse=true;
    sr=sfroot;

    isSLObj=sr.isValidSlObject(objHandle);





    if rmisl.isLibObject(objHandle)
        trueOrFalse=false;
        return;
    end


    if~isSLObj

        [transInfo,viewerInfo]=slreq.utils.getTransitionViewerList(objHandle);
        if~isempty(transInfo)&&~viewerInfo.isInTopView&&~viewerInfo.isInSourceView
            trueOrFalse=false;
            return;
        end
    end

    if rmisl.isObjectUnderCUT(objHandle)
        trueOrFalse=false;
        return;
    end

end
