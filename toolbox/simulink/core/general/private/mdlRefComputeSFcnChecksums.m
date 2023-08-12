function [ sfunChecksums, missingSFuns ] = mdlRefComputeSFcnChecksums( sfcnInfos, sourceFileMap, verbose, varargin )






assert( ~isequal( sfcnInfos,  - 1 ), 'sfcnInfo was not filled in' );
sfunChecksums = struct( 'SFunction', {  }, 'Dependency', {  }, 'Checksum', {  }, 'Block', {  } );
missingSFuns = {  };

for i = 1:length( sfcnInfos )
sfcnInfo = sfcnInfos( i );

[ sfcnFiles, missingSFun ] = loc_getAllSfcnFiles( sfcnInfo, sourceFileMap, verbose, varargin{ : } );
missingSFuns = [ missingSFuns, missingSFun ];%#ok<AGROW>


for j = 1:length( sfcnFiles )
sfcnFile = sfcnFiles{ j };

[ ~, basename, ext ] = fileparts( sfcnFile );

sfunChecksums( end  + 1 ).Dependency = [ basename, ext ];%#ok<AGROW>
sfunChecksums( end  ).SFunction = sfcnInfo.FunctionName;
sfunChecksums( end  ).Checksum = file2hash( sfcnFile );
sfunChecksums( end  ).Block = sfcnInfo.Block;
end 
end 
end 



function [ sfcnFiles, missingSFun ] = loc_getAllSfcnFiles( sfcnInfo, sourceFileMap, iVerbose, varargin )
sfcnName = sfcnInfo.FunctionName;
sfcnFiles = {  };
missingSFun = {  };



sfcnFile = which( sfcnName );
if isempty( sfcnFile )
missingSFun.sfcn = sfcnName;
missingSFun.block = sfcnInfo.Block;
return ;
end 


sfcnFiles = { sfcnFile };
sfcnFiles = [ sfcnFiles, loc_getTLCFiles( sfcnFile, sfcnInfo ) ];
sfcnFiles = [ sfcnFiles, loc_getModuleFiles( sfcnFile, sfcnInfo, sourceFileMap, iVerbose, varargin{ : } ) ];

for i = 1:length( sfcnFiles )
sfcnFile = sfcnFiles{ i };



if ( isempty( dir( sfcnFile ) ) )
msg = DAStudio.message( 'Simulink:slbuild:sfunctionFileDoesNotExist',  ...
sfcnFile, sfcnName, sfcnInfo.Block );
sl_disp_info( msg, iVerbose );
sfcnFiles{ i } = '';
end 
end 


sfcnFiles( strcmp( sfcnFiles, '' ) ) = [  ];
end 




function tlcFiles = loc_getTLCFiles( sfcnFile, sfcnInfo )
tlcFiles = {  };



if ( ~isempty( sfcnInfo.TLCDir ) )
sfcnDir = fileparts( sfcnFile );
tlcDir = strrep( sfcnInfo.TLCDir{ 1 }, '<SFCNDIR>', sfcnDir );
tlcFile = fullfile( tlcDir, [ sfcnInfo.FunctionName, '.tlc' ] );

tlcFiles = { tlcFile };
end 
end 




function allModuleFiles = loc_getModuleFiles( sfcnFile, sfcnInfo, sourceFileMap, iVerbose, varargin )
allModuleFiles = {  };


if ~isempty( sfcnInfo.Modules )

mdlRefTargetType = 'NONE';
rapidAcceleratorIsActive = false;

if length( varargin ) == 2
mdlRefTargetType = varargin{ 1 };
rapidAcceleratorIsActive = varargin{ 2 };
end 

useSFcnMexFile = false;

if isequal( mdlRefTargetType, 'SIM' ) || rapidAcceleratorIsActive
useSFcnMexFile = sfcnInfo.willBeDynamicallyLoaded == 1;
end 

sfcnDir = fileparts( sfcnFile );

for mIdx = 1:length( sfcnInfo.Modules )
module = sfcnInfo.Modules{ mIdx };
[ ~, ~, ext ] = fileparts( module );
if isempty( ext )
moduleFileName = [ module, '.c' ];
else 
moduleFileName = module;
end 
thisModuleFiles = {  };


moduleFile = fullfile( sfcnDir, moduleFileName );
if ( isempty( dir( moduleFile ) ) )


if ( sourceFileMap.isKey( module ) )
thisModuleFiles = sourceFileMap( module );
end 
else 

thisModuleFiles = { moduleFile };
end 

if ( isempty( thisModuleFiles ) )

if ~useSFcnMexFile
msg = DAStudio.message( 'Simulink:slbuild:sfunctionFileDoesNotExist',  ...
moduleFileName, sfcnInfo.FunctionName, sfcnInfo.Block );
sl_disp_info( msg, iVerbose );
end 

else 
allModuleFiles = [ allModuleFiles, thisModuleFiles ];%#ok<AGROW>
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpw8z_Zk.p.
% Please follow local copyright laws when handling this file.

