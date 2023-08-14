function out=exportConfigToMAT(filepath,data)
    sourceData=jsondecode(data);
    configData.configuration.top=sourceData.col;
    configData.configuration.left=sourceData.row;
    configData.configuration.cell=sourceData.cell;
    configData.configuration.highlight=sourceData.highlight;
    configData.configuration.matrix=sourceData.matrix;
    configData.configuration.scope.left=sourceData.scope.row;
    configData.configuration.scope.top=sourceData.scope.col;
    configData.configuration.history=sourceData.history;



    save(filepath,'configData');
    out=true;
end