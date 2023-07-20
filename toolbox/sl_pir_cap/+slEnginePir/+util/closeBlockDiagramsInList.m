
function loadedModelsList=closeBlockDiagramsInList(loadedModelsList)



    while length(loadedModelsList)>=1
        close_system(loadedModelsList{1},0);
        loadedModelsList=loadedModelsList(2:end);
    end
end
