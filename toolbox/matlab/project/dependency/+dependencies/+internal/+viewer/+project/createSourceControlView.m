function workflow=createSourceControlView(view)




    colorMap=i_createSourceControlColorMap;

    workflow=dependencies.internal.viewer.Workflow.createFor(...
    view,...
    @i_canApplySourceControlGraph,...
    [],...
    @(node)i_createSourceControlNodeProperties(node,colorMap));

    workflow.Name=string(message("MATLAB:dependency:project:SourceControlTitle"));
    workflow.TypeName=string(message("MATLAB:dependency:project:SourceControlTypeName"));
    workflow.Description=string(message("MATLAB:dependency:project:SourceControlDescription"));
    workflow.Group=string(message("MATLAB:dependency:project:ProjectViewGroup"));
    workflow.IconID="sourceControl";

    for color=colorMap.values
        workflow.NodeColors.add(color{1});
    end
end

function props=i_createSourceControlNodeProperties(node,map)
    project=currentProject();
    project.refreshSourceControl();

    localStatus=com.mathworks.toolbox.slprojectdependency.Queries.getFileSourceControlStatus(node.Location{1});
    status=char(matlab.internal.project.util.convertLocalStatusJava2Matlab(localStatus));

    nc=map(status);
    props=dependencies.internal.viewer.NodeProperties;
    props.Type=string(message("MATLAB:dependency:project:SourceControl"+status));
    props.Color=nc.Color;
end

function map=i_createSourceControlColorMap
    import matlab.sourcecontrol.Status;
    import dependencies.internal.viewer.Color;

    map=containers.Map;
    notTracked=i_createNamedColor("NotUnderSourceControl",Color.COLOR_DEFAULT);

    map(char(Status.Added))=i_createNamedColor(Status.Added,Color.COLOR_5);
    map(char(Status.Conflicted))=i_createNamedColor(Status.Conflicted,Color.COLOR_2);
    map(char(Status.Deleted))=i_createNamedColor(Status.Deleted,Color.COLOR_3);
    map(char(Status.External))=i_createNamedColor(Status.External,Color.COLOR_4);
    map(char(Status.Ignored))=notTracked;
    map(char(Status.NotUnderSourceControl))=notTracked;
    map(char(Status.Missing))=i_createNamedColor(Status.Missing,Color.COLOR_7);
    map(char(Status.Modified))=i_createNamedColor(Status.Modified,Color.COLOR_6);
    map(char(Status.Unknown))=notTracked;
    map(char(Status.Unmodified))=i_createNamedColor(Status.Unmodified,Color.COLOR_1);
end

function nc=i_createNamedColor(status,color)
    nc=dependencies.internal.viewer.NamedColor;
    nc.Name=string(message("MATLAB:dependency:project:SourceControl"+char(status)));
    nc.Color=color;
end

function applicable=i_canApplySourceControlGraph(~)
    project=matlab.project.currentProject;
    if isempty(project)||project.SourceControlIntegration==""
        applicable=false;
    else
        applicable=true;
    end
end
