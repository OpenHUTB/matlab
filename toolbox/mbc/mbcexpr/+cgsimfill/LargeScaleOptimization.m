classdef LargeScaleOptimization < handle & matlab.mixin.Copyable

    properties ( AbortSet )

        SimFill

        DataFolder

        Extension = 'csv';


        ExcludedFiles

        NumIterations = 30;

        StepSize = 0.001;

        CoefficientTables = false;


        WeightFactor = 1.2;

        Weights = [  ]


        KeepLastOnly = false;

        ReferenceVariable = '';


        ReferenceList = {  };

        OptimizeAll = false;

        InitialWindow = 0;

        ToAdjustBreakpoints

        NormalizeWeights = true;

        InitialConditions
    end

    properties ( Transient, SetAccess = private )


        ExpressionChain
    end
    properties ( SetAccess = private )

        RMSE
    end

    properties ( Dependent, SetAccess = private )

        DataFiles

        UseParallel

        FillItems
    end

    properties ( Dependent, AbortSet )


        ApproximationType



        Optimizer
    end

    properties ( Access = private )

        pApproximationType( 1, 1 )cgsimfill.internal.optimizer.ApproximationType = "linear";

        pOptimizer
    end

    methods

        function obj = LargeScaleOptimization( F )

            obj.SimFill = F;
        end


        function dataFiles = get.DataFiles( obj )


            dataFiles = dir( fullfile( obj.DataFolder, sprintf( '*.%s', obj.Extension ) ) );
            dataFiles = setdiff( { dataFiles.name }, obj.ExcludedFiles );
            if ~isempty( dataFiles )


                dataFiles( startsWith( dataFiles, '~' ) ) = [  ];
            end
        end

        function useParallel = get.UseParallel( obj )

            useParallel = length( obj.DataFiles ) > 1 && mbcfoundation.DCTManager.isDCTAvailable;
        end

        function ca = get.ApproximationType( obj )
            ca = obj.pApproximationType;
        end

        function set.ApproximationType( obj, val )




            F = obj.SimFill;
            obj.pApproximationType = val;

            if obj.pApproximationType == "linear"
                F.approximate( 'linear', false );
            else

                F.approximate( obj.pApproximationType, obj.CoefficientTables );
            end
        end

        function set.Optimizer( obj, optimizer )

            obj.pOptimizer = optimizer;

            obj.Weights = [  ];
        end

        function optimizer = get.Optimizer( obj )
            optimizer = obj.pOptimizer;
        end


        function items = get.FillItems( obj )

            if ~isempty( obj.SimFill )
                items = obj.SimFill.FillItems;
            else
                items = cgsimfill.Table.empty;
            end
        end

        function updateFolder( obj )


            folder = obj.DataFolder;
            if ~isempty( folder ) && ~exist( folder, 'dir' )

                projFile = obj.SimFill.Project.projectfile;
                [ projectPath, ~, ~ ] = fileparts( projFile );
                [ ~, subPath, ~ ] = fileparts( folder );
                newFolder = fullfile( projectPath, subPath );
                if exist( newFolder, 'dir' )

                    obj.DataFolder = newFolder;
                end
            end
        end

        function tbl = initialConditionsTable( obj )


            ES = cgsimfill.ExpressionChain( obj.SimFill.Pointer );
            ES.KeepLastOnly = obj.KeepLastOnly;
            if ES.HasState
                states = ES.ExpressionArray( cellfun( @hasState, ES.ExpressionArray ) );
                ic = cellfun( @( s )initialconditions( s ), states, 'UniformOutput', false );
                ic = cellfun( @( s )s( 1 ), ic, 'UniformOutput', false );
                stateNames = cellfun( @getname, states, 'UniformOutput', false );
                dataSource = repmat( { '<none>' }, size( ic ) );
                variableStepSize = strcmp( 'StepSize', stateNames );
                if nnz( variableStepSize ) == 1

                    pInp = getinputs( states{ variableStepSize } );
                    dataSource{ variableStepSize } = pInp.getname;
                end

                tbl = [ stateNames( : ), ic( : ), dataSource( : ) ];

            else
                tbl = cell( 0, 3 );
            end
            obj.InitialConditions = tbl;

        end

        function OK = checkFolder( LS, folder )

            OK = false;
            fileList = dir( fullfile( folder, sprintf( '*.%s', LS.Extension ) ) );
            inputs = pveceval( LS.SimFill.Inputs, @getname );
            referenceVarList = {  };
            if ~isempty( LS.ExcludedFiles )
                excluded = ismember( { fileList.name }, LS.ExcludedFiles );
            else
                excluded = false( size( fileList ) );
            end
            for i = 1:length( fileList )
                try
                    opts = detectImportOptions( fullfile( folder, fileList( i ).name ) );
                catch
                    excluded( i ) = true;
                    continue
                end
                if all( ismember( inputs, opts.VariableNames ) )

                    other = setdiff( opts.VariableNames, inputs );


                    if isempty( referenceVarList )
                        referenceVarList = other;
                    else
                        referenceVarList = intersect( referenceVarList, other );
                    end
                    if isempty( referenceVarList )
                        break
                    end
                else
                    excluded( i ) = true;
                end
            end
            if ~isempty( referenceVarList )

                LS.ReferenceList = referenceVarList;
                if ~any( strcmp( LS.ReferenceVariable, referenceVarList ) )

                    LS.ReferenceVariable = referenceVarList{ 1 };
                end
                LS.DataFolder = folder;
                LS.ExcludedFiles = { fileList( excluded ).name };
                OK = true;
            end
        end

        function [ Cost, errorMsg ] = run( obj, fOutputFcn )





            tableValues = initialize( obj );

            filler = obj.SimFill;

            startTime = tic;
            initStart = tic;
            snapshot( obj );

            if length( obj.Weights ) ~= length( obj.DataFiles )
                if ~obj.UseParallel && obj.ExpressionChain.HasLoop && length( obj.DataFiles ) > 6


                    fOutputFcn( [  ], [  ], 'message', 'Initializing. Parallel Computing for many data files and transient features is highly recommended.' )
                end

                [ rmse, residuals, dataSizes ] = evaluateFeature( obj );
                minsse = sum( residuals .^ 2 );
                totalRMSE = sqrt( minsse / length( residuals ) );
                obj.RMSE = rmse;
                filler.RMSE = totalRMSE;

                calculateWeights( obj, rmse, dataSizes );
            else
                totalRMSE = filler.RMSE;
            end
            iterTime = toc( initStart ) / 60;

            [ results, iter, errorMsg, minCost ] = mainRun( obj, fOutputFcn, iterTime, startTime, tableValues, totalRMSE );
            if ~isempty( errorMsg )

                Cost = NaN;
                clearSnapshot( obj );
                return
            end



            Cost = postProcess( obj, fOutputFcn, results, startTime, iter, minCost );



            reset( obj.Optimizer )
        end

        function clearMemory( obj )



            obj.Weights = [  ];
            obj.RMSE = [  ];
            if ~isempty( obj.Optimizer )

                clearMemory( obj.Optimizer );
            end
        end

        function ok = hasMemory( obj )

            ok = length( obj.Weights ) > 1 || hasMemory( obj.Optimizer );
        end


        function adjustBreakpoints( obj )






            pTables = obj.ToAdjustBreakpoints;
            for i = 1:length( pTables )
                LT = pTables( i ).info;
                maskValues = getExtrapolationMask( LT );
                if nnz( any( maskValues, 1 ) ) < 0.5 * size( maskValues, 2 ) ||  ...
                        nnz( any( maskValues, 2 ) ) < 0.5 * size( maskValues, 1 )

                    autoSpaceManager = bpinit( LT );
                    os = get( autoSpaceManager );
                    fnames = fieldnames( os );
                    bp = get( LT, 'allbreakpoints' );
                    if ~iscell( bp )
                        bp = { bp };
                    end
                    [ indices{ 1:2 } ] = find( maskValues );
                    for j = 1:length( bp )

                        st = min( min( indices{ j } ), size( maskValues, j ) - 1 );
                        fin = max( max( indices{ j } ), 2 );
                        if fin - st < 0.5 * size( maskValues, j )

                            dels = bp{ j }( st + 1 ) - bp{ j }( st );
                            delf = bp{ j }( fin ) - bp{ j }( fin - 1 );


                            r = [ bp{ j }( st ) - dels / 2, bp{ j }( fin ) + delf / 2 ];
                            autoSpaceManager = set( autoSpaceManager, [ fnames{ j }, '.Range' ], r );
                        else

                            autoSpaceManager = set( autoSpaceManager, [ fnames{ j }, '.Range' ], [ bp{ j }( 1 ), bp{ j }( end  ) ] );
                        end

                    end

                    [ LT, ~, ok ] = run( autoSpaceManager, LT, [  ] );
                    if ok
                        pTables( i ).info = LT;
                    end
                end
            end

            if ~isempty( pTables )

                clearMemory( obj )
                snapshot( obj );
                [ rmse, residuals ] = evaluateFeature( obj );
                clearSnapshot( obj )

                minsse = sum( residuals .^ 2 );
                totalRMSE = sqrt( minsse / length( residuals ) );
                obj.RMSE = rmse;
                obj.SimFill.RMSE = totalRMSE;
            end
        end

    end

    methods ( Access = protected )

        function obj = copyElement( obj )

            obj = copyElement@matlab.mixin.Copyable( obj );
            if ~isempty( obj.Optimizer )
                obj.Optimizer = copy( obj.Optimizer );
            end
        end

    end

    methods ( Access = private )

        function [ results, iter, errorMsg, minCost ] = mainRun( obj, fOutputFcn, iterTime, startTime, currentValues, minRMSE )










            results.rmse = obj.RMSE;
            results.residuals = [  ];
            results.active = [  ];
            results.dataSizes = [  ];

            if isnan( minRMSE )
                minRMSE = Inf;
            end
            currentRMSE = minRMSE;
            minCost = Inf;
            minValues = currentValues;
            minIter = 0;
            stopped = false;
            iter = 0;

            errorMsg = '';
            activeVariables = [  ];

            if obj.UseParallel
                fcnDerivatives = @obj.evaluateDerivativesParallel;
            else
                fcnDerivatives = @obj.evaluateDerivatives;
            end
            previousValues = currentValues;

            diffTables = NaN;
            reset( obj.Optimizer )
            minOptimizer = copy( obj.Optimizer );

            if false && strcmp( obj.Optimizer.StepUpdaterName, 'TrustRegionReflective' )

                [ OK, results, iter, minCost ] = optimize( obj, currentValues, fOutputFcn, minRMSE );
                if ~OK
                    errorMsg = 'Optimizer failed';
                end

            else

                for iterNum = 1:obj.NumIterations


                    previousOptimizer = copy( obj.Optimizer );
                    fOutputFcn( [  ], [  ], 'updatedata', results.rmse, currentRMSE, obj.Optimizer.Cost, iterNum - 1, diffTables,  ...
                        { duration( 0, 0, iterTime, 'Format', 'mm:ss' ), duration( 0, 0, toc( startTime ), 'Format', 'hh:mm:ss' ) } );
                    reset( obj.Optimizer )
                    startIter = tic;
                    [ results, stopped ] = fcnDerivatives( iterNum, fOutputFcn );

                    if stopped
                        iter = iterNum - 1;
                        break
                    end

                    currentRMSE = sqrt( sum( results.residuals .^ 2 ) / length( results.residuals ) );


                    activeVariables = results.active;

                    oldValues = currentValues;
                    [ currentValues, converged ] = solve( obj, currentValues, previousOptimizer, previousValues );
                    if converged
                        break
                    end
                    if obj.Optimizer.Cost < previousOptimizer.Cost

                        previousValues = oldValues;
                    end

                    if iterNum == 1 || obj.Optimizer.Cost < minCost

                        minRMSE = currentRMSE;
                        minOptimizer = copy( obj.Optimizer );
                        minCost = obj.Optimizer.Cost;
                        minIter = iterNum - 1;
                        minValues = previousValues;
                        minResults = results;
                    end

                    diffTables = cellfun( @( t, s )norm( t - s ), currentValues, previousValues );
                    diffTables = norm( diffTables );
                    msg = sprintf( 'Iteration %d: RMSE = %g, Change in table values = %g', iterNum, currentRMSE, diffTables );

                    stopped = fOutputFcn( [  ], [  ], 'message', msg );
                    if stopped
                        break
                    end
                    iter = iterNum;
                    iterTime = toc( startIter );
                end
                if stopped

                    setValuesInOpt( obj, previousValues )
                end
                if ~( iter == 0 || stopped ==  - 1 )


                    [ results.rmse, results.residuals ] = evaluateFinal( obj, fOutputFcn, startTime, iter );
                end

                if minCost < obj.Optimizer.Cost

                    setValuesInOpt( obj, minValues )
                    bestIterations = minIter;
                    obj.pOptimizer = minOptimizer;
                    results = minResults;
                    fOutputFcn( [  ], [  ], 'updatedata', results.rmse, minRMSE, minCost, iter, NaN,  ...
                        { duration( 0, 0, 0, 'Format', 'mm:ss' ), duration( 0, 0, toc( startTime ), 'Format', 'hh:mm:ss' ) } );
                    fOutputFcn( [  ], [  ], 'message', sprintf( 'Using best values from iteration %d', minIter ) );
                else
                    bestIterations = iter;
                end


                if stopped ==  - 1
                    errorMsg = 'Optimization cancelled';
                elseif bestIterations == 0
                    errorMsg = 'Optimization did not improve table fill';
                end
                results.active = activeVariables;
            end

        end

        function cost = postProcess( obj, fOutputFcn, results, startTime, iter, minCost )



            filler = obj.SimFill;

            updateFromCopy( obj.FillItems );

            totalRMSE = sqrt( sum( results.residuals .^ 2 ) / length( results.residuals ) );

            if ~strcmp( obj.ApproximationType, 'linear' )



                [ resultsLinear, iterTime ] = calculateActiveVariables( obj, fOutputFcn, iter );
                results.active = resultsLinear.active;

                totalRMSE = sqrt( sum( results.residuals .^ 2 ) / length( results.residuals ) );
                iter = iter + 1;
                fOutputFcn( [  ], [  ], 'updatedata', results.rmse, totalRMSE, obj.Optimizer.Cost, iter, NaN,  ...
                    { duration( 0, 0, iterTime, 'Format', 'mm:ss' ), duration( 0, 0, toc( startTime ), 'Format', 'hh:mm:ss' ) } );
                minCost = obj.Optimizer.Cost;
            end
            clearSnapshot( obj );


            filler.RMSE = totalRMSE;
            obj.RMSE = results.rmse;


            cost = filler.RMSE .^ 2;
            if obj.SimFill.SmoothingFactor > 0
                cost = [ cost, smoothingCost( obj ) ];
            end

            startMask = tic;
            [ maskMsg, changeRecommended ] = mask( obj, results.active );
            if ~isempty( maskMsg )
                iterTime = toc( startMask );

                fOutputFcn( [  ], [  ], 'breakpoints', maskMsg, changeRecommended );

                if totalRMSE ~= filler.RMSE
                    fOutputFcn( [  ], [  ], 'updatedata', obj.RMSE, filler.RMSE, minCost, iter + 1, NaN,  ...
                        { duration( 0, 0, iterTime, 'Format', 'mm:ss' ), duration( 0, 0, toc( startTime ), 'Format', 'hh:mm:ss' ) } );
                end
            end
        end


        function tableValues = initialize( obj )



            updateFolder( obj )
            F = obj.SimFill;

            ES = cgsimfill.ExpressionChain( F.Pointer );
            ES.KeepLastOnly = obj.KeepLastOnly;




            hasApproximation = any( cellfun( 'isempty', { F.Tables( 1 ).Approximation } ) );
            if obj.ApproximationType == "linear" && hasApproximation

                F.approximate( "linear", false );
            elseif obj.ApproximationType ~= "linear" && ~hasApproximation

                F.approximate( obj.ApproximationType, obj.CoefficientTables );
            end
            F.Object = set( F.Object, 'cgsimfill', F );


            ES.SimFillTables = F.Tables;

            obj.ExpressionChain = ES;

            numMaps = length( F.Tables );
            tableValues = cell( 1, numMaps + length( obj.SimFill.Constants ) );
            for i = 1:numMaps
                T = F.Tables( i );
                T.Initialize( true, true );
                tableValues{ i } = getOptimValues( T );
            end
            for i = 1:length( obj.SimFill.Constants )
                tableValues{ i + numMaps } = getOptimValues( obj.SimFill.Constants( i ) );
            end

            if isempty( obj.Optimizer )

                obj.Optimizer = cgsimfill.internal.optimizer.TableOptimizer.create( obj );
            else


                initialize( obj.Optimizer, obj )
            end

            obj.Optimizer.InitialConditions = obj.InitialConditions;

        end

        function [ rmse, residuals, dataSizes, cost ] = evaluateFeature( obj )




            dataFiles = obj.DataFiles;
            dataFolder = obj.DataFolder;
            numFiles = length( dataFiles );
            residuals = cell( numFiles, 1 );
            rmse = zeros( 1, numFiles );
            dataSizes = zeros( numFiles, 1 );
            cost = 0;
            weights = obj.Weights;
            if isempty( weights )
                weights = ones( 1, numFiles );
            end


            if obj.UseParallel

                poolConstant = parallel.pool.Constant( obj.Optimizer );
                normalizeWeights = obj.NormalizeWeights;
                parfor fileNum = 1:numFiles

                    fileName = fullfile( dataFolder, dataFiles{ fileNum } );

                    optimizer = poolConstant.Value;
                    [ rmse( fileNum ), residuals{ fileNum } ] = evaluateFeature( optimizer, fileName );
                    dataSizes( fileNum ) = length( residuals{ fileNum } );

                    dataSizes( fileNum ) = length( residuals{ fileNum } );
                    if normalizeWeights
                        cost = cost + rmse( fileNum ) ^ 2 * weights( fileNum ) / dataSizes( fileNum );
                    else
                        cost = cost + rmse( fileNum ) ^ 2 * weights( fileNum );
                    end
                end
                delete( poolConstant );

            else

                for fileNum = 1:numFiles

                    fileName = fullfile( dataFolder, dataFiles{ fileNum } );
                    [ rmse( fileNum ), residuals{ fileNum } ] = evaluateFeature( obj.Optimizer, fileName );
                    dataSizes( fileNum ) = length( residuals{ fileNum } );
                    if obj.NormalizeWeights
                        cost = cost + rmse( fileNum ) ^ 2 * weights( fileNum ) / dataSizes( fileNum );
                    else
                        cost = cost + rmse( fileNum ) ^ 2 * weights( fileNum );
                    end
                end
            end

            residuals = cat( 1, residuals{ : } );
        end

        function [ results, stopped, iterTime ] = evaluateDerivativesParallel( obj, iter, fOutputFcn, checkStop )









            arguments
                obj
                iter
                fOutputFcn
                checkStop = true;
            end
            dataFiles = obj.DataFiles;
            numFiles = length( dataFiles );

            e = cell( numFiles, 1 );
            dataSizes = zeros( numFiles, 1 );

            optimizer = obj.Optimizer;
            if strcmp( optimizer.StepUpdaterName, 'TrustRegionReflective' )
                fEvalFcn = @evaluateHessian;
            else
                fEvalFcn = @evaluateDataFile;
            end
            feFuture( 1:numFiles ) = parallel.FevalFuture;
            startTime = tic;
            reset( optimizer );
            optimizer.ExpressionChain = obj.ExpressionChain;

            poolConstant = parallel.pool.Constant( optimizer );

            for fileNum = 1:numFiles


                fileName = fullfile( obj.DataFolder, dataFiles{ fileNum } );
                feFuture( fileNum ) = parfeval( @( fileName )fEvalFcn( poolConstant.Value, fileName ), 3, fileName );
            end


            destroyJobs = onCleanup( @(  )cancel( feFuture( strcmp( { feFuture.State }, 'finished' ) ) ) );


            haveCompleted = false( 1, numFiles );
            rmse = zeros( numFiles, 1 );
            active = cell( 1, numFiles );
            for fileNum = 1:numFiles

                [ completedIdx, fileOptimizer, evalTime, totalLength ] = fetchNext( feFuture );

                e{ completedIdx } = fileOptimizer.Residuals;
                haveCompleted( completedIdx ) = true;

                n = length( fileOptimizer.Residuals );
                dataSizes( completedIdx ) = n;
                rmse( completedIdx ) = sqrt( sum( e{ completedIdx } .^ 2 ) / n );


                wmap = obj.Weights( completedIdx );
                if obj.NormalizeWeights
                    wmap = wmap / n;
                end
                accumulate( optimizer, fileOptimizer, wmap );

                active{ completedIdx } = fileOptimizer.Active;
                ng = fileOptimizer.NormGradient;



                msg = sprintf( 'File %d, RMSE=%g: %s, %d points, %smin',  ...
                    completedIdx, rmse( completedIdx ), dataFiles{ completedIdx },  ...
                    totalLength, duration( 0, 0, evalTime, 'Format', 'mm:ss' ) );
                stopped = fOutputFcn( [  ], [  ],  ...
                    'updatepoint', [ completedIdx, rmse( completedIdx ), ng > 1e8 * n ],  ...
                    [ iter, fileNum, numFiles ],  ...
                    msg );
                if checkStop && stopped

                    cancel( feFuture );
                    break
                end
            end
            active = any( cat( 1, active{ : } ), 1 );

            e = cat( 1, e{ : } );
            results.residuals = e;
            results.rmse = rmse;
            results.active = active;
            results.dataSizes = dataSizes;

            iterTime = toc( startTime );
            msg = sprintf( 'Iteration %d time: %smin', iter, duration( 0, 0, iterTime, 'Format', 'mm:ss' ) );
            stopped = fOutputFcn( [  ], [  ], 'message', msg );

            delete( poolConstant );
        end

        function [ results, stopped, iterTime ] = evaluateDerivatives( obj, iter, fOutputFcn, checkStop )









            arguments
                obj
                iter
                fOutputFcn
                checkStop = true;
            end

            dataFiles = obj.DataFiles;
            numFiles = length( dataFiles );

            residuals = cell( numFiles, 1 );
            dataSizes = zeros( numFiles, 1 );


            startTime = tic;
            optimizer = obj.Optimizer;
            reset( optimizer )

            fileOptimizer = copy( optimizer );

            if strcmp( optimizer.StepUpdaterName, 'TrustRegionReflective' )
                fEvalFcn = @( fileOptimizer, fileName )evaluateHessian( fileOptimizer, fileName, fOutputFcn );
            else
                fEvalFcn = @evaluateDataFile;
            end


            rmse = zeros( numFiles, 1 );
            active = cell( 1, numFiles );
            for fileNum = 1:numFiles

                fileName = fullfile( obj.DataFolder, dataFiles{ fileNum } );

                [ fileOptimizer, evalTime, totalLength ] = fEvalFcn( fileOptimizer, fileName );
                residuals{ fileNum } = fileOptimizer.Residuals;

                n = length( residuals{ fileNum } );
                dataSizes( fileNum ) = n;
                rmse( fileNum ) = sqrt( sum( residuals{ fileNum } .^ 2 ) / n );


                if isempty( obj.Weights )
                    wmap = 1;
                else
                    wmap = obj.Weights( fileNum );
                    if obj.NormalizeWeights
                        wmap = wmap / n;
                    end
                end

                accumulate( optimizer, fileOptimizer, wmap );

                active{ fileNum } = fileOptimizer.Active;

                ng = fileOptimizer.NormGradient;


                msg = sprintf( 'File %d, RMSE=%g: %s, %d points, %smin',  ...
                    fileNum, rmse( fileNum ), dataFiles{ fileNum },  ...
                    totalLength, duration( 0, 0, evalTime, 'Format', 'mm:ss' ) );
                stopped = fOutputFcn( [  ], [  ],  ...
                    'updatepoint', [ fileNum, rmse( fileNum ), ng > 1e8 * n ],  ...
                    [ iter, fileNum, numFiles ],  ...
                    msg );
                if checkStop && stopped

                    break
                end

            end



            active = any( cat( 1, active{ : } ), 1 );

            residuals = cat( 1, residuals{ : } );
            results.residuals = residuals;
            results.rmse = rmse;
            results.active = active;
            results.dataSizes = dataSizes;

            iterTime = toc( startTime );
            msg = sprintf( 'Iteration %d time: %s', iter, duration( 0, 0, iterTime, 'Format', 'mm:ss' ) );
            stopped = fOutputFcn( [  ], [  ], 'message', msg );

        end

        function calculateWeights( obj, rmse, dataSizes )




            if obj.NormalizeWeights

                err_sq = rmse( : ) .^ 2;
            else

                err_sq = rmse( : ) .^ 2 .* dataSizes( : );
            end
            max_err_sq = max( err_sq );
            sum_error_sq = sum( err_sq );
            numFiles = length( obj.DataFiles );
            mean_err_sq = sum_error_sq / numFiles;
            data_file_w = ones( numFiles, 1 );
            if numFiles > 1 && any( max_err_sq > mean_err_sq )
                needsWeights = err_sq >= mean_err_sq;
                data_file_w( needsWeights ) = obj.WeightFactor - ( obj.WeightFactor - 1 ) * ( max_err_sq - err_sq( needsWeights ) ) / ( max_err_sq - mean_err_sq );
            end


            obj.Weights = data_file_w / sum( data_file_w );
        end

        function [ maskMsg, changeRecommended ] = mask( obj, active )



            tables = obj.SimFill.Tables;
            startIndex = 1;
            warningTables = false( 1, length( tables ) );
            zeroTables = warningTables;
            for mapNum = 1:length( tables )
                n = numel( tables( mapNum ).Indices );
                maskValues = active( startIndex:startIndex + n - 1 );

                startIndex = startIndex + n;
                LT = tables( mapNum ).Object;
                vals = get( LT, 'values' );
                if numel( vals ) ~= numel( maskValues )

                    allMask = false( 1, numel( vals ) );
                    allMask( tables( mapNum ).Indices ) = maskValues;
                    maskValues = allMask;
                end


                maskValues = reshape( full( maskValues ), size( vals ) );
                if nnz( maskValues ) == 0

                    zeroTables( mapNum ) = true;
                elseif nnz( any( maskValues, 1 ) ) < 0.5 * size( maskValues, 2 ) ||  ...
                        nnz( any( maskValues, 2 ) ) < 0.5 * size( maskValues, 1 )
                    warningTables( mapNum ) = true;
                end



                LT = clearExtrapolationMask( LT );
                LT = addToExtrapolationMask( LT, maskValues );
                tables( mapNum ).Object = LT;
            end
            if any( zeroTables )

                problemTables = { tables( zeroTables ).Name };
                maskMsg = sprintf( 'Lookup table(s) %s have no affected cells. Consider adjusting the initial values of the lookup tables (for example, to a nonzero value).',  ...
                    strjoin( problemTables, ',' ) );
            else
                maskMsg = '';
            end
            if any( warningTables )


                changeRecommended = true;
                obj.ToAdjustBreakpoints = [ tables( warningTables ).Pointer ];
                problemTables = { tables( warningTables ).Name };
                maskMsg = sprintf( '%sBreakpoints for lookup table(s) %s may need adjusting. Do you want to automatically update the breakpoints?', maskMsg, strjoin( problemTables, ',' ) );
            else
                changeRecommended = true;
                obj.ToAdjustBreakpoints = mbcpointer( 0 );
                maskMsg = '';
            end
        end

        function [ newValues, converged ] = solve( obj, currentValues, previousOptimizer, previousValues )



            Aw = smoothingFactor( obj );
            [ newValues, converged ] = solve( obj.Optimizer, currentValues, Aw, previousOptimizer, previousValues );


            setValuesInOpt( obj, newValues )
        end

        function cost = smoothingCost( obj, normalize )


            arguments
                obj
                normalize = true;
            end
            F = obj.SimFill;
            cost = 0;
            N = 0;
            for mapNum = 1:length( F.Tables )
                T = F.Tables( mapNum );
                if ~isempty( T.Approximation )
                    b = T.Approximation.Coefficients;
                else
                    vals = get( T.Object, 'values' );
                    b = vals( T.Indices );
                end
                [ Alaplace, Claplace ] = smoothingConstraint( T );

                s = Alaplace * b( : ) - Claplace;
                cost = cost + s' * s;
                N = N + length( b );
            end
            if normalize
                cost = cost / N;
            end
        end










































































































































        function [ results, iterTime ] = calculateActiveVariables( obj, fOutputFcn, iter )



            fOutputFcn( [  ], [  ], 'message', 'Recalculating affected lookup table cells' );





            clearSnapshot( obj );
            obj.ExpressionChain.SimFillTables = cgsimfill.Table.empty;
            snapshot( obj );
            if obj.UseParallel
                fcnDerivatives = @obj.evaluateDerivativesParallel;
            else
                fcnDerivatives = @obj.evaluateDerivatives;
            end
            [ results, ~, iterTime ] = fcnDerivatives( iter, fOutputFcn, false );
        end

        function [ rmse, residuals, totalRMSE, cost ] = evaluateFinal( obj, fOutputFcn, startTime, iter )


            fOutputFcn( [  ], [  ], 'message', 'Evaluating final iteration' );

            startIter = tic;
            [ rmse, residuals, ~, cost ] = evaluateFeature( obj );

            cost = cost + smoothingCost( obj, false );
            obj.Optimizer.Cost = cost;

            iterTime = toc( startIter );
            totalRMSE = sqrt( sum( residuals .^ 2 ) / length( residuals ) );
            fOutputFcn( [  ], [  ], 'updatedata', rmse, totalRMSE, cost, iter, NaN,  ...
                { duration( 0, 0, iterTime, 'Format', 'mm:ss' ), duration( 0, 0, toc( startTime ), 'Format', 'hh:mm:ss' ) } );
        end

        function setValuesInOpt( obj, values )




            fillItems = obj.FillItems;
            for j = 1:length( fillItems )
                T = fillItems( j );
                setValuesInOpt( T, values{ j } );
            end
        end

        function snapshot( obj )

            snapshot( obj.ExpressionChain );
            snapshot( obj.FillItems )
        end

        function clearSnapshot( obj )

            clearSnapshot( obj.ExpressionChain );
            clearSnapshot( obj.FillItems )
        end

        function Aw = smoothingFactor( obj )

            F = obj.SimFill;

            fillItems = obj.FillItems;
            numItems = length( fillItems );
            if F.SmoothingFactor > 0

                As = cell( 1, numItems );
                for mapNum = 1:numItems
                    [ As{ mapNum }, Claplace, Aeq, Ceq ] = smoothingConstraint( fillItems( mapNum ) );%#ok<ASGLU>

                end
                lambda = F.FeatureScale * F.SmoothingFactor;
                Aw = cellfun( @( As )lambda * As, As, 'UniformOutput', false );
            else

                Aw = cell( 1, numItems );
            end
        end

    end

    methods ( Static )
        function obj = loadobj( LS, obj )

            if isstruct( LS ) && ~isempty( obj )

                obj.CoefficientTables = LS.ChebyshevTables;
                if LS.pChebyshevApproximation
                    obj.pApproximationType = 'chebyshev';
                end
            else
                obj = LS;
            end
        end
    end

end


