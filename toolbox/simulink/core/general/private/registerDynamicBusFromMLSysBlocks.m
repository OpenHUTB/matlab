









function result = registerDynamicBusFromMLSysBlocks( inputSigDesc, blockPath )
result = { false, [  ] };


if ~isa( inputSigDesc, 'Simulink.SignalDescriptor' )
return ;
end 



if inputSigDesc.isPartial(  )
return ;
end 

if l_hasPartialOrUnknownDescendant( inputSigDesc )
return ;
end 


inputSigSpecDataType = inputSigDesc.getDataTypeName(  );
if isempty( inputSigSpecDataType )
DAStudio.error( 'Simulink:Bus:DynamicBusMustHaveNamesAtEachLevel', blockPath );
end 


if ~isequal( inputSigDesc.getDimensions(  ), 1 )
DAStudio.error( 'Simulink:Bus:DynamicBusTopLevelCannotContainDimensions',  ...
inputSigSpecDataType, blockPath );
end 




if convertSignalDescriptorToBusObjectAndRegister( inputSigDesc, blockPath )
result{ 1 } = true;
result{ 2 } = inputSigDesc.getDataTypeName(  );
end 
end 


function result = l_hasPartialOrUnknownDescendant( sdObj )

if sdObj.isPartial(  ) || sdObj.isFromUnknownSource(  )
result = true;
return ;
end 

numChildren = sdObj.getNumElements(  );
for idx = 1:numChildren

if l_hasPartialOrUnknownDescendant( sdObj.getElement( idx ) )
result = true;
return ;
end 
end 
result = false;
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpcJOuXY.p.
% Please follow local copyright laws when handling this file.

