function childrenDeleted=removeEvolutionBranch(obj,ei,evManager)





    childrenDeleted=cell.empty;
    [childrenEis,workingIsChild]=...
    evolutions.internal.utils.findEvolutionChildren(...
    evManager,...
    ei);
    workingEi=evManager.WorkingEvolution;
    if evManager.RootEvolution~=ei
        parentEi=ei.Parent;
        obj.removeEdge(ei,parentEi);
        if workingIsChild

            workingEi=evManager.WorkingEvolution;
            obj.addEdge(workingEi,parentEi);
        end
    else



        workingEi.Parent=evolutions.model.EvolutionInfo.empty(0,1);
        evManager.RootEvolution=workingEi;

        ei.NumRefs=0;
    end

    for childIdx=1:numel(childrenEis)
        curChild=childrenEis(childIdx);
        curChild.releaseReferences;
        childrenDeleted{end+1}=curChild.getName;%#ok<AGROW>
    end


    ei.releaseReferences;

    childrenDeleted{end+1}=ei.getName;
end


