function simrfV2spartypeoption( blk, idxMaskNames, numPorts )




mask = Simulink.Mask.get( blk );
maskPars = mask.Parameters;

if strcmpi( maskPars( idxMaskNames.DataSource ).Value, 'Data file' )
auxData = get_param( [ blk, '/AuxData' ], 'UserData' );
hasNoise = isfield( auxData, 'Noise' ) && auxData.Noise.HasNoisefileData;
else 
hasNoise = false;
end 

sparStr = cell( numPorts ^ 2 + hasNoise, 1 );

s_idx = 0;
for row_idx = 1:numPorts
for col_idx = 1:numPorts
s_idx = s_idx + 1;
sparStr{ s_idx } = sprintf( 'S(%d,%d)', row_idx, col_idx );
end 
end 
if hasNoise
sparStr{ s_idx + 1 } = 'NF';
end 

maskPars( idxMaskNames.( 'YParam1' ) ).TypeOptions = sparStr;
maskPars( idxMaskNames.( 'YParam2' ) ).TypeOptions = vertcat( { 'None' }, sparStr );
% Decoded using De-pcode utility v1.2 from file /tmp/tmpAbEZpZ.p.
% Please follow local copyright laws when handling this file.

