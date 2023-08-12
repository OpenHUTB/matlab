function remove_mapping_listener( portObj, dialog )




portObjValid = true;
listeners = Simulink.CodeMapping.setGetListeners;
lastErrorDiag = sllasterror;
try 
portHandle = portObj.handle;
catch 
portObjValid = false;
sllasterror( lastErrorDiag );
end 

if portObjValid
openHandleIdx = find( listeners{ 1 } == portHandle, 1 );
else 
if isempty( listeners{ 1 } )
openHandleIdx = [  ];
else 
assert( length( listeners{ 1 } ) == 1 );
openHandleIdx = 1;
end 
end 
if ~isempty( openHandleIdx )
assert( length( openHandleIdx ) == 1 );
if ~isempty( listeners{ 3 }{ openHandleIdx } )
dialogIdx = find( listeners{ 3 }{ openHandleIdx } == dialog, 1 );
if ~isempty( dialogIdx )
listeners{ 3 }{ openHandleIdx }( dialogIdx ) = [  ];
end 
end 

if isempty( listeners{ 3 }{ openHandleIdx } )
listeners{ 1 }( openHandleIdx ) = [  ];
listeners{ 2 }( openHandleIdx ) = [  ];
listeners{ 3 }( openHandleIdx ) = [  ];
end 
Simulink.CodeMapping.setGetListeners( listeners );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSasOGi.p.
% Please follow local copyright laws when handling this file.

