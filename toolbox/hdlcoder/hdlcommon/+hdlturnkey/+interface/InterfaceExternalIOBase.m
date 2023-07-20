



























classdef(Abstract)InterfaceExternalIOBase<hdlturnkey.interface.InterfaceIOBase

    properties


        PortName='';

        FPGAPin={};
        IOPadConstraint={};

    end

    properties(Hidden=true)


        InOutSplitInputPortWidth=0;
        InOutSplitOutputPortWidth=0;



        PinName='';

    end

    methods

        function obj=InterfaceExternalIOBase(varargin)


            p=inputParser;
            p.addParameter('InterfaceID','');
            p.addParameter('InterfaceType','');
            p.addParameter('PortName','');
            p.addParameter('PinName','');
            p.addParameter('PortWidth',0);
            p.addParameter('FPGAPin',{});
            p.addParameter('IOPadConstraint',{});


            p.addParameter('IsRequired',false);

            p.parse(varargin{:});
            inputArgs=p.Results;

            obj=obj@hdlturnkey.interface.InterfaceIOBase(...
            inputArgs.InterfaceID,...
            inputArgs.InterfaceType,...
            inputArgs.PortWidth);

            obj.PortName=inputArgs.PortName;
            obj.FPGAPin=inputArgs.FPGAPin;
            obj.IOPadConstraint=inputArgs.IOPadConstraint;
            obj.IsRequired=inputArgs.IsRequired;


            if isempty(obj.FPGAPin)
                obj.isConstrainAttached=true;
            end

            if isempty(obj.PinName)
                obj.PinName=obj.PortName;
            end







        end

    end


    methods

        function validatePortForInterface(obj,hIOPort,~)






            portWidth=hIOPort.WordLength;
            portDimension=hIOPort.Dimension;
            interfaceWidth=obj.ChannelWidth;


            if portWidth*portDimension>interfaceWidth
                error(message('hdlcommon:workflow:BitWidthNotFit',obj.InterfaceID,...
                obj.ChannelWidth,hIOPort.PortName,portWidth*portDimension));
            end
        end
    end


    methods

    end


    methods

    end


    methods

    end


    methods

        function elaborate(obj,hN,hElab)


            hInterfaceSignal=obj.addInterfacePort(hN,hElab);


            if~hElab.hTurnkey.hTable.hTableMap.isAssignedInterface(obj.InterfaceID)
                return;
            end


            obj.connectInterfacePort(hN,hElab,hInterfaceSignal);

        end

        function hInterfaceSignal=addInterfacePort(obj,hN,hElab)



            obj.InportNames={};
            obj.InportWidths={};
            obj.OutportNames={};
            obj.OutportWidths={};



            obj.getSortedDutInputOutputIOPort;

            if isempty(obj.DutInputPortList)





                obj.OutportNames{1}=obj.PortName;
                obj.OutportWidths{1}=obj.PortWidth;

            elseif isempty(obj.DutOutputPortList)




                obj.InportNames{1}=obj.PortName;
                obj.InportWidths{1}=obj.PortWidth;

            else


                obj.getINOUTInterfaceSplitPortWidth(hElab);

                obj.InportNames{1}=sprintf('%s_in',obj.PortName);
                obj.InportWidths{1}=obj.InOutSplitInputPortWidth;
                obj.OutportNames{1}=sprintf('%s_out',obj.PortName);
                obj.OutportWidths{1}=obj.InOutSplitOutputPortWidth;
            end


            hInterfaceSignal=pirelab.addIOPortToNetwork(...
            'Network',hN,...
            'InportNames',obj.InportNames,...
            'InportWidths',obj.InportWidths,...
            'OutportNames',obj.OutportNames,...
            'OutportWidths',obj.OutportWidths);
        end

        function connectInterfacePort(obj,hN,hElab,hInterfaceSignal)




            if isempty(obj.DutInputPortList)




                obj.connectOutputInterfacePort(hN,hElab,hInterfaceSignal);

            elseif isempty(obj.DutOutputPortList)




                obj.connectInputInterfacePort(hN,hElab,hInterfaceSignal);

            else


                obj.connectINOUTInterfacePort(hN,hElab,hInterfaceSignal);
            end

        end

        function connectINOUTInterfacePort(obj,hN,hElab,hInterfaceSignal)



            hInportSignals=hInterfaceSignal.hInportSignals;
            hOutportSignals=hInterfaceSignal.hOutportSignals;


            bitStart=0;
            for ii=1:length(obj.DutInputPortList)
                dutPortName=obj.DutInputPortList{ii};



                hDutPortSignals=hElab.getCodegenPirSignalForPort(dutPortName);
                hDutPortSignal=hDutPortSignals{1};


                bitRangeData=hElab.hTurnkey.hTable.hTableMap.getBitRangeData(dutPortName);

                bitRangeLSB=bitRangeData{1};
                bitRangeMSB=bitRangeData{2};
                bitWidth=bitRangeMSB-bitRangeLSB+1;
                bitEnd=bitStart+bitWidth-1;


                pirtarget.getInPortBitSliceComp(hN,hInportSignals,hDutPortSignal,bitEnd,bitStart);

                bitStart=bitEnd+1;
            end


            hInSignals={};
            for ii=1:length(obj.DutOutputPortList)
                dutPortName=obj.DutOutputPortList{ii};



                hDutPortSignals=hElab.getCodegenPirSignalForPort(dutPortName);
                hDutPortSignal=hDutPortSignals{1};


                hInSignals{end+1}=hDutPortSignal;%#ok<*AGROW>
            end


            pirtarget.getOutPortBitConcatComp(hN,hInSignals,hOutportSignals);

        end

    end


    methods

        function constrainCell=generateFPGAPinConstrain(obj,hElab)









            if isempty(obj.FPGAPin)
                constrainCell={};
                return;
            end


            if~iscell(obj.IOPadConstraint)
                error(message('hdlcommon:hdlturnkey:InvalidIOPadConstrain',...
                obj.InterfaceID,'{''IOSTANDARD = LVCMOS33''}',...
                '{{''IOSTANDARD = LVCMOS25''}, {''IOSTANDARD = LVCMOS15''}}'));
            end


            if obj.isIOPadConstrainPinSpecific(obj.IOPadConstraint)&&...
                ~isequal(length(obj.IOPadConstraint),length(obj.FPGAPin))
                error(message('hdlcommon:hdlturnkey:IOPadConstrainNum',obj.InterfaceID,...
                '{{''IOSTANDARD = LVCMOS25''}, {''IOSTANDARD = LVCMOS15''}}'));
            end

            if~obj.isINOUTInterface

                obj.FPGAPinMap={{obj.PinName,obj.FPGAPin,obj.IOPadConstraint}};
            else

                obj.FPGAPinMap={};


                obj.getINOUTPortFPGAPinConstrain(hElab,obj.DutInputPortList,obj.InportNames{1});


                obj.getINOUTPortFPGAPinConstrain(hElab,obj.DutOutputPortList,obj.OutportNames{1});
            end


            constrainCell=obj.getFPGAPinConstraintCell;

        end

    end


    methods(Access=protected)

        function getINOUTInterfaceSplitPortWidth(obj,hElab)



            inputInterfaceWidth=0;
            for ii=1:length(obj.DutInputPortList)
                dutPortName=obj.DutInputPortList{ii};

                bitRangeData=hElab.hTurnkey.hTable.hTableMap.getBitRangeData(dutPortName);

                bitRangeLSB=bitRangeData{1};
                bitRangeMSB=bitRangeData{2};
                bitWidth=bitRangeMSB-bitRangeLSB+1;
                inputInterfaceWidth=inputInterfaceWidth+bitWidth;
            end


            outputInterfaceWidth=0;
            for ii=1:length(obj.DutOutputPortList)
                dutPortName=obj.DutOutputPortList{ii};

                bitRangeData=hElab.hTurnkey.hTable.hTableMap.getBitRangeData(dutPortName);

                bitRangeLSB=bitRangeData{1};
                bitRangeMSB=bitRangeData{2};
                bitWidth=bitRangeMSB-bitRangeLSB+1;
                outputInterfaceWidth=outputInterfaceWidth+bitWidth;
            end

            obj.InOutSplitInputPortWidth=inputInterfaceWidth;
            obj.InOutSplitOutputPortWidth=outputInterfaceWidth;
        end

        function getINOUTPortFPGAPinConstrain(obj,hElab,portList,portName)

            bitStart=0;
            fpgaPinCell={};
            fpgaIOConstraintCell={};
            for ii=1:length(portList)
                modelPortName=portList{ii};

                bitRangeData=hElab.hTurnkey.hTable.hTableMap.getBitRangeData(modelPortName);

                bitRangeLSB=bitRangeData{1};
                bitRangeMSB=bitRangeData{2};
                bitWidth=bitRangeMSB-bitRangeLSB+1;
                bitEnd=bitStart+bitWidth-1;
                bitstep=0;

                for jj=bitStart:bitEnd
                    fpgaPinCell{end+1}=obj.FPGAPin{bitRangeLSB+1+bitstep};
                    if obj.isIOPadConstrainPinSpecific(obj.IOPadConstraint)
                        fpgaIOConstraintCell{end+1}=obj.IOPadConstraint{bitRangeLSB+1+bitstep};
                    else
                        fpgaIOConstraintCell{end+1}=obj.IOPadConstraint;
                    end
                    bitstep=bitstep+1;
                end
                bitStart=bitEnd+1;
            end
            obj.FPGAPinMap{end+1}={portName,fpgaPinCell,fpgaIOConstraintCell};
        end

    end

    methods

        function result=isINOUTInterface(obj)

            if obj.InterfaceType==hdlturnkey.IOType.IN||...
                obj.InterfaceType==hdlturnkey.IOType.OUT||...
                (obj.InterfaceType==hdlturnkey.IOType.INOUT&&isempty(obj.DutInputPortList))||...
                (obj.InterfaceType==hdlturnkey.IOType.INOUT&&isempty(obj.DutOutputPortList))
                result=false;
            else
                result=true;
            end
        end

    end
end


