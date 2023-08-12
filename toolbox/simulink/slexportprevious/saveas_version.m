


classdef saveas_version
properties ( GetAccess = 'public', SetAccess = 'private' )
version;
release;
version_str
format;
label;
end 

properties ( Dependent )
description;
end 

properties ( Constant, Hidden )


oldest_supported_version = 6.4;

oldest_slx_version = 7.9;
end 

properties ( Access = 'private' )
sort_index;
end 

methods ( Static )

function x = supported_mdl_versions



all_known = Simulink.loadsave.getKnownSimulinkVersions;
supported = [ all_known{ :, 1 } ] >= saveas_version.oldest_supported_version;
supported( end  ) = false;
x = simulink_version( all_known( supported, 2 ) );
end 

function x = supported_slx_versions
all_known = Simulink.loadsave.getKnownSimulinkVersions;
supported = [ all_known{ :, 1 } ] >= saveas_version.oldest_slx_version;
supported( end  ) = false;
x = simulink_version( all_known( supported, 2 ) );
end 




function X = getSupported( earliest )
persistent all_supported;
if isempty( all_supported )
mdl = saveas_version.supported_mdl_versions;
slx = saveas_version.supported_slx_versions;
n = numel( mdl ) + numel( slx );
all_supported = repmat( saveas_version( saveas_version.oldest_supported_version ), n, 1 );
for i = 1:numel( mdl )
all_supported( i ) = saveas_version( [ mdl( i ).release, '_MDL' ] );
end 
for i = 1:numel( slx )
all_supported( i + numel( mdl ) ) = saveas_version( [ slx( i ).release, '_SLX' ] );
end 
labels = { all_supported.label };
[ ~, ind ] = sort( labels );
all_supported = all_supported( ind );
end 
if nargin < 1
X = all_supported;
else 
earliest = simulink_version( earliest ).version;
all_vers = [ all_supported.version ];
X = all_supported( all_vers >= earliest );
end 
end 


function x = getVersionStrings
vers = saveas_version.getSupported;
x = { vers.label }';
end 

function r = oldestSupportedRelease
all_versions = saveas_version.getSupported;
r = all_versions( 1 ).ver_info;
end 

end 

methods ( Static, Hidden )

function x = versionInfoFromNumber( ver )
x = saveas_version.versionInfoFromStr( sprintf( '%1.1f', ver ) );
end 


function x = versionInfoFromStr( verstr )
v = saveas_version( verstr );
x = v.release;
end 

function format = getDefaultFileFormat( simulinkVersionObj )


assert( simulinkVersionObj.valid, 'Must provide a valid simulink_version object' );
if simulinkVersionObj > simulink_version( 'R2012a' )
format = 'slx';
else 
format = 'mdl';
end 
end 

function labelStr = labelFromSimulinkVersionObject( simulinkVersionObj, format )
assert( isa( simulinkVersionObj, 'simulink_version' ), 'Input must be a simulink_version object' );
if nargin < 2
format = saveas_version.getDefaultFileFormat( simulinkVersionObj );
else 
assert( ischar( format ), '"format" must be a string' );
assert( any( strcmpi( format, { 'mdl', 'slx' } ) ),  ...
'"format" must be either or "mdl" or "slx"' );
end 
labelStr = upper( simulinkVersionObj.release );
labelStr = labelStr( ~ismember( labelStr, '( )' ) );
labelStr = [ 'SAVEAS_', labelStr ];
if saveas_version.isMDLOnlyVersion( simulinkVersionObj.version )



return ;
end 

labelStr = [ labelStr, '_', upper( format ) ];
if ~saveas_version.isMDLAndSLXVersion( simulinkVersionObj.version )
DAStudio.error( 'Simulink:ExportPrevious:BadVersion', labelStr );
end 
end 

function str = labelFromVersionNumber( v, format )
v = simulink_version( v );
str = saveas_version.labelFromSimulinkVersionObject( v, format );
end 



function [ b, id, fmt ] = isValidVersion( ver )
try 
r = saveas_version( ver );
b = true;
id = r.label;
fmt = r.format;
catch E %#ok<NASGU>
b = false;
id = [  ];
fmt = [  ];
end 
end 

function b = isMDLOnlyVersion( ver )
if ~isnumeric( ver )
ver = simulink_version( ver );
ver = ver.version;
end 
b = ver >= saveas_version.oldest_supported_version &&  ...
ver < saveas_version.oldest_slx_version;
end 

function b = isMDLAndSLXVersion( ver )
if ~isnumeric( ver )
ver = simulink_version( ver );
ver = ver.version;
end 
b = ver >= saveas_version.oldest_slx_version;
end 





function oldest_ver = getOldestFormallySupportedVersion( bdType )

R36
bdType = '';
end 
v = simulink_version;
v_str = v.release;
year = str2double( v_str( 2:5 ) );
year = year - 7;
a_or_b = v_str( end  );





if ( strcmpi( bdType, 'subsystem' ) && year <= 2019 )
year = 2019;
a_or_b = 'b';
end 

oldest_ver_str = sprintf( 'R%d%s', year, a_or_b );
oldest_ver = simulink_version( oldest_ver_str );
end 







function [ filters, vers ] = getDialogFilterStrings( bdType )
if ( nargin < 1 )
bdType = '';
end 
old_v_obj = saveas_version.getOldestFormallySupportedVersion( bdType );

vers = saveas_version.getSupported( old_v_obj.version );

vers = vers( numel( vers ): - 1:1 );

prompts = cell( size( vers ) );
filter_exts = cell( size( vers ) );
for i = 1:numel( vers )
prompts{ i } = vers( i ).description;
filter_exts{ i } = [ '*.', vers( i ).format ];
end 
filters = [ filter_exts( : ), prompts( : ) ];

assert( size( filters, 1 ) == numel( vers ) );

vers = { vers.label }';
end 







function rels = getFormallySupportedReleaseNames(  )


old_v_obj = saveas_version.getOldestFormallySupportedVersion;

vers = saveas_version.getSupported( old_v_obj.version );

rels = unique( { vers.release } )';
end 

end 

methods ( Hidden )




function configSetVer = getConfigSetVersionNumber( obj )

switch ( obj.release )
case 'R2021b'
configSetVer = '21.1.0';





case 'R2020a'
configSetVer = '20.0.1';
case 'R2019b'
configSetVer = '19.1.1';
case 'R2016b'
configSetVer = '1.16.5';
case 'R2016a'
configSetVer = '1.16.2';
case 'R2014b'
configSetVer = '1.14.3';
case 'R2014a'
configSetVer = '1.14.2';
case 'R2010b'
configSetVer = '1.10.0';
case { 'R2009b', 'R2009a' }
configSetVer = '1.6.0';
case 'R2008b'
configSetVer = '1.5.1';
case 'R2008a'
configSetVer = '1.4.0';
case 'R2007b'
configSetVer = '1.3.0';
case { 'R2007a', 'R2006b', 'R2006a' }
configSetVer = '1.2.0';
case { 'R14 (SP3)', 'R14 (SP2)' }
configSetVer = '1.1.0';
case { 'R14 (SP1)', 'R14' }
configSetVer = '1.0.4';
otherwise 
releaseStr = obj.release( 1:end  );
releaseYear = releaseStr( 4:5 );
releaseSeason = releaseStr( 6 );
if releaseSeason == 'a'
releaseSub = '0';
else 
releaseSub = '1';
end 



if ~isR2018bOrEarlier( obj )
configSetVer = [ releaseYear, '.', releaseSub, '.0' ];
elseif ~isR2009bOrEarlier( obj )
configSetVer = [ '1.', releaseYear, '.', releaseSub ];
else 

configSetVer = '';
end 
end 
end 
end 

methods 

function desc = get.description( obj )
desc = DAStudio.message(  ...
'Simulink:editor:ExportToVersionFilter',  ...
obj.version_str,  ...
obj.release,  ...
obj.format );
end 

function index = get.sort_index( obj )
if isempty( obj.sort_index )
vers = obj.getSupported;
obj.sort_index = find( strcmp( obj.label, { vers.label } ), 1, 'first' );
end 
index = obj.sort_index;
end 

end 


methods ( Access = 'public' )
function obj = saveas_version( ver )
if isa( ver, 'saveas_version' )
obj = ver;
return ;
end 
assert( ischar( ver ) || isstring( ver ) || ( isnumeric( ver ) && isscalar( ver ) ),  ...
'String or numeric scalar required' );
suppliedver = ver;
v = simulink_version( ver );
fmt = [  ];
if ~v.valid && ( ischar( ver ) || isstring( ver ) )
ver = char( ver );
if strncmpi( ver, 'SAVEAS_', 7 )

ver = ver( 8:end  );
end 
if length( ver ) > 4
ext = ver( end  - 3:end  );
if strcmpi( ext, '_MDL' )
fmt = 'mdl';
ver = ver( 1:end  - 4 );
elseif strcmpi( ext, '_SLX' )
fmt = 'slx';
ver = ver( 1:end  - 4 );
end 
end 
v = simulink_version( ver );
end 
if ~v.valid
obj.invalidRelease( ver, suppliedver );
elseif v == simulink_version
c = simulink_version;
if strcmp( c.release, v.release )


obj.invalidRelease( ver, suppliedver );
end 



end 

if isempty( fmt )
obj.format = saveas_version.getDefaultFileFormat( v );
else 
obj.format = fmt;
end 


obj.label = saveas_version.labelFromSimulinkVersionObject( v, obj.format );
obj.version = v.version;
obj.release = v.release;
obj.version_str = sprintf( '%1.1f', obj.version );
checkFileExtension( obj, [ '.', obj.format ] );

end 

function invalidRelease( ~, ver, suppliedver )
if ~ischar( ver ) && ~isstring( ver )
ver = sprintf( '%f', ver );
else 

ver = suppliedver;
end 
DAStudio.error( 'Simulink:ExportPrevious:BadVersion', ver )
end 

function checkFileExtension( obj, ext )
ext = char( ext );
assert( numel( ext ) && ext( 1 ) == '.',  ...
'Valid file extensions must start with a dot' );

requiredExtension = sprintf( '.%s', obj.format );

if ~strcmp( ext, requiredExtension )
DAStudio.error( 'Simulink:ExportPrevious:BadExtension',  ...
ext, obj.description, requiredExtension );
end 

if saveas_version.isMDLOnlyVersion( obj.version )
if ~strcmpi( ext, '.mdl' )
DAStudio.error( 'Simulink:ExportPrevious:BadExtension',  ...
ext, obj.description, '.mdl' );
end 
else 
derivedExt = [ '.', lower( obj.label( end  - 2:end  ) ) ];
if ~strcmpi( ext, derivedExt )
DAStudio.error( 'Simulink:ExportPrevious:BadExtension',  ...
ext, obj.description, ext );
end 
end 
end 

function x = isValid( ~ )
x = true;
end 

function x = isInVersionInterval( obj, begin, last )
x = obj.version >= simulink_version( begin ).version &&  ...
obj.version <= simulink_version( last ).version;
end 

function varargout = sort( varargin )
releaseArray = varargin{ 1 };
sortIndArray = [ releaseArray.sort_index ];

newArgs = varargin;
newArgs{ 1 } = sortIndArray;

[ ~, indexMapping ] = sort( newArgs{ : } );

varargout{ 1 } = releaseArray( indexMapping );
if ( nargout == 2 )
varargout{ 2 } = indexMapping;
elseif ( nargout > 2 )
msg = message( 'MATLAB:maxlhs' );
error( 'MATLAB:maxlhs', msg.getString );
end 

end 

function disp( obj )
for i = 1:numel( obj )
fprintf( '  saveas_version: %s (%s format)\n', obj( i ).label, obj( i ).format' );
end 
end 

function v = ver_info( obj )
v = obj.release;
end 
function v = ver_str( obj )
v = obj.version_str;
end 


function b = isSLX( obj )
b = strcmpi( obj.format, 'SLX' );
end 

function b = isMDL( obj )
b = strcmpi( obj.format, 'MDL' );
end 


function x = gt( obj1, obj2 )
x = [ obj1.sort_index ] > [ obj2.sort_index ];
end 

function x = lt( obj1, obj2 )
x = [ obj1.sort_index ] < [ obj2.sort_index ];
end 

function x = ge( obj1, obj2 )
x = [ obj1.sort_index ] >= [ obj2.sort_index ];
end 

function x = le( obj1, obj2 )
x = [ obj1.sort_index ] <= [ obj2.sort_index ];
end 

function x = eq( obj1, obj2 )
x = [ obj1.sort_index ] == [ obj2.sort_index ];
end 

function x = ne( obj1, obj2 )
x = [ obj1.sort_index ] ~= [ obj2.sort_index ];
end 


function x = isR2006a( obj )
x = obj.isRelease( 'R2006a' );
end 
function x = isR2006b( obj )
x = obj.isRelease( 'R2006b' );
end 
function x = isR2007a( obj )
x = obj.isRelease( 'R2007a' );
end 
function x = isR2007b( obj )
x = obj.isRelease( 'R2007b' );
end 
function x = isR2008a( obj )
x = obj.isRelease( 'R2008a' );
end 
function x = isR2008b( obj )
x = obj.isRelease( 'R2008b' );
end 
function x = isR2009a( obj )
x = obj.isRelease( 'R2009a' );
end 
function x = isR2009b( obj )
x = obj.isRelease( 'R2009b' );
end 
function x = isR2010a( obj )
x = obj.isRelease( 'R2010a' );
end 
function x = isR2010b( obj )
x = obj.isRelease( 'R2010b' );
end 
function x = isR2011a( obj )
x = obj.isRelease( 'R2011a' );
end 
function x = isR2011b( obj )
x = obj.isRelease( 'R2011b' );
end 
function x = isR2012a( obj )
x = obj.isRelease( 'R2012a' );
end 
function x = isR2012b( obj )
x = obj.isRelease( 'R2012b' );
end 
function x = isR2013a( obj )
x = obj.isRelease( 'R2013a' );
end 
function x = isR2013b( obj )
x = obj.isRelease( 'R2013b' );
end 
function x = isR2014a( obj )
x = obj.isRelease( 'R2014a' );
end 
function x = isR2014b( obj )
x = obj.isRelease( 'R2014b' );
end 
function x = isR2015a( obj )
x = obj.isRelease( 'R2015a' );
end 
function x = isR2015b( obj )
x = obj.isRelease( 'R2015b' );
end 
function x = isR2016a( obj )
x = obj.isRelease( 'R2016a' );
end 
function x = isR2016b( obj )
x = obj.isRelease( 'R2016b' );
end 
function x = isR2017a( obj )
x = obj.isRelease( 'R2017a' );
end 
function x = isR2017b( obj )
x = obj.isRelease( 'R2017b' );
end 
function x = isR2018a( obj )
x = obj.isRelease( 'R2018a' );
end 
function x = isR2018b( obj )
x = obj.isRelease( 'R2018b' );
end 
function x = isR2019a( obj )
x = obj.isRelease( 'R2019a' );
end 
function x = isR2019b( obj )
x = obj.isRelease( 'R2019b' );
end 
function x = isRelease( obj, rel )
x = strcmp( obj.release, simulink_version( rel ).release );
end 


function x = isReleaseOrEarlier( obj, rel )
x = obj.version <= simulink_version( rel ).version;
end 
function x = isR2022aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2022a' );
end 
function x = isR2021bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2021b' );
end 
function x = isR2021aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2021a' );
end 
function x = isR2020bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2020b' );
end 
function x = isR2020aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2020a' );
end 
function x = isR2019bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2019b' );
end 
function x = isR2019aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2019a' );
end 
function x = isR2018bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2018b' );
end 
function x = isR2018aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2018a' );
end 
function x = isR2017bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2017b' );
end 
function x = isR2017aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2017a' );
end 
function x = isR2016bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2016b' );
end 
function x = isR2016aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2016a' );
end 
function x = isR2015bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2015b' );
end 
function x = isR2015aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2015a' );
end 
function x = isR2014bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2014b' );
end 
function x = isR2014aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2014a' );
end 
function x = isR2013bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2013b' );
end 
function x = isR2013aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2013a' );
end 
function x = isR2012bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2012b' );
end 
function x = isR2012aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2012a' );
end 
function x = isR2011bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2011b' );
end 
function x = isR2011aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2011a' );
end 
function x = isR2010bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2010b' );
end 
function x = isR2010aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2010a' );
end 
function x = isR2009bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2009b' );
end 
function x = isR2009aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2009a' );
end 
function x = isR2008bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2008b' );
end 
function x = isR2008aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2008a' );
end 
function x = isR2007bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2007b' );
end 
function x = isR2007aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2007a' );
end 
function x = isR2006bOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2006b' );
end 
function x = isR2006aOrEarlier( obj )
x = obj.isReleaseOrEarlier( 'R2006a' );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp8ZAd1X.p.
% Please follow local copyright laws when handling this file.

