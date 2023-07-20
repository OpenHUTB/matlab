function v=validateVerilogBlackBoxPorts(~,hC)






    v=hdlvalidatestruct;

    if~hdlgetparameter('isverilog')
        return;
    end

    nInPorts=hC.NumberOfSLInputPorts;
    nOutPorts=hC.NumberOfSLOutputPorts;

    for ii=1:nInPorts
        port=hC.SLInputPorts(ii);
        signal=port.Signal;
        if~isempty(signal)&&~hdlissignalscalar(signal)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:verilogvectorinputports'));%#ok<AGROW>
        end
    end

    for ii=1:nOutPorts
        port=hC.SLOutputPorts(ii);
        signal=port.Signal;
        if~isempty(signal)&&~hdlissignalscalar(signal)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:verilogvectoroutputports'));%#ok<AGROW>
        end
    end

    if length(v)>1

        v=v(2:end);
    end
