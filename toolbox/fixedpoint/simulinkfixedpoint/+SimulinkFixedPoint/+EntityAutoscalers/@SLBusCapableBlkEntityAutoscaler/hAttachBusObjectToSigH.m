function sigH=hAttachBusObjectToSigH(h,sigH,busObjName,busObject,blkObj)








































































    sigH.BusObject=busObjName;

    for childIndex=1:length(sigH.Children)
        child=sigH.Children(childIndex);
        if~isempty(child.Children)

            if isempty(busObject)

                busObject=evalinGlobalScope(bdroot(blkObj.handle),...
                busObjName);
            end
            subBusObjName=h.hCleanBusName...
            (busObject.Elements(childIndex).DataType);
            subBusSigH=child;
            subBusSigH=hAttachBusObjectToSigH(h,subBusSigH,...
            subBusObjName,[],blkObj);
            sigH.Children(childIndex)=subBusSigH;
        end
    end





