function dut=createDUTComp(h)




    hdlcData=h.mWorkflowInfo.hdlcData;

    dut=eda.internal.component.BlackBox;



    dut.addprop('NoHDLFiles');

    dut.SimModel=[];
    dut.UniqueName=hdlcData.dutName;


    clock=hdlcData.dut.clock.Name;
    dut.addprop(clock);
    dut.(clock)=eda.internal.component.ClockPort;
    dut.(clock).UniqueName=clock;


    clkenable=hdlcData.dut.clkenable.Name;
    dut.addprop(clkenable);
    dut.(clkenable)=eda.internal.component.ClockEnablePort;
    dut.(clkenable).UniqueName=clkenable;


    reset=hdlcData.dut.reset.Name;
    dut.addprop(reset);
    dut.(reset)=eda.internal.component.ResetPort;
    dut.(reset).UniqueName=reset;


    ports=hdlcData.dut.inputs;
    for n=1:length(ports)
        validatePort(ports(n));
        inport=ports(n).Name;
        dut.addprop(inport);
        dut.(inport)=eda.internal.component.Inport('FiType',ports(n).Sltype);
        dut.(inport).UniqueName=inport;
    end


    ports=hdlcData.dut.outputs;
    for n=1:length(ports)
        validatePort(ports(n));
        outport=ports(n).Name;
        dut.addprop(outport);
        dut.(outport)=eda.internal.component.Outport('FiType',ports(n).Sltype);
        dut.(outport).UniqueName=outport;
    end


    function validatePort(port)

        if strcmpi(port.Sltype,'double')
            error(message('EDALink:FDHDLCWorkflowMgr:createDUTComp:DoublePort',port.Name));
        end

