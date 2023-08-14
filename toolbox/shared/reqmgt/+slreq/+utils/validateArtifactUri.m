function artifact=validateArtifactUri(artifact)



    if rmiut.isCompletePath(artifact)
        return;
    end
    if exist(artifact,'file')

        artifact=which(artifact);
    else

        rmiut.warnNoBacktrace('Slvnv:slreq:NeedFullPathToFile',artifact,slreq.uri.getShortNameExt(artifact));
    end
end