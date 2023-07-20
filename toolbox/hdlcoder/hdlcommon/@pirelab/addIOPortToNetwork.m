function hPortSignals=addIOPortToNetwork(varargin)




    p=inputParser;

    p.addParameter('Network','');
    p.addParameter('InportNames',{});
    p.addParameter('InportWidths',{});
    p.addParameter('InportDimensions',{});
    p.addParameter('OutportNames',{});
    p.addParameter('OutportWidths',{});
    p.addParameter('OutportDimensions',{});

    p.parse(varargin{:});
    args=p.Results;

    hN=args.Network;
    inportNames=args.InportNames;
    inportWidths=args.InportWidths;
    inportDimensions=args.InportDimensions;
    outportNames=args.OutportNames;
    outportWidths=args.OutportWidths;
    outportDimensions=args.OutportDimensions;

    if length(inportNames)~=length(inportWidths)||...
        length(outportNames)~=length(outportWidths)
        error(message('hdlcommon:workflow:MismatchPortName'));
    end
    if(~isempty(inportDimensions)&&(length(inportNames)~=length(inportDimensions)))||...
        (~isempty(outportDimensions)&&(length(outportNames)~=length(outportDimensions)))
        error(message('hdlcommon:workflow:MismatchPortDimension'));
    end


    hInportSignals=handle([]);
    for ii=1:length(inportNames)
        portName=inportNames{ii};
        portWidth=inportWidths{ii};


        portPirType=pir_ufixpt_t(portWidth,0);
        if~isempty(inportDimensions)
            portDimension=inportDimensions{ii};
            if portDimension>1
                portPirType=pirelab.getPirVectorType(portPirType,portDimension);
            end
        end
        hPortSignal=hN.addSignal(portPirType,portName);


        hN.addInputPort(portName);
        hPortSignal.addDriver(hN,hN.NumberOfPirInputPorts-1);

        hInportSignals(end+1)=hPortSignal;%#ok<*AGROW>
    end


    hOutportSignals=handle([]);
    for ii=1:length(outportNames)
        portName=outportNames{ii};
        portWidth=outportWidths{ii};


        portPirType=pir_ufixpt_t(portWidth,0);
        if~isempty(outportDimensions)
            portDimension=outportDimensions{ii};
            if portDimension>1
                portPirType=pirelab.getPirVectorType(portPirType,portDimension);
            end
        end
        hPortSignal=hN.addSignal(portPirType,portName);


        hN.addOutputPort(portName);
        hPortSignal.addReceiver(hN,hN.NumberOfPirOutputPorts-1);

        hOutportSignals(end+1)=hPortSignal;
    end

    hPortSignals.hInportSignals=hInportSignals;
    hPortSignals.hOutportSignals=hOutportSignals;

end
