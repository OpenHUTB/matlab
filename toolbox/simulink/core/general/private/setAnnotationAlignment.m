function setAnnotationAlignment( noteHandle, newVal )



note = get_param( noteHandle, 'Object' );
oldVal = note.HorizontalAlignment;
if ( ~strcmp( oldVal, newVal ) )
note.HorizontalAlignment = newVal;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3TRdJl.p.
% Please follow local copyright laws when handling this file.

