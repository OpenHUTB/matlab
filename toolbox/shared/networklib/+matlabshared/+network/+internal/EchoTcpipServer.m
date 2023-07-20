classdef EchoTcpipServer<matlabshared.network.internal.IDestroyable





    properties(Access=private)
Channel
    end

    properties
PortNumber
    end

    properties(Constant)


        EchoServerID=0
    end
    methods
        function obj=EchoTcpipServer(port)



            obj.PortNumber=port;


            devicePlugin=fullfile(toolboxdir(fullfile(...
            'shared','networklib','bin',computer('arch'))),'tcpserverdevice');
            converterPlugin=fullfile(toolboxdir(fullfile(...
            'shared','networklib','bin',computer('arch'))),'networkarrayconverter');

            options.PortNumber=obj.PortNumber;
            options.ServerType=obj.EchoServerID;


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