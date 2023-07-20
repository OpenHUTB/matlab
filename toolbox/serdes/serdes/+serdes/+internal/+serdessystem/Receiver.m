classdef Receiver<serdes.internal.serdessystem.Transceiver





    methods
        function rx=Receiver(varargin)

            rx=rx@serdes.internal.serdessystem.Transceiver(varargin{:});
            rx.Name='RX';
        end
    end

end

