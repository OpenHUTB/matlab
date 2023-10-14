function canUse = useLightweightWorkers( simInputs, options, pool )
arguments
    simInputs Simulink.SimulationInput
    options( 1, 1 )
    pool( 1, 1 )parallel.Pool
end

useThreadWorkers = options.UseThreadWorkers;
canUse = useThreadWorkers && locIsFeatureOn(  ) &&  ...
    locIsMultithreadedPool( pool, useThreadWorkers ) &&  ...
    locCheckOptions( options, useThreadWorkers ) &&  ...
    locCheckSimInputs( simInputs, useThreadWorkers );
end

function canUse = locIsFeatureOn(  )
feat = slfeature( 'RapidAcceleratorLightweightParallelSimulation' );
canUse = ( feat > 0 );
end

function canUse = locIsMultithreadedPool( pool, useThreadWorkers )
arguments
    pool( 1, 1 )parallel.Pool
    useThreadWorkers( 1, 1 )logical
end

if isa( pool, 'parallel.ThreadPool' )
    feat = slfeature( 'RapidAcceleratorLightweightParallelSimulation' );
    canUse = ( feat > 1 );
else
    canUse = ( pool.Cluster.NumThreads > 1 );
    if ~canUse && useThreadWorkers
        error( message( "multisim:ThreadWorkers:InsufficientNumThreads" ) );
    end
end
end

function canUse = locCheckOptions( options, useThreadWorkers )
canUse = true;
incompatibleOptions = [ "RunInBackground", "ShowSimulationManager", "StopOnError", "UseFastRestart" ];

for optionName = incompatibleOptions
    if options.( optionName )
        canUse = false;
        if useThreadWorkers
            error( message( "multisim:ThreadWorkers:IncompatibleOption", optionName ) );
        end
        return ;
    end
end
end

function canUse = locCheckSimInputs( simInputs, useThreadWorkers )
canUse = true;
numSims = numel( simInputs );
errMsg = [  ];
for i = 1:numSims
    if ~isempty( simInputs( i ).PreSimFcn )
        errMsg = message( "multisim:ThreadWorkers:PreSimFcnNotEmpty" );
    elseif ~strcmpi( simInputs( i ).get_param( 'RapidAcceleratorUpToDateCheck' ), 'off' )
        errMsg = message( "multisim:ThreadWorkers:UpToDateCheckOff" );
    elseif ~startsWith( simInputs( i ).get_param( 'SimulationMode' ), 'r', 'IgnoreCase', true )
        errMsg = message( "multisim:ThreadWorkers:IncompatibleSimMode" );
    end

    if ~isempty( errMsg )
        if useThreadWorkers
            error( errMsg );
        else
            canUse = false;
            return ;
        end
    end
end
end


