



















classdef ParseInfo < handle

properties ( SetAccess = protected )


Success( 1, 1 )logical;



AvailableFunctions( 1, : )string;




EntryFunctions( 1, : )string;



AvailableTypes( 1, : )string;

Errors = [  ];


BuildInfo( 1, 1 )Simulink.CodeImporter.BuildInfo;
end 

properties ( Hidden )
CodeInfo( 1, 1 );
FunctionInfoMap;
TypeInfoMap;
end 

properties ( Hidden, Access = private )
CodeImportObject( 1, 1 );
settingChecksumOfLockedccScope( 1, 1 )string;
oldPassByPointerDefaultSize( 1, 1 )string = "-1";
oldUndefinedFunctionHandling( 1, 1 )internal.CodeImporter.UndefinedFunctionHandling = internal.CodeImporter.UndefinedFunctionHandling.FilterOut;
end 

properties ( Hidden, Transient )

Functions( 1, : )Simulink.CodeImporter.Function;
end 

methods 

function obj = ParseInfo( parentObj )
if nargin > 0
obj.CodeImportObject = parentObj;
obj.Success = false;
obj.Errors = [  ];
obj.Functions = obj.Functions.empty;
obj.CodeInfo = { [  ] };
obj.FunctionInfoMap = containers.Map;
obj.TypeInfoMap = containers.Map;
obj.BuildInfo = Simulink.CodeImporter.BuildInfo;
end 
end 

function ret = getFunctions( obj, fcnNames )









R36
obj( 1, 1 )Simulink.CodeImporter.ParseInfo;
fcnNames( 1, : )string = string( [  ] );
end 

if ~obj.Success
ret = [  ];
return ;
end 

try 
if ~strcmp( obj.oldPassByPointerDefaultSize, obj.CodeImportObject.Options.PassByPointerDefaultSize ) ||  ...
~isequal( obj.oldUndefinedFunctionHandling, obj.CodeImportObject.Options.UndefinedFunctionHandling )
obj.clearFunctionObjects(  );
obj.oldPassByPointerDefaultSize = obj.CodeImportObject.Options.PassByPointerDefaultSize;
obj.oldUndefinedFunctionHandling = obj.CodeImportObject.Options.UndefinedFunctionHandling;
end 
if isempty( obj.Functions )
if obj.CodeImportObject.Options.ValidateBuild
obj.CodeImportObject.build(  );
end 
obj.Functions = obj.getFunctionObjects(  );
end 
availableFcnObjectNames = [ obj.Functions.Name ];
if isempty( fcnNames )
ret = obj.Functions;
else 
if isempty( availableFcnObjectNames )



missingFcns = fcnNames;
else 
missingFcns = setdiff( fcnNames, availableFcnObjectNames, 'stable' );
end 

if ~isempty( missingFcns )
errmsg = MException( message( 'Simulink:CodeImporter:FunctionToImportMismatch',  ...
join( missingFcns, ", " ) ) );
throw( errmsg );
end 
fcnIdxArr = ismember( availableFcnObjectNames, fcnNames );
ret = obj.Functions( fcnIdxArr );
end 
catch e
obj.CodeImportObject.handleError( e );
end 
end 

end 

methods ( Hidden )

function delete( obj )
obj.clearFunctionObjects(  );
end 

function computeFunctions( obj, isInterfaceHeader )
isSLUnitTest = obj.CodeImportObject.isSLUnitTest;
fcns = obj.CodeInfo.getFunctionInfoStruct( 'SLCCImportCompliant', true, 'IgnoreDeclarationPos', isInterfaceHeader );

for idx = 1:length( fcns.Function )
f = fcns.Function( idx );
fi = fcns.FunctionInfo( idx );

if ~isInterfaceHeader && ~obj.FunctionInfoMap.isKey( f.Name )

continue ;
end 


if ~isInterfaceHeader &&  ...
isSLUnitTest &&  ...
fi.IsDefined &&  ...
~isempty( f.DefPos ) &&  ...
obj.CodeImportObject.isAutoStubFile( f.DefPos( 1 ).File.Path )
obj.FunctionInfoMap.remove( f.Name );
continue ;
end 

fcnInfo = internal.CodeImporter.FunctionInfo;

fcnInfo.Name = f.Name;

fcnInfo.Signature = f.generateSignature;
fcnInfo.IsEntryFunction = ismember( fi, fcns.EntryPoints );
fcnInfo.IsDefined = fi.IsDefined;
fcnInfo.IsDeclared = fi.IsDeclared;
fcnInfo.IsStub = false;
fcnInfo.Function = f;


if ~isInterfaceHeader &&  ...
isSLUnitTest &&  ...
fi.IsDefined &&  ...
~isempty( f.DefPos ) &&  ...
obj.CodeImportObject.isManualStubFile( f.DefPos( 1 ).File.Path )
fcnInfo.IsStub = true;
end 

obj.FunctionInfoMap( fcnInfo.Name ) = fcnInfo;
end 

obj.AvailableFunctions = convertCharsToStrings( obj.FunctionInfoMap.keys );

FcnInfoList = obj.FunctionInfoMap.values;
entryFunctionIdx = arrayfun( @( x )x.IsEntryFunction, [ FcnInfoList{ : } ] );
obj.EntryFunctions = obj.AvailableFunctions( entryFunctionIdx );
end 

function computeTypes( obj, isInterfaceHeader )
if ~isInterfaceHeader

return ;
end 

types = obj.CodeInfo.getTypeInfoStruct( 'SLCCImportCompliant', true,  ...
'IgnoreMWIncludes', true );
for idx = 1:length( types.Type )
typeInfo = internal.CodeImporter.TypeInfo;

typeInfo.Name = types.Type( idx ).Name;

typeClass = class( types.Type( idx ) );
typeInfo.Class = obj.stripTypeClass( typeClass );
typeInfo.computeSpecialType(  );

obj.TypeInfoMap( typeInfo.Name ) = typeInfo;
end 

if isempty( obj.TypeInfoMap )
return ;
end 

compliantTypeList = obj.TypeInfoMap.values;
compliantTypeList = [ compliantTypeList{ : } ];
specialTypeList = compliantTypeList( [ compliantTypeList.IsSpecialType ] == true );
obj.AvailableTypes = [ specialTypeList.Name ];
end 

function types = computeTypesUsedByFunctions( obj, functions )
types = string( [  ] );

obj.getFunctions(  );

if isempty( functions ) || isempty( obj.Functions )
return ;
end 

fcnIdx = ismember( [ obj.Functions.Name ], functions );
for i = 1:length( fcnIdx )
if fcnIdx( i )
types = [ types, obj.Functions( i ).Types ];%#ok<AGROW>
end 
end 
types = unique( types );
end 

function res = hasGlobalVariable( obj )
res = false;
if obj.Success
globals = obj.CodeInfo.getVariables( 'SLCCImportCompliant', true );
res = ~isempty( globals );
end 
end 

function invalidateFunctions( obj )
obj.Functions = obj.Functions.empty;
end 

function updateTypesUsingMetadataInfo( obj, functionObj )
if isempty( functionObj.PortSpecification.GlobalArguments )
return 
end 
globalArgs = functionObj.PortSpecification.GlobalArguments;
for idx = 1:length( globalArgs )
gName = globalArgs( idx ).Name;
extraVarInfo = obj.CodeImportObject.MetadataInfo.getVariableInfo( gName );
if isempty( extraVarInfo ) || strcmp( extraVarInfo.Type, '' )

continue ;
else 
globalArgs( idx ).Type = extraVarInfo.Type;
end 
end 

end 

function ret = getFunctionObjects( obj )
[ hMdl, tmpMdlPath ] = internal.CodeImporter.createTempModel( obj.CodeImportObject );


function rmTmpLib( mdl, mdlPath )
close_system( mdl, 0 );
delete( mdlPath );
end 
modelCleaner = onCleanup( @(  )rmTmpLib( hMdl, tmpMdlPath ) );


slcc( 'parseCustomCode', hMdl, true );

availableFcns = obj.AvailableFunctions;


symbols = slcc( 'getExportedSymbols', hMdl );
availableFcns = intersect( availableFcns, symbols.functions );

ret( 1:length( availableFcns ) ) = Simulink.CodeImporter.Function(  );
if isempty( availableFcns )
return ;
end 
for i = 1:length( availableFcns )
ret( i ) = Simulink.CodeImporter.Function( hMdl, availableFcns{ i },  ...
obj.CodeImportObject.Options.PassByPointerDefaultSize );


if ~isempty( obj.CodeImportObject.MetadataInfo ) &&  ...
~obj.CodeImportObject.MetadataInfo.isempty(  )
obj.updateTypesUsingMetadataInfo( ret( i ) );
end 


fcnSettings = obj.CodeImportObject.getCachedFunctionSettings( availableFcns{ i } );
if ~isempty( fcnSettings )
if ~isempty( fcnSettings.PortSpecArray )
slcc( 'updateSLCCFcnFromArgsInfo', hMdl, fcnSettings.PortSpecArray, availableFcns{ i } );
end 
ret( i ).ArrayLayout = fcnSettings.ArrayLayout;
ret( i ).IsDeterministic = fcnSettings.IsDeterministic;
end 

assert( obj.FunctionInfoMap.isKey( ret( i ).Name ), 'Function info not available for ''%s''.', ret( i ).Name );
fcnInfo = obj.FunctionInfoMap( ret( i ).Name );
ret( i ).setIsEntry( fcnInfo.IsEntryFunction );
ret( i ).setIsDefined( fcnInfo.IsDefined );
ret( i ).setIsStub( fcnInfo.IsStub );
end 

obj.settingChecksumOfLockedccScope = slcc( 'getModelCustomCodeChecksum', hMdl, false );

assert( ~isempty( char( obj.settingChecksumOfLockedccScope ) ) );
slcc( 'lockSLCCScope', char( obj.settingChecksumOfLockedccScope ), true );
end 

function clearFunctionObjects( obj )
obj.Functions = obj.Functions.empty;
if ~isempty( char( obj.settingChecksumOfLockedccScope ) )

slcc( 'lockSLCCScope', char( obj.settingChecksumOfLockedccScope ), false );
obj.settingChecksumOfLockedccScope = "";
end 
end 

end 

methods ( Static, Hidden )
function typeName = stripTypeClass( fullTypeClass )
idxs = strfind( fullTypeClass, "." );
if ~isempty( idxs )
typeName = extractAfter( fullTypeClass, idxs( end  ) );
else 
typeName = fullTypeClass;
end 
end 
end 

methods ( Hidden )
function setSuccess( obj, val )
obj.Success = val;
end 

function setErrors( obj, val )
obj.Errors = val;
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnxOanN.p.
% Please follow local copyright laws when handling this file.

