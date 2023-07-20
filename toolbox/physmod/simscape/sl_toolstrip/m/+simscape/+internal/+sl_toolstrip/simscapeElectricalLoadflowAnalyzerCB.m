function simscapeElectricalLoadflowAnalyzerCB(cbInfo)


    modelName=getfullname(cbInfo.editorModel.handle);
    ee_loadFlowApp(modelName);
end