function out=openConfigFile(filepath)
    configData=load(filepath);



    data.col=configData.configData.configuration.top;
    data.row=configData.configData.configuration.left;
    data.cell=configData.configData.configuration.cell;
    data.highlight=configData.configData.configuration.highlight;
    data.matrix=configData.configData.configuration.matrix;
    data.scope.row=configData.configData.configuration.scope.left;
    data.scope.col=configData.configData.configuration.scope.top;

    out=jsonencode(data);
end