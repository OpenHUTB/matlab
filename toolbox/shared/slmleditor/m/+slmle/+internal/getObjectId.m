function objectId=getObjectId(cbinfo,varargin)




    if isempty(cbinfo)
        return;
    end


    studio=cbinfo.studio;
    mlfbEd=studio.App.getActiveEditor;
    mlfbName=mlfbEd.getName;

    m=slmle.internal.slmlemgr.getInstance;
    objectId=m.getObjectId(mlfbName);

















end



