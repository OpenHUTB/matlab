function out = getSInfo( slprjFolder, varargin )
narginchk( 1, 2 );
out = [  ];
sInfoFile = fullfile( slprjFolder, 'tmwinternal', 'sinfo.mat' );
if ~exist( sInfoFile, 'file' )
return 
end 
sinfo = load( sInfoFile, 'infoStruct' );
if isempty( sinfo ) || ~isfield( sinfo.infoStruct, 'Subsystems' ) || isempty( sinfo.infoStruct.Subsystems )
return 
end 
if nargin > 1 && ~strcmp( varargin{ 1 }, '*' )
sourceSubsystem = varargin{ 1 };
if ~ischar( sourceSubsystem )
sourceSubsystem = getfullname( sourceSubsystem );
end 
idx = [  ];
if ~isempty( strfind( sourceSubsystem, '/' ) )
idx = strcmp( { sinfo.infoStruct.Subsystems.BlockPath }, sourceSubsystem );
elseif isfield( sinfo.infoStruct.Subsystems, 'BlockSID' )
idx = strcmp( { sinfo.infoStruct.Subsystems.BlockSID }, sourceSubsystem );
end 
if any( idx )
out = sinfo.infoStruct.Subsystems( idx );
end 
else 

ts = arrayfun( @( x )datenum( x.TimeStamp ), sinfo.infoStruct.Subsystems );
if nargin > 1
[ ~, idx ] = sort( ts );
else 
[ ~, idx ] = max( ts );
end 
out = sinfo.infoStruct.Subsystems( idx );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp93S2sE.p.
% Please follow local copyright laws when handling this file.

