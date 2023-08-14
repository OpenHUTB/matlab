function jType=getJComparisonType(type)




    type=lower(string(type));

    switch(type)
    case "text"
        jType=com.mathworks.comparisons.register.type.ComparisonTypeText();
        return
    case "binary"
        jType=com.mathworks.comparisons.register.type.ComparisonTypeBinary();
        return
    case "list"
        jType=com.mathworks.comparisons.register.type.ComparisonTypeList();
        return
    case "zipfile"
        jType=com.mathworks.comparisons.register.type.ComparisonTypeZipFile();
        return
    case "matdata"
        jType=com.mathworks.comparisons.register.type.ComparisonTypeMatData();
        return
    case "xml"
        jType=com.mathworks.toolbox.rptgenxmlcomp.plugin.ComparisonPluginXMLComp.constructComparisonType();
        return
    case "slx"
        jType=com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.two.TwoSLXComparisonType([]);
        return
    case "mdl"
        jType=com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.MDLComparisonType();
        return
    case "datadict"
        jType=com.mathworks.toolbox.simulink.datadictionary.comparisons.register.type.ComparisonTypeDataDict();
        return
    case "slreqx"
        jType=com.mathworks.toolbox.slrequirements.comparisons.slreqx.SLREQXComparisonType();
        return
    case "slmx"
        jType=com.mathworks.toolbox.slrequirements.comparisons.slmx.SLMXComparisonType();
        return
    case "mlx"
        jType=com.mathworks.mde.liveeditor.comparison.TwoMLXComparisonType();
        return
    case "stm"
        jType=com.mathworks.toolbox.stm.compare.STMComparisonType();
        return
    case "opcpackagemlapp"
        jType=com.mathworks.toolbox.matlab.appdesigner.comparison.MlappComparisonType();
        return
    case "simulinkmodeltemplate"
        jType=com.mathworks.toolbox.rptgenslxmlcomp.plugins.template.model.SimulinkModelTemplateComparisonType();
        return
    case "simulinkprojecttemplate"
        jType=com.mathworks.toolbox.rptgenslxmlcomp.plugins.template.project.SimulinkProjectTemplateComparisonType();
        return
    case "graphml"
        jType=com.mathworks.toolbox.slprojectcomparison.graphml.GraphMLComparisonPlugin.createComparisonType();
        return
    case "projectmetadata"
        jType=com.mathworks.toolbox.slprojectcomparison.slproject.distributed.fileMetadata.FileMetadataPluginXML.constructComparisonType();
        return
    case "projectfixedmetadata"
        jType=com.mathworks.toolbox.slprojectcomparison.slproject.distributedFixedPath.fileMetadata.FileMetadataPluginXML.constructComparisonType();
        return
    case "project monolithic metadata"
        jType=com.mathworks.toolbox.slprojectcomparison.slproject.monolithic.MonolithicMetadataPluginXML.constructComparisonType();
        return
    case "label data"
        jType=com.mathworks.toolbox.slprojectcomparison.slproject.distributed.labelData.LabelDataPluginXML.constructComparisonType();
        return
    case "labelfixeddata"
        jType=com.mathworks.toolbox.slprojectcomparison.slproject.distributedFixedPath.labelData.LabelDataPluginXML.constructComparisonType();
        return
    case "projectarchive"
        jType=com.mathworks.toolbox.rptgenxmlcomp.template.projectarchive.ProjectArchiveComparisonType();
        return
    case "testxml"
        jType=com.mathworks.test.tools.rptgenxmlcomp.plugin.ComparisonPluginTestXML.constructComparisonType();
        return
    otherwise
        jType=[];
        return
    end
end

