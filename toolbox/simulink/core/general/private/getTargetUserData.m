function tud = getTargetUserData( model, object )













if ~( isa( object, 'Simulink.Parameter' ) ||  ...
isa( object, 'Simulink.Signal' ) ||  ...
isa( object, 'Simulink.LookupTable' ) ||  ...
isa( object, 'Simulink.Breakpoint' ) ||  ...
isa( object, 'Simulink.NumericType' ) )
tud = [  ];
return ;
end 

configSet = getActiveConfigSet( model );

if ~configSet.hasProp( 'UserDataClassName' )
tud = object.TargetUserData;
return ;
end 

userDataClass = configSet.get_param( 'UserDataClassName' );

if isempty( userDataClass )
tud = object.TargetUserData;
return ;
end 

objClassName = class( object );
tudIndex = 0;
for i = 1:size( userDataClass, 1 )
if ( strcmp( char( userDataClass( i, 1 ) ), objClassName ) == 1 )
tudIndex = i;
break ;
end 
end 

if ( tudIndex == 0 )
tud = [  ];
return ;
end 

tudClassName = userDataClass{ tudIndex, 2 };

if ( ~isempty( object.TargetUserData ) && strcmp( class( object.TargetUserData ), tudClassName ) == 1 )
tud = object.TargetUserData;
return ;
end 

tud = eval( tudClassName );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpASxApm.p.
% Please follow local copyright laws when handling this file.

