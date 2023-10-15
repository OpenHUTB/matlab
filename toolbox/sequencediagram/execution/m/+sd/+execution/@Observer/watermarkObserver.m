function watermarkObserver( observer )

arguments
    observer( 1, 1 )sd.execution.Observer
end

observerModelName = observer.name;


set_param( observerModelName, 'Watermark', 'update' );


rt = sfroot;
machine = rt.find( '-isa', 'Stateflow.Machine', 'Name', observerModelName );
charts = sf( 'get', machine.Id, '.charts' );

checksumKey = sprintf( '%c%c%c%c%c%c%c%c%c%c%c%c%c%c', char( 82 ), char( 65 ), char( 85 ),  ...
    char( 49 ), char( 84 ), char( 72 ), char( 118 ), char( 48 ),  ...
    char( 82 ), char( 55 ), char( 69 ), char( 68 ), char( 83 ), char( 70 ) );
for idx = 1:numel( charts )
    chartH = sf( 'IdToHandle', charts( idx ) );
    sf( 'UpdateSFAuthoredChartChecksum', chartH.Id, checksumKey );
end

Stateflow.internal.updateAuthoredMachine( machine.Id );

end

