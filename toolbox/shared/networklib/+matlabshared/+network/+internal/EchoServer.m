classdef EchoServer<handle







    methods(Static)

        function manageTransportLifetime(varargin)



            narginchk(2,3);


            varargin=instrument.internal.stringConversionHelpers.str2char(varargin);
            type=varargin{1};
            action=varargin{2};
            port=[];

            if nargin==3
                port=varargin{3};
            end

            type=validatestring(type,{'TCP','UDP'},mfilename,'type',1);


            action=validatestring(action,{'create','destroy'},mfilename,'action',2);


            persistent echoTcpipServer;
            persistent echoUdpServer;

            switch type


            case "TCP"


                echoTcpipServer=matlabshared.network.internal.EchoServer...
                .tcpHandler(echoTcpipServer,action,port);


            case "UDP"


                echoUdpServer=matlabshared.network.internal.EchoServer...
                .udpHandler(echoUdpServer,action,port);
            end
        end
    end

    methods(Static,Access='private')

        function echoServer=tcpHandler(echoServer,action,port)




            if strcmp(action,"create")

                echoServer=...
                matlabshared.network.internal.EchoServer.createTcp(echoServer,port);
            else

                echoServer=...
                matlabshared.network.internal.EchoServer.destroyTcp(echoServer);
            end
        end

        function echoServer=udpHandler(echoServer,action,port)




            if strcmp(action,"create")

                echoServer=...
                matlabshared.network.internal.EchoServer.createUdp(echoServer,port);
            else

                echoServer=...
                matlabshared.network.internal.EchoServer.destroyUdp(echoServer);
            end
        end

        function echoTcpipServer=createTcp(echoTcpipServer,port)


            try

                validateattributes(port,{'numeric'},{'>=',1,'<=',...
                65535,'scalar','nonnegative','finite'},mfilename,...
                'port number',3);
            catch
                throw(MException('instrument:echotcpip:invalidSyntax',...
                message('network:echotcpip:invalidSyntax').getString));
            end

            if isempty(echoTcpipServer)

                try
                    echoTcpipServer=matlabshared.network.internal.EchoTcpipServer(port);
                catch ex
                    throw(MException('instrument:echotcpip:createError',ex.message));
                end
            else

                throw(MException('instrument:echotcpip:running',...
                message('network:echotcpip:running',num2str(echoTcpipServer.PortNumber)).getString));
            end
        end

        function echoTcpipServer=destroyTcp(echoTcpipServer)


            if~isempty(echoTcpipServer)

                echoTcpipServer.destroy();
            end
            echoTcpipServer=[];
        end

        function echoUdpServer=createUdp(echoUdpServer,port)


            try

                validateattributes(port,{'numeric'},{'>=',1,'<=',...
                65535,'scalar','nonnegative','finite'},mfilename,...
                'port number',3);
            catch
                throw(MException('instrument:echoudp:invalidSyntaxPortRange',...
                message('network:echoudp:invalidSyntaxPortRange').getString));
            end

            if isempty(echoUdpServer)

                try
                    echoUdpServer=matlabshared.network.internal.EchoUdpServer(port);
                catch ex
                    throw(MException('instrument:echoudp:createError',ex.message));
                end
            else

                throw(MException('instrument:echoudp:running',...
                message('network:echoudp:running',num2str(echoUdpServer.PortNumber)).getString));
            end
        end

        function echoUdpServer=destroyUdp(echoUdpServer)

            if~isempty(echoUdpServer)


                echoUdpServer.destroy();
            end
            echoUdpServer=[];
        end
    end
end