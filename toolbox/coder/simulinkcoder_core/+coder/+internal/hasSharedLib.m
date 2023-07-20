function[lHasSharedLib,lSharedLibPath,lSharedLibName,sharedSrcLinkObject]...
    =hasSharedLib(lBuildInfo)




    sharedLibGroup='SHARED_SRC_LIB';

    linkObjs=lBuildInfo.LinkObjsDirect;
    sharedSrcIdx=strcmp({linkObjs.Group},sharedLibGroup);
    sharedSrcLinkObject=linkObjs(sharedSrcIdx);

    lHasSharedLib=~isempty(sharedSrcLinkObject);


    lSharedLibPath='';
    lSharedLibName='';
    if lHasSharedLib&&nargout>1

        lSharedLibPath=sharedSrcLinkObject.Path;



        startDir='$(START_DIR)';
        N=length(startDir);

        assert(strncmp(startDir,lSharedLibPath,N),...
        'Path must start with relative path to anchor');
        lSharedLibPath=lSharedLibPath(N+2:end);

        lSharedLibName=sharedSrcLinkObject.Name;
    end

