function enableStatus = pm_getenablestatus( hBlk, params )









simulationStatus = get_param( bdroot( hBlk ), 'SimulationStatus' );
simulating = ~strcmpi( simulationStatus, 'stopped' );


enableFcn = @( paramInfo )lGetEnabled( paramInfo, simulating );


infoFcn = @( param )lParamInfo( param, hBlk );


if ischar( params )
enableStatus = enableFcn( infoFcn( params ) );
elseif iscell( params )
enableStatus = false( 1, numel( params ) );
for idx = 1:numel( params )
enableStatus( idx ) = enableFcn( infoFcn( params{ idx } ) );
end 
else 
pm_error( 'physmod:pm_sli:pm_getenablestatus:UnsupportedArgument' );
end 

end 

function enabled = lGetEnabled( paramInfo, simulating )
enabled = paramInfo.enabled && ~paramInfo.promoted && ( paramInfo.tunable || ~simulating );
end 

function paramInfo = lParamInfo( param, hBlk )



maskParam = pm.sli.internal.getMaskParameterRecursive( hBlk, param );

if ~isempty( maskParam )

paramInfo.enabled = strcmpi( maskParam.Enabled, 'on' );
paramInfo.tunable = strcmpi( maskParam.Tunable, 'on' );
paramInfo.promoted = maskParam.isPromoted;
return 
end 


paramInfo = lNativeParamInfo( param, hBlk );

end 

function paramInfo = lNativeParamInfo( param, hBlk )









blkObj = get_param( hBlk, 'Object' );

if ( isprop( blkObj, param ) )
paramInfo.enabled = true;
paramInfo.tunable = false;
paramInfo.promoted = false;
else 
pm_error( 'physmod:pm_sli:pm_getenablestatus:ParamNotFound',  ...
param, getfullname( blkObj.Handle ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3snGZN.p.
% Please follow local copyright laws when handling this file.

