classdef IFDataXCPBuilder<handle







    methods(Access=public)
        function obj=IFDataXCPBuilder()



        end

        function build(~,defineMap,periodicEventList,transportLayerInfo,typeInfo,ifdataxcp)

            className=mfilename('class');
            validateattributes(defineMap,{'containers.Map'},{},className,'defineMap');
            validateattributes(periodicEventList,{'coder.internal.xcp.a2l.PeriodicEventList'},{},className,'periodicEventList');
            validateattributes(transportLayerInfo,{'coder.internal.xcp.a2l.TransportLayerInfo'},{},className,'transportLayerInfo');
            validateattributes(ifdataxcp,{'asam.mcd2mc.ifdata.xcp.IFDataXCPInfo'},{},className,'ifdataxcp');

            ifdataxcp.ProtocolLayer=asam.mcd2mc.create('ProtocolLayerInfo');
            protocolLayerBuilder=coder.internal.xcp.a2l.slcoderslave.ProtocolLayerBuilder();
            protocolLayerBuilder.build(defineMap,typeInfo,ifdataxcp.ProtocolLayer);

            if protocolLayerBuilder.HasDaqSupport



                eventBuilder=coder.internal.xcp.a2l.EventBuilder;
                eventObjs=asam.mcd2mc.ifdata.xcp.EventInfo.empty;
                for kEvt=1:periodicEventList.NumEvents

                    eventObjs(end+1)=asam.mcd2mc.create('EventInfo');%#ok<AGROW>


                    eventBuilder.build(...
                    periodicEventList.TIDs(kEvt),...
                    periodicEventList.Rates(kEvt),...
                    eventObjs(end));
                end


                timeStampSupported=asam.mcd2mc.create('TimeStampSupportedInfo');
                tssBuilder=coder.internal.xcp.a2l.slcoderslave.TimeStampSupportedBuilder();


                tssBuilder.build(defineMap,timeStampSupported);


                ifdataxcp.Daq=asam.mcd2mc.create('DaqInfo');
                daqBuilder=coder.internal.xcp.a2l.slcoderslave.DaqBuilder();
                daqBuilder.build(defineMap,eventObjs,timeStampSupported,ifdataxcp.Daq);
            end


            if transportLayerInfo.isTcp()
                xcpOnTcpIp=asam.mcd2mc.create('XCPOnTCPIPInfo');
                xcpOnTcpIpBuilder=coder.internal.xcp.a2l.XCPOnEthernetBuilder();
                xcpOnTcpIpBuilder.build(transportLayerInfo.Address,transportLayerInfo.Port,xcpOnTcpIp);
                ifdataxcp.XCPOnPhysical=xcpOnTcpIp;
            elseif transportLayerInfo.isSerial()
                xcpOnSxi=asam.mcd2mc.create('XCPOnSxIInfo');
                xcpOnSxiBuilder=coder.internal.xcp.a2l.slcoderslave.XCPOnSxIBuilder();
                xcpOnSxiBuilder.build(defineMap,transportLayerInfo.BaudRate,xcpOnSxi);
                ifdataxcp.XCPOnPhysical=xcpOnSxi;
            elseif transportLayerInfo.isCAN()
                xcpOnCAN=asam.mcd2mc.create('XCPOnCANInfo');
                xcpOnCANBuilder=coder.internal.xcp.a2l.slcoderslave.XCPOnCANBuilder();
                xcpOnCANBuilder.build(defineMap,xcpOnCAN);
                ifdataxcp.XCPOnPhysical=xcpOnCAN;
            end
        end
    end

end
