function out=hasModelMapping(mdl)




    modelMapping=Simulink.CodeMapping.getCurrentMapping(mdl);
    out=~isempty(modelMapping);
end
