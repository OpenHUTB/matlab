function exported_filename = exportToVersion( modelname, target_filename,  ...
version, opts )





R36
modelname;
target_filename{ mustBeTextScalar };
version;
opts.BreakUserLinks{ logicalOrOnOff } = false;
opts.BreakToolboxLinks{ logicalOrOnOff } = false;
opts.AllowPrompt{ logicalOrOnOff } = false;
end 

opts.BreakUserLinks = i_onoff( opts.BreakUserLinks );
opts.BreakToolboxLinks = i_onoff( opts.BreakToolboxLinks );
opts.AllowPrompt = i_onoff( opts.AllowPrompt );


opts = [ fieldnames( opts )';struct2cell( opts )' ];
opts = opts( : )';

c = slexportprevious.internal.ExportController( modelname, target_filename,  ...
version, opts{ : } );

c.run;

exported_filename = c.targetModelFile;

end 





function logicalOrOnOff( v )
if islogical( v ) && isscalar( v )
return ;
end 
if isnumeric( v ) && isscalar( v )
if v == 0 || v == 1
return ;
end 
end 
if isStringScalar( v ) || ischar( v )
if v == "on" || v == "off"
return ;
end 
end 
error( message( 'Simulink:Commands:MustBeLogicalOrOnOff' ) );
end 


function out = i_onoff( val )

if islogical( val )
out = val;
elseif isnumeric( val )
out = logical( val );
else 
s = string( val );
out = s == "on";
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpx9uVqu.p.
% Please follow local copyright laws when handling this file.

