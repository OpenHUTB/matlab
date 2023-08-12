function out = verifySubPlot( subPlotId )

R36
subPlotId{ mustBeInteger, mustBePositive }
end 

if isscalar( subPlotId )
validateattributes( subPlotId, { 'numeric' }, { '<=', 64 } );
out = int32( subPlotId );
else 
validateattributes( subPlotId, { 'numeric' }, { 'numel', 2, '<=', 8 } );
out = int32( sub2ind( [ 8, 8 ], subPlotId( 1 ), subPlotId( 2 ) ) );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpiMB0Hm.p.
% Please follow local copyright laws when handling this file.

