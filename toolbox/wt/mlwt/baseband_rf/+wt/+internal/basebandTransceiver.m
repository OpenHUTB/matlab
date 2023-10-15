classdef basebandTransceiver < wt.internal.AppBase




    properties ( Access = protected )
        ApplicationID = 'basebandTransceiver'
        PackageBase = 'wt.internal.baseband_rf'
    end

    properties
        DroppedSamplesAction( 1, 1 ){ mustBeMember( DroppedSamplesAction, [ "error", "warning", "none" ] ) } = "error"
    end

    properties ( Nontunable )
        UseOnboardMemory( 1, 1 )logical = true
        CaptureDataType( 1, 1 ){ mustBeMember( CaptureDataType, [ "int16", "double", "single" ] ) } = "int16"
        TransmitDataType( 1, 1 ){ mustBeMember( TransmitDataType, [ "int16", "double", "single" ] ) } = "int16"
    end

    properties ( SetAccess = immutable )
        AvailableReceiveAntennas
        AvailableTransmitAntennas
    end

    properties ( Access = private )
        pTransmitChannelsInUse = 0;
        pTransmitSamplesAllocated = 0;
    end

    methods ( Access = protected )
        function validateTransmitAntennas( obj, val )



            if ~isstring( val ) && val ==  - 1
            else
                validateTransmitAntennas@wt.internal.AppBase( obj, val )
            end
        end
        function validateReceiveAntennas( obj, val )


            if ~isstring( val ) && val ==  - 1
            else
                validateReceiveAntennas@wt.internal.AppBase( obj, val )
            end
        end
    end
    methods
        function obj = basebandTransceiver( RadioID, varargin )
            obj = obj@wt.internal.AppBase( RadioID, varargin{ : } );
            obj.AvailableReceiveAntennas = obj.Radio.AvailableReceiveAntennas;
            obj.AvailableTransmitAntennas = obj.Radio.AvailableTransmitAntennas;
        end

        function destroy( obj )
            if ~isempty( obj.TransmitAntennas )
                stopTransmitRepeat( obj )
            end
        end

        function transmit( obj, waveform, mode )
            arguments
                obj( 1, 1 )
                waveform
                mode( 1, 1 )wt.internal.TransmitModes
            end


            [ waveform, farrowFactor ] = obj.Driver.prepareTxWaveform( waveform, obj.SampleRate, obj.TransmitAntennas, mode );


            [ waveformLength, numWaveforms ] = size( waveform );




            if rem( waveformLength, 2 )


                error( message( 'wt:baseband_rf:TransmitEvenNoFarrow' ) )
            end

            if farrowFactor ~= 1
                allocateHardwareMemory( obj, numWaveforms, waveformLength, "wt:baseband_rf:NotEnoughMemoryTxFarrowRequired" );
            else
                allocateHardwareMemory( obj, numWaveforms, waveformLength, "wt:baseband_rf:NotEnoughMemoryTxNoFarrow" );
            end

            try
                obj.Driver.transmitViaOnboardMemory( waveform, mode );
            catch ME
                freeHardwareMemory( obj, numWaveforms, waveformLength );
                rethrow( ME )
            end

            if mode == wt.internal.TransmitModes.once
                freeHardwareMemory( obj, numWaveforms, waveformLength );
            elseif mode == wt.internal.TransmitModes.continuous
                obj.pTransmitChannelsInUse = numWaveforms;
                obj.pTransmitSamplesAllocated = waveformLength;
            end
        end

        function stopTransmitRepeat( obj )
            if ~isempty( obj.Driver )
                obj.Driver.stopTransmitViaOnboardMemory(  );
            end
            freeHardwareMemory( obj, obj.pTransmitChannelsInUse, obj.pTransmitSamplesAllocated );
        end

        function [ data, timestamp, droppedSamples ] = capture( obj, CaptureLength, timeout )

            lengthSamples = getCaptureLengthSamples( obj, CaptureLength );
            if rem( lengthSamples, 2 )
                lengthSamples = lengthSamples + 1;
                cropAfterFlag = 1;
            else
                cropAfterFlag = 0;
            end

            receiverOnly = ~isstring( obj.TransmitAntennas ) && obj.TransmitAntennas ==  - 1;

            if receiverOnly && strcmp( wt.internal.feature( "OversizedCaptureSupport" ), "on" )
                obj.checkUseOnboardMemoryValue( length( obj.ReceiveAntennas ), lengthSamples, true );
            end

            step( obj );

            timestamp = datetime;
            if obj.UseOnboardMemory
                if receiverOnly
                    allocationErrorMessage = "wt:baseband_rf:NotEnoughMemoryRx";
                else
                    allocationErrorMessage = "wt:baseband_rf:NotEnoughMemoryTransceiverRx";
                end
                allocateHardwareMemory( obj, length( obj.ReceiveAntennas ), lengthSamples, allocationErrorMessage );
                try
                    [ data, numSamps, overflow ] = obj.Driver.receiveViaOnboardMemory( lengthSamples, timeout );
                catch ME
                    freeHardwareMemory( obj, length( obj.ReceiveAntennas ), lengthSamples );
                    rethrow( ME )
                end
                freeHardwareMemory( obj, length( obj.ReceiveAntennas ), lengthSamples );
            else
                [ data, numSamps, overflow ] = obj.Driver.receive( lengthSamples, timeout );
            end

            if overflow || ~( numSamps == lengthSamples )
                droppedSamples = true;
                switch obj.DroppedSamplesAction
                    case "error"
                        error( message( 'wt:baseband_rf:DroppedSamplesAction', string( obj.AvailableHardwareMemory / obj.pBytesPerSampleOTW ) ) )
                    case "warning"
                        warning( message( 'wt:baseband_rf:DroppedSamplesAction', string( obj.AvailableHardwareMemory / obj.pBytesPerSampleOTW ) ) )
                    otherwise
                end
            else
                droppedSamples = false;
            end

            if cropAfterFlag
                data = data( 1:end  - 1, : );
            end
        end
    end

    methods ( Access = protected )
        function checkUseOnboardMemoryValue( obj, numChannels, lengthSamples, desiredValue )


            canFit = canAllocateHardwareMemory( obj, numChannels, lengthSamples );
            if canFit && ~( obj.UseOnboardMemory == desiredValue )
                obj.release;
                obj.UseOnboardMemory = desiredValue;
            elseif ~canFit && obj.UseOnboardMemory
                obj.release;
                obj.UseOnboardMemory = false;
            end
        end

        function [ CaptureLengthSamples, CaptureLengthTime ] = getCaptureLengthSamples( obj, CaptureLength )

            if isduration( CaptureLength )

                CaptureLengthTime = CaptureLength;

                time_seconds = seconds( CaptureLength );

                numSamples = ceil( time_seconds * obj.SampleRate );
                if numSamples > 0
                    CaptureLengthSamples = numSamples;
                else
                    error( message( 'wt:baseband_rf:CaptureLengthInvalid' ) )
                end
            else
                if isnumeric( CaptureLength )



                    if rem( CaptureLength, 1 ) == 0 && ( CaptureLength > 0 )

                        CaptureLengthSamples = CaptureLength;

                        time_seconds = CaptureLengthSamples / obj.SampleRate;

                        CaptureLengthTime = seconds( time_seconds );
                    else
                        error( message( 'wt:baseband_rf:CaptureLengthInvalid' ) )
                    end
                else
                    error( message( 'wt:baseband_rf:CaptureLengthInvalid' ) )
                end
            end
        end
    end

end

