function ca = getCurrentAnnotation(  )











cba = getCallbackAnnotation;
if ( ~isempty( cba ) )
ca = cba;
else 
ca = last_clicked_annotation;
if ( ~isempty( ca ) && isempty( ca.getParent ) )

ca = [  ];
end 
end 

if ( ~isa( ca, 'Simulink.Annotation' ) && ~isa( ca, 'Stateflow.Note' ) )
ca = [  ];
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmppp304K.p.
% Please follow local copyright laws when handling this file.

