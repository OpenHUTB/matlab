function deleteBDContentsImpl( bd )
















if nargin ~= 1
DAStudio.error( 'Simulink:modelReference:slBDDeleteContentsInvalidNumInputs' );
end 




if ischar( bd ) || iscell( bd )
bd = string( bd );
end 

if numel( bd ) ~= 1
DAStudio.error( 'Simulink:modelReference:slBDDeleteContentsInvalidNumInputs' );
end 

bd = convertStringsToChars( bd );

if ~strcmpi( get_param( bd, 'Type' ), 'block_diagram' )
DAStudio.error( 'Simulink:modelReference:slBDDeleteContentsInvalidInput' );
end 

Simulink.ModelReference.DeleteContent.deleteContents( bd );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpwiRZDW.p.
% Please follow local copyright laws when handling this file.

