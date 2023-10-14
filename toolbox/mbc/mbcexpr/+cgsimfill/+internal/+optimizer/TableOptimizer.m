classdef TableOptimizer < cgsimfill.internal.optimizer.OptimizerInterface

    properties

        StepUpdaters

        Active

        Residuals

        ItemsToDifferentiate

        InitialWindow

        ReferenceVariable

        ExpressionChain

        InitialConditions
    end

    properties ( Dependent, SetAccess = private )
        StepUpdaterName
    end

    methods

        function n = get.StepUpdaterName( obj )

            if isempty( obj.StepUpdaters )
                n = '';
            else
                n = obj.StepUpdaters( 1 ).Name;
            end
        end

        function [ obj, evalTime, totalLength ] = evaluateDataFile( obj, dataFile )




            startTime = tic;
            data = readtable( dataFile );
            if ~isempty( obj.InitialConditions )
                setInitialConditions( obj.ExpressionChain, obj.InitialConditions, data )
            end


            [ yf, dy ] = evaluate( obj.ExpressionChain, data, true, obj.ItemsToDifferentiate );
            y = data.( obj.ReferenceVariable );
            totalLength = length( y );
            if obj.ExpressionChain.KeepLastOnly
                y = y( end  );
            end
            e = y - yf;
            if obj.InitialWindow > 0

                e = e( obj.InitialWindow + 1:end  );
                for i = 1:length( dy )
                    dy{ i } = dy{ i }( obj.InitialWindow + 1:end , : );
                end
            end

            obj.Residuals = e;
            obj.ExpressionChain.Simulator = [  ];
            leastSquaresGradients( obj, dy, e );
            evalTime = toc( startTime );
        end

        function [ rmse, residuals ] = evaluateFeature( obj, dataFile )


            data = readtable( dataFile );
            if ~isempty( obj.InitialConditions )
                setInitialConditions( obj.ExpressionChain, obj.InitialConditions, data )
            end
            yf = evaluate( obj.ExpressionChain, data );
            y = data.( obj.ReferenceVariable );
            if obj.ExpressionChain.KeepLastOnly
                y = y( end  );
            end

            dataSize = length( y );
            residuals = y - yf;
            rmse = sqrt( sum( residuals .^ 2 / dataSize ) );

        end

        function [ obj, evalTime, totalLength ] = evaluateHessian( obj, dataFile, fOutputFcn )


            arguments
                obj
                dataFile
                fOutputFcn = [  ];
            end


            startTime = tic;
            data = readtable( dataFile );
            if ~isempty( obj.InitialConditions )
                setInitialConditions( obj.ExpressionChain, obj.InitialConditions, data )
            end


            s = cgsimfill.internal.expressions.Simulator.dynamicChain( obj.ExpressionChain, data,  ...
                obj.ItemsToDifferentiate, obj.ReferenceVariable, 2 );

            s.fOutputFcn = fOutputFcn;

            [ c2, gy, Hy, yf ] = simHessian( s );
            y = data.( obj.ReferenceVariable );
            totalLength = length( y );
            if obj.ExpressionChain.KeepLastOnly
                y = y( end  );
                yf = yf( end  );
            end
            e = y - yf;
            if obj.InitialWindow > 0

                e = e( obj.InitialWindow + 1:end  );
            end

            obj.Residuals = e;

            leastSquaresGradients( obj, c2, gy, Hy );
            evalTime = toc( startTime );

        end

        function reset( obj )



            for mapNum = 1:length( obj.StepUpdaters )
                reset( obj.StepUpdaters( mapNum ) )
            end
            obj.Cost = 0;
            obj.Residuals = [  ];
        end

        function clearMemory( obj )


            for i = 1:length( obj.StepUpdaters )
                clearMemory( obj.StepUpdaters( i ) )
            end

        end

        function ok = hasMemory( obj )




            ok = false;
            for i = 1:length( obj.StepUpdaters )

                ok = ok || hasMemory( obj.StepUpdaters( i ) );
            end

        end


    end

    methods ( Access = protected )

        function obj = copyElement( obj )

            obj = copyElement@matlab.mixin.Copyable( obj );
            obj.StepUpdaters = copy( obj.StepUpdaters );
        end
    end

    methods ( Abstract )
        initialize( obj, LS )


    end

    methods ( Static )

        function obj = create( LS, Type )



            arguments
                LS( 1, 1 )cgsimfill.LargeScaleOptimization
                Type = "ADAM"
            end

            stepUpdater = cgsimfill.internal.optimizer.StepUpdater.create( Type );
            LS.StepSize = stepUpdater.LearningRate;

            if LS.OptimizeAll

                obj = cgsimfill.internal.optimizer.OptimizerAllItems( stepUpdater, LS.SimFill );
            else

                obj = cgsimfill.internal.optimizer.OptimizerPerItem( stepUpdater, LS.SimFill );
            end

            initialize( obj, LS )
        end

    end

end

