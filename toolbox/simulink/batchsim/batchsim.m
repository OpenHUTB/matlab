function job = batchsim( simInsOrClusterObj, varargin, options, config )

arguments
    simInsOrClusterObj
end

arguments( Repeating )
    varargin
end

arguments
    options.ThrowAsCaller( 1, 1 )logical = true
    config.BatchSimFcn( 1, 1 )function_handle = @MultiSim.internal.batchsim
    config.BatchSimWithClusterArgFcn( 1, 1 )function_handle = @MultiSim.internal.batchsimWithClusterArgument
end




if ( nargin > 1 && isa( varargin{ 1 }, 'parallel.Cluster' ) )
    error( message( 'Simulink:batchsim:ClusterMustBeFirstArgument' ) );
end

if isa( simInsOrClusterObj, 'parallel.Cluster' )
    batchsimFcn = config.BatchSimWithClusterArgFcn;
else
    batchsimFcn = config.BatchSimFcn;
end

try
    job = batchsimFcn( simInsOrClusterObj, varargin{ : } );
catch ME
    if options.ThrowAsCaller
        throwAsCaller( ME )
    else
        rethrow( ME );
    end
end
end

