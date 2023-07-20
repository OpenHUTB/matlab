function eti=load(obj,varargin)




    inputs=evolutions.internal.utils.parseInputs(varargin{:});
    xmlFile=inputs.xml;
    constellation=mf.zero.ModelConstellation;
    eti=obj.readDataFile(constellation,xmlFile);

    if(evolutions.internal.BackupReader.hasValidBackupXML(eti))

        evolutions.internal.BackupReader.updateIds(eti);

        constellation=mf.zero.ModelConstellation;
        updateConstellationWithBackups(obj,constellation);

        xml=evolutions.internal.BackupReader.getBackupFile(xmlFile);
        eti=obj.readDataFile(constellation,xml);
    end
    eti.loadInfo(struct('Project',obj.Project,'ArtifactRootFolder',convertStringsToChars(obj.ArtifactRootFolder),'XmlPath',xmlFile));



    EvolutionManager=...
    evolutions.internal.evolution.EvolutionManager(...
    eti.Project,convertStringsToChars(eti.ArtifactRootFolder),"Evolutions",constellation,...
    'DefaultEvolutionProfile');
    EdgeManager=...
    evolutions.internal.evolution.EdgeManager(...
    eti.Project,convertStringsToChars(eti.ArtifactRootFolder),"Edges",constellation,...
    'DefaultEvolutionProfile');

    eti.EvolutionManager=EvolutionManager;
    eti.EvolutionManager.RootEvolution=eti.RootEvolution;
    eti.EdgeManager=EdgeManager;
    eti.EdgeManager.RootEvolution=eti.RootEvolution;

    mfDataManager=evolutions.internal.session.SessionManager.getMf0Data;
    mfDataManager.addConstellation(eti,constellation);


    evolutions.internal.artifactserver.setArtifactStorage(eti);
end


