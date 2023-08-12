function TF = simInputGlobalWSExists( modelHandle )





R36
modelHandle( 1, 1 )double
end 

TF = false;

dataId = 'SL_SimulationInputInfo';
if Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, dataId )
simInputInfo = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );
wsNames = simInputInfo.ModelWorkspaceNames;
if ~isempty( wsNames ) && any( contains( wsNames, "global-workspace" ) )
TF = true;
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpgoGFH9.p.
% Please follow local copyright laws when handling this file.

