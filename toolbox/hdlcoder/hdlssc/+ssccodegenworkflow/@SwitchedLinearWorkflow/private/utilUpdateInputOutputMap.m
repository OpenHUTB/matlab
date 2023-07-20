function[inMap,outMap]=utilUpdateInputOutputMap(inMap,outMap,GenModel)





    for i=1:size(inMap,2)
        for j=1:size(inMap{i},1)
            inMap{i}{j,3}=getNewHandle(inMap{i}{j,1},GenModel);
        end

    end
    for i=1:size(outMap,2)
        for j=1:size(outMap{i},1)
            outMap{i}{j,3}=getNewHandle(outMap{i}{j,1},GenModel);
        end
    end
end

function handle=getNewHandle(blockName,genModel)
    [~,remain]=strtok(blockName,'/');


    genModelName=[genModel,remain];
    handle=getSimulinkBlockHandle(genModelName);
end
