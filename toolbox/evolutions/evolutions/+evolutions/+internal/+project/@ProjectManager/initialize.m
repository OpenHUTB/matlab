function initialize(obj)




    obj.addOpenProjects;

    currentPath=pwd;
    cleanup=onCleanup(@()cd(currentPath));
    try
        for piIdx=1:numel(obj.Infos)

            cd(obj.Infos(piIdx).Project.RootFolder);
            curEtm=obj.Infos(piIdx).EvolutionTreeManager;
            curEtm.loadArtifacts();
        end
    catch ME
        rethrow(ME);
    end
end
