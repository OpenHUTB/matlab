function setSessionDirtyState( modelHandle, dirtyState )

arguments
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
