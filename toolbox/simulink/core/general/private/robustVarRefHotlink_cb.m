function result = robustVarRefHotlink_cb( varargin )








































































assert( ~isempty( varargin ) && ischar( varargin{ 1 } ) )


funcName = varargin{ 1 };
mdlName = '';
switch funcName
case 'revertCache'
assert( nargin == 5 )
result = revertCache( varargin{ 2:5 } );
mdlName = varargin{ 2 };
case 'createEntry'
assert( nargin == 8 )
result = createEntry( varargin{ 2:8 } );
mdlName = varargin{ 3 };
case 'copyEntry'
assert( nargin == 6 )
result = copyEntry( varargin{ 3:6 } );
mdlName = varargin{ 2 };
case 'renameRef'
assert( nargin == 8 )
result = renameRef( varargin{ 3:8 } );
mdlName = varargin{ 2 };
case 'loadFile'
assert( nargin == 3 )
result = loadFile( varargin{ 2:3 } );
mdlName = varargin{ 2 };
case 'createDataDictionaryReference'
assert( nargin == 3 )
result = createDataDictionaryReference( varargin{ 2:3 } );
case 'refreshEditTime'
assert( nargin == 2 );
mdlName = varargin{ 2 };
result = 'Refresh';
case 'copyGlobalVarFromCache'
assert( nargin == 6 )
result = copyGlobalVarFromCache( varargin{ 2:6 } );
case 'copyGlobalVarFromSrc'
assert( nargin == 6 )
result = copyGlobalVarFromSrc( varargin{ 2:6 } );
otherwise 
assert( false )
end 
if ~isempty( result ) && ~isempty( mdlName )

EditTimeEngine = edittimecheck.EditTimeEngine.getInstance(  );
EditTimeEngine.refreshWorkspaceChecks( mdlName );
end 
end 







function result = renameRef( ddName, newName, oldName, paramName, blkPath, varType )


isCfgSet = isequal( varType, 'config' );
result = '';
if ~isCfgSet
try 
blkObject = get_param( blkPath, 'Object' );
blkHandle = get_param( blkPath, 'Handle' );
if isModelReference( blkObject )
paramExpr = get_param( blkPath, 'ParameterArgumentValues' );
Simulink.updateReferenceInBlockParam( blkHandle, 'ParameterArgumentValues', paramExpr, oldName, newName, blkPath );
else 
paramExpr = get_param( blkPath, paramName );
Simulink.updateReferenceInBlockParam( blkHandle, paramName, paramExpr, oldName, newName );
end 
result = DAStudio.message( 'SLDD:sldd:ReferenceUpdated', blkPath );


hitApplyAfterUpdatingReference( blkHandle );
catch e
if isequal( e.identifier, 'Simulink:Commands:ParamUnknown' )

port_handles = get_param( blkPath, 'PortHandles' );
if isequal( paramName, 'SignalName' )
paramName = 'Name';
end 
prop = paramName;
try 
for i = 1:length( port_handles.Outport )
paramExpr = get_param( port_handles.Outport( i ), prop );
if ischar( paramExpr )
paramExpr = Simulink.internal.replaceID( paramExpr, oldName, newName );
set_param( port_handles.Outport( i ), prop, paramExpr );
result = DAStudio.message( 'SLDD:sldd:ReferenceUpdated', blkPath );
end 
end 
catch 
DAStudio.error( 'SLDD:sldd:OperationCanceled' );
end 
else 
DAStudio.error( 'SLDD:sldd:UpdateReferenceFailed' );
end 
end 
end 
end 



function hitApplyAfterUpdatingReference( blkHandle )
dlgs = DAStudio.ToolRoot.getOpenDialogs;
blkObject = get_param( blkHandle, 'Object' );
dlgSrc = blkObject.getDialogSource;
for i = 1:length( dlgs )
openDlgSrc = dlgs( i ).getDialogSource;
if isequal( dlgSrc, openDlgSrc )
dlgs( i ).apply;
end 
end 
end 



function result = loadFile( mdlName, varName )






assert( isequal( get_param( mdlName, 'HasAccessToBaseWorkspace' ), 'on' ) );


if loadFileInToBWS(  )
evalCmd = [ 'exist(''', varName, ''', ''var'')' ];
if evalin( 'base', evalCmd ) == 0
DAStudio.error( 'SLDD:sldd:VarNotInBWS', varName );
else 
result = DAStudio.message( 'SLDD:sldd:FileLoaded', DAStudio.message( 'SLDD:sldd:BaseWorkspace' ) );
end 
else 
DAStudio.error( 'SLDD:sldd:OperationCanceled' );
end 
end 


function result = revertCache( mdlName, wsName, varName, varType )










isCfgSet = isequal( varType, 'config' );
[ result, isArg, successful ] = undoDeletionUseMemory( mdlName, wsName, varName, isCfgSet );



if ~successful
if slfeature( 'SLDataDictionaryRobustVarRef' ) > 1
[ result, successful ] = undoDeletionUseMat( mdlName, wsName, varName, isCfgSet );
if ~successful
DAStudio.error( 'SLDD:sldd:UndoDeletionFailed' );
end 
else 
DAStudio.error( 'SLDD:sldd:UndoDeletionFailed' );
end 
end 


if isArg
mdlWS = 'model workspace';
assert( isequal( wsName, mdlWS ) );
setArgument( mdlName, varName );
end 
end 


function result = copyEntry( ddName, srcName, dstName, varType )




dd = Simulink.data.dictionary.open( ddName );

isCfgSet = isequal( varType, 'config' );
if isCfgSet
dg = dd.getSection( 'Configurations' );
else 
dg = dd.getSection( 'Design Data' );
end 

if ( exist( dg, dstName ) )
result = DAStudio.message( 'SLDD:sldd:VariableExists', dstName );
else 
srcEn = dg.getEntry( srcName );
value = srcEn.getValue(  );
if isCfgSet

set_param( value, 'name', dstName );
end 
dg.addEntry( dstName, value );
result = DAStudio.message( 'SLDD:sldd:VariableCopied', srcName, dstName );
end 
close( dd );
end 


function result = createEntry( varName, mdlName, srcName, varType, propName, blkPath, wsName )




if checkVarExistence( mdlName, varName, varType )
result = DAStudio.message( 'SLDD:sldd:VariableExists', varName );
return 
end 

if isequal( wsName, ' ' )
wsName = 'all';
elseif isequal( wsName, mdlName )
wsName = 'model workspace';
elseif isequal( wsName, 'base' )
wsName = 'base workspace';
else 
assert( contains( wsName, '.sldd' ) );
end 

classList = 'AllClasses';
if isequal( varType, 'config' )
classList = 'ConfigSet';
else 
if isempty( blkPath ) || isempty( propName )
classList = 'AllClasses';
else 
blkObj = get_param( blkPath, 'Object' );


outPortHandles = blkObj.PortHandles.Outport;
for i = 1:length( outPortHandles )
mustResolveCheckbox = get_param( outPortHandles( i ), 'MustResolveToSignalObject' );
if ( isequal( mustResolveCheckbox, 'on' ) && isequal( varName, get_param( outPortHandles( i ), 'Name' ) ) )
classList = 'Signal';
break ;
end 
end 
if ( isequal( classList, 'AllClasses' ) && ( blkObj.isValidProperty( propName ) ) )

try 
classList = blkObj.getClassSuggestion( propName );
catch E
end 
end 
end 
end 

if isequal( srcName, 'model workspace' )
srcName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_Model' );
elseif isequal( srcName, 'base workspace' ) ...
 || isequal( srcName, 'data dictionary' )
srcName = '';
end 

showMdlWS = ~isequal( varType, 'global' );

if strcmp( classList, 'Enum' ) && isempty( get_param( mdlName, 'DataDictionary' ) )


slprivate( 'createEnumClassDefinition', varName, mdlName, classList, blkPath );
else 




dlgSrc = createDataDDG.makeCreateDataDDG( varName, mdlName, classList, '', srcName, showMdlWS, wsName, '', '' );
slprivate( 'showDDG', dlgSrc );
end 


openDlgs = DAStudio.ToolRoot.getOpenDialogs;
dlg = openDlgs.find( 'dialogTag', dlgSrc.mDialogTag );
waitfor( dlg );


if checkVarExistence( mdlName, varName, varType )
result = DAStudio.message( 'SLDD:sldd:VariableCreated', varName );
else 
DAStudio.error( 'SLDD:sldd:OperationCanceled' );
end 
end 


function result = createDataDictionaryReference( ddRefFrom, ddRefTo )
ddConnFrom = Simulink.data.dictionary.open( ddRefFrom );
ddConnFrom.addDataSource( ddRefTo );
result = DAStudio.message( 'SLDD:sldd:DataDictRefCreated', ddRefTo, ddRefFrom );
end 


function result = copyGlobalVarFromCache( varName, mdlName, srcName, varType, dstName )




assert( isequal( srcName, 'base workspace' ) || contains( srcName, '.sldd' ) );
assert( isequal( dstName, 'base workspace' ) || contains( dstName, '.sldd' ) );


if checkVarExistence( mdlName, varName, varType )
result = DAStudio.message( 'SLDD:sldd:VariableExists', varName );
return 
end 


isCfgSet = isequal( varType, 'config' );
[ ~, isArg, successful ] = copyCachedValueFromMemory( mdlName, srcName, dstName, varName, isCfgSet );
assert( ~isArg );

if successful
result = DAStudio.message( 'SLDD:sldd:VariableValueCopied' );
return ;
end 


if slfeature( 'SLWriteRobustVarRefVarUsageInfo' ) > 0
[ ~, successful ] = copyCachedValueFromMat( mdlName, srcName, dstName, varName, isCfgSet );
if successful
result = DAStudio.message( 'SLDD:sldd:VariableValueCopied' );
return ;
end 
end 
end 


function result = copyGlobalVarFromSrc( varName, mdlName, srcName, varType, dstName )




assert( isequal( srcName, 'base workspace' ) || contains( srcName, '.sldd' ) );
assert( isequal( dstName, 'base workspace' ) || contains( dstName, '.sldd' ) );


if checkVarExistence( mdlName, varName, varType )
result = DAStudio.message( 'SLDD:sldd:VariableExists', varName );
return 
end 


isCfgSet = isequal( varType, 'config' );
if isequal( srcName, 'base workspace' )
if evalin( 'base', [ 'exist(''', varName, ''')' ] ) ~= 1
result = DAStudio.message( 'SLDD:sldd:VarNotInBWS', varName );
return ;
end 

value = evalin( 'base', varName );
else 
ddSrc = Simulink.data.dictionary.open( srcName );
if ~isCfgSet
secSrc = ddSrc.getSection( 'Design Data' );
else 
secSrc = ddSrc.getSection( 'Configurations' );
end 

if ~secSrc.exist( varName )
result = DAStudio.message( 'SLDD:sldd:EntryNotFoundInDD', srcName );
return ;
end 

ent = secSrc.getEntry( varName );
value = ent.getValue(  );
end 

if isequal( dstName, 'base workspace' )
assignin( 'base', varName, value );
result = DAStudio.message( 'SLDD:sldd:VariableValueCopied' );
else 
ddDst = Simulink.data.dictionary.open( dstName );
if ~isCfgSet
secDst = ddDst.getSection( 'Design Data' );
else 
secDst = ddDst.getSection( 'Configurations' );
end 
secDst.assignin( varName, value );
result = DAStudio.message( 'SLDD:sldd:VariableValueCopied' );
end 
end 







function [ result, isArg, successful ] = undoDeletionUseMemory( mdlName, wsName, varName, isCfgSet )
[ result, isArg, successful ] = copyCachedValueFromMemory( mdlName, wsName, wsName, varName, isCfgSet );
end 


function [ result, isArg, successful ] = copyCachedValueFromMemory( mdlName, srcName, dstName, varName, isCfgSet )



result = '';

ws = get_param( mdlName, 'modelworkspace' );
baseWS = 'base workspace';
mdlWS = 'model workspace';
glbWS = 'global workspace';

if isequal( srcName, mdlWS )
wksName = mdlWS;
else 
wksName = glbWS;
end 



if ~isCfgSet
[ isArg, successful ] = ws.getCacheProperty( varName, wksName, 'isArgument' );
if ~successful

return 
end 
else 
isArg = false;
end 

[ value, successful ] = ws.getCacheValue( varName, wksName, isCfgSet );
if ~successful

return 
end 

switch dstName
case baseWS
ws = 'base';
case mdlWS

otherwise 
ddName = dstName;
dd = Simulink.data.dictionary.open( ddName );
if isCfgSet
ws = dd.getSection( 'Configurations' );
else 
ws = dd.getSection( 'Design Data' );
end 
end 


if evalin( ws, [ 'exist(''', varName, ''')' ] ) == 1
result = DAStudio.message( 'SLDD:sldd:VariableExists', varName );
return ;
end 


if isequal( dstName, baseWS ) || isequal( dstName, mdlWS )
assignin( ws, varName, value );
else 
undoDelEntryInDataDictionary( ddName, varName, value, isCfgSet );
end 
result = DAStudio.message( 'SLDD:sldd:DeletionReverted', varName );
end 


function [ result, successful ] = undoDeletionUseMat( mdlName, wsName, varName, isCfgSet )
[ result, successful ] = copyCachedValueFromMat( mdlName, wsName, wsName, varName, isCfgSet );
end 


function [ result, successful ] = copyCachedValueFromMat( mdlName, srcName, dstName, varName, isCfgSet )




filePath = slprivate( 'getVarCacheFilePath', mdlName );
baseWS = 'base workspace';
mdlWS = 'model workspace';

if isequal( srcName, mdlWS )
matFile = fullfile( filePath, 'ModelWSVarValue.mat' );
else 
if isCfgSet
matFile = fullfile( filePath, 'ConfigSetValue.mat' );
else 
matFile = fullfile( filePath, 'GlobalWSVarValue.mat' );
end 
end 

switch dstName
case baseWS
ws = 'base';
case mdlWS
ws = get_param( mdlName, 'modelworkspace' );
otherwise 
ddName = dstName;
dd = Simulink.data.dictionary.open( ddName );
if isCfgSet
ws = dd.getSection( 'Configurations' );
else 
ws = dd.getSection( 'Design Data' );
end 
finish = onCleanup( @(  )close( dd ) );
end 


if evalin( ws, [ 'exist(''', varName, ''')' ] ) == 1
result = DAStudio.message( 'SLDD:sldd:VariableExists', varName );
return ;
end 


if exist( matFile, 'file' ) ~= 2
builtin( '_unpackSLCacheVarCache', mdlName );
end 


[ value, successful ] = loadValue( matFile, varName );

if ( ~successful )
return ;
end 


if isequal( dstName, baseWS ) || isequal( dstName, mdlWS )
assignin( ws, varName, value );
else 
undoDelEntryInDataDictionary( ddName, varName, value, isCfgSet );
end 
result = DAStudio.message( 'SLDD:sldd:DeletionReverted', varName );
end 


function [ value, successful ] = loadValue( matFile, varName )




value = '';
successful = true;


if exist( matFile, 'file' ) ~= 2
successful = false;
return ;
end 


varInfo = who( '-file', matFile, varName );
if isempty( varInfo )
successful = false;
return ;
end 

valStr = load( matFile, varName );
value = valStr.( varName );
end 


function varExists = checkVarExistence( mdlName, varName, varType )



varExists = false;


if isequal( varType, 'config' )
ddName = get_param( mdlName, 'DataDictionary' );
if ~isempty( ddName )
dd = Simulink.dd.open( ddName );
hasBWS = strcmp( get_param( mdlName, 'EnableAccessToBaseWorkspace' ), 'on' );
varExists = evalin( dd, [ 'exist(''', varName, ''')' ], 'Configurations', 'SimulinkDataObject', hasBWS ) == 1;
if ( varExists )
return ;
end 
end 
end 

if isequal( varType, 'global' )

dataAccessor = Simulink.data.DataAccessor.createForExternalData( mdlName );
else 

dataAccessor = Simulink.data.DataAccessor.create( mdlName );
end 
varId = dataAccessor.identifyByName( varName );
if ~isempty( varId )
varExists = true;
end 
end 


function setArgument( mdlName, varName )





dictSys = get_param( mdlName, 'DictionarySystem' );
varObj = dictSys.Parameter.getByKey( varName );
assert( ~isempty( varObj ) );


varObj.Argument = true;
end 



function undoDelEntryInDataDictionary( ddName, entryName, value, isCfg )







































ddConn = Simulink.dd.open( ddName );
idVec = ddConn.getChangedEntries(  )';


savedInfo = '';
for id = idVec
try 
savedInfo = ddConn.getEntryAtRevertPoint( id );
catch 
savedInfo = '';
end 


if ~isempty( savedInfo ) && isequal( savedInfo.Name, entryName )
break ;
else 
savedInfo = '';
end 
end 


dd = Simulink.data.dictionary.open( ddName );
if ( isCfg )
sec = dd.getSection( 'Configurations' );
else 
sec = dd.getSection( 'Design Data' );
end 

if isempty( savedInfo )

sec.assignin( entryName, value );
else 

ddConn.discardEntryChanges( id );
entryAtRevert = sec.getEntry( savedInfo.Name );
assert( isequal( savedInfo.Name, entryName ) );
if ~isequal( entryAtRevert.getValue(  ), value )
entryAtRevert.setValue( value );
end 
end 

ddConn.close(  );
dd.close(  );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpbKHWkt.p.
% Please follow local copyright laws when handling this file.

