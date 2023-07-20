



function[blkNameAsInCompiled,refMdl]=i_getMdlBlkNameFromRootPathPrefix(topModelName,reverseBDMap,rootPathPrefix)



    refMdl='';
    strcell=strsplit(rootPathPrefix,'/');
    if strcmp(strcell{1},topModelName)
        blkNameAsInCompiled=strjoin(strcell,'/');
    else
        strcell{1}=reverseBDMap(strcell{1});
        blkNameAsInCompiled=strjoin(strcell,'/');
    end
end


