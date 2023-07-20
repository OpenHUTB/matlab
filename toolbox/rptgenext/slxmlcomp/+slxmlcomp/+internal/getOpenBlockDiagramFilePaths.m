function[absoluteBlockDiagramFilePaths,simulationStatus]=getOpenBlockDiagramFilePaths(filterType)



    openBlockDiagrams=find_system('type','block_diagram');

    openblockDiagramsDirtyParameter=cellfun(@(x)get_param(x,'Dirty'),openBlockDiagrams,'UniformOutput',false);

    switch filterType
    case 'clean'
        openBlockDiagrams=openBlockDiagrams(strcmp('off',openblockDiagramsDirtyParameter));
    case 'dirty'
        openBlockDiagrams=openBlockDiagrams(strcmp('on',openblockDiagramsDirtyParameter));
    otherwise

    end

    absoluteBlockDiagramFilePaths=cellfun(@(x)get_param(x,'FileName'),openBlockDiagrams,'UniformOutput',false);
    simulationStatus=cellfun(@(x)get_param(x,'SimulationStatus'),openBlockDiagrams,'UniformOutput',false);

end