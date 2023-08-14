classdef VisadevApp<matlabshared.transportapp.internal.SharedApp








    properties(Constant)
        DisplayName=string(message("transportapp:visadevapp:DisplayName").getString)
        TransportName=string(message("transportapp:visadevapp:TransportName").getString)
        TransportInstance=string(message("transportapp:visadevapp:TransportInstance").getString)
    end

    properties(Constant,Access=private)
        VISAInstallErrorID="transportapp:visadevapp:VISAInstallationError"
    end

    methods
        function obj=VisadevApp()


            if isunix&&~ismac
                throwAsCaller(MException(message("transportapp:visadevapp:LinuxNoSupport")));
            end

            try
                instrument.internal.InstrumentBaseClass.attemptLicenseCheckout();
            catch ex
                if ex.identifier=="instrument:general:notlicensed"
                    ex=MException(message("transportapp:visadevapp:ICTLicenseRequired"));
                end
                throwAsCaller(ex);
            end

            try


                transportapp.visadev.internal.VisadevApp.checkVisa();
            catch ex
                throwAsCaller(ex);
            end
        end
    end

    methods
        function tabName=getAppTabName(~)
            tabName=string(message("transportapp:visadevapp:DisplayName"));
        end

        function form=getToolstripForm(~,~)
            import matlabshared.transportapp.internal.utilities.forms.Entries

            form=matlabshared.transportapp.internal.utilities.forms.ToolstripForm();
            form.WriteSectionView=Entries("transportapp.visadev.internal.toolstrip.WriteView");
            form.WriteSectionController=Entries("transportapp.visadev.internal.toolstrip.WriteController");

            form.ReadSectionView=Entries("transportapp.visadev.internal.toolstrip.ReadView");
            form.ReadSectionController=Entries("transportapp.visadev.internal.toolstrip.ReadController");
        end

        function form=getAppSpaceForm(~,~)
            form=matlabshared.transportapp.internal.utilities.forms.AppSpaceForm;

            form.ReadWarningIDs=["instrument:interface:visa:operationTimedOut","transportlib:client:ReadWarning"];
        end

        function transport=getTransportProxy(obj)

            props=obj.TransportProperties;
            v=visadev(props.ResourceName);


            proxyConstructor=obj.getTransportProxyConstructor(v.Type);


            transport=proxyConstructor(v,obj.Mediator);
        end

        function[comment,code]=getConstructorCommentAndCode(obj)
            comment=message("transportapp:visadevapp:ConstructorComment");
            code=obj.TransportInstance+" = visadev("""+obj.TransportProperties.ResourceName+""")";
        end
    end

    methods(Access=protected)
        function codeGenerator=constructCodeGenerator(obj)

            codeGenerator=transportapp.visadev.internal.utilities.MATLABCodeGenerator...
            (obj.Mediator,obj.DisplayName,obj.TransportName,obj.TransportInstance);
        end
    end

    methods(Access=private)

        function proxyConstructor=getTransportProxyConstructor(~,visaInterface)
            import visalib.InterfaceType
            import transportapp.visadev.internal.utilities.*


            switch visaInterface
            case InterfaceType.gpib
                proxyConstructor=@transport.GPIB;

            case InterfaceType.serial
                proxyConstructor=@transport.Serial;

            case InterfaceType.tcpip
                proxyConstructor=@transport.TCPIP;

            case InterfaceType.usb
                proxyConstructor=@transport.USB;

            case InterfaceType.vxi
                proxyConstructor=@transport.VXI;

            case InterfaceType.pxi
                proxyConstructor=@transport.PXI;

            case InterfaceType.socket
                proxyConstructor=@transport.Socket;

            otherwise
                assert(false,"Unepected VISA interface: "+string(visaInterface));

            end
        end
    end

    methods(Static)
        function checkVisa()






            persistent checked

            if~isempty(checked)
                return
            end












            interfaceType=uint16(1);
            resourceType="INSTR";
            interfaceNum=uint16(0);

            try
                visalib.internal.ConflictManager.findVisaForResource(interfaceType,interfaceNum,resourceType);
            catch ex
                switch ex.identifier
                case 'instrument:interface:visa:noVisaLibraryFoundForResource'



                otherwise


                    throw(MException(message(transportapp.visadev.internal.VisadevApp.VISAInstallErrorID)));

                end
            end

            checked=true;

        end
    end
end