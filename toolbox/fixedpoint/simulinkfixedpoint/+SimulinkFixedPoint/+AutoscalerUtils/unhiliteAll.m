function unhiliteAll()








    allModels=find_system('type','block_diagram');


    for modelIndex=1:length(allModels)
        currentModel=get_param(allModels{modelIndex},'Object');


        currentModel.hilite('off');
    end
end