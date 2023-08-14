function section=createTitleSection(this,docType)




    section=dependencies.internal.report.DependencyAnalyzerReportPart(docType);

    title=getResource("DocumentTitle");
    section.append(mlreportgen.dom.Heading1(title));

    infoTableRows=[
    getResource("DocumentTimeStampPrompt"),string(datetime);...
    getResource("NumberOfFilesPrompt"),length(this.FileNodes);...
    getResource("NumberOfDependenciesPrompt"),length(this.Graph.Dependencies)
    ];

    infoTable=mlreportgen.dom.Table(infoTableRows);
    infoTable=setPropertyTableStyle(infoTable);
    section.append(infoTable);

    numProperties=length(this.SessionProperties);
    if numProperties>0
        sessionPropsTableRows=strings(numProperties,2);
        for index=1:numProperties
            prop=this.SessionProperties(index);
            sessionPropsTableRows(index,:)=[...
            string(prop.Name),string(prop.Value)];
        end
        sessionPropsTable=mlreportgen.dom.Table(sessionPropsTableRows);
        sessionPropsTable=setPropertyTableStyle(sessionPropsTable);
        section.append(sessionPropsTable);
    end

    diagram=i_generateDiagram(this.Graph,this.DiagramFile);
    section.append(diagram);

    section=applyMargin(section,docType);
end


function diagram=i_generateDiagram(graph,diagramFile)
    dependencies.internal.viewer.export.toImage(graph,diagramFile);
    diagram=mlreportgen.dom.Image(diagramFile);
    diagram.Style={mlreportgen.dom.ScaleToFit};
end