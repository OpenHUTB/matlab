function[success,info,newCount]=rmidlgApply(reqObj,linkDstInfo)



    try
        srcInfo=slreq.utils.getRmiStruct(reqObj);
        slreq.internal.setLinks(srcInfo,linkDstInfo);
        success=true;
        info='';
        newCount=length(linkDstInfo);
    catch Mex
        success=false;
        info=Mex.message;
        newCount=-1;
    end
end
