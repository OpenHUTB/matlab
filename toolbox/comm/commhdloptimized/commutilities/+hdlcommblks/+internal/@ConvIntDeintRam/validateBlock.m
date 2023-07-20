function v=validateBlock(this,hC)





    v=hdlvalidatestruct;


    inp=hC.PirInputSignals(1);
    op=hC.PirOutputSignals(1);
    if(hdlissignalvector(inp)||hdlissignalvector(op))
        v(end+1)=...
        hdlvalidatestruct(1,...
        message('comm:hdl:ConvIntDeintRam:validateBlock:VectorInputOutput')...
        );
    end


    slbh=hC.SimulinkHandle;
    ic=hdlslResolve('ic',slbh);

    if~(all(ic==0))
        v(end+1)=...
        hdlvalidatestruct(1,...
        message('comm:hdl:ConvIntDeintRam:validateBlock:NonZeroIC')...
        );
    end



    ports=[hC.SLInputPorts(1),hC.SLOutputPorts(1)];
    [noports,any_port_double]=this.checkForDoublePorts(ports);%#ok
    if any_port_double
        v(end+1)=...
        hdlvalidatestruct(1,...
        message('comm:hdl:ConvIntDeintRam:validateBlock:DoubleInputOutput')...
        );
    end



    slbh=hC.SimulinkHandle;
    N=hdlslResolve('N',slbh);
    B=hdlslResolve('B',slbh);
    numramloc=N*B*N;
    minramloc=8;
    if(numramloc<minramloc)
        v(end+1)=...
        hdlvalidatestruct(1,...
        message('comm:hdl:ConvIntDeintRam:validateBlock:MinRAMSize',...
        numramloc,minramloc));
    end


    intdelay=(0:B:B*(N-1))';
    if length(intdelay)<2
        v(end+1)=...
        hdlvalidatestruct(1,...
        message('comm:hdl:ConvIntDeintRam:validateBlock:NumberofRows')...
        );
    end


