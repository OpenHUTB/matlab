function eti=create(obj,name)





    constellation=mf.zero.ModelConstellation;
    mfModel=mf.zero.Model(constellation);


    inputData=struct('Project',obj.Project,'ArtifactRootFolder',...
    convertStringsToChars(obj.ArtifactRootFolder),'Name',convertStringsToChars(name)...
    ,'Constellation',constellation);
    inputData.Profiles=obj.Profiles;


    eti=evolutions.model.EvolutionTreeInfo.createObject(mfModel,inputData);

    mfDataManager=evolutions.internal.session.SessionManager.getMf0Data;
    mfDataManager.addConstellation(eti,constellation);


    obj.insert(eti);


    evolutions.internal.artifactserver.setArtifactStorage(eti);


    obj.syncTreesWithProject;
end


