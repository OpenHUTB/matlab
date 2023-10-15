function refreshNumSims( ~, designSession, modelHandle )

arguments
    ~
    designSession( 1, 1 )simulink.multisim.mm.session.Session
    modelHandle( 1, 1 )double
end

dataId = simulink.multisim.internal.blockDiagramAssociatedDataId(  );
bdData = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );
designSuiteStruct = bdData.DesignSuiteMap( designSession.ActiveDesignSuiteUUID );
designSuite = designSuiteStruct.DesignSuite;

designStudies = designSuite.DesignStudies.toArray(  );

for designStudy = designStudies
    rootParameterSpace = designStudy.ParameterSpace;
    simulink.multisim.internal.utils.Session.recalculateNumDesignPoints( rootParameterSpace );
    designStudy.NumSimulations = rootParameterSpace.NumDesignPoints;
    simulink.multisim.internal.updateDesignStudyErrorText( designStudy );
end
end


