function leanSim( modelName, reduceFcn, simCompletedFcn, decimation, simMgrOptions )
R36
modelName( 1, 1 )string
reduceFcn( 1, 1 )function_handle
simCompletedFcn function_handle = function_handle.empty
decimation( 1, 1 )double = 100;
simMgrOptions struct = struct
end 

modelHandle = load_system( modelName );

activeDesignSuite = getActiveDesignSuite( modelHandle );
designStudy = getFirstSelectedDesignStudy( activeDesignSuite );

simulink.multisim.internal.runner.MassiveSimRunnerClient( modelName, designStudy, reduceFcn, simCompletedFcn, decimation, simMgrOptions );
end 

function activeDesignSuite = getActiveDesignSuite( modelHandle )
dataId = simulink.multisim.internal.blockDiagramAssociatedDataId(  );
bdData = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );
designSession = bdData.SessionDataModel.topLevelElements;
designSuiteData = bdData.DesignSuiteMap( designSession.ActiveDesignSuiteUUID );
activeDesignSuite = designSuiteData.DesignSuite;
end 

function designStudy = getFirstSelectedDesignStudy( designSuite )
designStudies = designSuite.DesignStudies.toArray(  );
selectedDesignStudies = designStudies( [ designStudies.SelectedForRun ] );
assert( numel( selectedDesignStudies ) > 0, "No Design Study selected" )
designStudy = selectedDesignStudies( 1 );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpNpWVNQ.p.
% Please follow local copyright laws when handling this file.

