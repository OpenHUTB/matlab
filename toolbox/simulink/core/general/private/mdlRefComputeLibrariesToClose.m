function libsToClose = mdlRefComputeLibrariesToClose( mdlRefInfo, openModelsAtStart )



topMdl = mdlRefInfo( end  ).mdlRefs;


openModelsAtStart = containers.Map( openModelsAtStart, true( 1, length( openModelsAtStart ) ) );

libToLastModelUsed = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
normalModeModels = {  };

for i = 1:length( mdlRefInfo )
info = mdlRefInfo( i );
modelName = info.mdlRefs;
myTargetType = info.mdlRefTargetType;


if ( info.protected )
continue ;
end 


if ( info.isNormalMode )
normalModeModels{ end  + 1 } = modelName;%#ok<AGROW>
continue ;
end 

minfo = coder.internal.infoMATFileMgr( 'load', 'minfo', modelName, myTargetType );
libDeps = minfo.libDeps;
for j = 1:length( libDeps )
libName = libDeps{ j };
libToLastModelUsed( libName ) = modelName;
end 
end 


for i = 1:length( normalModeModels )
modelName = normalModeModels{ i };


libDeps = mdlRefGetLinkedLibraryModels( modelName );
for j = 1:length( libDeps )
libName = libDeps{ j };
libToLastModelUsed( libName ) = topMdl;
end 
end 




libsToClose = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
allLibs = libToLastModelUsed.keys(  );
for i = 1:length( allLibs )
libName = allLibs{ i };
lastUsedIn = libToLastModelUsed( libName );



if ( openModelsAtStart.isKey( libName ) )
continue ;
end 

if ( ~libsToClose.isKey( lastUsedIn ) )
libsToClose( lastUsedIn ) = {  };
end 

libsToClose( lastUsedIn ) = [ libsToClose( lastUsedIn ), libName ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpAiddT7.p.
% Please follow local copyright laws when handling this file.

