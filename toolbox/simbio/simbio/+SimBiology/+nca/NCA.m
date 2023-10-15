classdef NCA




    properties ( Hidden = true )
        DataSet
        Options SimBiology.nca.Options

        Lambda_Z_Time_Min_Max
        PartialAreas
        C_max_usr
        T_max_usr

        results
    end

    methods
        function obj = NCA( data, options )
            if isa( data, 'dataset' )
                data = dataset2table( data );
            end

            obj.DataSet = data;
            obj.Options = options;

            obj = validateDataAndOptions( obj );
        end

        function [ NCAParams, errorMsgs, obj ] = run( obj )
            errorMsgs = {  };



            [ groups, groupIndex ] = getUniqueGroups( obj );


            dosingRegimen = getDosingRegimen( obj, groups );

            if isempty( dosingRegimen )

            end


            if size( obj.Options.Lambda_Z_Time_Min_Max, 1 ) == 1

                obj.Lambda_Z_Time_Min_Max = repmat( obj.Options.Lambda_Z_Time_Min_Max, size( groups, 1 ), 1 );
            else

                if size( obj.Options.Lambda_Z_Time_Min_Max, 1 ) ~= size( groups, 1 )
                    error( 'SimBiology:NCA:Lambda_Z_TimeRange', 'Wrong number of rows for Lambda_Z_Time_Min_Max' );
                end
                obj.Lambda_Z_Time_Min_Max = obj.Options.Lambda_Z_Time_Min_Max;
            end




            if size( obj.Options.PartialAreas, 1 ) == 1
                obj.PartialAreas = repmat( obj.Options.PartialAreas, size( groups, 1 ), 1 );
            else
                obj.PartialAreas = obj.Options.PartialAreas;
            end




            if size( obj.Options.C_max_ranges, 1 ) == 1
                obj.C_max_usr = repmat( obj.Options.C_max_ranges, size( groups, 1 ), 1 );
            else
                obj.C_max_usr = obj.Options.C_max_ranges;
            end




            for j = 1:numel( obj.Options.concentrationColumnName )


                profileIndex = ~isnan( obj.DataSet.( obj.Options.concentrationColumnName( j ) ) );

                for i = 1:size( groups, 1 )
                    try
                        [ groupDosing, dosingColumn, doseCount, doseAdministration, exception ] = getGroupDosing( obj, dosingRegimen, groups( i, : ) );



                        rec = SimBiology.nca.internal.NCAParameters( doseCount, doseAdministration );



                        rec.doseSchedule = char( doseCount );
                        rec.administrationRoute = char( doseAdministration );

                        if ~isempty( exception )
                            throw( exception );
                        end

                        [ time, conc, errorMsgs ] = extractProfile( obj, obj.Options.concentrationColumnName( j ), profileIndex & groupIndex == i, errorMsgs, groups, i );




                        timeOffset = groupDosing.( obj.Options.timeColumnName )( 1 );
                        time = time - timeOffset;
                        groupDosingTimes = groupDosing.( obj.Options.timeColumnName ) - timeOffset;


                        conc( conc < obj.Options.LOQ ) = 0;



                        dose = groupDosing.( dosingColumn )( end  );

                        if doseAdministration == SimBiology.nca.AdministrationRoute.IVInfusion
                            rate = groupDosing.( obj.Options.infusionRateColumnName )( end  );
                        else
                            rate = [  ];
                        end

                        idx = isnan( groupDosing.( obj.Options.concentrationColumnName( j ) ) );
                        needsExtrap = any( idx );

                        switch doseCount
                            case SimBiology.nca.internal.DoseSchedule.Multiple
                                [ errorMsgs, rec ] = SimBiology.nca.NCA.multipleDoseParameters( rec, time, conc, dose, rate, errorMsgs, needsExtrap, groupDosingTimes, groups( i, : ), obj.Options.TAU, obj.Lambda_Z_Time_Min_Max( i, : ), obj.PartialAreas( i, : ), obj.C_max_usr( i, : ) );

                                rec.DM = groupDosing.( dosingColumn )( end  );
                                rec.doseCountParams.T_min = rec.doseCountParams.T_min + timeOffset;

                            case SimBiology.nca.internal.DoseSchedule.Single
                                [ errorMsgs, rec ] = SimBiology.nca.NCA.singleDoseParameters( rec, time, conc, dose, rate, errorMsgs, needsExtrap, obj.Lambda_Z_Time_Min_Max( i, : ), obj.PartialAreas( i, : ), obj.C_max_usr( i, : ) );

                                rec.DM = groupDosing.( dosingColumn );
                        end








                        rec.T_max = rec.T_max + timeOffset;
                        rec.Tlast = rec.Tlast + timeOffset;



                        rec.responseName = obj.Options.concentrationColumnName( j );

                        obj = obj.addRecord( rec, groups( i, : ) );
                    catch me
                        obj = obj.addRecord( rec, groups( i, : ) );
                        errorMsgs{ end  + 1 } = me.message;
                        continue
                    end
                end
            end

            d = [ obj.results.records ];
            g = vertcat( obj.results.grouping );

            NCAParams = table( g( :, 1 ), 'VariableNames', { obj.Options.groupColumnName } );
            if size( g, 2 ) == 2
                NCAParams.( obj.Options.idColumnName ) = g( :, 2 );
            end

            NCAParams = horzcat( NCAParams, d.getTable );


            if numel( obj.Options.concentrationColumnName ) == 1
                NCAParams.responseName = [  ];
            end
        end
    end

    methods ( Access = private )


        function obj = validateDataAndOptions( obj )



            if ~isa( obj.Options, 'SimBiology.nca.Options' )
                error( message( 'SimBiology:NCA:InvalidSignature' ) );
            end



            if isa( obj.DataSet, 'table' ) && numel( obj.Options.concentrationColumnName ) > 1
                error( message( 'SimBiology:NCA:InvalidConcentrationColumnName' ) );
            end





            if isa( obj.DataSet, 'struct' )
                [ obj.DataSet, obj.Options ] = SimBiology.nca.internal.dataFromSD( obj.DataSet, obj.Options );
            end


            if isempty( obj.Options.groupColumnName )

                obj.Options.groupColumnName = matlab.lang.makeUniqueStrings( 'GROUP', obj.DataSet.Properties.VariableNames );
                obj.DataSet.( obj.Options.groupColumnName ) = ones( height( obj.DataSet ), 1 );



                if ~isempty( obj.Options.idColumnName )
                    error( message( 'SimBiology:NCA:InvalidGroupSpecification' ) );
                end
            end


            obj.DataSet.( obj.Options.groupColumnName ) = categorical( obj.DataSet.( obj.Options.groupColumnName ) );

            if ~isempty( obj.Options.idColumnName )
                obj.DataSet.( obj.Options.idColumnName ) = categorical( obj.DataSet.( obj.Options.idColumnName ) );
            end

            if isempty( obj.Options.IVDoseColumnName ) && isempty( obj.Options.EVDoseColumnName )
                msgID = 'SimBiology:NCA:NoDoseVar';
                errorMsg = SimBiology.nca.NCA.getErrorMessage( msgID );
                error( msgID, errorMsg );
            end



            if obj.Options.AdministrationRoute == SimBiology.nca.AdministrationRoute.IVInfusion
                if isempty( obj.Options.infusionRateColumnName )
                    error( message( 'SimBiology:NCA:NoInfusionRateColumn' ) );
                end
            end

            if isempty( obj.Options.independentVariableColumnName )
                error( message( 'SimBiology:NCA:NoIndependentVar' ) );
            end


            if any( obj.Options.concentrationColumnName == "" )
                error( message( 'SimBiology:NCA:NoConcVar' ) );
            end

            if ~ismember( obj.Options.concentrationColumnName, string( obj.DataSet.Properties.VariableNames ) );
                error( message( 'SimBiology:NCA:InvalidConcentrationColumnNameValue' ) )
            end





            for j = 1:numel( obj.Options.concentrationColumnName )
                concentrationColumnName = obj.Options.concentrationColumnName( j );
                if isa( obj.DataSet.( concentrationColumnName ), 'cell' )
                    originalLength = numel( obj.DataSet.( concentrationColumnName ) );
                    obj.DataSet.( concentrationColumnName ) = str2double( obj.DataSet.( concentrationColumnName ) );
                    if originalLength ~= numel( obj.DataSet.( concentrationColumnName ) )
                        error( 'SimBiology:NCA:InvalidConcentrationVar', 'Concentration data is not numeric or not convetible to numeric' );
                    end
                end
            end









        end

        function [ groupDosing, dosingColumn, doseCount, doseAdministration, exception ] = getGroupDosing( obj, dosingRegimen, group )

            groupDosing_i = dosingRegimen.( obj.Options.groupColumnName ) == group( 1, 1 );

            ivdosingTF = ~isempty( obj.Options.IVDoseColumnName ) && ~all( isnan( dosingRegimen.( obj.Options.IVDoseColumnName )( groupDosing_i ) ) );
            scdosingTF = ~isempty( obj.Options.EVDoseColumnName ) && ~all( isnan( dosingRegimen.( obj.Options.EVDoseColumnName )( groupDosing_i ) ) );


            ivinfusionTF = false;
            if ismember( string( obj.Options.infusionRateColumnName ), string( dosingRegimen.Properties.VariableNames ) )
                ivinfusionTF = ivdosingTF && ~isempty( obj.Options.infusionRateColumnName ) && ~all( isnan( dosingRegimen.( obj.Options.infusionRateColumnName )( groupDosing_i ) ) );
            end

            dosingColumn = '';
            if ivdosingTF && scdosingTF
                msgID = 'SimBiology:NCA:InvalidDoseAmount';
                errorMsg = SimBiology.nca.NCA.getErrorMessage( msgID, char( group( 1 ) ) );
                exception = MException( msgID, errorMsg );
                groupDosing = [  ];
                dosingColumn = nan;
                doseCount = nan;
                doseAdministration = nan;
                return ;

            elseif ~ivdosingTF && ~scdosingTF

                msgID = 'SimBiology:NCA:InvalidDoseAmount';
                errorMsg = SimBiology.nca.NCA.getErrorMessage( msgID, char( group( 1 ) ) );
                exception = MException( msgID, errorMsg );
                groupDosing = [  ];
                dosingColumn = nan;
                doseCount = nan;
                doseAdministration = nan;
                return ;

            else
                if ivdosingTF
                    dosingColumn = obj.Options.IVDoseColumnName;
                elseif scdosingTF
                    dosingColumn = obj.Options.EVDoseColumnName;
                end
            end


            equalTime = all( dosingRegimen.( obj.Options.timeColumnName )( groupDosing_i ) == dosingRegimen.( obj.Options.timeColumnName )( find( groupDosing_i, 1 ) ) );


            if equalTime
                equalDosing = all( dosingRegimen.( dosingColumn )( groupDosing_i ) == dosingRegimen.( dosingColumn )( find( groupDosing_i, 1 ) ) );
                if equalDosing
                    groupDosing = dosingRegimen( find( groupDosing_i, 1 ), : );
                else




                    groupDosing = dosingRegimen( groupDosing_i, : );
                end
            else
                groupDosing = table.empty;
                tmp = dosingRegimen( groupDosing_i, : );

                times = dosingRegimen.( obj.Options.timeColumnName )( groupDosing_i );
                unique_times = unique( times );
                for unique_times_i = 1:numel( unique_times )
                    commonTimeDosing = dosingRegimen.( obj.Options.timeColumnName )( groupDosing_i ) == unique_times( unique_times_i );
                    if sum( commonTimeDosing ) > 1
                        dosingToConsider = dosingRegimen.( obj.Options.timeColumnName )( groupDosing_i );

                        sampleDosing = find( commonTimeDosing );
                        equalDosing = all( dosingToConsider( commonTimeDosing ) == dosingToConsider( sampleDosing( 1 ) ) );
                        if equalDosing

                            groupDosing( end  + 1, : ) = tmp( find( commonTimeDosing, 1 ), : );
                        end
                    else
                        groupDosing( end  + 1, : ) = tmp( commonTimeDosing, : );
                    end
                end
            end


            if height( groupDosing ) == 1
                doseCount = SimBiology.nca.internal.DoseSchedule.Single;
            elseif height( groupDosing ) > 1
                doseCount = SimBiology.nca.internal.DoseSchedule.Multiple;
            end





            if ivinfusionTF
                doseAdministration = SimBiology.nca.AdministrationRoute.IVInfusion;
            elseif ivdosingTF
                doseAdministration = SimBiology.nca.AdministrationRoute.IVBolus;
            elseif scdosingTF
                doseAdministration = SimBiology.nca.AdministrationRoute.ExtraVascular;
            end


            exception = [  ];
            dosingValues = groupDosing.( dosingColumn );
            if any( ~isnumeric( dosingValues ) ) ||  ...
                    any( dosingValues <= 0 ) ||  ...
                    any( ~isreal( dosingValues ) ) ||  ...
                    any( ~isfinite( dosingValues ) )

                msgID = 'SimBiology:NCA:InvalidDoseAmount';
                errorMsg = SimBiology.nca.NCA.getErrorMessage( msgID, char( group( 1 ) ) );
                exception = MException( msgID, errorMsg );

            end
        end

        function obj = addRecord( obj, record, grouping )
            obj.results( end  + 1 ).grouping = grouping;
            obj.results( end  ).records = record;
        end

        function [ uniqueGroups, groupIndex ] = getUniqueGroups( obj )
            if ~isempty( obj.Options.groupColumnName )
                groups = obj.DataSet.( obj.Options.groupColumnName );
            end


            if ~isempty( obj.Options.idColumnName ) && obj.Options.SparseData == false
                groups = [ groups, obj.DataSet.( obj.Options.idColumnName ) ];
            end



            if size( groups, 2 ) == 2

                undefinedRows = sum( isundefined( obj.DataSet.( obj.Options.idColumnName ) ), 2 ) > 0;
                groups( undefinedRows, 2 ) = groups( find( undefinedRows ) + 1, 2 );
            end






            [ uniqueGroups, ~, groupIndex ] = unique( groups, 'rows' );
        end

        function [ timeOfInfusion, errorMsgs ] = getTimeOfInfusion( obj, groupIdx, time, dose, doseTime, errorMsgs, currentGroup )
            timeOfInfusion = 0;
            if obj.Options.DoseType == SimBiology.nca.internal.DoseType.IVInfusion
                infusionRate = obj.DataSet.( obj.InfusionRateColumn )( groupIdx );
                doseIndex = ( time == doseTime );
                infusionRate = infusionRate( doseIndex );
                assert( isscalar( infusionRate ) );
                if ~isnumeric( infusionRate ) || infusionRate <= 0 || ~isreal( infusionRate ) || ~isfinite( infusionRate )
                    errorMsgs{ end  + 1 } = SimBiology.nca.NCA.getErrorMessage( 'SimBiology:NCA:InvalidInfusionRate', char( currentGroup( end  ) ) );
                    infusionRate = nan;
                end
                timeOfInfusion = dose / infusionRate;
            end
        end

        function baseUnits = getDataSetUnits( obj )
            units = obj.DataSet.Properties.VariableUnits;

            baseUnits.concUnit = '';
            baseUnits.timeUnit = '';
            baseUnits.doseUnit = '';
            baseUnits.volumeUnit = '';

            if ~isempty( units ) && ~all( strcmp( '', units ) )
                varNames = obj.DataSet.Properties.VariableNames;
                timeUnit = units( strcmp( obj.Options.timeColumnName, varNames ) );
                baseUnits.timeUnit = timeUnit{ 1 };

                concUnit = units( strcmp( obj.Options.concentrationColumnName, varNames ) );
                concUnit = concUnit{ 1 };
                baseUnits.concUnit = concUnit;

                doseUnit = units( strcmp( obj.Options.doseColumnName, varNames ) );
                doseUnit = doseUnit{ 1 };
                baseUnits.doseUnit = doseUnit;


                if ~isempty( concUnit ) && ~isempty( timeUnit ) && ~isempty( doseUnit )
                    if strcmp( concUnit, 'molarity' )
                        concUnit = 'mole/liter';
                    end
                    volumeUnit = regexp( concUnit, '/', 'split' );
                    volumeUnit = volumeUnit{ 2 };

                    baseUnits.volumeUnit = volumeUnit;
                end
            end
        end


        function doseTable = getDosingRegimen( obj, groups )

            doseIdx = false( height( obj.DataSet ), 1 );



            if ~isempty( obj.Options.IVDoseColumnName )
                doseIdx = doseIdx | ( ~isnan( obj.DataSet.( obj.Options.IVDoseColumnName ) ) & obj.DataSet.( obj.Options.IVDoseColumnName ) ~= 0 );
            end

            if ~isempty( obj.Options.EVDoseColumnName )
                doseIdx = doseIdx | ( ~isnan( obj.DataSet.( obj.Options.EVDoseColumnName ) ) & obj.DataSet.( obj.Options.EVDoseColumnName ) ~= 0 );
            end

            doseTable = obj.DataSet( doseIdx, : );


            if height( doseTable ) == 1

                doseTable = repmat( doseTable, size( groups, 1 ), 1 );
            end
        end

        function [ time, conc, errorMsgs ] = extractProfile( obj, profileName, profileIndicator, errorMsgs, groups, i )
            time = obj.DataSet.( obj.Options.timeColumnName )( profileIndicator );
            conc = obj.DataSet.( profileName )( profileIndicator );

            if obj.Options.SparseData
                [ time, conc ] = SimBiology.nca.NCA.handleSparseSamplingNEW( time, conc );
            end


            if numel( conc ) < 2
                errorMsg = SimBiology.nca.NCA.getErrorMessage( 'SimBiology:NCA:TooFewObservations', char( groups( i, 1 ) ) );
                me = MException( 'SimBiology:NCA:TooFewObservations', errorMsg );
                throw( me );
            end


            if numel( unique( time ) ) ~= numel( time )
                msgID = 'SimBiology:NCA:NonUniqueTimes';
                errorMsg = SimBiology.nca.NCA.getErrorMessage( msgID, char( groups( i, 1 ) ) );
                me = MException( msgID, errorMsg );
                throw( me );
            end

            if ~issorted( time ) || ~isnumeric( time ) || ~isreal( time ) || any( time < 0 ) || ~all( isfinite( time ) )
                msgID = 'SimBiology:NCA:InvalidTimeColumn';
                errorMsg = SimBiology.nca.NCA.getErrorMessage( msgID, char( groups( i, 1 ) ) );
                me = MException( msgID, errorMsg );
                throw( me );
            end
        end
    end

    methods ( Static )




        function auc = computeAuc( time, conc, tstart, tend )

            assert( any( time == tstart ) );
            assert( any( time == tend ) );
            if isempty( time ) || length( conc ) < 2 || isnan( tstart ) || isnan( tend )
                auc = NaN;
            else
                endIdx = find( time == tend );
                x = time( 1:endIdx );
                y = conc( 1:endIdx );

                startIdx = find( time == tstart );
                x = x( startIdx:end  );
                y = y( startIdx:end  );
                auc = trapz( x, y );
            end
        end



        function auc = computeAUC_ArbitraryTimes( time, conc, tstart, tend )
            activeIndex = time >= tstart & time <= tend;

            if sum( activeIndex ) > 1
                auc = trapz( time( activeIndex ), conc( activeIndex ) );
            else
                auc = nan;
            end
        end




        function [ lambda_Z, R2, nPoints, adjusted_R2 ] = calculateLambdaZBounds( time, conc, timeBounds )

            timeRange = time >= timeBounds( 1 ) & time <= timeBounds( 2 );
            activeTime = time( timeRange );
            activeConc = log( conc( timeRange ) );

            nPoints = numel( activeTime );



            [ b, ~, ~, ~, stats ] = regress( activeConc, [ ones( nPoints, 1 ), activeTime ] );
            lambda_Z =  - b( 2 );

            R2 = stats( 1 );
            adjusted_R2 = 1 - ( ( 1 - R2 ) * ( nPoints - 1 ) / ( nPoints - 2 ) );
        end










        function [ best_lambda_Z, max_R2, nPoints, maxAdjusted_R2, debugData ] = calculateLambdaZ( time, conc )






            [ ~, i ] = max( conc );
            timeTerminal = time( i:end  );
            concTerminal = conc( i:end  );

            nonZeros = concTerminal ~= 0;
            timeTerminal = timeTerminal( nonZeros );
            concTerminal = concTerminal( nonZeros );

            npts = 3;
            nTerminalPoints = numel( concTerminal );
            logConcTerminal = log( concTerminal );

            if nTerminalPoints < npts


                maxAdjusted_R2 = NaN;
                max_R2 = NaN;
                nPoints = NaN;
                best_lambda_Z = NaN;
            else









                testEqualTerminalValues = logConcTerminal == logConcTerminal( end  );




                if all( testEqualTerminalValues( end  - npts + 1:end  ) ) == true
                    firstNonConstantValue = find( flipud( testEqualTerminalValues == false ), 1 );

                    if isempty( firstNonConstantValue )
                        numConstantPts = numel( logConcTerminal );
                    else
                        numConstantPts = firstNonConstantValue - 1;
                    end


                    data = repmat( [ 1, 1, inf, 0, NaN ], numConstantPts - npts + 1, 1 );
                    data( :, 3 ) = ( npts:numConstantPts )';
                    npts = numConstantPts + 1;
                end





                for n = npts:nTerminalPoints
                    y = logConcTerminal( end  - n + 1:end  );

                    x = [ ones( n, 1 ), timeTerminal( end  - n + 1:end  ) ];

                    [ b, ~, ~, ~, stats ] = regress( y, x );
                    lambdaZ =  - b( 2 );
                    intercept = b( 1 );
                    R2 = stats( 1 );
                    adjR2 = 1 - ( ( 1 - R2 ) * ( n - 1 ) / ( n - 2 ) );

                    runningIndex = n - npts + 1;
                    data( runningIndex, : ) = [ adjR2, R2, n, lambdaZ, intercept ];
                end


                debugData = array2table( data, 'VariableNames', { 'AdjR2', 'R2', 'n', 'lambdaZ', 'intercept' } );


                debug = false;
                if debug
                    ax1 = subplot( 311 );
                    plot( ax1, timeTerminal, logConcTerminal, 'o' );
                    title( 'Data' );
                    ax2 = subplot( 312 );
                    plot( ax2, 3:3 + height( debugData ) - 1, debugData.AdjR2, 's' );
                    title( 'AdjR2' );
                    ax3 = subplot( 313 );
                    plot( ax3, 4:3 + height( debugData ) - 1, diff( debugData.AdjR2 ), 'o' );
                    refline( 0 );
                    title( 'diff(AdjR2)' );
                end

                assert( all( isfinite( data( :, 1 ) ) ), 'Internal error. Expecting finite R^2 values.' );



                possibilities = max( data( :, 1 ) ) - data( :, 1 ) <= 1e-4;

                data = data( possibilities, : );
                [ ~, best ] = max( data( :, 3 ) );

                maxAdjusted_R2 = data( best, 1 );
                max_R2 = data( best, 2 );
                nPoints = data( best, 3 );
                best_lambda_Z = data( best, 4 );
            end
        end

        function [ time, conc ] = handleSparseSamplingNEW( time, conc )


            removeRows = isnan( conc );

            time = time( ~removeRows );
            conc = conc( ~removeRows );

            [ uniqueTime, ~, f3 ] = unique( time, 'last' );
            averageConc = accumarray( f3, conc, [  ], @( x )mean( x ) );





            time = uniqueTime;
            conc = averageConc;
        end

        function [ time, conc, dose ] = handleSparseSampling( time, conc, dose )


            removeRows = isnan( conc ) & isnan( dose );

            time = time( ~removeRows );
            conc = conc( ~removeRows );

            [ uniqueTime, ~, f3 ] = unique( time, 'last' );
            averageConc = accumarray( f3, conc, [  ], @( x )mean( x ) );





            time = uniqueTime;
            conc = averageConc;
        end

        function C_0 = extrapolateToFindMissingConcentrationsAtDoseTime( time, conc, doseTime )
            C_0 = log( conc( find( conc( 1:2 ) > 0, 1 ) ) );



            if ~any( conc( 1:2 ) == 0 )
                slope = regress( log( conc( 1:2 ) ), [ ones( 2, 1 ), time( 1:2 ) ] );
                if slope( 2 ) < 0
                    C_0 = log( conc( 1 ) ) + slope( 2 ) * ( doseTime - time( 1 ) );
                end
            end

            C_0 = exp( C_0 );
        end

        function CMin = calculateCMin( conc )
            if isempty( conc )
                CMin = NaN;
            else
                CMin = min( conc );
            end
        end

        function [ Tmax, CMax ] = calculateTmax( time, conc )
            if isempty( time )
                Tmax = NaN;
            else
                [ CMax, i ] = max( conc );
                Tmax = time( i );
            end
        end

        function [ auc, auc_Tz, auc_extrap_percent, aumc, aumc_Tz, aumc_extrap_percent ] = calculateAUCRelatedParameters( time, conc, Lambda_z )

            if isempty( time ) || length( conc ) < 2
                auc = NaN;
                auc_Tz = NaN;
                auc_extrap_percent = NaN;
                aumc = NaN;
                aumc_Tz = NaN;
                aumc_extrap_percent = NaN;
            else
                auc_Tz = SimBiology.nca.NCA.computeAuc( time, conc, time( 1 ), time( end  ) );
                aumc_Tz = SimBiology.nca.NCA.computeAuc( time, time .* conc, time( 1 ), time( end  ) );

                if ( Lambda_z > 0 )
                    auc_extrap = conc( end  ) / Lambda_z;
                    auc = auc_Tz + auc_extrap;
                    auc_extrap_percent = ( auc_extrap / auc ) * 100;
                    aumc_extrap = ( conc( end  ) / Lambda_z ^ 2 ) + ( time( end  ) * conc( end  ) / Lambda_z );
                    aumc = aumc_Tz + aumc_extrap;
                    aumc_extrap_percent = ( aumc_extrap / aumc ) * 100;
                else
                    auc = auc_Tz;
                    auc_extrap_percent = 0;
                    aumc = aumc_Tz;
                    aumc_extrap_percent = 0;
                end
            end
        end






        function C_star = estimateC( time, conc, t_star )
            assert( t_star > 0 );
            assert( t_star < time( end  ) );
            lower = find( time < t_star, 1, 'last' );
            if isempty( lower )
                c1 = 0;
                c2 = conc( 1 );
                t1 = 0;
                t2 = time( 1 );
            else
                upper = lower + 1;
                t1 = time( lower );
                t2 = time( upper );
                c1 = conc( lower );
                c2 = conc( upper );
            end

            C_star = ( c2 - c1 ) * ( t_star - t1 ) / ( t2 - t1 ) + c1;
        end

        function parameters = getParamNames( baseUnits )

            concUnit = baseUnits.concUnit;
            doseUnit = baseUnits.doseUnit;
            timeUnit = baseUnits.timeUnit;
            volumeUnit = baseUnits.volumeUnit;

            parameters.Lambda_z = [ '1/', timeUnit ];
            parameters.npts = '';
            parameters.AUC = [ concUnit, '*', timeUnit ];
            parameters.R2 = '';
            parameters.adjusted_R2 = '';
            parameters.T_max = timeUnit;
            parameters.V_ss = volumeUnit;
            parameters.C_max = concUnit;
            parameters.T_half = timeUnit;
            parameters.AUC_0_tz = [ concUnit, '*', timeUnit ];
        end

        function [ errorMsgs, record ] = singleDoseParameters( record, time, conc, dose, rate, errorMsgs, extrapNeeded, lambda_timeBounds, partialAreas, C_max_usr )







            useTime = time;
            useConc = conc;


            [ record.T_max, record.C_max ] = SimBiology.nca.NCA.calculateTmax( useTime, useConc );

            record.C_max_Dose = record.C_max / dose * 1e3;

            if any( isnan( lambda_timeBounds ) )


                [ Lambda_z, R, npts, adj_R ] = SimBiology.nca.NCA.calculateLambdaZ( useTime, useConc );
            else
                [ Lambda_z, R, npts, adj_R ] = SimBiology.nca.NCA.calculateLambdaZBounds( useTime, useConc, lambda_timeBounds );
            end

            record.Lambda_Z = Lambda_z;
            record.R2 = R;
            record.Num_points = npts;
            record.adjusted_R2 = adj_R;


            if ~all( cellfun( @( x )isempty( x ), C_max_usr ) )
                for C_max_usr_i = 1:size( C_max_usr, 2 )
                    timeLimits = C_max_usr{ C_max_usr_i };
                    variableName = matlab.lang.makeValidName( sprintf( 'C_max_%g__%g', timeLimits( 1 ), timeLimits( 2 ) ) );
                    TmaxVariableName = matlab.lang.makeValidName( sprintf( 'T_max_%g__%g', timeLimits( 1 ), timeLimits( 2 ) ) );
                    idx = time >= timeLimits( 1 ) & time <= timeLimits( 2 );
                    if any( idx )
                        timeInRange = time( idx );
                        concInRange = conc( idx );
                        [ record.C_max_usr.( variableName ), max_idx ] = max( concInRange );
                        record.T_max_usr.( TmaxVariableName ) = timeInRange( max_idx );
                    else
                        record.C_max_usr.( variableName ) = NaN;
                        record.T_max_usr.( TmaxVariableName ) = NaN;
                    end
                end
            end

            if extrapNeeded

                missingC = SimBiology.nca.NCA.extrapolateToFindMissingConcentrationsAtDoseTime( time, conc, 0 );
                time = [ 0;time ];
                conc = [ missingC;conc ];

                if isa( record.doseAdministrationParams, 'SimBiology.nca.internal.IVDoseParameters' )
                    record.doseAdministrationParams.C_0 = missingC;
                end
            else
                if isa( record.doseAdministrationParams, 'SimBiology.nca.internal.IVDoseParameters' )
                    record.doseAdministrationParams.C_0 = conc( 1 );
                end
            end

            [ record.AUC_infinity,  ...
                record.AUC_0_last,  ...
                record.AUC_extrap_percent,  ...
                record.doseCountParams.AUMC,  ...
                record.doseCountParams.AUMC_0_last,  ...
                record.doseCountParams.AUMC_extrap_percent ] ...
                = SimBiology.nca.NCA.calculateAUCRelatedParameters( time, conc, Lambda_z );

            record.AUC_infinity_dose = record.AUC_infinity / dose * 1e3;


            if ~all( cellfun( @( x )isempty( x ), partialAreas ) )
                for partialArea_i = 1:size( partialAreas, 2 )
                    timeLimits = partialAreas{ partialArea_i };
                    variableName = matlab.lang.makeValidName( sprintf( 'AUC_%g__%g', timeLimits( 1 ), timeLimits( 2 ) ) );
                    if any( time >= timeLimits( 1 ) & time <= timeLimits( 2 ) )
                        record.partialAreas.( variableName ) = SimBiology.nca.NCA.computeAUC_ArbitraryTimes( time, conc, timeLimits( 1 ), timeLimits( 2 ) );
                    else
                        record.partialAreas.( variableName ) = NaN;
                    end
                end
            end

            record.MRT = record.doseCountParams.AUMC / record.AUC_infinity;
            if ~isempty( rate )
                record.MRT = record.MRT - dose / rate / 2;
            end


            record.CL = dose / record.AUC_infinity;

            record.T_half = log( 2 ) / record.Lambda_Z;

            if isa( record.doseAdministrationParams, 'SimBiology.nca.internal.IVDoseParameters' )
                record.doseAdministrationParams.V_ss = record.CL * record.MRT;
            end

            record.V_z = dose / ( record.AUC_infinity * record.Lambda_Z );

            record.Tlast = max( time );
        end

        function [ errorMsgs, record ] = multipleDoseParameters( record, time, conc, dose, rate, errorMsgs, extrapNeeded, groupDosingTimes, currentGroup, userTau, lambda_timeBounds, partialAreas, C_max_usr )

            [ Tau, errs ] = SimBiology.nca.NCA.computeTauFromData( userTau, groupDosingTimes, currentGroup );

            if ~isempty( errs )

                errorMsgs = horzcat( errorMsgs, errs );
            end



            record.doseCountParams.TAU = Tau;





            measurementsPerDosingInterval = SimBiology.nca.NCA.getDosingPeriodInMultipleDosing( time, groupDosingTimes );






            firstPeriodIndex = [  ];
            if ~isempty( measurementsPerDosingInterval )
                firstPeriodIndex = measurementsPerDosingInterval{ 1, 2 };
            end

            if any( firstPeriodIndex )
                [ C_max_SS, maxIdx ] = max( conc( firstPeriodIndex ) );
                firstPeriodTime = time( firstPeriodIndex );
                T_max_SS = firstPeriodTime( maxIdx );
            else



                T_max_SS = nan;
                C_max_SS = nan;
            end

            record.C_max = C_max_SS;
            record.C_max_Dose = record.C_max / dose * 1e3;
            record.T_max = T_max_SS;

            record.Tlast = max( time );


            dummy = find( firstPeriodIndex );

            if isempty( dummy )
                record.doseCountParams.C_min = nan;
                record.doseCountParams.T_min = nan;
            else
                [ record.doseCountParams.C_min, minIdx ] = min( conc( firstPeriodIndex ) );
                record.doseCountParams.T_min = time( dummy( minIdx ) );
            end

            if any( isnan( lambda_timeBounds ) )


                [ lambda_z, max_R2, nPoints, maxAdjusted_R2 ] = SimBiology.nca.NCA.calculateLambdaZ( time( measurementsPerDosingInterval{ end , 2 } ), conc( measurementsPerDosingInterval{ end , 2 } ) );

            else

                [ lambda_z, max_R2, nPoints, maxAdjusted_R2 ] = SimBiology.nca.NCA.calculateLambdaZBounds( time, conc, lambda_timeBounds );
            end


            if extrapNeeded
                doseTime = 0;
                C_0 = SimBiology.nca.NCA.extrapolateToFindMissingConcentrationsAtDoseTime( time, conc, doseTime );
                time = [ 0;time ];
                conc = [ C_0;conc ];
                if isa( record.doseAdministrationParams, 'SimBiology.nca.internal.IVDoseParameters' )
                    record.doseAdministrationParams.C_0 = C_0;
                end

                measurementsPerDosingInterval = SimBiology.nca.NCA.getDosingPeriodInMultipleDosing( time, groupDosingTimes );
            end

            record.Lambda_Z = lambda_z;
            record.R2 = max_R2;
            record.Num_points = nPoints;
            record.adjusted_R2 = maxAdjusted_R2;

            record.T_half = log( 2 ) / record.Lambda_Z;

            record.doseCountParams.Accumulation_Index = 1 / ( 1 - exp(  - lambda_z * Tau ) );




            nPeriod = 1;
            AUCtimeRange = measurementsPerDosingInterval{ nPeriod, 2 };

            AUCtimeRangeIndicies = find( AUCtimeRange );

            aucTime = time( AUCtimeRangeIndicies );
            aucConc = conc( AUCtimeRangeIndicies );


            catTau = aucConc( end  ) * exp(  - lambda_z * ( nPeriod * Tau - aucTime( end  ) ) );
            aucTime = [ aucTime;nPeriod * Tau ];
            aucConc = [ aucConc;catTau ];


            if numel( conc ) < 2
                errorMsgs{ end  + 1 } = SimBiology.nca.NCA.getErrorMessage( 'SimBiology:NCA:TooFewObservations', char( currentGroup( end  ) ) );
                return
            end


            record.doseCountParams.AUC_TAU = SimBiology.nca.NCA.computeAuc( aucTime, aucConc, aucTime( 1 ), aucTime( end  ) );

            record.AUC_0_last = SimBiology.nca.NCA.computeAuc( time, conc, time( 1 ), time( end  ) );

            auc_extrap = conc( end  ) / record.Lambda_Z;
            record.AUC_infinity = record.AUC_0_last + auc_extrap;
            record.AUC_infinity_dose = record.AUC_infinity / dose * 1e3;
            record.AUC_extrap_percent = ( auc_extrap / record.AUC_infinity ) * 100;

            record.doseCountParams.C_avg = record.doseCountParams.AUC_TAU / Tau;

            record.CL = dose / record.doseCountParams.AUC_TAU;

            record.doseCountParams.PTF_Percent = ( 100 * ( C_max_SS - record.doseCountParams.C_min ) ) / record.doseCountParams.C_avg;

            record.doseCountParams.AUMC_TAU = SimBiology.nca.NCA.computeAuc( aucTime, aucTime .* aucConc, aucTime( 1 ), aucTime( end  ) );

            record.MRT = ( record.doseCountParams.AUMC_TAU + Tau * ( record.AUC_infinity - record.doseCountParams.AUC_TAU ) ) / record.doseCountParams.AUC_TAU;

            record.V_z = dose / ( lambda_z * record.doseCountParams.AUC_TAU );

            if isa( record.doseAdministrationParams, 'SimBiology.nca.internal.IVDoseParameters' )
                record.doseAdministrationParams.V_ss = record.CL * record.MRT;
            end


            if ~all( cellfun( @( x )isempty( x ), partialAreas ) )
                for partialArea_i = 1:size( partialAreas, 2 )
                    timeLimits = partialAreas{ partialArea_i };
                    variableName = matlab.lang.makeValidName( sprintf( 'AUC_%g__%g', timeLimits( 1 ), timeLimits( 2 ) ) );
                    if any( time >= timeLimits( 1 ) & time <= timeLimits( 2 ) )
                        record.partialAreas.( variableName ) = SimBiology.nca.NCA.computeAUC_ArbitraryTimes( time, conc, timeLimits( 1 ), timeLimits( 2 ) );
                    else
                        record.partialAreas.( variableName ) = NaN;
                    end
                end
            end


            if ~all( cellfun( @( x )isempty( x ), C_max_usr ) )

                if extrapNeeded
                    useTime = time( 2:end  );
                    useConc = conc( 2:end  );
                else
                    useConc = conc;
                    useTime = time;
                end

                for cmax_i = 1:size( C_max_usr, 2 )
                    timeLimits = C_max_usr{ cmax_i };
                    variableName = matlab.lang.makeValidName( sprintf( 'C_max_%g__%g', timeLimits( 1 ), timeLimits( 2 ) ) );
                    TmaxVariableName = matlab.lang.makeValidName( sprintf( 'T_max_%g__%g', timeLimits( 1 ), timeLimits( 2 ) ) );
                    ind = useTime >= timeLimits( 1 ) & useTime <= timeLimits( 2 );
                    if any( ind )
                        concInRange = useConc( ind );
                        timeInRange = useTime( ind );
                        [ record.C_max_usr.( variableName ), max_idx ] = max( concInRange );
                        record.T_max_usr.( TmaxVariableName ) = timeInRange( max_idx );
                    else
                        record.C_max_usr.( variableName ) = NaN;
                        record.T_max_usr.( TmaxVariableName ) = NaN;
                    end
                end
            end
        end

        function [ tau, errorMsgs ] = computeTauFromData( userTau, doseTimes, group )

            errorMsgs = {  };

            if numel( doseTimes ) > 1
                Taus = diff( doseTimes );
                if ~all( Taus == Taus( 1 ) )
                    errorMsgs{ end  + 1 } = SimBiology.nca.NCA.getErrorMessage( 'SimBiology:NCA:NonConstantDosingInterval', char( group( end  ) ) );
                end

                Tau = Taus( end  );

                if Tau <= 0 || ~isfinite( Tau )
                    errorMsgs{ end  + 1 } = SimBiology.nca.NCA.getErrorMessage( 'SimBiology:NCA:InvalidTau', char( group( end  ) ) );
                end
            else
                if userTau <= 0 || ~isfinite( userTau )
                    errorMsgs{ end  + 1 } = SimBiology.nca.NCA.getErrorMessage( 'SimBiology:NCA:InvalidTau', char( group( end  ) ) );
                end
                Tau = userTau;
            end

            tau = Tau;
        end


        function group = getDosingPeriodInMultipleDosing( measuredTimes, dosingTimes )
            arguments
                measuredTimes double
                dosingTimes double
            end

            nDosings = numel( dosingTimes );
            dosingTimes = [ dosingTimes;inf ];

            group = cell( nDosings, 2 );
            counter = 0;

            for i = 1:nDosings
                measurementsInThisDosingPeriod_TF = measuredTimes >= dosingTimes( i ) & measuredTimes < dosingTimes( i + 1 );
                if any( measurementsInThisDosingPeriod_TF )
                    counter = counter + 1;
                    group{ counter, 1 } = i;
                    group{ counter, 2 } = measurementsInThisDosingPeriod_TF;
                end
            end
            group = group( 1:counter, : );
        end

        function index = getDosingPeriod( time, tau, nPeriod, boundary )

            if nargin == 3
                boundary = 'inclusive';
            end

            startPeriod = ( nPeriod - 1 ) * tau;
            endPeriod = startPeriod + tau;

            if strcmp( boundary, 'inclusive' )
                index = time >= startPeriod & time <= endPeriod;
            elseif strcmp( boundary, 'exclusive' )
                index = time >= startPeriod & time < endPeriod;
            end
        end

        function errStr = getErrorMessage( msgID, varargin )
            msg = message( msgID, varargin{ : } );
            errStr = getString( msg );
        end
    end
end
