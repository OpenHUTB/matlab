function output = sllegacysymbol( model, name )













output = [  ];
if ~( isvarname( name ) )
return ;
end 


mwks = get_param( model, 'ModelWorkspace' );
if ( mwks.hasVariable( name ) )
output = mwks.getVariable( name );
else 
output = Simulink.data.internal.getModelGlobalVariable( model, name );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpYQuuIK.p.
% Please follow local copyright laws when handling this file.

