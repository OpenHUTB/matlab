function v=validateBlock(~,hC)


    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;



    if(checkArrayofBus(hC))
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:ArrayOfBusUnsupportedBlock',get_param(hC.SimulinkHandle,'Name')));
    end
end

function retval=checkArrayofBus(hC)
    retval=false;
    for ii=1:hC.NumberOfSLInputPorts
        if hC.SLInputPorts(ii).Signal.Type.isArrayOfRecords
            retval=true;
            return;
        end
    end

    for ii=1:hC.NumberOfSLOutputPorts
        if hC.SLOutputPorts(ii).Signal.Type.isArrayOfRecords
            retval=true;
            return;
        end
    end
end


