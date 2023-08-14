function visitEvolutionTreeInfo(obj,evolutionTreeInfo)





    evolutions.internal.BackupReader.clearBackup(evolutionTreeInfo);

    obj.deleteSerializableInfoBackup(evolutionTreeInfo);



    evolutionTreeInfo.EvolutionManager.deleteBackups;
    evolutionTreeInfo.EdgeManager.deleteBackups;

end
