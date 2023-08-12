function output = writeCAPIMATFile( CAPIDataTLC, CodeGenModel, IsModelReference )





output.success = 1;
output.message = '';






try 
narginchk( 3, 3 );


buildDirStruct = RTW.getBuildDir( CodeGenModel );
MATFilePath = fullfile( buildDirStruct.CodeGenFolder,  ...
buildDirStruct.ModelRefRelativeBuildDir,  ...
'tmwinternal' );


if ~exist( MATFilePath, 'dir' )
[ success, message, messageid ] = mkdir( MATFilePath );
if ~success
error( messageid, '%s', message );
end 
end 



if slfeature( 'ParameterService' ) ~= 0 && contains( CAPIDataTLC.DataInterfaceDef, 'rtInf' )
rtInf = inf;
end 


eval( CAPIDataTLC.DataInterfaceDef );
CAPIData.DataInterfaces = dataInterfaces;
assert( length( CAPIData.DataInterfaces ) == CAPIDataTLC.NumDataInterfaces,  ...
'Unexpected number of DataInterfaces created.' );

if IsModelReference
MATFileName = 'capi_mdlref.mat';
else 
MATFileName = 'capi.mat';
end 
MATFile = fullfile( MATFilePath, MATFileName );


save( MATFile, 'CAPIData' );
catch e
output.success = 0;
output.message = e.getReport;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpEWNft8.p.
% Please follow local copyright laws when handling this file.

