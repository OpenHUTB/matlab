function ret = configure_model( mdl, config )






R36
mdl( 1, 1 )string
config( 1, 1 )sltp.mm.modelHierarchy.SolverAndTaskingConfiguration =  ...
sltp.mm.modelHierarchy.SolverAndTaskingConfiguration.FixedStepMultiTasking
end 

ge = sltp.GraphEditor( mdl );
ge.configureModel( config );



ret = '';

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpdkBtZI.p.
% Please follow local copyright laws when handling this file.

