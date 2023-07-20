function isSimBuild=isSimulationBuild(mdl,modelReferenceTargetType)





    if hasSimulink
        isSimBuild=slprivate('isSimulationBuild',mdl,modelReferenceTargetType);
    else
        isSimBuild=false;
    end
