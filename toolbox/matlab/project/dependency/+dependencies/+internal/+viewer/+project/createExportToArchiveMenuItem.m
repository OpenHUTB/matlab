function item=createExportToArchiveMenuItem(view)




    function export(controller,nodes)
        import dependencies.internal.graph.NodeFilter
        isNodeResolved=NodeFilter.isResolved.apply(nodes);
        isNodeFile=NodeFilter.nodeType("File").apply(nodes);
        resolvedFileNodes=nodes(isNodeResolved&isNodeFile);
        locations=unique(arrayfun(@i_getLocation,resolvedFileNodes));

        import matlab.internal.project.util.currentProjectExistsAndContainsAnyNode
        if currentProjectExistsAndContainsAnyNode(resolvedFileNodes)
            defaultArchiveName=matlab.project.currentProject().Name;
        else
            defaultArchiveName=i_getMessage("DefaultArchiveName");
        end
        defaultArchiveName=strcat(defaultArchiveName,".mlproj");

        filter={'*.mlproj',i_getMessage('ToArchiveProjectArchive','*.mlproj');...
        '*.zip',i_getMessage('ToArchiveArchiveFile','*.zip');...
        '*.*',i_getMessage('ToArchiveAllFiles')};
        dialogTitle=i_getMessage("ToArchiveMenuItemTitle");

        [archiveName,archivePath,index]=uiputfile(filter,dialogTitle,defaultArchiveName);

        if index==0
            return
        end

        archive=fullfile(archivePath,archiveName);
        if index==3
            if~endsWith(archive,'.mlproj')
                archive=[archive,'.mlproj'];
            end
        end


        import matlab.internal.project.util.getCommonParentFolder
        if currentProjectExistsAndContainsAnyNode(resolvedFileNodes)
            root=matlab.project.currentProject().RootFolder;
        elseif isempty(locations)
            root=pwd;
        else
            root=getCommonParentFolder(locations);
            if strcmp(root,"")
                error(i_getMessage("NoCommonRootFolder"));
            end
        end

        closure=dependencies.internal.viewer.project.addRequiredFiles(...
        controller.getGraph(),resolvedFileNodes,root);

        locations=arrayfun(@i_getLocation,closure);

        matlab.internal.project.archive.createArchive(...
        archive,root,locations);
    end

    item=dependencies.internal.viewer.MenuItem.createFor(view,@export);
    item.Name=i_getMessage("ToArchiveMenuItemTitle");
    item.Description=i_getMessage("ToArchiveMenuItemDescription");
    item.IconID="projectArchive";
    item.EnableAttributes.add("Exists");
    item.Priority=2;
    item.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.NO_SELECTION_MEANS_ALL;
end



function value=i_getMessage(resource,varargin)
    value=string(message("MATLAB:dependency:project:"+resource,varargin{:}));
end

function location=i_getLocation(node)
    location=string(node.Location{1});
end
