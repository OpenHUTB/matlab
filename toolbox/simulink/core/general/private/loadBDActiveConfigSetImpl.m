function loadBDActiveConfigSetImpl( model, filename )















if nargin < 2
throw( MSLException( [  ], message( 'Simulink:ConfigSet:MissingInpArgs' ) ) );
end 

filename = convertStringsToChars( filename );


if isempty( model )
throw( MSLException( [  ], message( 'Simulink:ConfigSet:FirstInpArgMustBeValidModel' ) ) );
end 
active_CS_model = getActiveConfigSet( model );
model = get_param( model, 'Name' );

textFormat = true;
[ pathstr, name, ext ] = fileparts( filename );

if strcmp( model, name )
throw( MSLException( [  ], message( 'Simulink:ConfigSet:MdlCSNameConflict', name ) ) );
end 


if isempty( ext )

filename = [ filename, '.m' ];
elseif ext == ".mat"
textFormat = false;
elseif ext ~= ".m"
throw( MSLException( [  ], message( 'Simulink:ConfigSet:badFileExtension' ) ) );
end 


if ~exist( filename, 'file' )
throw( MSLException( [  ], message( 'Simulink:ConfigSet:fileNotExisted', filename ) ) );
end 


if textFormat
cls = internal.matlab.codetools.reports.matlabType.findType( filename );

if ~isa( cls, 'internal.matlab.codetools.reports.matlabType.Function' )
throw( MSLException( [  ], message( 'Simulink:ConfigSet:notMATLABFunction', filename ) ) );
end 

cleanup = [  ];
if ~isempty( pathstr )
cur_Dir = cd( pathstr );
cleanup = onCleanup( @(  )cd( cur_Dir ) );
end 


try 
cs_tmp = eval( name );
catch ME
except = MSLException( message( 'Simulink:ConfigSet:badMATLABFunctionNoConfigSet', filename ) );
throw( except.addCause( ME ) );
end 


if nargout( name ) > 1
throw( MSLException( [  ], message( 'Simulink:ConfigSet:badMATLABFunctionMultiConfigSet', filename ) ) );
end 


if ~isa( cs_tmp, 'Simulink.ConfigSet' )
throw( MSLException( [  ], message( 'Simulink:ConfigSet:badMATLABFunctionNoConfigSet', filename ) ) );
end 

delete( cleanup );
else 

objInMAT = load( filename );


isaConfigSet = structfun( @( x )isa( x, 'Simulink.ConfigSet' ), objInMAT );
if length( find( isaConfigSet ) ) > 1
throw( MSLException( [  ], message( 'Simulink:ConfigSet:multipleCSinMATFile' ) ) );
end 


if ~any( isaConfigSet )
throw( MSLException( [  ], message( 'Simulink:ConfigSet:noCSinMATFile' ) ) );
end 


if ~all( isaConfigSet )
MSLDiagnostic( 'Simulink:ConfigSet:otherObjsinMATFile' ).reportAsWarning;
end 

f = fieldnames( objInMAT );
cs_tmp = objInMAT.( f{ find( isaConfigSet, 1 ) } );
end 


origName = cs_tmp.name;
attachConfigSet( model, cs_tmp, 1 );
try 

setActiveConfigSet( model, cs_tmp.name );
catch me
detachConfigSet( model, cs_tmp.name );
rethrow( me );
end 


if isa( active_CS_model, 'Simulink.ConfigSetRef' )
MSLDiagnostic( 'Simulink:ConfigSet:warningToReplaceConfigSetRef', model ).reportAsWarning;
end 

detachConfigSet( model, active_CS_model.Name );
if ~strcmp( cs_tmp.name, origName ) && ~isempty( getConfigSet( model, origName ) )
detachConfigSet( model, origName );
MSLDiagnostic( 'Simulink:ConfigSet:csNameConflict', origName ).reportAsWarning;
end 
cs_tmp.name = origName;
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmp7qsRKY.p.
% Please follow local copyright laws when handling this file.

