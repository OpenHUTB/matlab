function removeEvolution(obj,ei,evManager)




    deletingRoot=ei==evManager.RootEvolution;
    if deletingRoot
        if numel(evManager.RootEvolution.Children)>1
            error(getString(message('evolutions:manage:InvalidRootDelete')));
        end
    end

    if(ei==evManager.WorkingEvolution)
        error(getString(message('evolutions:manage:InvalidWorkingDelete')));
    end
    eiToDeleteChildren=ei.Children;
    eiToDeleteParent=ei.Parent;
    if~deletingRoot


        obj.removeEdge(ei,eiToDeleteParent);


        for childIdx=1:numel(eiToDeleteChildren)

            curChild=eiToDeleteChildren(childIdx);

            childToEiEdge=obj.findEdge(curChild,ei);

            ei.ChildEdges.remove(childToEiEdge);

            childToEiEdge.connect(curChild,eiToDeleteParent);

            eiToDeleteParent.addChild(childToEiEdge);
        end
    else



        newRoot=eiToDeleteChildren(1);
        newRoot.removeParent;
        obj.removeEdge(newRoot,ei);
        evManager.RootEvolution=newRoot;

        ei.NumRefs=0;
    end

    if ei==evManager.WorkingEvolution
        evManager.WorkingEvolution=evolutions.model.EvolutionInfo.empty(0,1);
    end
    ei.releaseReferences;
end

