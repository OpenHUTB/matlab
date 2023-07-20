classdef UdpportApp<matlabshared.transportapp.internal.SharedApp








    properties(Constant)
        DisplayName=string(message("transportapp:udpportapp:AppDisplayName").getString)
        TransportName="udpport"
        TransportInstance=string(message("transportapp:udpportapp:TransportInstance").getString)
        FormattedParametersDelimeter=","
        EnabledValue(1,1)string=message("transportapp:udpportapp:Enabled").getString()
        DisabledValue(1,1)string=message("transportapp:udpportapp:Disabled").getString()
    end

    properties(Access={?matlabshared.transportapp.internal.utilities.ITestable})


FormFactory



TransportProxyFactory




TransportParameters
    end


    methods
        function tabName=getAppTabName(obj)


            tabName=obj.DisplayName;
        end
    end

    methods
        function obj=UdpportApp()
            try
                instrument.internal.InstrumentBaseClass.attemptLicenseCheckout();
            catch ex
                if ex.identifier=="instrument:general:notlicensed"
                    ex=MException(message("transportapp:udpportapp:ICTLicenseRequired"));
                end
                throwAsCaller(ex);
            end
        end
    end


    methods
        function init(obj,hwMgrHandles)



            transportProperties=hwMgrHandles.DeviceInfo.CustomData.TransportProperties;

            obj.TransportParameters=obj.getTransportParameters(transportProperties);


            init@matlabshared.transportapp.internal.SharedApp(obj,hwMgrHandles);
        end
    end


    methods

        function toolstripForm=getToolstripForm(obj,~)




            communicationMode=obj.TransportProperties.CommunicationMode;
            toolstripForm=transportapp.udpport.internal.(communicationMode).utilities.factories.FormFactory.createToolstripForm(...
            obj.TransportName,obj.TransportInstance,...
            obj.TransportProperties.DestinationAddress,...
            obj.TransportProperties.DestinationPort);
            toolstripForm.ShowFlushButton=false;
        end

        function appSpaceForm=getAppSpaceForm(obj,~)



            communicationMode=obj.TransportProperties.CommunicationMode;
            appSpaceForm=...
            transportapp.udpport.internal.(communicationMode).utilities.factories.FormFactory.createAppSpaceForm();
        end

        function transportProxy=getTransportProxy(obj)




            communicationMode=obj.TransportProperties.CommunicationMode;
            transportProxy=...
            transportapp.udpport.internal.(communicationMode).utilities.factories.TransportProxyFactory.createTransportProxy(obj.Mediator,...
            obj.TransportProperties,obj.TransportParameters);
        end

        function[comment,code]=getConstructorCommentAndCode(obj)



            comment=obj.prepareConstructorComment();
            code=obj.prepareConstructorCode();
        end
    end


    methods(Access={?matlabshared.transportapp.internal.utilities.ITestable})
        function transportParams=getTransportParameters(~,transportProperties)





            import transportapp.udpport.internal.DescriptorValidator

            transportParams={};

            communicationMode=transportProperties.CommunicationMode;
            ipAddressVersion=transportProperties.IPAddressVersion;
            localHost=transportProperties.LocalHost;
            localPort=transportProperties.LocalPort;
            portSharing=transportProperties.EnablePortSharing;

            if communicationMode~="byte"
                transportParams(end+1)={communicationMode};
            end
            if ipAddressVersion~="IPV4"
                transportParams(end+1)={ipAddressVersion};
            end
            if~DescriptorValidator.isAuto(localHost)
                transportParams(end+1:end+2)={"LocalHost",localHost};
            end
            if~DescriptorValidator.isAuto(localPort)
                transportParams(end+1:end+2)={"LocalPort",str2double(localPort)};
            end
            if portSharing
                transportParams(end+1:end+2)={"EnablePortSharing",portSharing};
            end
        end

        function comment=prepareConstructorComment(obj)



            import transportapp.udpport.internal.DescriptorValidator

            localHost=obj.TransportProperties.LocalHost;
            localPort=obj.TransportProperties.LocalPort;
            portSharing=obj.TransportProperties.EnablePortSharing;
            communicationMode=obj.TransportProperties.CommunicationMode;
            ipAddressVersion=obj.TransportProperties.IPAddressVersion;
            transportInstance=obj.TransportInstance;


            if DescriptorValidator.isAuto(localHost)
                localHostComment=message("transportapp:udpportapp:LocalHostAuto").getString();
            else
                localHostComment=message("transportapp:udpportapp:LocalHostManual",...
                localHost).getString();
            end
            if DescriptorValidator.isAuto(localPort)
                localPortComment=message("transportapp:udpportapp:LocalPortAuto").getString();
            elseif localPort=="0"
                localPortComment=message("transportapp:udpportapp:LocalPortZero").getString();
            else
                localPortComment=message("transportapp:udpportapp:LocalPortManual",...
                localPort).getString();
            end


            if portSharing
                portSharingString=obj.EnabledValue;
            else
                portSharingString=obj.DisabledValue;
            end
            comment=message("transportapp:udpportapp:ConstructorComment",...
            transportInstance,...
            ipAddressVersion,...
            communicationMode,...
            localHostComment,...
            localPortComment,...
            lower(portSharingString)).getString();
        end

        function code=prepareConstructorCode(obj)







            paramString=obj.getFormatedConstructorParameters(obj.TransportParameters);
            code=message("transportapp:udpportapp:ConstructorCode",...
            obj.TransportInstance,paramString).getString();
        end

        function formattedParameters=getFormatedConstructorParameters(~,transportParameters)



            if isempty(transportParameters)
                formattedParameters="";
                return
            end

            for i=1:length(transportParameters)
                val=transportParameters{i};
                if isstring(val)


                    transportParameters{i}=""""+val+"""";
                end
            end

            formattedParameters=join(string(transportParameters),...
            transportapp.udpport.internal.UdpportApp.FormattedParametersDelimeter);
        end
    end
end
