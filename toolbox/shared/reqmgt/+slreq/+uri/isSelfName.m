function tf=isSelfName(storedPath,actualArtifactPath)


    if iscell(storedPath)
        tf=false(size(storedPath));
        for i=1:length(tf)
            tf(i)=storedIsSelf(storedPath{i},actualArtifactPath);
        end
    else
        tf=storedIsSelf(storedPath,actualArtifactPath);
    end
end

function tf=storedIsSelf(stored,aFullPath)
    if rmiut.isCompletePath(stored)&&exist(stored,'file')
        tf=strcmp(stored,aFullPath);
    else
        [~,aName,aExt]=fileparts(aFullPath);
        tf=any(strcmp(stored,{'_SELF',aName,[aName,aExt]}));
    end
end
