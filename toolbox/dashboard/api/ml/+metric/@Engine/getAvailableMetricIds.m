


function ids = getAvailableMetricIds( obj, NameValueArgs )
R36
obj;
NameValueArgs.App( 1, 1 )string = "";
NameValueArgs.Dashboard( 1, 1 )string = "";
NameValueArgs.Installed( 1, 1 )logical = true;
end 
ids = strings( 0 );

es = metric.internal.ExecutionService.get( obj.ProjectPath );
[ loc, name, ext ] = fileparts( es.getConfigurationFile(  ) );
CONF = metric.config.Configuration.open( 'FileName', [ name, ext ], 'Location', loc );

dbMetricIds = getMetricsInDashboard( obj.ProjectPath, NameValueArgs.App,  ...
NameValueArgs.Dashboard );
filterForDb = ~isempty( dbMetricIds );

am = metric.internal.AlgorithmManager.get(  );

for c = CONF.AlgorithmConfigurations

if ( c.Type == metric.data.AlgorithmType.DATASERVICE )
continue ;
end 


if ( NameValueArgs.Installed )
try 
algo = am.getAlgorithm( c.AlgorithmID );
catch 

continue 
end 

if isempty( algo ) || strcmp( algo.AlgorithmType, 'DataService' )
continue 
end 
end 

if filterForDb
if any( dbMetricIds == string( c.ID ) )
ids( end  + 1 ) = string( c.ID );%#ok<AGROW> 
end 
else 
ids( end  + 1 ) = string( c.ID );%#ok<AGROW> 
end 
end 
end 

function ids = getMetricsInDashboard( prjPath, app, db )
ids = strings( 0, 0 );

if ( app ~= "" )
if app == "DashboardApp"
layout = dashboard.internal.getDashboardLayout( prjPath,  ...
app, db,  ...
'metric.dashboard.Configuration' );

if isempty( layout )
error( message( 'dashboard:api:UnknownDbForApp', db, app ) );
end 

ids = string( layout.getAllMetricIds( layout.Widgets ) );

elseif app == "DesignCostEstimation"
ids = [ "DataSegmentEstimate", "OperatorCount" ];
else 
error( message( 'dashboard:api:UnknownAppId', app ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQEx3Zk.p.
% Please follow local copyright laws when handling this file.

