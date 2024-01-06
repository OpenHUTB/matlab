function ret = configure_model( mdl, config )

arguments
    mdl( 1, 1 )string
    config( 1, 1 )sltp.mm.modelHierarchy.SolverAndTaskingConfiguration =  ...
        sltp.mm.modelHierarchy.SolverAndTaskingConfiguration.FixedStepMultiTasking
end

ge = sltp.GraphEditor( mdl );
ge.configureModel( config );

ret = '';

end

