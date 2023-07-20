classdef EchoUdpServer<matlabshared.network.internal.IDestroyable





    properties(Access=private)
Channel
    end

    properties
PortNumber
    end

    properties(Constant)


        EchoServerID=0


        ProtocolType=1
        RemoteHost='::1'
        LocalHost='::'


        RemotePort=9090


        Mode=1


        SocketType=0
    end
    methods
        function obj=EchoUdpServer(port)



            obj.PortNumber=port;


            devicePlugin=fullfile(toolboxdir(fullfile(...
            'shared','networklib','bin',computer('arch'))),'udpdevice');
            converterPlugin=fullfile(toolboxdir(fullfile(...
            'shared','networklib','bin',computer('arch'))),'networkmlconverter');

            options.PortNumber=obj.PortNumber;
            options.ServerType=obj.EchoServerID;
            options.RemoteHost=obj.RemoteHost;
            options.RemotePort=obj.RemotePort;
            options.LocalPort=obj.PortNumber;
            options.ProtocolType=obj.ProtocolType;
            options.Mode=obj.Mode;
            options.SocketType=obj.SocketType;
            options.EnablePortSharing=true;


            obj.Channel=matlabshared.asyncio.internal.Channel(devicePlugin,...
            converterPlugin,...
            Options=options);


            obj.Channel.InputStream.Timeout=Inf;
            obj.Channel.OutputStream.Timeout=Inf;





            obj.Channel.DataEventsDisabled=true;
            obj.Channel.open(options);
        end

        function delete(obj)


            destroy(obj);
        end

        function destroy(obj)



            if~isempty(obj.Channel)
                obj.Channel.OutputStream.drain();
                obj.Channel.close();
            end
            obj.Channel=[];
        end
    end
end