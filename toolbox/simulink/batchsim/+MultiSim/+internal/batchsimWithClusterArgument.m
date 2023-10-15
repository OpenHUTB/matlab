function job = batchsimWithClusterArgument( clusterObj, simIns, varargin, config )

arguments
    clusterObj( 1, 1 )parallel.Cluster
    simIns Simulink.SimulationInput{ mustBeNonempty }
end

arguments( Repeating )
    varargin
end

arguments
    config.BatchSimFcn( 1, 1 )function_handle = @MultiSim.internal.batchsim
end

errorOutIfProfileWasSpecified( varargin{ : } );
job = config.BatchSimFcn( simIns, varargin{ : }, 'Profile', clusterObj );
end

function errorOutIfProfileWasSpecified( varargin )
p = inputParser;
addParameter( p, 'Profile', parallel.defaultProfile );
p.KeepUnmatched = true;
parse( p, varargin{ : } );

if ~ismember( 'Profile', p.UsingDefaults )
    error( message( 'Simulink:batchsim:ProfileUsedWithClusterObject' ) );
end
end

