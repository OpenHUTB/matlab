function out = verifySubPlot( subPlotId )

arguments
    subPlotId{ mustBeInteger, mustBePositive }
end

if isscalar( subPlotId )
    validateattributes( subPlotId, { 'numeric' }, { '<=', 64 } );
    out = int32( subPlotId );
else
    validateattributes( subPlotId, { 'numeric' }, { 'numel', 2, '<=', 8 } );
    out = int32( sub2ind( [ 8, 8 ], subPlotId( 1 ), subPlotId( 2 ) ) );

end

