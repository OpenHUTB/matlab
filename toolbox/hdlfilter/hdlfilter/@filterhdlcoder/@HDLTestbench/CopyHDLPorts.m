function CopyHDLPorts(this)







    portStruct=struct('Name','',...
    'RefNum','',...
    'SimulinkHandle',-1,...
    'SimulinkRate',1,...
    'VType','',...
    'Forward',[],...
    'Imag',[],...
    'SLType',[],...
    'Reg',0,...
    'Owner',[],...
    'Vector',[],...
    'isClockEnable',0,...
    'OpClockEnIndex',0,...
    'Synthetic',0);
    port=portStruct;
    inports=[];
    tmp=hdlinportsignals;

    for i=1:length(tmp)
        port.Name=hdlsignalname(tmp(i));
        port.SimulinkRate=hdlsignalrate(tmp(i));
        port.VType=hdlsignalvtype(tmp(i));
        port.Forward=hdlsignalforward(tmp(i));
        port.SLType=hdlsignalsltype(tmp(i));
        port.Synthetic=1;
        port.RefNum='';
        port.isClockEnable=hdlisclockenablesignal(tmp(i));
        port.Vector=hdlsignalvector(tmp(i));
        inports=[inports,port];
    end
    this.DUTInport=inports;

    port=portStruct;
    outports=[];
    tmp=hdloutportsignals;
    for i=1:length(tmp)
        port.Name=hdlsignalname(tmp(i));
        port.SimulinkHandle=0;
        port.SimulinkRate=hdlsignalrate(tmp(i));
        port.VType=hdlsignalvtype(tmp(i));
        port.Forward=hdlsignalforward(tmp(i));
        port.SLType=hdlsignalsltype(tmp(i));
        port.Synthetic=1;
        port.RefNum='';
        port.isClockEnable=hdlisclockenablesignal(tmp(i));
        port.OpClockEnIndex=0;
        port.Vector=hdlsignalvector(tmp(i));
        outports=[outports,port];
    end
    this.DUTOutport=outports;
