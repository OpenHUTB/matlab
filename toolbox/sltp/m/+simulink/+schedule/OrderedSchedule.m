classdef OrderedSchedule

    properties ( Dependent = true )
        Order( :, 3 )table
        RateSections( 1, : )simulink.schedule.RateSection

        Events( :, 1 )simulink.schedule.Event
    end

    properties
        Description char
    end


    properties ( Hidden = true )

        PartitionProperties( :, 8 )table =  ...
            simulink.schedule.internal.createPartitionPropertiesTable( 0 )


        EventsInternal( :, 1 )simulink.schedule.Event


        IsExportFunction( 1, 1 )logical = false


        Version( 1, 1 )double = 1.0
    end

    properties ( Hidden = true, Constant )
        UnknownPriority = intmin( 'int32' );
    end

    methods
        function eo = get.Order( this )
            eo = this.PartitionProperties( :, 1:3 );
        end

        function this = set.Order( this, eo )
            arguments
                this( 1, 1 )simulink.schedule.OrderedSchedule
                eo( :, 3 )table
            end

            simulink.schedule.internal.validateOrderTableProperties( eo );
            simulink.schedule.internal.validateNamesAgainst(  ...
                eo.Partition, this.PartitionProperties.Partition, false );


            if ~isequal( eo.Partition, this.PartitionProperties.Partition )
                error( message(  ...
                    'SimulinkPartitioning:CLI:InvalidOrderPartitionOrderEdit' ) );
            end

            this.validateReadOnlyVariables( eo );

            this.validateNewTriggers( eo );




            newProperties = this.PartitionProperties;
            newProperties( :, 1:3 ) = eo;


            newIdxs = newProperties.Index;
            moved = newIdxs ~= ( 1:length( newIdxs ) )';
            movedOldIdxs = find( moved );
            movedNewIdxs = newIdxs( moved );


            this.validateMovedIndexes( movedOldIdxs, movedNewIdxs );

            movedNewLocations = false( size( newProperties.Partition ) );
            movedNewLocations( newProperties.Index( moved ) ) = true;

            movedInNewOrder = sortrows( newProperties( moved, : ), 'Index' );

            newTable = newProperties;
            rowLabels = newProperties.Partition;
            newTable( movedNewLocations, : ) = movedInNewOrder;
            rowLabels( movedNewLocations ) = movedInNewOrder.Partition;
            newTable( ~movedNewLocations, : ) = newProperties( ~moved, : );
            rowLabels( ~movedNewLocations ) = newProperties.Partition( ~moved );


            aperiodics = newTable.Type == simulink.schedule.PartitionType.Aperiodic;


            [ this.EventsInternal, eventPartitions ] =  ...
                this.getNewEventsAndEventPartitionsFromOrder( newTable );
            newTable.Event( eventPartitions ) = newTable.Trigger( eventPartitions );

            hitTimePartitions = aperiodics & ~eventPartitions;
            newTable.HitTimes( hitTimePartitions ) = newTable.Trigger( hitTimePartitions );
            newTable.Event( hitTimePartitions ) = "";


            newTable.Partition = rowLabels;
            newTable.Index = ( 1:height( newProperties ) )';
            newProperties = newTable;


            this.validateResultingPositions( newProperties );

            this.PartitionProperties = newProperties;
            this.PartitionProperties.Partition = newProperties.Partition;
        end

        function rateSections = get.RateSections( this )
            rateSections = this.createRateSections(  );
        end

        function this = set.RateSections( this, rs )
            eo = this.Order;

            this.validateNewRateSections( rs );

            rsa = vertcat( rs.Order );
            eo( rsa.Partition, : ) = rsa;

            this.Order = eo;
        end

        function events = get.Events( this )
            events = this.EventsInternal;
        end


        function this = set.Events( this, events )
            this.validateNewEvents( events );
            [ ~, index ] = sort( [ events.Name ] );
            this.EventsInternal = events( index );
        end


        function tf = eq( s1, s2 )
            tf = arrayfun( @( a, b )eqElement( a, b ), s1, s2 );
        end


        function tf = ne( s1, s2 )
            tf = ~eq( s1, s2 );
        end


        function summary( this )

            fprintf( '\n%s', message( 'SimulinkPartitioning:CLI:SummaryHeading', 'OrderedSchedule' ).getString );

            partitions = height( this.PartitionProperties );
            periodicIdxs =  ...
                simulink.schedule.PartitionType.Periodic ==  ...
                this.PartitionProperties.Type;
            aperiodicIdxs =  ...
                simulink.schedule.PartitionType.Aperiodic ==  ...
                this.PartitionProperties.Type;

            fprintf( '\n\n    %s',  ...
                message( 'SimulinkPartitioning:CLI:SummaryPartitions',  ...
                partitions ) );
            fprintf( '\n    %s',  ...
                message( 'SimulinkPartitioning:CLI:SummaryPeriodicRates',  ...
                length( unique( this.PartitionProperties.Rate( periodicIdxs ) ) ) ) );
            fprintf( '\n    %s',  ...
                message( 'SimulinkPartitioning:CLI:SummaryPeriodicPartitions',  ...
                nnz( periodicIdxs ) ) );
            fprintf( '\n    %s\n\n',  ...
                message( 'SimulinkPartitioning:CLI:SummaryAperiodicPartitions',  ...
                nnz( aperiodicIdxs ) ) );
        end
    end


    methods ( Hidden = true )

        function out = saveobj( this )
            out = simulink.schedule.internal.convertToStruct( this );
        end


        function this = OrderedSchedule( modelHandle )

            arguments
                modelHandle( 1, 1 )double = 0
            end

            if ~exist( 'sltp.TaskConnectivityGraph', 'class' )

                return
            end

            tcg = sltp.TaskConnectivityGraph( modelHandle );

            partitionNames = tcg.getSortedChildTasks( '' );

            this.IsExportFunction = false;

            if modelHandle ~= 0
                this.IsExportFunction = strcmp( get_param( modelHandle, 'IsExportFunctionModel' ), 'on' );
            end
            this.PartitionProperties =  ...
                this.getPartitionProperties( modelHandle, partitionNames );
            this.Description = tcg.Description;
            this.EventsInternal = simulink.schedule.internal.createEventObjects( modelHandle );
        end


        function applyToModel( this, modelHandle )

            arguments
                this( :, : )simulink.schedule.OrderedSchedule
                modelHandle( 1, 1 )double
            end

            if ~strcmp( get_param( modelHandle, 'SimulationStatus' ), 'stopped' )
                error( message( 'Simulink:Engine:SimCantChangeBDPropDuringSim',  ...
                    'Schedule',  ...
                    get_param( modelHandle, 'Name' ) ) );
            end

            if ~isscalar( this )
                error( message( 'SimulinkPartitioning:CLI:UnexpectedScheduleValue' ) );
            end

            this.validateScheduleContentMatches( modelHandle );

            tcg = sltp.TaskConnectivityGraph( modelHandle );
            tcg.Description = this.Description;

            if height( this.PartitionProperties ) == 0

                return
            end

            tcg.setChildTaskExecutionOrder( '',  ...
                this.PartitionProperties.Partition );

            if strcmp( get_param( modelHandle, 'IsExportFunctionModel' ), 'on' )
                tcg.assignInputPortPrioritiesForModel(  );
                return ;
            end

            aperiodics = this.PartitionProperties.Type ==  ...
                simulink.schedule.PartitionType.Aperiodic;

            aperiodicNames = this.PartitionProperties.Partition( aperiodics );
            cellfun(  ...
                @( x )tcg.setTrigger( x, this.PartitionProperties.Trigger( x ) ),  ...
                aperiodicNames );


            for event = this.Events'
                event.applyToModel( modelHandle );
            end
        end
    end


    methods ( Access = private )

        function partitionProperties = getPartitionProperties( this, handle, names )

            partitionProperties =  ...
                simulink.schedule.internal.createPartitionPropertiesTable( length( names ) );

            if isempty( names )

                return
            end

            tcg = sltp.TaskConnectivityGraph( handle );

            partitionProperties.Partition = string( names )';
            partitionProperties.Priority( names ) =  ...
                cellfun( @( x )tcg.getPriority( x ), names );
            partitionProperties.Index = ( 1:length( names ) )';
            partitionProperties.InternalType =  ...
                simulink.schedule.OrderedSchedule.getInternalTypes(  ...
                tcg, names );

            partitionProperties.Type = this.getTypes(  ...
                partitionProperties.InternalType );
            partitionProperties.Rate =  ...
                simulink.schedule.OrderedSchedule.getRates(  ...
                tcg, partitionProperties.Type, names );

            if ~this.IsExportFunction
                partitionProperties.HitTimes =  ...
                    simulink.schedule.OrderedSchedule.getHitTimes(  ...
                    tcg, partitionProperties.Type, names );
                partitionProperties.Event =  ...
                    simulink.schedule.OrderedSchedule.getPartitionEvent(  ...
                    tcg, partitionProperties.Type, names );
            else
                partitionProperties.HitTimes( : ) = "";
                partitionProperties.Event( : ) = "";
            end

            hasHitTimes = strlength( partitionProperties.HitTimes ) > 0;
            hasEvent = strlength( partitionProperties.Event ) > 0;
            assert( ~any(  ...
                strlength( partitionProperties.Rate ) > 0 &  ...
                hasHitTimes ) );
            assert( ~any(  ...
                strlength( partitionProperties.Rate ) > 0 &  ...
                hasEvent ) );

            partitionProperties.Trigger = partitionProperties.Rate;
            partitionProperties.Trigger( hasHitTimes ) = partitionProperties.HitTimes( hasHitTimes );
            partitionProperties.Trigger( hasEvent ) = partitionProperties.Event( hasEvent );
        end

        function rateSections = createRateSections( this )


            if this.IsExportFunction || isempty( this.PartitionProperties )
                rateSections = simulink.schedule.RateSection.empty;
                return
            end


            periodics =  ...
                this.PartitionProperties.Type ==  ...
                simulink.schedule.PartitionType.Periodic;
            trimmedPartitionProperties = this.PartitionProperties( periodics, : );

            allRates = unique( trimmedPartitionProperties.Rate, 'stable' );

            function out = createRateSection( rate )
                rows = trimmedPartitionProperties.Rate == rate;
                out = simulink.schedule.RateSection(  ...
                    rate, trimmedPartitionProperties( rows, : ) );
            end

            rateSections = arrayfun( @( x )createRateSection( x ), allRates );
        end


        function validateMovedIndexes( this, movedOldIdxs, movedNewIdxs )

            inRangeIndexes = movedNewIdxs >= 1 &  ...
                movedNewIdxs <= length( this.PartitionProperties.Partition );
            outOfRangeIndexes = ~inRangeIndexes;
            if any( outOfRangeIndexes )
                msg = 'SimulinkPartitioning:CLI:InvalidIndexOutOfRange';
                error( message( msg,  ...
                    this.PartitionProperties.Partition{ movedOldIdxs( find( outOfRangeIndexes, 1 ) ) },  ...
                    string( length( this.PartitionProperties.Partition ) ) ) );
            end

            nonIntegerIndexes = ~isreal( movedNewIdxs ) | 0 ~= mod( real( movedNewIdxs ), 1 );
            if any( nonIntegerIndexes )
                msg = 'SimulinkPartitioning:CLI:InvalidIndexNonInteger';
                error( message( msg,  ...
                    this.PartitionProperties.Partition{ movedOldIdxs( find( nonIntegerIndexes, 1 ) ) } ) );
            end

            [ ~, ia, ~ ] = unique( movedNewIdxs );
            duplicateIdxs = setdiff( 1:length( movedNewIdxs ), ia );
            if size( duplicateIdxs ) > 0
                msg = 'SimulinkPartitioning:CLI:InvalidIndexDuplicate';
                error( message( msg,  ...
                    string( movedNewIdxs( duplicateIdxs( 1 ) ) ) ) );
            end
        end


        function validateReadOnlyVariables( this, eo )

            oldTypes = this.PartitionProperties.Type;
            newTypes = eo.Type;
            differentTypes = oldTypes ~= newTypes;
            if any( differentTypes )
                msg = 'SimulinkPartitioning:CLI:InvalidTypeEdit';
                error( message( msg, eo.Partition{ find( differentTypes, 1 ) } ) );
            end
        end


        function validateNewTriggers( this, eo )

            partitionsWithModifiedTriggers =  ...
                eo.Trigger ~= this.PartitionProperties.Trigger;

            if this.IsExportFunction && any( partitionsWithModifiedTriggers )
                msg = "SimulinkPartitioning:CLI:InvalidSetTriggerExportFunction";
                error( message( msg,  ...
                    this.PartitionProperties.Partition{ find(  ...
                    partitionsWithModifiedTriggers, 1 ) } ) );
            end

            aperiodics = this.PartitionProperties.Type ==  ...
                simulink.schedule.PartitionType.Aperiodic;
            nonAperiodicsWithModifiedTrigger =  ...
                ~aperiodics & partitionsWithModifiedTriggers;

            if any( nonAperiodicsWithModifiedTrigger )
                firstInvalidIndex = find( nonAperiodicsWithModifiedTrigger, 1 );
                firstInvalidType =  ...
                    this.PartitionProperties.Type( firstInvalidIndex );
                firstInvalidName =  ...
                    this.PartitionProperties.Partition{ firstInvalidIndex };

                if firstInvalidType == simulink.schedule.PartitionType.AsynchronousFunction
                    msg = "SimulinkPartitioning:CLI:InvalidSetTriggerAsync";
                    error( message( msg, firstInvalidName ) );
                else
                    assert( eo.Type( firstInvalidIndex ) ==  ...
                        simulink.schedule.PartitionType.Periodic );
                    assert( ~this.IsExportFunction );
                    msg = "SimulinkPartitioning:CLI:InvalidSetTriggerPeriodic";
                    error( message( msg, firstInvalidName ) );
                end

            end
        end


        function [ events, eventPartitions ] = getNewEventsAndEventPartitionsFromOrder( this, eo )

            aperiodics = eo.Type == simulink.schedule.PartitionType.Aperiodic;

            events = simulink.schedule.Event.empty;
            eventPartitions = false( size( aperiodics ) );
            eventNames = [ this.Events.Name ];

            if isempty( this.Events )
                return
            end

            [ ~, eventIndexes ] = ismember( eo.Trigger( aperiodics ), eventNames );
            eventPartitions( aperiodics ) = eventIndexes > 0;

            events = this.EventsInternal;

            for eventNameIndex = 1:length( eventNames )
                eventName = eventNames( eventNameIndex );
                eventIndex = [ events.Name ] == eventName;

                events( eventIndex ).Listeners =  ...
                    sort( eo.Partition( eo.Trigger == eventName ) );
            end
        end

        function validateResultingPositions( this, properties )




            freeFloatingPartitions =  ...
                this.PartitionProperties.InternalType == "aperiodic";
            fixedPartitions =  ...
                this.PartitionProperties.InternalType == "base" |  ...
                this.PartitionProperties.InternalType == "async" |  ...
                this.PartitionProperties.InternalType == "aperiodic-async" |  ...
                this.PartitionProperties.InternalType == "simulink-function";
            fixedPartitionNames =  ...
                this.PartitionProperties.Partition( fixedPartitions );
            nonFloatingPartitionNames =  ...
                this.PartitionProperties.Partition( ~freeFloatingPartitions );

            fixedPartitionsOldIndex =  ...
                this.PartitionProperties.Index( fixedPartitions );
            fixedPartitionsNewIndex =  ...
                properties.Index( fixedPartitionNames );

            nonFloatingPartitionOldIndex =  ...
                this.PartitionProperties.Index( ~freeFloatingPartitions );
            nonFloatingPartitionNewIndex =  ...
                properties.Index( nonFloatingPartitionNames );

            for i = 1:length( fixedPartitionsOldIndex )


                oldBefore = nonFloatingPartitionOldIndex <  ...
                    fixedPartitionsOldIndex( i );
                newBefore = nonFloatingPartitionNewIndex <  ...
                    fixedPartitionsNewIndex( i );
                fixedType = this.PartitionProperties.InternalType(  ...
                    fixedPartitionsOldIndex( i ) );
                fixedPartition = this.PartitionProperties.Partition{  ...
                    fixedPartitionsOldIndex( i ) };

                movedBelow = oldBefore & ~newBefore;
                assert( ~any( movedBelow ), "Internal error. We shouldn't see any partitions moved below a fixed partition" )

                movedAbove = ~oldBefore & newBefore;
                if any( movedAbove )
                    belowPartition = this.PartitionProperties.Partition{  ...
                        nonFloatingPartitionOldIndex( find( movedAbove, 1 ) ) };

                    if fixedType == "base"
                        msg = "SimulinkPartitioning:CLI:InvalidMoveBeforeBase";
                        error( message( msg, belowPartition, fixedPartition ) );
                    elseif fixedType == "async" || fixedType == "aperiodic-async"
                        msg = "SimulinkPartitioning:CLI:InvalidMoveBeforeAsync";
                        error( message( msg, belowPartition, fixedPartition ) );
                    else
                        assert( fixedType == "simulink-function" )
                        msg = "SimulinkPartitioning:CLI:InvalidMoveBeforeSimulinkFunction";
                        error( message( msg, belowPartition, fixedPartition ) );
                    end
                end
            end



            priorityPartitions = properties.Priority ~=  ...
                simulink.schedule.OrderedSchedule.UnknownPriority;
            periodicNames = properties.Partition( priorityPartitions );
            priorities = properties.Priority( priorityPartitions );

            if any( diff( priorities ) < 0 )
                for i = 2:length( periodicNames )
                    if priorities( i ) < priorities( i - 1 )
                        beforeName = periodicNames{ i - 1 };
                        afterName = periodicNames{ i };

                        msg = 'SimulinkPartitioning:CLI:InvalidMoveBeforeRate';
                        error( message( msg, beforeName, afterName ) );
                    end
                end
                assert( false, 'Did not find a mismatch.' );
            end
        end

        function validateNewRateSections( this, newRateSections )

            newRates = [ newRateSections.Rate ];
            oldRates = [ this.RateSections.Rate ];

            [ ~, ia, ~ ] = unique( newRates );
            duplicates = setdiff( 1:length( newRates ), ia );
            if ~isempty( duplicates )
                msg = 'SimulinkPartitioning:CLI:RateSectionsMismatchDuplicate';
                error( message( msg,  ...
                    newline + strjoin( unique( newRates( duplicates ) ), newline ) ) );
            end

            addedRates = setdiff( newRates, oldRates );
            if ~isempty( addedRates )
                msg = 'SimulinkPartitioning:CLI:RateSectionsMismatchExtra';
                error( message( msg,  ...
                    newline + strjoin( addedRates, newline ) ) );
            end

            missingRates = setdiff( oldRates, newRates );
            if ~isempty( missingRates )
                msg = 'SimulinkPartitioning:CLI:RateSectionsMismatchMissing';
                error( message( msg,  ...
                    newline + strjoin( missingRates, newline ) ) );
            end





            if ~isequal( oldRates, newRates )
                msg = 'SimulinkPartitioning:CLI:RateSectionsOutOfOrder';
                error( message( msg ) );
            end
        end

        function validateNewEvents( this, newEvents )

            newEventNames = [ newEvents.Name ];
            oldEventNames = [ this.EventsInternal.Name ];

            [ ~, ia, ~ ] = unique( newEventNames );
            duplicates = setdiff( 1:length( newEventNames ), ia );
            if ~isempty( duplicates )



                msle = MSLException( 'SimulinkPartitioning:CLI:EventMismatchDuplicate',  ...
                    unique( newEventNames( duplicates ) ) );
                msle.throw;
            end

            addedEvents = setdiff( newEventNames, oldEventNames );
            if ~isempty( addedEvents )
                msle = MSLException( 'SimulinkPartitioning:CLI:EventMismatchExtra',  ...
                    addedEvents );
                msle.throw;
            end

            missingEvents = setdiff( oldEventNames, newEventNames );
            if ~isempty( missingEvents )
                msle = MSLException( 'SimulinkPartitioning:CLI:EventMismatchMissing',  ...
                    missingEvents );
                msle.throw;
            end



            if ~isequal( oldEventNames, newEventNames )
                msle = MSLException( 'SimulinkPartitioning:CLI:EventOutOfOrder' );
                msle.throw;
            end


            for index = 1:length( newEvents )
                oldEvent = this.EventsInternal( index );
                newEvent = newEvents( index );

                if ~isequal( oldEvent.Broadcasters, newEvent.Broadcasters )
                    msle = MSLException( 'SimulinkPartitioning:CLI:EventBroadcastersMismatch',  ...
                        newEvent.Name );
                    msle.throw;
                end

                if ~isequal( oldEvent.Listeners, newEvent.Listeners )
                    msle = MSLException( 'SimulinkPartitioning:CLI:EventListenersMismatch',  ...
                        newEvent.Name );
                    msle.throw;
                end
            end
        end

        function validateScheduleContentMatches( this, model )



            targetSchedule = get_param( model, 'Schedule' );
            if isempty( targetSchedule.PartitionProperties ) &&  ...
                    isempty( this.PartitionProperties )

                return
            end



            thisPartitions = this.PartitionProperties.Partition;
            targetPartitions = targetSchedule.PartitionProperties.Partition;


            extraPartitions = setdiff( thisPartitions, targetPartitions );
            if ~isempty( extraPartitions )
                msg = 'SimulinkPartitioning:CLI:InvalidSetParamExtraPartitions';
                error( message( msg,  ...
                    get_param( model, 'Name' ),  ...
                    sprintf( '\n%s', extraPartitions{ : } ) ) );
            end


            missingPartitions = setdiff( targetPartitions, thisPartitions );
            if ~isempty( missingPartitions )
                msg = 'SimulinkPartitioning:CLI:InvalidSetParamMissingPartitions';
                error( message( msg,  ...
                    get_param( model, 'Name' ),  ...
                    sprintf( '\n%s', missingPartitions{ : } ) ) );
            end


            thisTypes = this.PartitionProperties.Type;
            targetTypes = targetSchedule.PartitionProperties.Type( thisPartitions );
            mismatchedTypes = thisTypes ~= targetTypes;
            if any( mismatchedTypes )
                msg = 'SimulinkPartitioning:CLI:InvalidSetParamMismatchedType';
                error( message( msg,  ...
                    get_param( model, 'Name' ),  ...
                    sprintf( '\n%s',  ...
                    this.PartitionProperties.Partition{ mismatchedTypes } ) ) );
            end


            thisRates = this.PartitionProperties.Rate;
            targetRates = targetSchedule.PartitionProperties.Rate( thisPartitions );
            mismatchedRates = thisRates ~= targetRates;
            if any( mismatchedRates )
                msg = 'SimulinkPartitioning:CLI:InvalidSetParamMismatchedRate';
                error( message( msg,  ...
                    get_param( model, 'Name' ),  ...
                    sprintf( '\n%s',  ...
                    this.PartitionProperties.Partition{ mismatchedRates } ) ) );
            end
        end

        function types = getTypes( this, internalType )
            types = simulink.schedule.internal.getPartitionTypeFromInternalType(  ...
                internalType, 'IsExportFunction', this.IsExportFunction );

            assert( ~any( types == simulink.schedule.PartitionType.Unknown ),  ...
                "Unknown partition type." );
        end

        function tf = eqElement( a, b )
            tf = isequal( a.Description, b.Description ) &  ...
                isequal( a.PartitionProperties, b.PartitionProperties ) &  ...
                ( isequal( size( a.Events ), size( b.Events ) ) &&  ...
                all( a.Events == b.Events ) );
        end
    end

    methods ( Static, Access = private )

        function obj = loadobj( in )
            obj = simulink.schedule.internal.createFromStruct( in );
        end

        function rates = getRates( tcg, types, names )
            rates = cellfun( @( x )string( tcg.getRateSpecString( x ) ), names );

            rates( types == simulink.schedule.PartitionType.AsynchronousFunction ) = "A";
            rates( types == simulink.schedule.PartitionType.Aperiodic ) = "";
            rates( types == simulink.schedule.PartitionType.ExportedFunction ) = "A";
            rates( types == simulink.schedule.PartitionType.SimulinkFunction ) = "A";
        end

        function hitTimes = getHitTimes( tcg, types, names )
            hitTimes = strings( size( names ) );

            aperiodics = types == simulink.schedule.PartitionType.Aperiodic;

            aperiodicNames = names( aperiodics );

            aperiodicHitTimes = cellfun(  ...
                @( x )string( tcg.getHitTimes( x ) ), aperiodicNames );
            hitTimes( aperiodics ) = aperiodicHitTimes;
        end

        function partitionEvent = getPartitionEvent(  ...
                tcg, types, names )
            partitionEvent = strings( size( names ) );

            aperiodics = types == simulink.schedule.PartitionType.Aperiodic;

            aperiodicNames = names( aperiodics );

            aperiodicEvents = cellfun(  ...
                @( x )string( tcg.getEvent( x ) ), aperiodicNames );
            partitionEvent( aperiodics ) = aperiodicEvents;
        end

        function internalTypes = getInternalTypes( tcg, names )


            internalTypes = cellfun( @( x )string( tcg.getPartitionTypeString( x ) ), names );

            if strcmp( get_param( tcg.modelName, 'IsExportFunctionModel' ), 'on' )
                internalTypes( internalTypes == "aperiodic" ) = "explicit-periodic";
                internalTypes( internalTypes == "async" ) = "aperiodic";
            end
        end
    end
end



