function[childrenEis,workingIsChild]=findEvolutionChildren(...
    evolutionManager,evolutionInfo)





    workingIsChild=false;
    childrenEis=evolutions.model.EvolutionInfo.empty(0,1);
    [childrenEis,workingIsChild]=findChildrenRecursively(...
    childrenEis,evolutionInfo,...
    evolutionManager.WorkingEvolution,...
    workingIsChild);
end

function[childrenEis,workingIsChild]=findChildrenRecursively(...
    childrenEis,evolutionInfo,workingEvolutionInfo,workingIsChild)
    children=evolutionInfo.Children;
    for childIdx=1:numel(children)
        curChildEi=children(childIdx);
        if curChildEi==workingEvolutionInfo

            workingIsChild=true;
        else
            childrenEis(end+1)=curChildEi;%#ok<AGROW>
            [childrenEis,workingIsChild]=findChildrenRecursively(...
            childrenEis,curChildEi,workingEvolutionInfo,workingIsChild);
        end
    end
end


