function artifacts=reconsileArtifactNames(artifacts)





    totalItems=size(artifacts,1);


    isFullPath=false(totalItems,1);
    shortNames=cell(totalItems,1);
    for i=1:totalItems
        [aDir,aName,aExt]=fileparts(artifacts{i,1});
        isFullPath(i)=~isempty(aDir);
        shortNames{i}=[aName,aExt];
    end


    isMatched=false(totalItems,1);
    orderNumbers=(1:totalItems)';
    for i=1:totalItems
        if~isFullPath(i)
            thisName=artifacts{i,1};
            thisType=artifacts{i,2};
            isMatched(i)=any(i~=orderNumbers&strcmp(shortNames,thisName)&strcmp(artifacts(:,2),thisType));
        end
    end


    artifacts(isMatched,:)=[];
end
