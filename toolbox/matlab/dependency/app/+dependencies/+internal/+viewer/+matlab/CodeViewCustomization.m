classdef CodeViewCustomization<dependencies.internal.viewer.ViewCustomization




    methods

        function customize(~,controller,~)
            view=controller.View;
            view.AvailableWorkflows.add(dependencies.internal.viewer.matlab.createCodeWorkflow(view));
            view.AvailableWorkflows.add(i_createClassHierarchyWorkflow(view));
        end

    end

end

function workflow=i_createClassHierarchyWorkflow(view)
    map=i_createClassHierarchyColorMap;

    workflow=dependencies.internal.viewer.Workflow.createFor(...
    view,...
    @i_canApplyClassHierarchyGraph,...
    @i_createClassHierarchyGraph,...
    @(n)i_createClassHierarchyNodeProperties(n,map));

    workflow.Name=string(message("MATLAB:dependency:viewer:ClassHierarchyTitle"));
    workflow.Description=string(message("MATLAB:dependency:viewer:ClassHierarchyDescription"));
    workflow.Group=string(message("MATLAB:dependency:viewer:FilteredViewGroup"));
    workflow.PreferredLayout=dependencies.internal.viewer.Layout.VERTICAL;
    workflow.Orientation=dependencies.internal.viewer.Orientation.LEAF_TO_ROOT;
    workflow.IconID="classHierarchy";

    i_addColorMap(workflow,map);
end


function i_addColorMap(workflow,map)
    for color=map.values
        workflow.NodeColors.add(color{1});
    end
end

function map=i_createClassHierarchyColorMap
    import dependencies.internal.viewer.Color;

    map=containers.Map;
    map("Class")=i_createNamedColor('Class',Color.COLOR_1);
    map("AbstractClass")=i_createNamedColor('AbstractClass',Color.COLOR_2);
    map("Enum")=i_createNamedColor('EnumClass',Color.COLOR_3);
    map("NotOnPath")=i_createNamedColor('NotOnPath',Color.COLOR_4);
    map("Unknown")=i_createNamedColor('Unknown',Color.COLOR_DEFAULT);
end

function nc=i_createNamedColor(resource,color)
    nc=dependencies.internal.viewer.NamedColor;
    nc.Name=string(message("MATLAB:dependency:viewer:"+resource));
    nc.Color=color;
end

function props=i_createClassHierarchyNodeProperties(node,map)
    nc=map(i_getClass(node));
    props=i_createNodeProperties(nc);
end

function props=i_createNodeProperties(nc)
    props=dependencies.internal.viewer.NodeProperties;
    props.Type=nc.Name;
    props.Color=nc.Color;
end

function type=i_getClass(node)
    file=node.Location{1};
    if which(file)==""
        type="NotOnPath";
        return
    end
    [path,className,~]=fileparts(file);

    package=matlab.internal.language.introspective.getPackageName(path);
    if endsWith(path,"@"+className)
        package=package(1:end-length(className)-1);
    end
    packagedName=matlab.internal.language.introspective.makePackagedName(package,className);

    try
        class=meta.class.fromName(packagedName);
    catch
        class=meta.class.empty;
    end

    if isempty(class)
        type="Unknown";
    elseif class.Abstract
        type="AbstractClass";
    elseif class.Enumeration
        type="Enum";
    else
        type="Class";
    end

end

function applicable=i_canApplyClassHierarchyGraph(graph)
    nodeFilter=i_isMatlabClass();
    applicable=false;
    for node=graph.Nodes
        if apply(nodeFilter,node)
            applicable=true;
            return;
        end
    end
end

function classGraph=i_createClassHierarchyGraph(graph)
    import dependencies.internal.viewer.util.createFilteredGraph;
    classGraph=createFilteredGraph(graph,i_isMatlabClass(),"MATLABFile,Inheritance");
end

function filter=i_isMatlabClass()
    import dependencies.internal.graph.NodeFilter.fileExtension;
    import dependencies.internal.graph.NodeFilter.wrapNode;
    import dependencies.internal.viewer.matlab.FileType;
    filter=fileExtension([".m",".mlx"])...
    &wrapNode(@(nodes)arrayfun(@(n)dependencies.internal.viewer.matlab.getMATLABFileType(n.Location{1})==FileType.Class,nodes));
end
