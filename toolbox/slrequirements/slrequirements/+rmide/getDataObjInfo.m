function[navcmd,dispstr,iconFile]=getDataObjInfo(ddFile,guidstr)

    if~rmiut.isCompletePath(ddFile)
        ddFile=rmide.resolveDict(ddFile);
    end

    dispstr=rmide.getEntryPath(ddFile,guidstr);

    if strcmp(rmipref('ModelPathReference'),'none')
        ddFile=slreq.uri.getShortNameExt(ddFile);
    end

    navcmd=['rmiobjnavigate(''',ddFile,''',''',guidstr,''');'];

    if nargout==3
        iconFile=rmiut.getMwIcon();
    end

end
