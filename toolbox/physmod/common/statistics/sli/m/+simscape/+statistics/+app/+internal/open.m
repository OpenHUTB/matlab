function app = open( mdl )





R36
mdl{ lMustBeSimulinkModel }
end 


hMdl = get_param( mdl, 'Handle' );


refresher = @(  )lRefresher( hMdl );


maybeNodes = lStatistics( hMdl );
options = {  };
if ~isempty( maybeNodes )
options = { 'Statistics', maybeNodes };
end 


app = simscape.statistics.gui.internal.ModelStatisticsApp(  ...
getfullname( mdl ), refresher, options{ : } );
end 

function stats = lRefresher( hMdl )

if ishandle( hMdl )
try 
set_param( hMdl, 'SimulationCommand', 'update' );
catch 
end 
stats = lStatistics( hMdl );
else 
errordlg( 'Model is no longer open.' );
stats = repmat( simscape.statistics.data.internal.Statistic, 0, 0 );
end 
end 

function lMustBeSimulinkModel( mdl )

hMdl = get_param( mdl, 'Handle' );
getfullname( hMdl );
end 

function stats = lStatistics( mdl )

R36
mdl( 1, 1 )double
end 
stats = simscape.statistics.data.internal.transformedStatistics( mdl );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpoOw9db.p.
% Please follow local copyright laws when handling this file.

