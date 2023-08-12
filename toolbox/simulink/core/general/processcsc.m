function retArg = processcsc( action, varargin )







mlock
persistent cachedDefns
persistent packageStack

switch action

case 'GetCSCRegFile'







if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

retArg = LocalFindRegFilePath( pkgName );



if ~isempty( retArg ) && isempty( meta.package.fromName( pkgName ) )
DAStudio.error( 'Simulink:dialog:UnableToFindPKg', pkgName );
end 

case 'GetCSCChecksums'
















validArgs = ( ( nargin == 1 ) ||  ...
( ( nargin == 2 ) && ischar( varargin{ 1 } ) ) );
if ~validArgs
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

retArg.Checksum = [  ];
retArg.ChecksumSource = [  ];


packageList = {  };
if ( nargin == 1 )

if ~isempty( cachedDefns )
packageList = fieldnames( cachedDefns );
end 
else 

packageListStr = varargin{ 1 };
while ( ~isempty( packageListStr ) )
[ onePackage, packageListStr ] = strtok( packageListStr, ',' );%#ok
packageList{ end  + 1, 1 } = onePackage;%#ok
end 
end 


packageList = sort( packageList );


for i = 1:length( packageList )
pkgName = packageList{ i };
if ~isfield( cachedDefns, pkgName )
processcsc( 'GetAllDefns', pkgName );
end 
retArg.Checksum.( pkgName ) = cachedDefns.( pkgName ).RegChecksum;
retArg.ChecksumSource.( pkgName ) = cachedDefns.( pkgName ).RegChecksumSource;
end 

case 'GetAllDefns'








if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

if isfield( cachedDefns, pkgName )

allDefns = processcsc( 'GetAllDefnsFromCache', pkgName );
else 
allDefns = processcsc( 'GetAllDefnsFromCSCRegFile', pkgName );


filePath = LocalFindRegFilePath( pkgName );
if ~isempty( filePath )
regChecksum = slprivate( 'file2hash', filePath );
cscDefns = allDefns{ 1 };
msDefns = allDefns{ 2 };

cacheStruct.RegChecksum = regChecksum;
cacheStruct.RegChecksumSource = filePath;
cacheStruct.CSCDefns = cscDefns;
cacheStruct.MemorySectionDefns = msDefns;


names.All = {  };
names.Parameter = {  };
names.Signal = {  };

for i = 1:length( cscDefns )
names.All = [ names.All;{ cscDefns( i ).Name } ];
if cscDefns( i ).getProp( 'DataUsage' ).IsParameter
names.Parameter = [ names.Parameter;{ cscDefns( i ).Name } ];
end 

if cscDefns( i ).getProp( 'DataUsage' ).IsSignal
names.Signal = [ names.Signal;{ cscDefns( i ).Name } ];
end 
end 

names.All = unique( names.All, 'stable' );
names.Parameter = unique( names.Parameter, 'stable' );
names.Signal = unique( names.Signal, 'stable' );

cacheStruct.CSCNames = names;

cacheStruct.DefaultCustomAttributes = createCustomAttribObj( cscDefns( 1 ), false );


names.All = {  };
names.Function = {  };
names.Parameter = {  };
names.Signal = {  };

for i = 1:length( msDefns )
names.All = [ names.All;{ msDefns( i ).Name } ];
names.Function = [ names.Function;{ msDefns( i ).Name } ];
if msDefns( i ).getProp( 'DataUsage' ).IsParameter
names.Parameter = [ names.Parameter;{ msDefns( i ).Name } ];
end 

if msDefns( i ).getProp( 'DataUsage' ).IsSignal
names.Signal = [ names.Signal;{ msDefns( i ).Name } ];
end 
end 

names.All = unique( names.All, 'stable' );
names.Function = unique( names.Function, 'stable' );
names.Parameter = unique( names.Parameter, 'stable' );
names.Signal = unique( names.Signal, 'stable' );

cacheStruct.MemorySectionNames = names;

cachedDefns.( pkgName ) = cacheStruct;

end 
end 

retArg = allDefns;

case 'GetCSCDefns'






if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 


if ~isfield( cachedDefns, pkgName )
processcsc( 'GetAllDefns', pkgName );
end 

retArg = cachedDefns.( pkgName ).CSCDefns;

case 'GetCSCDefn'






if ( ( nargin == 3 ) && ischar( varargin{ 2 } ) )
pkgName = varargin{ 1 };
cscName = varargin{ 2 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

cscDefns = processcsc( 'GetCSCDefns', pkgName );

retArg = find( cscDefns, 'Name', cscName );
assert( length( retArg ) <= 1, [ 'More than one storage class named ''', cscName, '''.' ] );

case 'GetMemorySectionDefn'






if ( ( nargin == 3 ) && ischar( varargin{ 2 } ) )
pkgName = varargin{ 1 };
msName = varargin{ 2 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

msDefns = processcsc( 'GetMemorySectionDefns', pkgName );

retArg = find( msDefns, 'Name', msName );
assert( length( retArg ) <= 1, [ 'More than one memory section named ''', msName, '''.' ] );

case 'GetCSCNames'







if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
filter = 'All';
elseif ( nargin == 3 ) && ischar( varargin{ 1 } ) && ischar( varargin{ 2 } )
pkgName = varargin{ 1 };
filter = varargin{ 2 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

if isvarname( pkgName )

if ~isfield( cachedDefns, pkgName )
processcsc( 'GetAllDefns', pkgName );
end 

retArg = cachedDefns.( pkgName ).CSCNames.( filter );
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

case 'GetNamesForParameter'






if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

retArg = processcsc( 'GetCSCNames', pkgName, 'Parameter' );

case 'GetNamesForSignal'






if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

retArg = processcsc( 'GetCSCNames', pkgName, 'Signal' );

case 'doesPackageHaveCSC'





if ( nargin == 5 ) && ischar( varargin{ 1 } ) && ischar( varargin{ 2 } ) && ischar( varargin{ 3 } ) && islogical( varargin{ 4 } )
pkgName = varargin{ 1 };
cscName = varargin{ 2 };
filter = varargin{ 3 };
createAttribClass = varargin{ 4 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

cscNames = processcsc( 'GetCSCNames', pkgName, filter );
isValidCSC = any( strcmp( cscName, cscNames ) );



if isValidCSC && createAttribClass
processcsc( 'CreateAttributesObject', pkgName, cscName );
end 

retArg = isValidCSC;

case 'GetMemorySectionDefns'






if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 


if ~isfield( cachedDefns, pkgName )
processcsc( 'GetAllDefns', pkgName );
end 

retArg = cachedDefns.( pkgName ).MemorySectionDefns;

case 'GetMemorySectionNames'







if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
filter = 'All';
elseif ( ( nargin == 3 ) && ischar( varargin{ 1 } ) && ischar( varargin{ 2 } ) )
pkgName = varargin{ 1 };
filter = varargin{ 2 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

if isvarname( pkgName )

if ~isfield( cachedDefns, pkgName )
processcsc( 'GetAllDefns', pkgName );
end 

retArg = cachedDefns.( pkgName ).MemorySectionNames.( filter );

else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

case 'GetCommaSeparatedMemSecList'







msNames = processcsc( 'GetMemorySectionNames', varargin{ : } );

if isempty( msNames )
retArg = '';
else 
retArg = msNames{ 1 };
for idx = 2:length( msNames )
retArg = [ retArg, ',', msNames{ idx } ];%#ok
end 
end 

case 'CheckCircularReference'
callerPackage = varargin{ 1 };
targetPackage = varargin{ 2 };


packageStack{ end  + 1 } = callerPackage;

try 

if any( strcmp( targetPackage, packageStack ) )
DAStudio.error( 'Simulink:dialog:PkgCircularReference', targetPackage, callerPackage );
end 






if isfield( cachedDefns, targetPackage )
allDefns = processcsc( 'GetAllDefns', targetPackage );


cscDefns = allDefns{ 1 };
for idx = 1:length( cscDefns )
thisDefn = cscDefns( idx );
thisDefn.checkCircularReference;
end 


msDefns = allDefns{ 2 };
for idx = 1:length( msDefns )
thisDefn = msDefns( idx );
thisDefn.checkCircularReference;
end 
else 
processcsc( 'GetAllDefns', targetPackage );
end 
catch err
packageStack( end  ) = [  ];
rethrow( err.message );
end 


assert( isequal( packageStack{ end  }, callerPackage ),  ...
'Package stack corrupted during circular reference check' );
packageStack( end  ) = [  ];

case 'ClearCache'




clear packageStack;

if ( nargin == 1 )
cachedDefns = [  ];


clear functions %#ok

elseif ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };

if isfield( cachedDefns, pkgName )
cachedDefns = rmfield( cachedDefns, pkgName );
end 



filePath = LocalFindRegFilePath( pkgName );
clear( filePath )

else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

retArg = [  ];

case 'CreateAttributesObject'








if ( nargin == 3 )
pkgName = varargin{ 1 };
thisCSCName = varargin{ 2 };
inModel = false;
elseif ( nargin == 4 )
pkgName = varargin{ 1 };
thisCSCName = varargin{ 2 };
inModel = varargin{ 3 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

if isvarname( pkgName )
if strcmp( thisCSCName, 'Default' )

if ~isfield( cachedDefns, pkgName )
processcsc( 'GetAllDefns', pkgName );
end 

retArg = copy( cachedDefns.( pkgName ).DefaultCustomAttributes );
else 


thisCSCDefn = processcsc( 'GetCSCDefn', pkgName, thisCSCName );
if isempty( thisCSCDefn )
DAStudio.error( 'Simulink:dialog:InvalidCSCName', thisCSCName, pkgName );
end 

retArg = createCustomAttribObj( thisCSCDefn, inModel );
end 

else 


retArg = processcsc( 'CreateAttributesObject', 'Simulink', 'Default' );
end 




case 'GetAllDefnsFromCSCRegFile'









if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

if isempty( meta.package.fromName( pkgName ) )


if ( ( ~isempty( findpackage( pkgName ) ) ) &&  ...
( ~isempty( which( [ '@', pkgName, filesep, 'csc_registration' ] ) ) ) )









MSLDiagnostic( 'Simulink:dialog:CannotLoadDefnsForLevel1Package', pkgName ).reportAsWarning;
retArg = LocalGetDefaultDefns( pkgName );
return ;
else 
DAStudio.error( 'Simulink:dialog:UnableToFindPKg', pkgName );
end 
end 


try 
defaultDefns = LocalGetDefaultDefns( pkgName );

cscDefns = [ defaultDefns{ 1 }; ...
LocalGetDefnsFromRegFile( 'CSCDefn', pkgName ) ];
msDefns = [ defaultDefns{ 2 }; ...
LocalGetDefnsFromRegFile( 'MemorySectionDefn', pkgName ) ];
catch err
DAStudio.error( 'Simulink:dialog:UnableToLoadRegFile',  ...
pkgName, err.message );
end 


pkgDir = fileparts( LocalFindRegFilePath( pkgName ) );
invalidList = validatecsc( pkgDir, cscDefns, msDefns );
for i = 1:size( invalidList{ 1 }, 2 )
invalidDefn = invalidList{ 1 }( :, i );
warnMsg = DAStudio.message( 'Simulink:dialog:InvalidCSCDefn',  ...
invalidDefn{ 1 }, invalidDefn{ 2 } );
disp( warnMsg );
end 
for i = 1:size( invalidList{ 2 }, 2 )
invalidDefn = invalidList{ 2 }( :, i );
warnMsg = DAStudio.message( 'Simulink:dialog:InvalidMSDefn',  ...
invalidDefn{ 1 }, invalidDefn{ 2 } );
disp( warnMsg );
end 

retArg = { cscDefns;msDefns };

case 'GetAllDefnsFromCache'





if ( ( nargin == 2 ) && ischar( varargin{ 1 } ) )
pkgName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

if isfield( cachedDefns, pkgName )

cscDefns = cachedDefns.( pkgName ).CSCDefns;
msDefns = cachedDefns.( pkgName ).MemorySectionDefns;
retArg = { cscDefns;msDefns };
else 
retArg = {  };
end 

case 'GetCopyOfSimulinkDefns'
if ( nargin ~= 2 )
DAStudio.error( 'Simulink:dialog:ActionInCorrectArg', action );
end 

pkgName = varargin{ 1 };
if isempty( meta.package.fromName( pkgName ) )
DAStudio.error( 'Simulink:dialog:UnableToFindPKg', pkgName );
end 

retArg = LocalGetCopyOfDefnsFromSimulink( pkgName );

case 'PrintCache'


disp( '{' );
if ~isempty( cachedDefns )
disp( cachedDefns );
tmpFn = fieldnames( cachedDefns );
for i = 1:length( tmpFn )
disp( cachedDefns.( tmpFn{ i } ) );
end 
end 
disp( '}' );

otherwise 
DAStudio.error( 'Simulink:dialog:CSCRegInvalidAction', action );
end 






function filePath = LocalFindRegFilePath( pkgName )







fileName = 'csc_registration';
tmpstr = [ '+', pkgName, filesep, fileName ];
filePath = which( tmpstr );




function defns = LocalGetDefnsFromRegFile( whichDefns, pkgName )


filePath = LocalFindRegFilePath( pkgName );
if ~isempty( filePath )

clear( filePath );



[ ~, fname ] = fileparts( filePath );

strEval = [ pkgName, '.', fname, '(''', whichDefns, ''')' ];
defns = eval( strEval );

if strcmp( whichDefns, 'CSCDefn' )
expectRtnType = [ 'Simulink.', 'BaseCSCDefn' ];
else 
assert( strcmp( whichDefns, 'MemorySectionDefn' ), 'Unexpected definition type' );
expectRtnType = 'Simulink.BaseMSDefn';
end 

if ~isempty( defns ) && ~isa( defns, expectRtnType )
DAStudio.error( 'Simulink:dialog:InvalidCSCType', expectRtnType );
end 
else 
DAStudio.error( 'Simulink:dialog:CSCRegFileNotFound', pkgName );
end 




function copyobjs = LocalCopyObj( origobjs )


copyobjs = [  ];
for i = 1:length( origobjs )
tmp = origobjs( i ).deepCopy;
copyobjs = [ copyobjs;tmp ];%#ok
end 




function defaultDefns = LocalGetDefaultDefns( pkgName )
cscDefault = Simulink.CSCDefn;
cscDefault.Name = 'Default';
cscDefault.OwnerPackage = pkgName;
cscDefault.MemorySection = 'Default';
cscDefault.DataScope = 'Exported';
cscDefault.DataInit = 'Auto';

msDefault = Simulink.MemorySectionDefn;
msDefault.Name = 'Default';
msDefault.OwnerPackage = pkgName;

defaultDefns = { cscDefault;msDefault };


function allDefns = LocalGetCopyOfDefnsFromSimulink( pkgName )



origDefns = processcsc( 'GetAllDefns', 'Simulink' );
cscDefns = LocalCopyObj( origDefns{ 1 } );
msDefns = LocalCopyObj( origDefns{ 2 } );

for idx = 1:length( cscDefns )

if strcmp( cscDefns( idx ).CSCType, 'Other' )
thisDefn = cscDefns( idx );
newDefn = Simulink.CSCRefDefn;
newDefn.Name = thisDefn.Name;
newDefn.OwnerPackage = pkgName;
newDefn.RefPackageName = thisDefn.OwnerPackage;
newDefn.RefDefnName = thisDefn.Name;
cscDefns( idx ) = newDefn;
else 
cscDefns( idx ).OwnerPackage = pkgName;
end 

end 

for idx = 1:length( msDefns )
msDefns( idx ).OwnerPackage = pkgName;
end 

allDefns = { cscDefns;msDefns };





% Decoded using De-pcode utility v1.2 from file /tmp/tmpTqMUJU.p.
% Please follow local copyright laws when handling this file.

