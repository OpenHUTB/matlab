function differences=calculateEvolutionDifferences(treeInfo,baseEi,otherEi)




    differences.addedFiles=evolutions.model.BaseFileInfo.empty(0,1);
    differences.removedFiles=evolutions.model.BaseFileInfo.empty(0,1);
    differences.changedFiles=evolutions.model.BaseFileInfo.empty(0,1);
    differences.hasDifferences=false;
    if isempty(baseEi)||isempty(otherEi)
        return;
    end
    if~isequal(baseEi,otherEi)&&isa(baseEi,'evolutions.model.EvolutionInfo')...
        &&isa(otherEi,'evolutions.model.EvolutionInfo')

        addedFiles=evolutions.internal.utils.keydiff(baseEi,otherEi);
        if~isempty(addedFiles)
            differences.addedFiles=addedFiles;
        end
        removedFiles=evolutions.internal.utils.keydiff(otherEi,baseEi);
        if~isempty(removedFiles)
            differences.removedFiles=removedFiles;
        end
        differences.changedFiles=calculateChangedFiles(treeInfo,baseEi,otherEi);
        differences.hasDifferences=~isempty(addedFiles)||~isempty(removedFiles)...
        ||~isempty(differences.changedFiles);
    end

end

function changedFiles=calculateChangedFiles(treeInfo,baseEi,otherEi)

    sharedBfis=evolutions.internal.utils.sharedkeys(baseEi,otherEi);
    changedFiles=evolutions.model.BaseFileInfo.empty(0,1);
    for idx=1:numel(sharedBfis)
        bfi=sharedBfis(idx);


        if(baseEi.IsWorking)
            baseArtifactToCompare=bfi;
        else

            val=evolutions.internal.artifactserver.getFileMetaData(treeInfo,bfi,baseEi);
            baseArtifactToCompare=val;
        end

        if(otherEi.IsWorking)
            otherArtifactToCompare=bfi;
        else
            val=evolutions.internal.artifactserver.getFileMetaData(treeInfo,bfi,otherEi);
            otherArtifactToCompare=val;
        end



        if(baseEi.IsWorking)
            changedFiles=calcBfiArtifactDiff(baseArtifactToCompare,otherArtifactToCompare,changedFiles);%#ok<*AGROW> 
        elseif(otherEi.IsWorking)
            changedFiles=calcBfiArtifactDiff(otherArtifactToCompare,baseArtifactToCompare,changedFiles);
        else

            if areFilesDifferent(baseArtifactToCompare,otherArtifactToCompare)
                changedFiles(end+1)=bfi;
            end
        end
    end
end

function tf=areFilesDifferent(afi1,afi2)
    if(isempty(afi1)||isempty(afi2))
        tf=true;
        return;
    end
    afi1State=afi1.Data.CheckSum;
    afi2State=afi2.Data.CheckSum;
    tf=~isequal(afi1State,afi2State);

end

function changedFile=calcBfiArtifactDiff(baseFile,artifact,files)





    if isempty(artifact)||~isequal(baseFile.CheckSum,artifact.Data.CheckSum)
        files(end+1)=baseFile;
    end
    changedFile=files;
end


