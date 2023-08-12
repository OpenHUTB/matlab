function PerInstancePropertyChanged( dlg, controlTag, modelH, mappingObj, propName )






if isempty( mappingObj.MappedTo )
return ;
end 
originalValue = Simulink.CodeMapping.getPerInstancePropertyValue( modelH, mappingObj, 'MappedTo', propName );
dataType = Simulink.CodeMapping.getPerInstancePropertyDataType( modelH, mappingObj, 'MappedTo', propName );
if strcmp( dataType, 'enum' )
val = dlg.getComboBoxText( controlTag );
elseif strcmp( dataType, 'bool' )
val = dlg.getWidgetValue( controlTag );
val = num2str( val );
else 
val = dlg.getWidgetValue( controlTag );
end 
if strcmp( originalValue, val )
return ;
end 
Simulink.CodeMapping.setPerInstancePropertyValue( modelH, mappingObj, 'MappedTo', propName, val );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpg1DvmV.p.
% Please follow local copyright laws when handling this file.

