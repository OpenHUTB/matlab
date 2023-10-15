function TF = simInputGlobalWSExists( modelHandle )

arguments
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
