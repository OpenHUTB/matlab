function ed=createEditor(input)








    info=slmle.internal.getInfo(input);
    m=slmle.internal.slmlemgr.getInstance;

    ed=m.addMLFBEditor(info.objectId,info.blkH,info.studio);
