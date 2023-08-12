function tf = isComponent( hdl )



tf = strcmp( get_param( hdl, 'BlockType' ), 'SubSystem' );



if tf
tf = isempty( get_param( hdl, 'ReferencedSubsystem' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4zfHOv.p.
% Please follow local copyright laws when handling this file.

