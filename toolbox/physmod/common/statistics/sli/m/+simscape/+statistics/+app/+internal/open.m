function app = open( mdl )

arguments
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

arguments
    mdl( 1, 1 )double
end
stats = simscape.statistics.data.internal.transformedStatistics( mdl );
end

