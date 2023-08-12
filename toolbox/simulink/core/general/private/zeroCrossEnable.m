function zeroCrossEnable( blockHandle )







if ( ishandle( blockHandle ) ~= 1 )
disp( 'invalid block handle' );
end 

params = get_param( blockHandle, 'DialogParameters' );
flds = fieldnames( params );


zeroCrossIndex = 0;
for i = 1:length( flds )
if ( strcmp( flds( i ), 'ZeroCross' ) )
zeroCrossIndex = i;
break ;
end 
end 




if zeroCrossIndex > 0

zeroCrossEnables = get_param( blockHandle, 'MaskEnables' );
model = bdroot( blockHandle );
config = getActiveConfigSet( model );



if ( isempty( config ) ~= 1 )
if ( strcmp( get_param( config, 'SolverType' ), 'Fixed-step' ) )
zeroCrossEnables{ zeroCrossIndex } =  ...
get_param( config, 'EnableFixedStepZeroCrossing' );
else 
zeroCrossEnables{ zeroCrossIndex } = 'on';
if ( strcmp( get_param( config, 'ZeroCrossControl' ), 'EnableAll' ) )
zeroCrossEnables{ zeroCrossIndex } = 'on';
elseif ( strcmp( get_param( config, 'ZeroCrossControl' ), 'DisableAll' ) )
zeroCrossEnables{ zeroCrossIndex } = 'off';
end 
end 

set_param( blockHandle, 'MaskEnables', zeroCrossEnables );

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRBogXr.p.
% Please follow local copyright laws when handling this file.

