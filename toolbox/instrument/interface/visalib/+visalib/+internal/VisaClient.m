classdef VisaClient < matlabshared.transportlib.internal.client.GenericClient

    methods
        function obj = VisaClient( clientProperties )
            obj@matlabshared.transportlib.internal.client.GenericClient( clientProperties );
        end
    end

    
    methods
        function [ ready, status ] = readStatusByte( obj, resourceNames )
            n = numel( resourceNames );
            ready = false( 1, n );
            status = zeros( 1, n );

            for idx = 1:n
                options.ResourceName = resourceNames( idx );
                try
                    obj.execute( visalib.internal.VISACommand.ReadStatusByte.string(  ),  ...
                        options );
                catch e
                    throwAsCaller( e );
                end

                statusByte = obj.getCustomProperty( "StatusByte" );
                ready( idx ) = statusByte.Ready;
                status( idx ) = statusByte.Status;
            end
        end

        function assertTrigger( obj, resourceName )
            options.ResourceName = resourceName;
            try
                obj.execute( visalib.internal.VISACommand.AssertTrigger.string(  ),  ...
                    options );
            catch e
                throwAsCaller( e );
            end
        end

        function clearDevice( obj, resourceName )
            options.ResourceName = resourceName;
            try
                obj.execute( visalib.internal.VISACommand.ClearDevice.string(  ),  ...
                    options );
            catch e
                throwAsCaller( e );
            end
        end

        function getAttributesByType( obj, resourceName, attributeValue )



            narginchk( 3, 3 );

            options.ResourceName = resourceName;
            options.AttributeValue = uint32( attributeValue );
            options.AttributeType = getAttributeType( attributeValue );

            try
                obj.execute( visalib.internal.VISACommand.GetAttributeByType.string(  ),  ...
                    options );
            catch e
                throwAsCaller( e );
            end
        end

        function setAttributesByType( obj, resourceName, attributeValue, attributeState )





            narginchk( 4, 4 );

            options.ResourceName = resourceName;
            options.AttributeValue = uint32( attributeValue );
            options.AttributeState = uint64( attributeState );

            try
                obj.execute( visalib.internal.VISACommand.SetAttributeByType.string(  ),  ...
                    options );
            catch e
                throwAsCaller( e );
            end
        end

        function setTransferPeriod( obj, transferPeriod )
            options.Period = transferPeriod;
            try
                obj.execute( visalib.internal.VISACommand.SetTransferPeriod.string(  ),  ...
                    options );
            catch e
                throwAsCaller( e );
            end
        end

        function setTransferSize( obj, numSamples )
            options.NumSamples = uint64( numSamples );
            try
                obj.execute( visalib.internal.VISACommand.SetTransferSize.string(  ),  ...
                    options );
            catch e
                throwAsCaller( e );
            end
        end

        function startTransfer( obj )
            try
                obj.execute( visalib.internal.VISACommand.StartTransfer.string(  ), struct( [  ] ) );
            catch e
                throwAsCaller( e );
            end
        end

        function stopTransfer( obj )
            try
                obj.execute( visalib.internal.VISACommand.StopTransfer.string(  ), struct( [  ] ) );
            catch e
                throwAsCaller( e );
            end
        end

        function initiateReadSync( obj, count )
            obj.readSync( "Binary", count );
        end

        function initiateReadlineSync( obj )
            obj.readSync( "ASCII" );
        end

        function initiateReadBinblockSync( obj )
            obj.readSync( "Binblock" );
        end
    end

    methods ( Access = ?visalib.Resource )
        function enableErrorOnRead( obj )
            obj.ShowReadWarnings = false;
        end

        function disableErrorOnRead( obj )
            obj.ShowReadWarnings = true;
        end
    end

    methods ( Access = private )
        function readSync( obj, type, count )
            arguments
                obj
                type( 1, 1 )string{ mustBeMember( type, [ "Binary", "ASCII", "Binblock" ] ) }
                count( 1, 1 )uint64 = 0
            end

            options.Type = type;
            options.Count = count;

            try
                obj.execute( visalib.internal.VISACommand.ReadSync.string(  ), options );
            catch e
                throwAsCaller( e );
            end
        end
    end
end


