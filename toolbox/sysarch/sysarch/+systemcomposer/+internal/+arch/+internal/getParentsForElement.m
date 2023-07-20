function parents=getParentsForElement(appName,elemUUID)
















    app=systemcomposer.internal.arch.load(appName);
    archViewModel=app.getArchitectureViewsManager.getModel;
    elem=archViewModel.findElement(elemUUID);
    assert(~isempty(elem));

    if(isa(elem,'systemcomposer.architecture.model.view.ViewComponent'))

        parents=getParentsForBaseViewComponent(elem);
    elseif(isa(elem,'systemcomposer.architecture.model.view.ComponentOccurrence'))

        parents=getParentsForBaseViewComponent(elem);
    else
        assert(isa(elem,'systemcomposer.architecture.model.view.View'));

        parents={};
    end

end


function parentMap=getParentsForBaseViewComponent(viewComp)
    views=viewComp.getViews;
    parentMap={};
    for i=1:numel(views)
        if(viewComp.isViewParent(views(i)))
            parentMap=addPairToMap(parentMap,views(i).getName,views(i).UUID,'ROOT',views(i).UUID);
        end

        parent=viewComp.getParentInView(views(i));
        if(~isempty(parent))
            parentMap=addPairToMap(parentMap,views(i).getName,views(i).UUID,parent.getName,parent.UUID);
        end
    end
end

function parentMap=addPairToMap(parentMap,viewName,viewUUID,parentName,parentUUID)
    if(isempty(parentMap))
        parentMap=struct('ViewName',viewName,'ViewUUID',viewUUID,'ParentNames',{parentName},'ParentUUIDs',{parentUUID});
    else
        exists=false;
        for i=1:numel(parentMap,1)
            if strcmp(parentMap(i).ViewName,viewName)
                if(strcmp(parentName,'ROOT'))

                    parentMap(i).ParentNames={parentName,parentMap(i).ParentNames};
                    parentMap(i).ParentUUIDs={parentUUID,parentMap(i).ParentUUIDs};
                else
                    parentMap(i).ParentNames={parentMap(i).ParentNames,parentName};
                    parentMap(i).ParentUUIDs={parentMap(i).ParentUUIDs,parentUUID};
                end
                exists=true;
            end
        end
        if(~exists)
            parentMap(i+1)=struct('ViewName',viewName,'ViewUUID',viewUUID,'ParentNames',{parentName},'ParentUUIDs',{parentUUID});
        end
    end
end