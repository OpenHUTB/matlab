function components=getComponentsToAddToSequenceDiagram(zcViewName,zcModelName)




    components={};
    zcModel=get_param(zcModelName,'SystemComposerModel');
    zcModelImpl=zcModel.getImpl;
    view=zcModelImpl.getView(zcViewName);
    if~isempty(view)
        elems=view.getRoot().getElements;
        components=getComponentsToAddToSequenceDiagramFromElements(elems,components);

        subGroups=view.getRoot().p_SubGroups;
        if~isempty(subGroups)
            subGroups=subGroups.toArray;
            components=getComponentsToAddToSequenceDiagramFromSubGroups(subGroups,components);
        end
    end
end

function components=getComponentsToAddToSequenceDiagramFromElements(elems,components)
    componentsToAdd=arrayfun(@(elem)elem.getQualifiedName,elems,'UniformOutput',false);
    components=[components,componentsToAdd];
end

function components=getComponentsToAddToSequenceDiagramFromSubGroups(subGroups,components)
    for index=1:numel(subGroups)
        subGroup=subGroups(index);
        elems=subGroup.getElements;
        components=getComponentsToAddToSequenceDiagramFromElements(elems,components);

        chilSubGroups=subGroup.p_SubGroups;
        if~isempty(chilSubGroups)
            chilSubGroups=chilSubGroups.toArray;
            components=getComponentsToAddToSequenceDiagramFromSubGroups(chilSubGroups,components);
        end
    end
end
