function out = TargetLangStandard( action, cc, param, value )




R36
action
cc
end 
R36( Repeating )
param
value
end 

out = [  ];
allowed = [ "C89/C90 (ANSI)", "C99 (ISO)" ];
if ~any( allowed == value{ 1 } )
if action == "apply"


set_param( cc.getConfigSet, param{ 1 }, allowed( end  ) );
else 
out = message( 'RTW:configSet:IncompatibleParameter', param{ 1 } );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptSfIWk.p.
% Please follow local copyright laws when handling this file.

