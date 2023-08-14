function dut=createDUTComp(h)







    hdlcData=h.mWorkflowInfo.hdlcData;

    dut=eda.internal.component.BlackBox;



    dut.addprop('NoHDLFiles');

    dut.SimModel=get_param(hdlcData.dutPath,'Handle');
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
        pirtype=pirgetdatatypeinfo(ports(n).Signal.Type);
        dut.addprop(inport);
        dut.(inport)=eda.internal.component.Inport('FiType',pirtype.sltype);
        dut.(inport).UniqueName=inport;
    end


    ports=hdlcData.dut.outputs;
    for n=1:length(ports)
        validatePort(ports(n));
        outport=ports(n).Name;
        pirtype=pirgetdatatypeinfo(ports(n).Signal.Type);
        dut.addprop(outport);
        dut.(outport)=eda.internal.component.Outport('FiType',pirtype.sltype);
        dut.(outport).UniqueName=outport;
    end

    ports=hdlcData.dut.ceout;
    for n=1:length(ports)
        outport=ports(n).Name;


        pirtype=pirgetdatatypeinfo(ports(n).Signal.Type);
        dut.addprop(outport);
        dut.(outport)=eda.internal.component.Outport('FiType',pirtype.sltype);
        dut.(outport).UniqueName=outport;
    end

end

function validatePort(port)
    if isempty(port.Signal)
        error(message('EDALink:WorkflowManager:createDUTComp:NoSignal',port.Name));
    end

    type=port.Signal.Type;
    if type.isDoubleType
        error(message('EDALink:WorkflowManager:createDUTComp:DoublePort',port.Name));
    elseif type.isSingleType
        error(message('EDALink:WorkflowManager:createDUTComp:SinglePort',port.Name));
    elseif type.isArrayType
        error(message('EDALink:WorkflowManager:createDUTComp:VectorPort',port.Name));
    elseif type.isComplexType
        error(message('EDALink:WorkflowManager:createDUTComp:ComplexPort',port.Name));
    end
end
