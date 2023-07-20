function mlfbPathList=getAllMLFB(modelName)








    subsystemPathList=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');


    mlfbPathList=cell(1,0);
    for idx=1:numel(subsystemPathList)
        if internal.ml2pir.mlfb.isMLFB(subsystemPathList{idx})
            mlfbPathList(end+1)=subsystemPathList(idx);
        end
    end

end


