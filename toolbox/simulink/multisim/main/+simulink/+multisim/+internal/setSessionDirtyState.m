function setSessionDirtyState( modelHandle, dirtyState )




R36
modelHandle( 1, 1 )double
dirtyState( 1, 1 )logical
end 

dataId = simulink.multisim.internal.blockDiagramAssociatedDataId(  );
bdData = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );

sessionDataModel = bdData.SessionDataModel;
session = sessionDataModel.topLevelElements;
if session.IsDirty ~= dirtyState
txn = sessionDataModel.beginTransaction(  );
session.IsDirty = dirtyState;
txn.commit(  );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpp5h_HY.p.
% Please follow local copyright laws when handling this file.

