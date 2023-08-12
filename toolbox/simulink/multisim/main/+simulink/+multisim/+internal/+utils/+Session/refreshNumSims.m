function refreshNumSims( ~, designSession, modelHandle )




R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpKfqoO5.p.
% Please follow local copyright laws when handling this file.

