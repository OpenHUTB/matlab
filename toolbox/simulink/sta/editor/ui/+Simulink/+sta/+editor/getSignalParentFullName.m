function parentFullName=getSignalParentFullName(sigIDToCopy)



    repoUtil=starepository.RepositoryUtility;


    lineageIDS(1)=repoUtil.getParent(sigIDToCopy);
    aParentID=lineageIDS(1);
    parentFullName=[];
    if aParentID~=0
        while aParentID~=0
            aParentID=repoUtil.getParent(lineageIDS(length(lineageIDS)));
            if aParentID~=0
                lineageIDS(length(lineageIDS)+1)=aParentID;
            end
        end

        parentFullName=repoUtil.getSignalLabel(lineageIDS(length(lineageIDS)));
        for k=length(lineageIDS)-1:-1:1
            parentFullName=[parentFullName,'.',repoUtil.getSignalLabel(lineageIDS(k))];
        end
    end
