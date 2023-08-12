classdef Configuration < handle

properties 
FileName
Location
end 

properties ( Dependent )
Name
end 

properties ( Dependent, SetAccess = private )
AlgorithmConfigurations
end 

properties ( Access = private )
MF0
MF0Config
end 

properties ( Constant, Hidden )
DefaultConfigFileName = 'MetricDefaultConfiguration.json';
DefaultConfigLocation = fullfile( matlabroot, 'toolbox', 'dashboard', 'default_config' );
end 

properties ( Hidden )
Locales = { 'en_US', 'ja_JP' };
end 

methods ( Access = private )

function obj = Configuration( mf0, mf0config )
obj.MF0 = mf0;
obj.MF0Config = mf0config;
end 
end 

methods 


function set.Name( obj, name )
R36
obj
name{ StringOrCharScalar( name ) }
end 

obj.MF0Config.Name = name;
end 

function out = get.Name( obj )
out = obj.MF0Config.Name;
end 


function val = get.AlgorithmConfigurations( obj )
val = metric.config.AlgorithmConfiguration.empty(  );

mfACs = obj.MF0Config.AlgorithmConfigurations.toArray(  );

for n = 1:numel( mfACs )
val( n ) = metric.config.AlgorithmConfiguration( obj.MF0,  ...
mfACs( n ) );
end 
end 

function ac = addAlgorithmConfiguration( obj, algoID, instanceID )
mfAC = metric.data.AlgorithmDynamicProperties.createEmptyInstance( obj.MF0 );
mfAC.ID = instanceID;
mfAC.AlgorithmID = algoID;

obj.MF0Config.AlgorithmConfigurations.add( mfAC );
ac = metric.config.AlgorithmConfiguration( obj.MF0, mfAC );
end 

function ac = getAlgorithmConfiguration( obj, instanceID )
ac = metric.config.AlgorithmConfiguration.empty(  );

mfAC = obj.MF0Config.AlgorithmConfigurations.getByKey( instanceID );

if ~isempty( mfAC )
ac = metric.config.AlgorithmConfiguration( obj.MF0, mfAC );
end 
end 

function acs = getConfigurationsForAlgorithmID( obj, algoID )
acs = metric.config.AlgorithmConfiguration.empty(  );

mfACs = obj.MF0Config.AlgorithmConfigurations.toArray(  );

for n = 1:numel( mfACs )
if strcmp( mfACs( n ).AlgorithmID, algoID )
acs( end  + 1 ) = metric.config.AlgorithmConfiguration( obj.MF0, mfACs( n ) );%#ok<AGROW>
end 
end 
end 



function set.FileName( obj, name )
R36
obj
name{ StringOrCharScalar( name ) }
end 

name = string( name );

if ~name.endsWith( '.json', 'IgnoreCase', true )
name = name + ".json";
end 

obj.FileName = char( name );
end 



function set.Location( obj, loc )
R36
obj
loc{ StringOrCharScalar( loc ) }
end 
obj.Location = char( loc );
end 



function validate( obj )
for i = 1:numel( obj.AlgorithmConfigurations )
obj.AlgorithmConfigurations( i ).validate(  );
end 
end 


function save( obj, varargin )

f = @( x )isstring( x ) | ischar( x );



for idx = 1:length( obj.AlgorithmConfigurations )
mi = obj.AlgorithmConfigurations( idx );
mi.update( obj.Locales );
end 
p = inputParser;
p.addParameter( 'FileName', obj.FileName, f );
p.addParameter( 'Location', obj.Location, f );



p.addParameter( 'xx_AllowOverWriteDefault_xx', false, @islogical );
p.parse( varargin{ : } );


obj.validate(  );

filename = string( p.Results.FileName );
if ~filename.endsWith( '.json', 'IgnoreCase', true )
filename = char( filename + ".json" );
end 

location = p.Results.Location;

if exist( location, 'dir' ) == 0
mkdir( location );
end 

trgt = fullfile( location, filename );

if ~p.Results.xx_AllowOverWriteDefault_xx && ( exist( trgt, 'file' ) ~= 0 )
fid = fopen( trgt, 'r' );
absTrgt = fopen( fid );
fclose( fid );

cmprfcn = @( x, y )strcmpi( x, y );
if strcmp( computer( 'arch' ), 'glnxa64' )
cmprfcn = @( x, y )strcmp( x, y );
end 

if cmprfcn( absTrgt, fullfile(  ...
metric.config.Configuration.DefaultConfigLocation,  ...
metric.config.Configuration.DefaultConfigFileName ) )
error( message( 'dashboard:metricConfiguration:CantOverwriteDefault' ) );
end 

end 

s = mf.zero.io.JSONSerializer;
s.serializeToFile( obj.MF0Config, trgt );
end 

end 

methods ( Static )

function config = new( varargin )
f = @( x )isstring( x ) | ischar( x );

p = inputParser;
p.addParameter( 'FileName', 'newConfiguration.json', f );
p.addParameter( 'Location', pwd, f );
p.addParameter( 'Name', 'Default', f );
p.parse( varargin{ : } );

mf0 = mf.zero.Model;
mf0config = metric.data.config.Configuration( mf0 );

config = metric.config.Configuration( mf0, mf0config );
config.FileName = p.Results.FileName;
config.Location = p.Results.Location;
config.Name = p.Results.Name;

end 

function config = openDefaultConfiguration(  )

config = metric.config.Configuration.open(  ...
'FileName', metric.config.Configuration.DefaultConfigFileName,  ...
'Location', metric.config.Configuration.DefaultConfigLocation );
end 


function config = open( varargin )

if nargin == 0
config = metric.config.Configuration.openDefaultConfiguration(  );
return 
end 

f = @( x )isstring( x ) | ischar( x );

p = inputParser;
p.addParameter( 'FileName', f );
p.addParameter( 'Location', pwd, f );
p.parse( varargin{ : } );

filename = string( p.Results.FileName );
if ~filename.endsWith( '.json', 'IgnoreCase', true )
filename = char( filename + ".json" );
end 

jp = mf.zero.io.JSONParser;
mf0 = mf.zero.Model;
jp.Model = mf0;
mf0config = jp.parseFile( fullfile( p.Results.Location, filename ) );
config = metric.config.Configuration( mf0, mf0config );
config.FileName = filename;
config.Location = p.Results.Location;
end 

end 


end 



function StringOrCharScalar( val )
if ( ~isa( val, 'char' ) && ~isa( val, 'string' ) ) || ( numel( string( val ) ) > 1 )
error( message( 'dashboard:metricConfiguration:CharOrStringScalar' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYiYM8k.p.
% Please follow local copyright laws when handling this file.

