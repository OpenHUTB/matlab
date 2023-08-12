







function callback = getBusObjectCallbackInErrorMessages( modelName, busName )



callback = [  ];




if ~isempty( modelName )
dataAccessor = Simulink.data.DataAccessor.createForExternalData( modelName );
cbPart1 = strcat( 'da  = Simulink.data.DataAccessor.createForExternalData(', modelName, ');\n' );
else 
dataAccessor = Simulink.data.DataAccessor.createWithNoContext(  );
cbPart1 = 'da  = Simulink.data.DataAccessor.createWithNoContext();\n';
end 

varId = dataAccessor.identifyByName( busName );
if ~isempty( varId )

varObj = dataAccessor.getVariable( varId );
if ~isa( varObj, 'Simulink.Bus' )

return ;
end 



cbPart2 = strcat( 'vid = da.identifyByName(', busName, ');\n' );
cbPart3 = 'da.showVariableInUI(vid);';
callback = strcat( cbPart1, cbPart2, cbPart3 );
return ;
end 


busDict = Simulink.BusDictionary.getInstance(  );
registeredBusType = busDict.getRegisteredBusType( busName );


if ~isempty( registeredBusType )



if ~busDict.registeredBusOriginProvided( busName )
return ;
end 

busOrigin = busDict.getRegisteredBusOrigin( busName );

if ishandle( busOrigin )
blkFullPath = getfullname( busOrigin );


blkFullPath = strrep( blkFullPath, newline, ' ' );
cbPart1 = 'matlab:hilite_system(''';
cbPart2 = blkFullPath;
cbPart3 = ''');';
callback = strcat( cbPart1, cbPart2, cbPart3 );

else 
cbPart1 = 'matlab:';
callback = strcat( cbPart1, busOrigin );
end 
return ;
else 
classBasedBusType = busDict.getClassBasedBusType( busName );
if ~isempty( classBasedBusType )

cbPart1 = 'matlab:edit(''';
cbPart2 = busName;
cbPart3 = '.m'');';
callback = strcat( cbPart1, cbPart2, cbPart3 );
return ;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpbkgOHU.p.
% Please follow local copyright laws when handling this file.

