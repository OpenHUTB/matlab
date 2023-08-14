function item=createCreateProjectButton(view)




    function callback(controller,nodes)
        graph=controller.getGraph();

        import dependencies.internal.graph.NodeFilter
        isNodeResolved=NodeFilter.isResolved.apply(nodes);
        isNodeFile=NodeFilter.nodeType("File").apply(nodes);
        resolvedFileNodes=nodes(isNodeResolved&isNodeFile);
        locations=unique(arrayfun(@i_getLocation,resolvedFileNodes));

        if isempty(locations)
            error(i_getMessage("NoValidFiles"));
        end

        matlab.internal.project.creation.fromFile(...
        locations,...
        ProjectCreatedCallback=@(~)i_updateDependencyAnalyzer(controller),...
        Graph=graph);
    end

    item=dependencies.internal.viewer.MenuItem.createFor(view,@callback);
    item.Name=string(i_getMessage("CreateProjectMenuItemTitle"));
    item.Description=string(i_getMessage("CreateProjectMenuItemDescription"));
    item.IconID="new_project";
    item.EnableAttributes.add("Exists");
    item.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.NO_SELECTION_MEANS_ALL;
end


function i_updateDependencyAnalyzer(controller)
    controller.notify("CloseRequest");
    matlab.internal.project.dependency.openDependencyAnalyzer(currentProject())
end

function value=i_getMessage(resource)
    value=message("MATLAB:dependency:project:"+resource);
end


function location=i_getLocation(node)
    location=string(node.Location{1});
end
