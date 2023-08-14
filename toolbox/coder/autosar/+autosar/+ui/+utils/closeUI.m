function closeUI(arExplorer)




    assert(isa(arExplorer,'AUTOSAR.Explorer'),'arExplorer is not of AUTOSAR.Explorer type');
    autosarcore.unregisterListenerCB(arExplorer.TraversedRoot.M3iObject);
    traversedRoot=arExplorer.TraversedRoot;
    deleteTree(traversedRoot);
end


function deleteTree(root)
    if isvalid(root)
        hChildren=root.getHierarchicalChildren();
        nhChildren=root.getChildren();
        for i=length(nhChildren):-1:1
            deleteTree(nhChildren(i));
        end
        for i=length(hChildren):-1:1
            deleteTree(hChildren(i));
        end
        root.delete;
    end
end
