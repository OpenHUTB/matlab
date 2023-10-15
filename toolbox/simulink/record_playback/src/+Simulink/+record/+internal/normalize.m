function normalize( blockHandleOrPath, subPlotId, normalizeValue )

arguments
    blockHandleOrPath
    subPlotId
    normalizeValue{ mustBeNumericOrLogical, mustBeNonnegative, mustBeInteger,  ...
        mustBeLessThan( normalizeValue, 2 ) }
end


blockHandle = blockHandleOrPath;
if ischar( blockHandleOrPath )
    blockHandle = getSimulinkBlockHandle( blockHandleOrPath );
end

viewModel = get_param( blockHandle, 'View' );
subPlotId = Simulink.record.internal.verifySubPlot( subPlotId );

subPlot = viewModel.subplots.getByKey( subPlotId );


if ~subPlot.visible
    return ;
end

if strcmp( subPlot.visual.visualName, DAStudio.message( 'record_playback:params:TimePlot' ) )
    model = mf.zero.getModel( viewModel );
    tx = model.beginTransaction(  );
    subPlot.visual.normalize = logical( normalizeValue );
    tx.commit(  );
else
    throwAsCaller( MException( 'record_playback:errors:InvalidNormalizePlotType',  ...
        DAStudio.message( 'record_playback:errors:InvalidNormalizePlotType' ) ) );
end


end


