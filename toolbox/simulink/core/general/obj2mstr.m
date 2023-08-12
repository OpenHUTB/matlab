function mstr = obj2mstr( hobjsrc, objdst_name, indents )














if nargin < 2
DAStudio.error( 'Simulink:dialog:SyntaxStr', 'obj2mstr(hobjsrc, objdst_name, idents)' );
end 


mstr = [  ];

if isempty( hobjsrc ) || isempty( objdst_name )
return ;
end 

hprops = Simulink.data.getPropList( hobjsrc,  ...
'GetAccess', 'public',  ...
'SetAccess', 'public',  ...
'Transient', false );







matches = regexp( objdst_name, '\.' );
if length( matches ) <= 0
class_name = class( hobjsrc );
tmp_mstr = sprintf( '%s%s = %s;\n', indents, objdst_name, class_name );
mstr = [ mstr, tmp_mstr ];
end 






for i = 1:length( hprops )
prop_name = hprops( i ).Name;
prop_value = get( hobjsrc, prop_name );
full_name = [ objdst_name, '.', prop_name ];


if ( Simulink.data.getScalarObjectLevel( prop_value ) > 0 )

hpropobj = prop_value;
tmp_mstr = obj2mstr( hpropobj, full_name, [ indents, '    ' ] );

else 
try 
prop_value = mat2str( prop_value );
catch e %#ok
MSLDiagnostic( 'Simulink:dialog:Obj2StrCannotWritePropertyValue', full_name ).reportAsWarning;
tmp_mstr = sprintf( '%s%% Cannot write value of property %s\n', indents, full_name );
mstr = [ mstr, tmp_mstr ];%#ok
continue ;
end 

tmp_mstr = sprintf( '%sset(%s, ''%s'', %s);\n',  ...
indents, objdst_name, prop_name, prop_value );
end 

mstr = [ mstr, tmp_mstr ];%#ok
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpcsjCnv.p.
% Please follow local copyright laws when handling this file.

