function out = exportToExperimentManager( template, results )

arguments
    template( 1, 1 )experiments.internal.AbstractExperiment
    results( :, 1 )struct
end
out = experiments.internal.View(  ).import( { template, results } );

end
