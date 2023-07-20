function out=documentIsDirty(obj,objectId)


    if obj.logger
        disp(mfilename);
    end

    out=false;

    m=slmle.internal.slmlemgr.getInstance;
    eds=m.getMLFBEditorsFromAllStudios(objectId);

    if isempty(eds)
        return;
    end

    ed=eds{1};
    modelH=bdroot(ed.blkH);

    if isempty(modelH)
        return;
    end

    out=strcmp(get_param(modelH,'dirty'),'on');