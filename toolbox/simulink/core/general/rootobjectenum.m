function [ choices ] = rootobjectenum( field )






if nargin < 1
DAStudio.error( 'Simulink:utility:invNumArgsWithAbsValue', mfilename, 1 );
end 

choices = getfield( getfield( get_param( 0, 'ObjectParameters' ), field ), 'Enum' );
choices{ end  + 1 } = get_param( 0, field );


% Decoded using De-pcode utility v1.2 from file /tmp/tmppjyu2t.p.
% Please follow local copyright laws when handling this file.

