classdef RateSection






















    properties ( SetAccess = private )

        Rate string
    end

    properties ( Dependent = true )
















        Order( :, 3 )table
    end

    properties ( Access = private )
        PartitionProperties( :, 8 )table
        Version = 1
    end

    methods ( Access = { ?simulink.schedule.OrderedSchedule } )
        function this = RateSection( rate, properties )
            if ( nargin ~= 0 )
                this.Rate = rate;
                this.PartitionProperties = properties;
            end
        end
    end

    methods
        function eo = get.Order( this )
            eo = this.PartitionProperties( :, 1:3 );
        end

        function this = set.Order( this, eo )


            arguments
                this( 1, 1 )simulink.schedule.RateSection
                eo( :, 3 )table
            end

            simulink.schedule.internal.validateOrderTableProperties( eo );

            names = eo.Partition;
            existingNames = this.PartitionProperties.Partition;


            extraNames = setdiff( names, existingNames );
            if ~isempty( extraNames )
                msg = 'SimulinkPartitioning:CLI:RateSectionPartitionMismatchExtra';
                error( message( msg, sprintf( '\n%s', extraNames{ : } ) ) );
            end


            missingNames = setdiff( existingNames, names );
            if ~isempty( missingNames )
                msg = 'SimulinkPartitioning:CLI:RateSectionPartitionMismatchMissing';
                error( message( msg, sprintf( '\n%s', missingNames{ : } ) ) );
            end

            this.PartitionProperties( :, 1:3 ) = eo;
        end
    end
end



