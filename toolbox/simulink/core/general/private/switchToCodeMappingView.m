function switchToCodeMappingView( h, type )






if strcmp( type, 'Variable' )


parent = h.getParent;
model = parent.getParent(  );
modelName = model.getPropValue( 'name' );
displayName = h.getPropValue( 'name' );
else 

hSlidObject = h.getObject;
hSlidSystem = hSlidObject.System;
handle = hSlidSystem.Handle;
obj = get_param( handle, 'Object' );
modelName = obj.Name;
displayName = hSlidObject.Name;
end 

if ~createCodeGenBtn_isValid( h )

DAStudio.error( 'Simulink:Data:UnsupportedCodeGenTarget_ConfigureButton' );
end 

if strcmp( type, 'Signal' )
switchToCodeMappingView2( modelName, displayName, 'DataStores' );
else 
switchToCodeMappingView2( modelName, displayName, 'Parameters' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpc5PIw3.p.
% Please follow local copyright laws when handling this file.

