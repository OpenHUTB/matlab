classdef UDPPortCommon<handle&instrument.internal.InstrumentBaseClass






    properties

        Transport=[]


        RemoteHost=""


        RemotePort=[]
    end


    methods
        function obj=UDPPortCommon(transport)
            obj.Transport=transport;
        end
    end


    methods
        function write(obj,varargin)































































            try
                narginchk(2,5);
            catch
                throwAsCaller(getWriteNarginError(obj));
            end
            data=varargin{1};
            precision="uint8";
            try
                switch nargin
                case 2

                    checkEmptyRemoteHostAndPort(obj,"write");
                case 3

                    checkEmptyRemoteHostAndPort(obj,"write");
                    precision=varargin{2};
                case 4

                    setRemoteEndpoint(obj,varargin{2},varargin{3});
                case 5

                    setRemoteEndpoint(obj,varargin{3},varargin{4});
                    precision=varargin{2};
                end
                write(obj.Transport,data,precision);
            catch ex
                throw(ex);
            end
        end

        function configureMulticast(obj,varargin)
































            if~ispc
                throwAsCaller(MException(message(...
                "instrument:interface:udpport:PlatformNotSupported")));
            end
            try
                narginchk(2,3);
            catch
                throwAsCaller(getConfigureMulticastNarginError(obj));
            end

            try
                validateattributes(varargin{1},{'char','string'},{'nonempty'},mfilename,"MULTICASTGROUP",2);
            catch ex
                throwAsCaller(MException("instrument:interface:udpport:InvalidEntry",ex.message));
            end

            switch nargin
            case 2


                if string(varargin{1})=="off"
                    try


                        resetMulticast(obj.Transport);
                        setEnableLoopback(obj.Transport,false);
                    catch ex
                        throwAsCaller(ex);
                    end
                    return
                end


                try
                    setMulticast(obj.Transport,varargin{1});
                catch ex
                    throwAsCaller(MException(message("instrument:interface:udpport:InvalidMulticastAddressGroup",varargin{1},ex.message)));
                end
                setEnableLoopback(obj.Transport,true);
            case 3

                if string(varargin{1})=="off"
                    throwAsCaller(MException(message("instrument:interface:udpport:InvalidMulticastSyntaxOff")));
                end

                try
                    setMulticast(obj.Transport,varargin{1});
                catch ex
                    throwAsCaller(MException(message("instrument:interface:udpport:InvalidMulticastAddressGroup",varargin{1},ex.message)));
                end

                try
                    validateattributes(varargin{2},{'logical'},{'nonempty'},mfilename,'ENABLEMULTICASTLOOPBACK');
                    setEnableLoopback(obj.Transport,varargin{2});
                catch ex
                    throwAsCaller(MException("instrument:interface:udpport:InvalidEntry",ex.message));
                end
            end
        end
    end


    methods
        function checkEmptyRemoteHostAndPort(obj,functionName)


            if obj.RemoteHost==""||isempty(obj.RemotePort)
                switch functionName
                case "write"
                    validSyntax=message("instrument:interface:udpport:EmptyRemoteHostWriteSyntax").getString;
                case "writeline"
                    validSyntax=message("instrument:interface:udpport:EmptyRemoteHostWritelineSyntax").getString;
                end
                throw(MException(message("instrument:interface:udpport:EmptyRemoteHostAndPort",functionName,...
                validSyntax)));
            end
        end

        function setRemoteEndpoint(obj,remoteHost,remotePort)


            try
                validateattributes(remoteHost,{'string','char'},{'nonempty'},mfilename,"DESTINATIONADDRESS");
                validateBroadcastAddress(obj,remoteHost);
            catch ex
                throw(ex);
            end

            try
                setRemoteEndpoint(obj.Transport,remoteHost,remotePort);
            catch ex
                mExc=MException(message("instrument:interface:udpport:InvalidRemoteEndpoint",ex.message));
                throwAsCaller(mExc);
            end
            obj.RemoteHost=remoteHost;
            obj.RemotePort=remotePort;
        end

        function initProperties(obj,varargin)





            if mod(numel(varargin),2)
                throwAsCaller(MException(message("instrument:interface:udpport:UnmatchedPVPairs")));
            end

            try
                p=inputParser;
                p.PartialMatching=true;
                addParameter(p,'LocalPort',0);

                if obj.Transport.AddressType=="IPV4"
                    addParameter(p,'LocalHost',"0.0.0.0");
                else
                    addParameter(p,'LocalHost',"::");
                end
                addParameter(p,'OutputDatagramSize',512,...
                @(x)validateOutputDatagramSize(obj,x));
                addParameter(p,'EnablePortSharing',false);
                addParameter(p,'ByteOrder','little-endian');
                addParameter(p,'Timeout',10,...
                @(x)validateTimeout(obj,x));
                parse(p,varargin{:});
                output=p.Results;
            catch parserEx
                throwAsCaller(parserEx);
            end

            try
                obj.Transport.LocalPort=output.LocalPort;
                obj.Transport.LocalHost=output.LocalHost;
                obj.Transport.OutputDatagramPacketSize=output.OutputDatagramSize;
                obj.Transport.EnablePortSharing=output.EnablePortSharing;
                obj.Transport.ByteOrder=output.ByteOrder;
                obj.Transport.Timeout=output.Timeout;
            catch ex
                mExc=MException("instrument:interface:udpport:InvalidEntry",ex.message);
                throwAsCaller(mExc);
            end
        end
    end


    methods(Access=private)
        function ex=getWriteNarginError(~)

            validSyntaxes=message("instrument:interface:udpport:WriteSyntax").getString;
            ex=MException(message("instrument:interface:udpport:IncorrectInputArgumentsPlural",...
            "write",validSyntaxes));
        end

        function ex=getConfigureMulticastNarginError(~)

            validSyntaxes=message("instrument:interface:udpport:ConfigureMulticastSyntax").getString;
            ex=MException(message("instrument:interface:udpport:IncorrectInputArgumentsPlural",...
            "configureMulticast",validSyntaxes));
        end
    end


    methods(Access=private)
        function validateOutputDatagramSize(~,value)


            try
                validateattributes(value,{'numeric'},...
                {'scalar','positive','nonnan','finite','integer',...
                "<=",65507},"","OUTPUTDATAGRAMSIZE")
            catch ex
                mExc=MException("instrument:interface:udpport:InvalidEntry",ex.message);
                throwAsCaller(mExc);
            end
        end

        function validateTimeout(~,value)




            try
                validateattributes(value,{'double'},{'positive'},mfilename,"TIMEOUT");
            catch ex
                mExc=MException("instrument:interface:udpport:InvalidEntry",ex.message);
                throwAsCaller(mExc);
            end
        end

        function validateBroadcastAddress(obj,address)






            if~obj.Transport.EnableBroadcast&&...
                obj.Transport.AddressType=="IPV4"&&...
                string(address)=="255.255.255.255"
                throwAsCaller(MException(message("instrument:interface:udpport:EnableBroadcast")));
            end
        end
    end
end