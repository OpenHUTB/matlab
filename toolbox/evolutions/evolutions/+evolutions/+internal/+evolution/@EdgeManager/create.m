function edge=create(obj,evolution1,evolution2)




    inputData=struct('Project',obj.Project,...
    'ArtifactRootFolder',convertStringsToChars(obj.ArtifactRootFolder));
    inputData.Profiles=obj.Profiles;


    mfModel=mf.zero.Model(obj.Constellation);
    edge=evolutions.model.Edge.createObject(mfModel,inputData);


    edge.connect(evolution1,evolution2);
end
