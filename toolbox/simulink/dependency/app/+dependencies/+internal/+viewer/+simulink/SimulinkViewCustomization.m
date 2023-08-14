classdef SimulinkViewCustomization<dependencies.internal.viewer.ViewCustomization




    methods

        function customize(~,controller,~)
            view=controller.View;
            i_replaceMainDocLink(view)
            view.AvailableWorkflows.add(i_createModelHierarchyWorkflow(view));
            view.AvailableWorkflows.add(i_createModelInstanceWorkflow(view));
        end

    end

end

function i_replaceMainDocLink(view)
    newDocLink=i_createSimulinkMainDocLink();
    view.DocLinks.remove(view.DocLinks.getByKey(newDocLink.Type));
    view.DocLinks.add(newDocLink);
end

function docLink=i_createSimulinkMainDocLink()
    docLink=dependencies.internal.viewer.DocLink;
    docLink.Type=dependencies.internal.viewer.DocLinkType.Main;
    docLink.ShortName='simulink';
    docLink.TopicID='slAboutDependencyAnalyzer';
end

function workflow=i_createModelHierarchyWorkflow(view)
    map=i_createHierachyColorMap;

    workflow=dependencies.internal.viewer.Workflow.createFor(...
    view,...
    @i_containsSimulinkFiles,...
    @dependencies.internal.viewer.simulink.createModelHierarchyGraph,...
    @(n)i_createHierarchyProperties(n,map));

    workflow.Name=string(message("SimulinkDependencyAnalysis:Viewer:ModelHierarchyTitle"));
    workflow.Description=string(message("SimulinkDependencyAnalysis:Viewer:ModelHierarchyDescription"));
    workflow.Group=string(message("MATLAB:dependency:viewer:FilteredViewGroup"));
    workflow.IconID="modelHierachy";
    workflow.PreferredLayout=dependencies.internal.viewer.Layout.VERTICAL;

    i_addColorMap(workflow,map);
end

function applicable=i_containsSimulinkFiles(graph)
    import dependencies.internal.graph.NodeFilter.fileExtension;
    nodes=graph.Nodes;
    applicable=~isempty(nodes)&&any(apply(fileExtension([".mdl",".slx",".sldd"]),nodes));
end


function workflow=i_createModelInstanceWorkflow(view)
    map=i_createInstanceColorMap;

    workflow=dependencies.internal.viewer.Workflow.createFor(...
    view,...
    @i_containsModel,...
    @dependencies.internal.viewer.simulink.createModelInstanceGraph,...
    @(n)i_createInstanceProperties(n,map));

    workflow.Name=string(message("SimulinkDependencyAnalysis:Viewer:ModelInstancesTitle"));
    workflow.Description=string(message("SimulinkDependencyAnalysis:Viewer:ModelInstancesDescription"));
    workflow.Group=string(message("MATLAB:dependency:viewer:FilteredViewGroup"));
    workflow.IconID="modelInstance";
    workflow.PreferredLayout=dependencies.internal.viewer.Layout.VERTICAL;

    i_addColorMap(workflow,map);
end

function applicable=i_containsModel(graph)
    import dependencies.internal.graph.NodeFilter.fileExtension;
    import dependencies.internal.graph.NodeFilter.wrapNode;
    import dependencies.internal.viewer.simulink.getSimulinkType;
    nodeFilter=fileExtension([".mdl",".slx"])&wrapNode(@(n)string(arrayfun(@getSimulinkType,n))=="model");
    applicable=false;
    for node=graph.Nodes
        if apply(nodeFilter,node)
            applicable=true;
            return;
        end
    end

end


function i_addColorMap(workflow,map)
    for color=map.values
        workflow.NodeColors.add(color{1});
    end
end


function map=i_createHierachyColorMap
    import dependencies.internal.viewer.Color;
    map=containers.Map;
    map('model')=i_createNamedColor('Model',Color.COLOR_1);
    map('library')=i_createNamedColor('Library',Color.COLOR_2);
    map('subsystem')=i_createNamedColor('Subsystem',Color.COLOR_3);
    map('dictionary')=i_createNamedColor('DataDictionary',Color.COLOR_4);
    map('harness')=i_createNamedColor('TestHarness',Color.COLOR_5);
    map('protectedModel')=i_createNamedColor('ProtectedModel',Color.COLOR_7);
    map('')=i_createNamedColor('Missing',Color.COLOR_DEFAULT);
end


function nc=i_createNamedColor(resource,color)
    nc=dependencies.internal.viewer.NamedColor;
    nc.Name=string(message("SimulinkDependencyAnalysis:Viewer:"+resource));
    nc.Color=color;
end


function props=i_createHierarchyProperties(node,map)
    nc=map(dependencies.internal.viewer.simulink.getSimulinkType(node));
    props=dependencies.internal.viewer.NodeProperties;
    props.Type=nc.Name;
    props.Color=nc.Color;
end


function map=i_createInstanceColorMap
    import dependencies.internal.viewer.Color;
    map=containers.Map;
    map('TopModel')=i_createNamedColor('TopModel',Color.COLOR_1);
    map('Normal')=i_createNamedColor('NormalMode',Color.COLOR_2);
    map('Subsystem')=i_createNamedColor('Subsystem',Color.COLOR_3);
    i_addNamedColor(map,'Accelerator',Color.COLOR_4);
    i_addNamedColor(map,'Processor-in-the-loop (PIL)',Color.COLOR_5);
    i_addNamedColor(map,'Software-in-the-loop (SIL)',Color.COLOR_6);
end


function i_addNamedColor(map,type,color)
    nc=dependencies.internal.viewer.NamedColor;
    nc.Name=type;
    nc.Color=color;
    map(type)=nc;%#ok<NASGU>
end


function props=i_createInstanceProperties(node,map)
    [type,overridden]=dependencies.internal.viewer.simulink.getInstanceType(node);
    nc=map(type);
    props=dependencies.internal.viewer.NodeProperties;
    if overridden
        props.Type=nc.Name+" ("+string(message("SimulinkDependencyAnalysis:Viewer:Overridden"))+")";
    else
        props.Type=nc.Name;
    end
    props.Color=nc.Color;
end
