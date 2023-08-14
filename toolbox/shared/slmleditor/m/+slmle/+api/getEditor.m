function ed=getEditor(input)








    ed=[];

    info=slmle.internal.getInfo(input);
    if isempty(info)
        return;
    end

    m=slmle.internal.slmlemgr.getInstance;
    ed=m.getMLFBEditor(info.objectId,info.blkH,info.studio);