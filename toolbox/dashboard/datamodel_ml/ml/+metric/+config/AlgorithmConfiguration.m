classdef AlgorithmConfiguration < handle




properties ( Dependent, SetAccess = private )

ID
AlgorithmID


ScopeQuery alm.gdb.QueryConfiguration
ArtifactQuery alm.gdb.QueryConfiguration
end 

properties ( Dependent )
AlgorithmDependencies string
DataServiceDependencies string
ExecutionContext metric.data.Context
ValueDataType
ParameterValues
Type
end 

properties ( Dependent, Hidden )
MapKey string
AnchorID string
Licenses string
end 

properties ( Access = private )
MF0
MF0DynamicProperties
end 

methods ( Access = ?metric.config.Configuration, Hidden )

function out = getMF0AlgorithmConfiguration( obj )
out = obj.MF0DynamicProperties;
end 

function obj = AlgorithmConfiguration( mf0, mf0dynamicProps )
obj.MF0 = mf0;
obj.MF0DynamicProperties = mf0dynamicProps;
end 

function update( mi, locales )
mfMI = mi.MF0DynamicProperties.MetaInformation.getByKey( '' );
if ~isempty( mfMI )
miOut = [  ];
for k = 1:length( locales )
miOut = [ miOut, metric.internal.localizeMetaInfo( mfMI, locales{ k } ) ];%#ok<AGROW> 
end 

for k = 1:length( miOut )
mi.MF0DynamicProperties.MetaInformation.add( miOut( k ) );
end 

mi.MF0DynamicProperties.MetaInformation.remove( mfMI );
end 
end 

end 

methods 
function val = get.ID( obj )
val = obj.MF0DynamicProperties.ID;
end 

function val = get.AlgorithmID( obj )
val = obj.MF0DynamicProperties.AlgorithmID;
end 

function val = get.Type( obj )
val = obj.MF0DynamicProperties.Type;
end 

function set.Type( obj, val )
obj.MF0DynamicProperties.Type = val;
end 

function val = get.AlgorithmDependencies( obj )
val = {  };

objArray = obj.MF0DynamicProperties.AlgorithmDependencies.toArray(  );
for n = 1:numel( objArray )
val{ n } = objArray( n ).ID;%#ok<AGROW>
end 
end 

function set.AlgorithmDependencies( obj, val )
R36
obj
val string
end 

ads = obj.MF0DynamicProperties.AlgorithmDependencies;
ads.clear(  );

for n = 1:numel( val )
obj.MF0DynamicProperties.addAlgorithmDependency( val( n ) );
end 
end 

function val = get.DataServiceDependencies( obj )
val = {  };

objArray = obj.MF0DynamicProperties.DataServiceDependencies.toArray(  );
for n = 1:numel( objArray )
val{ n } = objArray( n ).ID;%#ok<AGROW>
end 
end 

function set.DataServiceDependencies( obj, val )
R36
obj
val string
end 

ads = obj.MF0DynamicProperties.DataServiceDependencies;
ads.clear(  );

for n = 1:numel( val )
obj.MF0DynamicProperties.addDataServiceDependency( val( n ) );
end 
end 

function val = get.ScopeQuery( obj )
val = obj.MF0DynamicProperties.ScopeQuery;
end 

function setScopeQuery( obj, v, statement )
if isa( v, "alm.gdb.Query" )
obj.MF0DynamicProperties.ScopeQuery = v.getConfiguration(  ).copy( obj.MF0 );
elseif isa( v, "alm.gdb.QueryConfiguration" )
obj.MF0DynamicProperties.ScopeQuery = v.copy( obj.MF0 );
else 
qc = alm.gdb.QueryConfiguration( obj.MF0 );
qc.Namespace = v;
qc.Statement = statement;
obj.MF0DynamicProperties.ScopeQuery = qc;
end 
end 

function val = get.ArtifactQuery( obj )
val = obj.MF0DynamicProperties.ArtifactQuery;
end 

function setArtifactQuery( obj, v, statement )
if isa( v, "alm.gdb.Query" )
obj.MF0DynamicProperties.ArtifactQuery = v.getConfiguration(  ).copy( obj.MF0 );
elseif isa( v, "alm.gdb.QueryConfiguration" )
obj.MF0DynamicProperties.ArtifactQuery = v.copy( obj.MF0 );
else 
qc = alm.gdb.QueryConfiguration( obj.MF0 );
qc.Namespace = v;
qc.Statement = statement;
obj.MF0DynamicProperties.ArtifactQuery = qc;
end 
end 

function val = get.ExecutionContext( obj )
val = obj.MF0DynamicProperties.ExecutionContext;
end 

function set.ExecutionContext( obj, val )
R36
obj
val metric.data.Context
end 
obj.MF0DynamicProperties.ExecutionContext = val;
end 

function val = get.ValueDataType( obj )
val = obj.MF0DynamicProperties.ValueDataType;
end 

function set.ValueDataType( obj, val )
R36
obj
val metric.data.ValueType
end 
obj.MF0DynamicProperties.ValueDataType = val;
end 

function val = get.MapKey( obj )
val = obj.MF0DynamicProperties.MapKey;
end 

function set.MapKey( obj, val )
obj.MF0DynamicProperties.MapKey = val;
end 

function val = get.AnchorID( obj )
val = obj.MF0DynamicProperties.AnchorID;
end 

function set.AnchorID( obj, val )
obj.MF0DynamicProperties.AnchorID = val;
end 

function set.Licenses( obj, val )
obj.MF0DynamicProperties.Licenses.clear(  );
for n = 1:numel( val )
value = val( n );
if iscell( value )
value = value{ 1 };
end 
obj.MF0DynamicProperties.Licenses.add( value );
end 
end 

function val = get.Licenses( obj )
val = obj.MF0DynamicProperties.Licenses.toArray(  );

if isempty( val )

val = {  };
end 
end 


function addParameter( obj, id, val )
pv = metric.data.ParameterValue( obj.MF0 );
pv.ID = id;
pv.Value = metric.internal.convertToMetricDynamicValue( obj.MF0, val );
obj.MF0DynamicProperties.ParameterValues.add( pv );
end 

function pv = getParameterValue( obj, id )
mfpv = obj.MF0DynamicProperties.ParameterValues.getByKey( id );

if ~isempty( mfpv )
pv = metric.internal.convertFromMetricDynamicValue( mfpv.Value );
else 
pv = [  ];
end 
end 


function metaInfo = addMetaInformation( obj, locale )
obj.MF0DynamicProperties.addLocale( locale );

metaInfo = obj.getMetaInformation( locale );
end 

function metaInfo = getMetaInformation( obj, locale )
metaInfo = metric.config.MetaInformation.empty(  );

mfMI = obj.MF0DynamicProperties.MetaInformation.getByKey( locale );

if ~isempty( mfMI )
metaInfo = metric.config.MetaInformation( obj.MF0, mfMI );
end 
end 

function validate( obj )




algo = [  ];
try 
am = metric.internal.AlgorithmManager.get(  );
algo = am.getAlgorithm( obj.AlgorithmID );
catch except
if ~strcmp( except.identifier, 'dashboard:algomanager:UnknownAlgorithmID' )
disp( except.message );
end 
end 


if isa( algo, 'metric.internal.Algorithm' )
algo.DynamicProperties = obj.MF0DynamicProperties;
algo.validate(  );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpkcP_Cg.p.
% Please follow local copyright laws when handling this file.

