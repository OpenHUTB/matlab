




function bm=getBlockMapping(modelMapping,modelElementCategory,model,blockH)
    modelName=get_param(model,'Name');
    blockName=get_param(blockH,'Name');
    blockName=Simulink.CodeMapping.escapeSimulinkName(blockName);
    bm=modelMapping.(modelElementCategory).findobj('Block',[modelName,'/',blockName]);
end
