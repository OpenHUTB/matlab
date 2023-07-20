classdef(Abstract)TransportLayerInfo<handle&matlab.mixin.Heterogeneous






    methods(Static,Access=public)

        function ret=isTcp()

            ret=false;
        end

        function ret=isUdp()

            ret=false;
        end

        function ret=isSerial()

            ret=false;
        end

        function ret=isCAN()

            ret=false;
        end

        function obj=getTransportLayerInfoForModel(modelName,cs,codeGenFolder,defineMap)

            className=mfilename('class');
            validateattributes(modelName,{'char','string'},{'scalartext'},className,'modelName');
            validateattributes(cs,{'Simulink.ConfigSet'},{},className,'cs');
            validateattributes(defineMap,{'containers.Map'},{},className,'defineMap');



            extModeEnabled=strcmp(get_param(cs,'ExtMode'),'on');
            isXcpTarget=coder.internal.xcp.isXCPTarget(cs);
            if~extModeEnabled||~isXcpTarget
                DAStudio.error('coder_xcp:a2l:XCPTransportNotConfigured',modelName);
            end

            if(defineMap.isKey('XCP_ON_CAN'))
                obj=coder.internal.xcp.a2l.CANTransportLayerInfo();
            else

                extModeMexArgs=get_param(cs,'ExtModeMexArgs');
                index=get_param(cs,'ExtModeTransport');
                transport=Simulink.ExtMode.Transports.getExtModeTransport(cs,index);
                xcpExtModeArgs=coder.internal.xcp.parseExtModeArgs(extModeMexArgs,...
                transport,...
                modelName,...
                codeGenFolder);

                switch(xcpExtModeArgs.transport)
                case Simulink.ExtMode.Transports.XCPTCP.Transport
                    obj=coder.internal.xcp.a2l.TcpTransportLayerInfo(...
                    xcpExtModeArgs.targetName,...
                    xcpExtModeArgs.targetPort);
                case Simulink.ExtMode.Transports.XCPSerial.Transport
                    obj=coder.internal.xcp.a2l.SerialTransportLayerInfo(...
                    xcpExtModeArgs.baudRate);
                otherwise
                    assert(false,'Unsupported transport');
                end
            end
        end
    end
end
