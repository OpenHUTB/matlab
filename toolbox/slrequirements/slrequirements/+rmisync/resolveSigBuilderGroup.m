function[objH,groupNames,actCnt]=resolveSigBuilderGroup(parentPath,dmPaths,groupIdx)





    allGroupPaths=dmPaths(groupIdx);
    pathL=length(parentPath)+2;

    blockNgroup=allGroupPaths{1}(pathL:end);
    isSlash=blockNgroup=='/';
    slashIdx=find(isSlash);
    if length(slashIdx)==1
        fullPath=[parentPath,'/',blockNgroup(1:(slashIdx-1))];

    else

        dontCount=[isSlash(2:end)==isSlash(1:(end-1)),0];
        dontCount=dontCount|[0,dontCount(1:(end-1))];
        validIdx=find(isSlash&~dontCount);
        fullPath=[parentPath,'/',blockNgroup(1:(validIdx(1)-1))];

    end

    pathMatches=strncmp([fullPath,'/'],allGroupPaths,length(fullPath)+1);
    actCnt=sum(pathMatches);

    try
        objH=get_param(fullPath,'Handle');
    catch ME %#ok<NASGU>
        objH=-1;
    end


    if(actCnt==0)
        actCnt=1;
    end

    if(actCnt>1)
        objH=[objH;-2*ones(actCnt-1,1)];
    end

    firstGroupChar=length(fullPath)+2;
    groupNames=cell(actCnt,1);
    for i=1:actCnt
        groupNames{i,1}=allGroupPaths{i}(firstGroupChar:end);
    end
end
