classdef ProjectViewCustomization<dependencies.internal.viewer.ViewCustomization




    methods
        function customize(~,controller,nodes)
            import dependencies.internal.attribute.project.UnsavedFilesAnalyzer
            view=controller.View;
            view.addAttributeAnalyzer(UnsavedFilesAnalyzer());

            i_addExportToArchiveButton(view)

            if matlab.internal.project.util.currentProjectExistsAndContainsAnyNode(nodes)
                i_applyProjectDecoration(controller,matlab.project.currentProject());
            else
                i_addCreateProjectButton(view);
            end
        end
    end
end


function i_addExportToArchiveButton(view)
    import dependencies.internal.viewer.project.createExportToArchiveMenuItem
    item=createExportToArchiveMenuItem(view);
    exportMenu=view.ExportMenu;

    if exportMenu.Size==0
        section=dependencies.internal.viewer.MenuSection(...
        view.getViewModel);
        exportMenu.add(section);
    else
        section=exportMenu(1);
    end

    section.Items.add(item);
end

function i_addCreateProjectButton(view)
    import dependencies.internal.viewer.project.createCreateProjectButton
    section=dependencies.internal.viewer.MenuSection(view.getViewModel);
    section.Items.add(createCreateProjectButton(view));
    view.ProjectMenu.add(section);
end

function i_applyProjectDecoration(controller,project)
    view=controller.View;

    if matlab.internal.project.util.useWebFrontEnd
        import dependencies.internal.viewer.project.createSourceControlWorkflow;
        view.AvailableWorkflows.add(createSourceControlWorkflow(view));
        for category=project.Categories
            import dependencies.internal.viewer.project.createProjectLabelWorkflow;
            view.AvailableWorkflows.add(createProjectLabelWorkflow(view,category.Name));
        end
        dependencies.internal.viewer.project.attachCategoryListener(view,controller);
        dependencies.internal.viewer.project.attachFileListener(controller);

        import dependencies.internal.viewer.project.createContextActions;
        view.ContextMenu.add(createContextActions(view));
        view.ContextMenu.add(i_createHideWarningsContextMenu(view));




        suppressed=string.empty;
    else
        import dependencies.internal.viewer.project.createSourceControlView;
        view.AvailableWorkflows.add(createSourceControlView(view));
        import dependencies.internal.viewer.project.createLabelView
        for category=project.Categories
            view.AvailableWorkflows.add(createLabelView(view,category));
        end
        listener=com.mathworks.toolbox.slprojectdependency.Events.createListener(...
        @(paths)controller.refresh(string(paths.toArray)),...
        @(categoryName)(view.AvailableWorkflows.add(createLabelView(view,project.findCategory(categoryName)))),...
        @(categoryUUID)(i_removeWorkflowWithIdentifier(view,categoryUUID)),...
        @(categoryName,categoryUUID)(i_renameWorkflow(view,categoryName,categoryUUID)),...
        @()i_refreshAllNodes(controller));

        controller.addSubscription(@listener.dispose);

        view.ContextMenu.add(i_createProjectContextMenuJava(view));
        view.ContextMenu.add(i_createHideWarningsContextMenu(view));
        view.ProjectMenu.add(i_createProjectExportMenu(view));

        suppressed=string(com.mathworks.toolbox.slprojectdependency.Queries.getSuppressedFiles.toArray);
    end

    arrayfun(@(path)view.SuppressedFilePaths.add(path),suppressed);

    projectName=project.Name;
    if ""==projectName
        projectName=string(message("MATLAB:dependency:project:ProjectNameUntitled"));
    end

    import dependencies.internal.viewer.StringPropertyType;
    view.SessionProperties.add(i_createStringProperty(...
    view,"InspectorProjectName",projectName,StringPropertyType.TEXT));
    view.SessionProperties.add(i_createStringProperty(...
    view,"InspectorProjectRootFolder",project.RootFolder,StringPropertyType.PATH));

    view.RootFolders.add(project.RootFolder);

    import dependencies.internal.attribute.project.ProjectAnalyzer
    if usejava('jvm')
        view.addAttributeAnalyzer(ProjectAnalyzer(project));
    end
end

function i_refreshAllNodes(controller)
    nodes=controller.getTransformedGraph().Nodes();
    fileNodes=nodes(nodes.isFile);
    paths=arrayfun(@(node)(string(node.Location{1})),fileNodes);
    controller.refresh(paths);
end

function i_removeWorkflowWithIdentifier(view,identifier)
    for workflow=view.AvailableWorkflows.toArray
        if strcmp(workflow.Identifier,identifier)
            view.AvailableWorkflows.remove(workflow);
            workflow.destroy();
            return;
        end
    end

end

function i_renameWorkflow(view,categoryName,identifier)
    import dependencies.internal.viewer.project.createLabelView
    i_removeWorkflowWithIdentifier(view,identifier);
    view.AvailableWorkflows.add(createLabelView(view,categoryName));
end

function prop=i_createStringProperty(view,nameKey,value,propertyType)
    import dependencies.internal.viewer.StringProperty;
    prop=StringProperty(view.getViewModel,struct(...
    'Name',string(message("MATLAB:dependency:viewer:"+nameKey)),...
    'Value',value,...
    'Type',propertyType));
end

function section=i_createProjectContextMenuJava(view)

    section=dependencies.internal.viewer.MenuSection(view.getViewModel);

    addFile=i_createContextMenuItemJava(view,"addFile","AddToProjectMenuItem");
    addFile.VisibleAttributes.add("NotInProject");
    section.Items.add(addFile);

    removeFile=i_createContextMenuItemJava(view,"removeFile","RemoveFromProjectMenuItem");
    removeFile.VisibleAttributes.add("InProject");
    section.Items.add(removeFile);

    addLabel=i_createContextMenuItemJava(view,"addLabel","AddLabelMenuItem");
    addLabel.EnableAttributes.add("InProject");
    section.Items.add(addLabel);

    removeLabel=i_createContextMenuItemJava(view,"removeLabel","RemoveLabelMenuItem");
    removeLabel.EnableAttributes.add("InProject");
    section.Items.add(removeLabel);

end


function section=i_createHideWarningsContextMenu(view)

    function show(~,nodes)
        paths=arrayfun(@(n)string(n.Location{1}),nodes);
        com.mathworks.toolbox.slprojectdependency.Actions.showWarnings(paths);
        arrayfun(@(path)view.SuppressedFilePaths.remove(path),paths);
    end

    function hide(~,nodes)
        paths=arrayfun(@(n)string(n.Location{1}),nodes);
        com.mathworks.toolbox.slprojectdependency.Actions.hideWarnings(paths);
        arrayfun(@(path)view.SuppressedFilePaths.add(path),paths);
    end

    section=dependencies.internal.viewer.MenuSection(view.getViewModel);

    showWarnings=dependencies.internal.viewer.MenuItem.createFor(view,@show);
    showWarnings.Name=string(message("MATLAB:dependency:project:ShowWarningsMenuItem"));
    showWarnings.VisibleAttributes.add("Suppressed");
    showWarnings.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.REQUIRE_SELECTION;
    section.Items.add(showWarnings);

    hideWarnings=dependencies.internal.viewer.MenuItem.createFor(view,@hide);
    hideWarnings.Name=string(message("MATLAB:dependency:project:HideWarningsMenuItem"));
    hideWarnings.VisibleAttributes.add("NotSuppressed");
    hideWarnings.EnableAttributes.add("HasWarning");
    hideWarnings.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.REQUIRE_SELECTION;
    section.Items.add(hideWarnings);
end


function section=i_createProjectExportMenu(view)

    section=dependencies.internal.viewer.MenuSection(view.getViewModel);
    section.Items.add(i_createMenuItemJava(...
    view,...
    "showInProject",...
    "ShowInProjectMenuItem",...
    "ShowInProjectMenuItemDescription",...
    "details_project",...
    0));
    section.Items.add(i_createMenuItemJava(...
    view,...
    "showInCustomTask",...
    "ShowInCustomTaskMenuItem",...
    "ShowInCustomTaskMenuItemDescription",...
    "task",...
    1,...
    "InProject"));

end


function item=i_createContextMenuItemJava(view,action,name)

    function run(~,nodes)
        paths=arrayfun(@(n)string(n.Location{1}),nodes);
        com.mathworks.toolbox.slprojectdependency.Actions.(action)(paths);
    end

    item=dependencies.internal.viewer.MenuItem.createFor(view,@run);
    item.Name=string(message("MATLAB:dependency:project:"+name));
    item.EnableAttributes.add("Exists");
    item.EnableAttributes.add("UnderProjectRoot");
    item.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.REQUIRE_SELECTION;

end



function item=i_createMenuItemJava(view,action,name,description,icon,priority,extraAttribute)

    item=i_createContextMenuItemJava(view,action,name);

    item.Description=string(message("MATLAB:dependency:project:"+description));
    item.IconID=icon;
    item.Priority=priority;

    if nargin>6
        item.EnableAttributes.add(extraAttribute);
    end

end
