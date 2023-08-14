




function explr=findExplorer(explrRoot)

    root=DAStudio.Root;
    listObjs=find(root,'-isa','AUTOSAR.Explorer');

    explr=[];
    for j=1:length(listObjs)
        listObj=listObjs(j);

        if isfile(listObj.SharedAutosarDictionary)&&isa(explrRoot,autosar.ui.metamodel.PackageString.TargetRootClass)
            sharedM3IModel=autosar.dictionary.Utils.getM3IModelForDictionaryFile(...
            listObj.SharedAutosarDictionary);
            if(sharedM3IModel==explrRoot)

                explr=listObj;
                return;
            end
        end
        if(listObj.getRoot==explrRoot)...
            ||...
            (isa(explrRoot,autosar.ui.metamodel.PackageString.TargetRootClass)...
            &&~isempty(listObj.TraversedRoot)&&~isempty(listObj.TraversedRoot.getM3iObject())...
            &&listObj.TraversedRoot.getM3iObject()==explrRoot)
            explr=listObj;
            return;
        end
    end
end
