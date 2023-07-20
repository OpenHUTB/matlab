classdef(Hidden)TransportFactory<handle





    methods(Static)
        function transportObj=getTransport(transportType,varargin)

            transportType=instrument.internal.stringConversionHelpers.str2char(transportType);
            switch transportType
            case 'tcpip'
                narginchk(3,3);
                transportObj=matlabshared.network.internal.TCPClient(varargin{1},varargin{2});
            case 'serial'
                narginchk(2,2);
                transportObj=matlabshared.seriallib.internal.Serial(varargin{1});
            case 'udp'
                transportObj=matlabshared.network.internal.UDP(varargin{:});
            case 'udpbyte'
                transportObj=matlabshared.network.internal.UDPByte(varargin{:});
            otherwise

                throw(MException(message('transportlib:transport:invalidTransport','tcpip, serial, udp, udpbyte')));
            end
        end
    end
end