function lSimulationModeMap=getSimulationModeMap(lOrderedMdlRefs)







    if isempty(lOrderedMdlRefs)



        lSimulationModeMap=containers.Map;
        return;
    end




    [lModelNames,~,lUniqueIdx]=unique({lOrderedMdlRefs.modelName});
    nUniqueModels=numel(lModelNames);



    lSimModes=arrayfun(@(kModel)unique({lOrderedMdlRefs(lUniqueIdx==kModel).mdlRefSimMode}),...
    1:nUniqueModels,...
    'UniformOutput',false);
    lSimulationModeMap=containers.Map(lModelNames,lSimModes);
end
