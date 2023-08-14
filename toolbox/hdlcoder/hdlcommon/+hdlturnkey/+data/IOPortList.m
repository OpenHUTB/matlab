


classdef IOPortList<hdlturnkey.data.IOPortListBase


    properties

        NumClock=0;
        NumClockEnb=0;
        NumReset=0;
        NumCE_Out=0;

        CEOutPortNameList={};
    end

    methods

        function obj=IOPortList()

            obj=obj@hdlturnkey.data.IOPortListBase();
        end

        function buildIOPortList(obj,p,hDI,emlPortInfo)


            if nargin<4


                topNet=p.getTopNetwork;
                topNetFullPath=hdlturnkey.data.getTopNetFullPath(topNet,hDI);


                topNetInPort=topNet.PirInputPorts;
                for ii=1:length(topNetInPort)
                    ioPort=topNetInPort(ii);
                    ioSignal=topNet.PirInputSignals(ii);
                    obj.addIOPortFromPir(ioPort,ioSignal,hdlturnkey.IOType.IN,topNetFullPath,hDI);
                end


                topNetOutPort=topNet.PirOutputPorts;
                for ii=1:length(topNetOutPort)
                    ioPort=topNetOutPort(ii);
                    ioSignal=topNet.PirOutputSignals(ii);
                    obj.addIOPortFromPir(ioPort,ioSignal,hdlturnkey.IOType.OUT,topNetFullPath,hDI);

                    if(strcmp(ioPort.Kind,'clock_enable'))
                        obj.CEOutPortNameList{end+1}=ioPort.Name;
                    end
                end

                obj.NumClock=topNet.NumberOfPirInputPorts('clock');
                obj.NumClockEnb=topNet.NumberOfPirInputPorts('clock_enable');
                obj.NumReset=topNet.NumberOfPirInputPorts('reset');
                obj.NumCE_Out=topNet.NumberOfPirOutputPorts('clock_enable');
            else

                obj.addIOPortFromEMLPortInfo(emlPortInfo);

                obj.NumClock=0;
                obj.NumClockEnb=0;
                obj.NumReset=0;
                obj.NumCE_Out=0;
            end
        end

        function modifyIOPortList(obj,p)






            topNet=p.getTopNetwork;



            portInformation=streamingmatrix.getStreamedPorts(topNet);


            modifyIOValidReadyPorts(obj,portInformation.streamedInPorts)


            modifyIOValidReadyPorts(obj,portInformation.streamedOutPorts)

        end

        function addTunableParamPortList(obj,hTunableParamPortList)


            for ii=1:length(hTunableParamPortList.TunableParamNameList)
                obj.addIOPort(hTunableParamPortList.TunableParamPortMap(hTunableParamPortList.TunableParamNameList{ii}));
            end
        end

        function addTestPointPortList(obj,hTestPointPortList)


            if~isempty(hTestPointPortList)
                hTestPointPorts=hTestPointPortList.TestPointPorts;
                numTestPointPorts=numel(hTestPointPorts);
                for ii=1:numTestPointPorts
                    obj.addIOPort(hTestPointPorts{ii});
                end
            end
        end

    end

    methods(Access=protected)

        function addIOPortFromPir(obj,ioPort,ioSignal,ioType,topNetFullPath,hDI)









            portType=ioSignal.Type;
            if portType.isRecordType
                hDataType=hdlturnkey.data.TypeBus();
            else
                hDataType=hdlturnkey.data.TypeFixedPt();
            end
            hDataType.initFromPirType(portType);

            portType=ioSignal.Type;
            typeInfo=pirgetdatatypeinfo(portType);
            issingle=(typeInfo.isfloat)&&(typeInfo.wordsize==32)&&(typeInfo.binarypoint==23);
            isdouble=(typeInfo.isfloat)&&(typeInfo.wordsize==64)&&(typeInfo.binarypoint==52);
            ishalf=(typeInfo.isfloat)&&(typeInfo.wordsize==16)&&(typeInfo.binarypoint==10);
            ioPortBiDirectional=ioPort.getBidirectional;


            if typeInfo.isvector
                dispTypeStr=sprintf('%s (%d)',typeInfo.sltype,typeInfo.dims);
            elseif typeInfo.ismatrix
                dispTypeStr=sprintf('%s [%d x %d]',typeInfo.sltype,...
                typeInfo.dims(1),typeInfo.dims(2));
            elseif portType.isRecordType
                dispTypeStr=sprintf('bus');
            else
                dispTypeStr=typeInfo.sltype;
            end







            streamedPort=false;
            if(hDI.hTurnkey.hStream.isFrameToSampleMode)
                if(ioType==hdlturnkey.IOType.OUT)||ioPort.hasStreamingMatrixTag
                    dispTypeStr=[dispTypeStr,' (streamed port)'];
                    streamedPort=true;
                end
            end








            portName=downstream.tool.removeChangeOfLine(ioPort.Name);
            portFullName=sprintf('%s/%s',topNetFullPath,ioPort.Name);
            obj.addIOPort(hdlturnkey.data.IOPort(...
            'PortName',portName,...
            'PortFullName',portFullName,...
            'PortRate',ioSignal.SimulinkRate,...
            'PortType',ioType,...
            'PortIndex',ioPort.PortIndex,...
            'PortKind',ioPort.Kind,...
            'Signed',typeInfo.issigned,...
            'WordLength',typeInfo.wordsize,...
            'FractionLength',typeInfo.binarypoint,...
            'isBoolean',portType.isBooleanType,...
            'isComplex',typeInfo.iscomplex,...
            'isDouble',isdouble,...
            'isSingle',issingle,...
            'isHalf',ishalf,...
            'isVector',typeInfo.isvector,...
            'isMatrix',typeInfo.ismatrix,...
            'isBus',portType.isRecordType,...
            'isArrayOfBus',portType.isArrayOfRecords,...
            'isStreamedPort',streamedPort,...
            'Type',hDataType,...
            'Dimension',typeInfo.dims,...
            'SLDataType',typeInfo.sltype,...
            'DispDataType',dispTypeStr,...
            'Bidirectional',ioPortBiDirectional,...
            'IOInterface',ioPort.getIOInterface,...
            'IOInterfaceMapping',ioPort.getIOInterfaceMapping));
        end

        function addIOPortFromEMLPortInfo(obj,emlportInfo)

            for i=1:length(emlportInfo)
                portInfo=emlportInfo(i);


                if portInfo.isVector
                    dispTypeStr=sprintf('%s (%d)',portInfo.SLDataType,portInfo.Dimension);
                else
                    dispTypeStr=portInfo.SLDataType;
                end

                obj.addIOPort(hdlturnkey.data.IOPort(...
                'PortName',portInfo.PortName,...
                'PortRate',1,...
                'PortType',portInfo.PortType,...
                'PortIndex',portInfo.PortIndex,...
                'PortKind','data',...
                'Signed',portInfo.Signed,...
                'WordLength',portInfo.WordLength,...
                'FractionLength',portInfo.FractionLength,...
                'isBoolean',portInfo.isBoolean,...
                'isComplex',portInfo.isComplex,...
                'isDouble',portInfo.isDouble,...
                'isSingle',portInfo.isSingle,...
                'isHalf',portInfo.isHalf,...
                'isVector',portInfo.isVector,...
                'Dimension',portInfo.Dimension,...
                'SLDataType',portInfo.SLDataType,...
                'DispDataType',dispTypeStr));
            end
        end

        function modifyIOValidReadyPorts(obj,streamedPorts)

            for ii=1:length(streamedPorts)

                dataInterface=streamedPorts(ii).data.getIOInterface;

                hIOPort=obj.getIOPort(streamedPorts(ii).valid.Name);
                hIOPort.IOInterface=dataInterface;
                hIOPort.IOInterfaceMapping='Valid';
                obj.IOPortMap(hIOPort.PortName)=hIOPort;

                hIOPort=obj.getIOPort(streamedPorts(ii).ready.Name);
                hIOPort.IOInterface=dataInterface;
                hIOPort.IOInterfaceMapping='Ready';
                obj.IOPortMap(hIOPort.PortName)=hIOPort;
            end
        end
    end
end
