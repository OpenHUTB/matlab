classdef TCPServerCustomClient<matlabshared.transportlib.internal.client.GenericClient&...
    instrument.internal.InstrumentBaseClass









    properties

        ServerAddress(1,1)string


ServerPort


        Connected(1,1)logical=false


        ClientAddress(1,1)string


        ClientPort=[]



        ConnectionChangedFcn=function_handle.empty()
    end

    properties(Access=private)

ConnectionInfoListener
    end


    methods
        function value=get.ServerAddress(obj)
            value=getCustomProperty(obj,"Address");
        end

        function value=get.ServerPort(obj)
            value=getCustomProperty(obj,"PortNumber");
        end
    end


    methods
        function obj=TCPServerCustomClient(clientProperties)




            obj@matlabshared.transportlib.internal.client.GenericClient(clientProperties);

            obj.ConnectionInfoListener=event.listener(obj.Client.EventHandler,'ConnectionInfo',...
            @(src,evt)obj.connectionCallbackFunction(src,evt));
        end

        function delete(obj)
            obj.ConnectionInfoListener=[];
        end
    end


    methods(Access=private)
        function connectionCallbackFunction(obj,~,evt)




            obj.ClientAddress=evt.ClientAddress;
            obj.ClientPort=evt.ClientPort;
            obj.Connected=evt.Connected;

            if~isempty(obj.ConnectionChangedFcn)
                obj.ConnectionChangedFcn(obj.CallbackSource,evt);
            end
        end
    end
end