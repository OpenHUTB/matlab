











classdef simulink_version

properties ( Constant, GetAccess = 'private' )
version_list = Simulink.loadsave.getKnownSimulinkVersions;
end 

properties ( GetAccess = 'public', SetAccess = 'private' )
version;
release;
valid;
end 

methods ( Access = 'private' )
function obj = scalar_simulink_version( obj, s )
if ischar( s ) || isstring( s )
[ obj.version, obj.valid ] = simulink_version.releaseToVersion( char( s ) );
if ~obj.valid


v = str2double( s );
if ~isnan( v )
[ obj.release, obj.valid ] = simulink_version.versionToRelease( v );
[ obj.version, ~ ] = simulink_version.releaseToVersion( obj.release );
return ;
end 
end 

[ obj.release, obj.valid ] = simulink_version.normalizeReleaseName( s );
else 
assert( isnumeric( s ) && isscalar( s ),  ...
'String or numeric scalar required' );
obj.version = s;
[ obj.release, obj.valid ] = simulink_version.versionToRelease( s );
end 
if ~obj.valid
obj.version =  - 1;
obj.release = DAStudio.message( 'sl_utility:general:UnknownVersion' );
end 
end 
end 

methods ( Access = 'public' )
function obj = simulink_version( s )
if nargin < 1 || isempty( s )

list = simulink_version.version_list;
obj.version = list{ end , 1 };
obj.release = list{ end , 2 };
obj.valid = true;
return ;
end 
if ischar( s )
obj = obj.scalar_simulink_version( s );
return ;
else 

m = size( s, 1 );
n = size( s, 2 );

obj( m, n ) = simulink_version;
for releaseIndex = 1:numel( s )
if ( iscell( s ) )
obj( releaseIndex ) = obj( releaseIndex ).scalar_simulink_version( s{ releaseIndex } );
else 
obj( releaseIndex ) = obj( releaseIndex ).scalar_simulink_version( s( releaseIndex ) );
end 
end 
end 
end 
function disp( obj )
for i = 1:numel( obj )
fprintf( '  simulink_version:' );
fprintf( '  %1.1f (%s)\n', obj( i ).version, obj( i ).release );
end 
end 
function x = gt( obj1, obj2 )
x = [ obj1.version ] > [ obj2.version ];
end 
function x = lt( obj1, obj2 )
x = [ obj1.version ] < [ obj2.version ];
end 
function x = eq( obj1, obj2 )
x = [ obj1.version ] == [ obj2.version ];
end 
function x = ne( obj1, obj2 )
x = [ obj1.version ] ~= [ obj2.version ];
end 
function x = ge( obj1, obj2 )
x = [ obj1.version ] >= [ obj2.version ];
end 
function x = le( obj1, obj2 )
x = [ obj1.version ] <= [ obj2.version ];
end 
end 

methods ( Static, Access = 'public' )

function vers = all_versions(  )
list = simulink_version.version_list;
vers = vertcat( list{ :, 1 } );
end 

function rels = all_releases(  )
list = simulink_version.version_list;
rels = list( :, 2 );
end 

end 

methods ( Static, Access = 'private' )

function [ r, valid ] = versionToRelease( ver )



base_ver = floor( ver * 100 + 0.00000000001 ) / 100;
verPair = Simulink.loadsave.getKnownSimulinkVersions( base_ver );
r = verPair{ 2 };
v = verPair{ 1 };
valid = true;


service_pack = ( ver - v ) * 1000;
if v < 0 || service_pack > 9.00001 || abs( round( service_pack ) - service_pack ) > 0.00001
r = DAStudio.message( 'sl_utility:general:UnknownVersion' );
valid = false;
end 
end 

function [ v, valid ] = releaseToVersion( r )
verPair = Simulink.loadsave.getKnownSimulinkVersions( r );
v = verPair{ 1 };
valid = true;
if v < 0
[ goodRel, valid ] = simulink_version.normalizeReleaseName( r );
if valid
verPair = Simulink.loadsave.getKnownSimulinkVersions( goodRel );
v = verPair{ 1 };
end 
end 

end 

function [ normRel, valid ] = normalizeReleaseName( r )

valid = true;


rels = simulink_version.all_releases(  );
match = strcmpi( rels, r );
if any( match )
tmpRel = rels( match );
normRel = tmpRel{ 1 };
return ;
end 


match = ~isempty( regexpi( r, 'R20\d\d\wSP\d' ) );
if match
[ normRel, valid ] = simulink_version.normalizeReleaseName( r( 1:end  - 3 ) );
return ;
end 





filteredRels = rels;
filteredRels = strrep( filteredRels, '(', '' );
filteredRels = strrep( filteredRels, ')', '' );
filteredRels = strrep( filteredRels, ' ', '' );
filteredRels = strrep( filteredRels, '.', 'p' );
match = strcmpi( filteredRels, r );
if any( match )
tmpRel = rels( match );
normRel = tmpRel{ 1 };
return ;
end 

normRel = DAStudio.message( 'sl_utility:general:UnknownVersion' );
valid = false;
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp8nfE64.p.
% Please follow local copyright laws when handling this file.

