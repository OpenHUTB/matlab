function CopyHDLPorts(this)



    portStruct=struct('Name','',...
    'RefNum','',...
    'SimulinkRate',1,...
    'VType','',...
    'SLType',[],...
    'Reg',0,...
    'Owner',[],...
    'Vector',[],...
    'isClockEnable',0,...
    'OpClockEnIndex',0,...
    'Synthetic',0);

    input=hdlinportsignals;

    if isempty(input)
        inports=[];
    else
        inports(1:length(input))=portStruct;
        for i=1:length(input)
            port=portStruct;
            port.Name=hdlsignalname(input(i));
            port.SimulinkRate=hdlsignalrate(input(i));
            port.VType=hdlsignalvtype(input(i));
            port.SLType=hdlsignalsltype(input(i));
            port.Synthetic=input(i).Synthetic;
            port.RefNum=input(i).RefNum;
            port.isClockEnable=input(i).isClockEnable;
            port.Vector=hdlsignalvector(input(i));
            inports(i)=port;
        end
    end
    this.DUTInport=inports;

    output=hdloutportsignals;
    if isempty(output)
        outports=[];
    else
        outports(1:length(output))=portStruct;
        for i=1:length(output)
            port=portStruct;
            port.Name=hdlsignalname(output(i));
            port.SimulinkRate=hdlsignalrate(output(i));
            port.VType=hdlsignalvtype(output(i));
            port.SLType=hdlsignalsltype(output(i));
            port.Synthetic=output(i).Synthetic;
            port.RefNum=output(i).RefNum;
            port.isClockEnable=output(i).isClockEnable;
            port.OpClockEnIndex=0;
            port.Vector=hdlsignalvector(output(i));
            outports(i)=port;
        end
    end
    this.DUTOutport=outports;
end

