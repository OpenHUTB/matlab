classdef ExportViewCustomization<dependencies.internal.viewer.ViewCustomization




    methods
        function customize(~,controller,~)
            view=controller.View;
            if view.ExportMenu.Size==0
                section=dependencies.internal.viewer.MenuSection(view.getViewModel);
                view.ExportMenu.insertAt(section,1);
            else
                section=view.ExportMenu(1);
            end

            section.Items.add(i_createExportToWorkspaceMenuItem(view));
            section.Items.add(i_createExportToGraphmlMenuItem(view));
            section.Items.add(i_createExportToImageMenuItem(view));
        end
    end

end


function i_exportToWorkspaceCallback(~,nodes)
    paths=unique(arrayfun(@(n)string(n.Location{1}),nodes'));
    dependencies.internal.viewer.matlab.exportToWorkspaceDialog(paths);
end

function item=i_createExportToWorkspaceMenuItem(view)
    item=dependencies.internal.viewer.MenuItem.createFor(...
    view,@i_exportToWorkspaceCallback);
    item.Name=i_getMessage("ToBaseWorkspaceMenuItemTitle");
    item.Description=i_getMessage("ToBaseWorkspaceMenuItemDescription");
    item.IconID="workspace";
    item.Priority=0;
    item.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.NO_SELECTION_MEANS_ALL;
end


function i_exportToGraphmlCallback(controller,nodes)
    filter={'*.graphml',i_getMessage('ToGraphMLDependencyGraph','*.graphml')};
    dialogTitle=i_getMessage("ToGraphMLMenuItemTitle");
    defaultFile=i_getMessage("ToGraphMLDefaultFile");

    [fileName,fileFolder]=uiputfile(filter,dialogTitle,defaultFile);


    if fileName==0
        return
    end

    filePath=fullfile(fileFolder,fileName);

    if~endsWith(filePath,".graphml")
        filePath=filePath+".graphml";
    end

    project=matlab.project.currentProject();
    if isempty(project)
        root="";
    else
        root=project.RootFolder;
    end

    filteredGraph=i_filterGraphByLocations(controller.getGraph,nodes);
    dependencies.internal.graph.writeGraphML(filePath,root,filteredGraph);
end

function item=i_createExportToGraphmlMenuItem(view)
    item=dependencies.internal.viewer.MenuItem.createFor(...
    view,@i_exportToGraphmlCallback);
    item.Name=i_getMessage("ToGraphMLMenuItemTitle");
    item.Description=i_getMessage("ToGraphMLMenuItemDescription");
    item.IconID="documentHierarchy";
    item.Priority=3;
    item.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.NO_SELECTION_MEANS_ALL;
end



function i_exportToImagelCallback(controller,~)
    filter=i_getImageExtensionFilter();
    dialogTitle=i_getMessage("ToImageMenuItemTitle");
    defaultFile=i_getMessage("ToImageDefaultFile");

    [fileName,fileFolder]=uiputfile(filter,dialogTitle,defaultFile);

    if fileName==0
        return
    end

    dependencies.internal.viewer.export.toImage(...
    controller,fullfile(fileFolder,fileName));
end

function filter=i_getImageExtensionFilter()
    imageExtensions=lower(string(properties(diagram.editor.print.ExportFormat)));

    extensionsWithPrefix=arrayfun(@(ext)"*."+ext,imageExtensions);

    explanationStrings=arrayfun(...
    @(ext)upper(ext)+" (*."+ext+")",imageExtensions);

    filter=[extensionsWithPrefix,explanationStrings];
end

function item=i_createExportToImageMenuItem(view)
    item=dependencies.internal.viewer.MenuItem.createFor(...
    view,@i_exportToImagelCallback);
    item.Name=i_getMessage("ToImageMenuItemTitle");
    item.Description=i_getMessage("ToImageMenuItemDescription");
    item.IconID="image";
    item.Priority=4;
    item.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.NO_SELECTION_MEANS_ALL;
end



function outGraph=i_filterGraphByLocations(inGraph,nodes)
    import dependencies.internal.viewer.util.createFilteredGraph;
    import dependencies.internal.graph.NodeFilter;

    selectedNodeFilter=NodeFilter.isMemberByLocation(nodes);

    outGraph=createFilteredGraph(inGraph,selectedNodeFilter);
end


function value=i_getMessage(resource,varargin)
    value=string(message("MATLAB:dependency:viewer:"+resource,varargin{:}));
end
