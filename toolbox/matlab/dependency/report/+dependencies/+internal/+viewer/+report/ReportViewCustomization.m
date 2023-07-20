classdef ReportViewCustomization<dependencies.internal.viewer.ViewCustomization




    methods
        function customize(~,controller,~)
            view=controller.View;
            if view.ExportMenu.Size==0
                section=dependencies.internal.viewer.MenuSection(view.getViewModel);
                view.ExportMenu.insertAt(section,1);
            else
                section=view.ExportMenu(1);
            end

            section.Items.add(i_createExportToReportMenuItem(view));
        end
    end

end


function i_exportToReportCallback(controller,nodes)
    filter={'*.html',i_getMessage('ToReportWeb','*.html');...
    '*.docx',i_getMessage('ToReportDoc','*.docx');...
    '*.pdf',i_getMessage('ToReportPDF','*.pdf');...
    '*.*',i_getMessage('ToReportAllFiles')};

    dialogTitle=i_getMessage("ToReportMenuItemTitle");

    projectNameOrEmpty=i_getProjectNameIfInSessionProperties(...
    controller.View.SessionProperties);

    if~isempty(projectNameOrEmpty)
        defaultName=i_getMessage("ToReportDefaultFileNameIfProject",projectNameOrEmpty);
    else
        defaultName=i_getMessage("ToReportDefaultFileName");
    end
    [fileName,fileFolder,index]=uiputfile(filter,dialogTitle,defaultName);


    if index==0
        return
    end

    filePath=fullfile(fileFolder,fileName);
    if index==find(strcmp(filter,'*.*'))&&~endsWith(fileName,".html")
        filePath=filePath+".html";
    end

    nodes=arrayfun(@i_dropAdditionalLocations,nodes);
    filteredGraph=i_filterGraph(controller.getTransformedGraph,nodes);
    sessionProperties=i_StringPropertySequenceToStructArray(...
    controller.View.SessionProperties);
    rootFolders=i_StringSequenceToStringArray(...
    controller.View.RootFolders);

    analyzers=i_getAnalyzers(controller.View);
    attributes=dependencies.internal.attribute.analyze(...
    filteredGraph,analyzers);
    reportGenerator=dependencies.internal.report.ReportGenerator(...
    filteredGraph,...
    "Properties",sessionProperties,...
    "RootFolders",rootFolders,...
    "Attributes",attributes);
    progressBar=[];
    generationStartedListener=addlistener(...
    reportGenerator,"GenerationStarted",@generationStarted);
    generationProgressListener=addlistener(...
    reportGenerator,"GenerationProgress",@generationProgress);
    generationFinishedListener=addlistener(...
    reportGenerator,"GenerationFinished",@generationFinished);

    function generationStarted(~,evt)
        progressBar=waitbar(...
        0,i_getMessage("ProgressLabel",evt.FileName),...
        "Name",i_getMessage("ProgressTitle"),...
        "CreateCancelBtn",@cancelReportGeneration);
    end

    function cancelReportGeneration(~,~)
        reportGenerator.notify("Cancel");
        delete(progressBar);
    end

    function generationProgress(~,evt)
        waitbar(evt.Progress,progressBar);
    end

    function generationFinished(~,~)
        delete(generationStartedListener);
        delete(generationProgressListener);
        delete(generationFinishedListener);
        delete(progressBar);
        open(filePath);
    end

    reportGenerator.generateReport(filePath);
end

function item=i_createExportToReportMenuItem(view)
    item=dependencies.internal.viewer.MenuItem.createFor(...
    view,@i_exportToReportCallback);
    item.Name=i_getMessage("ToReportMenuItemTitle");
    item.Description=i_getMessage("ToReportMenuItemDescription");
    item.IconID="documentScript";
    item.Priority=1;
    item.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.NO_SELECTION_MEANS_ALL;
end


function analyzers=i_getAnalyzers(view)
    wrappers=view.AttributeAnalyzers.toArray;
    analyzers=[wrappers.Analyzer];
end


function projectName=i_getProjectNameIfInSessionProperties(props)
    projectName=string.empty;
    projectLabel=string(message(...
    "MATLAB:dependency:viewer:InspectorProjectName"));
    for index=1:props.Size
        if props(index).Name==projectLabel
            projectName=props(index).Value;
            return
        end
    end
end



function outGraph=i_filterGraph(inGraph,nodes)
    import dependencies.internal.viewer.util.createFilteredGraph;
    import dependencies.internal.graph.NodeFilter;
    nodeFilter=NodeFilter.isMember(nodes);
    outGraph=createFilteredGraph(...
    inGraph,nodeFilter,...
    "IncludeUnresolvedDownstreamFiles",false);
end

function fileNode=i_dropAdditionalLocations(node)
    fileNode=dependencies.internal.graph.Node.createFileNode(...
    node.Location{1});
end

function props=i_StringPropertySequenceToStructArray(viewSessionProperties)
    props=arrayfun(...
    @(prop)struct('Name',prop.Name,'Value',prop.Value),...
    viewSessionProperties.toArray());
end

function roots=i_StringSequenceToStringArray(viewRootFolders)
    roots=string(viewRootFolders.toArray());
end

function value=i_getMessage(resource,varargin)
    value=string(message("MATLAB:dependency:report:"+resource,varargin{:}));
end
