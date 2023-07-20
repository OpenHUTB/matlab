function workflow=createLabelView(view,category)




    colorMap=containers.Map;
    nameMap=containers.Map('KeyType','double','ValueType','any');

    workflowRef=dependencies.internal.util.Reference;

    workflow=dependencies.internal.viewer.Workflow.createFor(...
    view,...
    @i_isProjectOpen,...
    @(g)i_update(g,workflowRef,category,colorMap,nameMap),...
    @(node)i_customizeByLabel(node,category,colorMap));

    workflow.Name=category.Name;
    workflow.TypeName=category.Name;
    workflow.Description=string(message("MATLAB:dependency:project:LabelViewDescription"));
    workflow.Group=string(message("MATLAB:dependency:project:ProjectViewGroup"));
    workflow.IconID="categoryLabelBlank";
    workflow.Identifier=category.UUID;

    workflowRef.Value=workflow;
end

function applicable=i_isProjectOpen(~)
    project=matlab.project.currentProject;
    applicable=~isempty(project);
end

function graph=i_update(graph,workflowRef,category,colorMap,nameMap)
    i_updateLabelMaps(category,colorMap,nameMap,graph);
    i_updateNodeColors(workflowRef.Value,nameMap);
end

function i_updateLabelMaps(category,colorMap,nameMap,graph)
    colorMap.remove(colorMap.keys);
    nameMap.remove(nameMap.keys);

    fileNodes=graph.Nodes(graph.Nodes.isFile);

    fileSet=java.util.HashSet();
    for file=fileNodes
        fileSet.add(file.Location{1});
    end

    labelMap=com.mathworks.toolbox.slprojectdependency.Queries.getLabelsUsedByFiles(fileSet);
    usedLabels=sort(string(toArray(labelMap.get(category.Name))))';

    cls=?dependencies.internal.viewer.Color;
    numColors=length(cls.EnumerationMemberList)-1;
    numLabels=length(usedLabels);
    colorIdx=repmat(1:numColors,1,ceil(numLabels/numColors));

    for n=1:numLabels
        label=usedLabels(n);
        color=colorIdx(n);

        colorMap(label)=dependencies.internal.viewer.Color.("COLOR_"+color);

        if nameMap.isKey(color)
            nameMap(color)=nameMap(color)+", "+label;
        else
            nameMap(color)=label;
        end
    end
end

function i_updateNodeColors(workflow,nameMap)
    workflow.NodeColors.clear;

    for color=nameMap.keys
        namedColor=dependencies.internal.viewer.NamedColor;
        namedColor.Name=nameMap(color{1});
        namedColor.Color=dependencies.internal.viewer.Color.("COLOR_"+color);
        workflow.NodeColors.add(namedColor);
    end

    namedColor=dependencies.internal.viewer.NamedColor;
    namedColor.Name=string(message("MATLAB:dependency:project:LabelViewNoLabel"));
    namedColor.Color=dependencies.internal.viewer.Color.COLOR_DEFAULT;
    workflow.NodeColors.add(namedColor);
end

function np=i_customizeByLabel(node,category,colorMap)
    np=dependencies.internal.viewer.NodeProperties;

    label=string(com.mathworks.toolbox.slprojectdependency.Queries.getLabel(node.Location{1},category.Name));

    if isempty(label)
        return;
    end

    np.Type=label;
    if colorMap.isKey(label)
        np.Color=colorMap(label);
    end
end
