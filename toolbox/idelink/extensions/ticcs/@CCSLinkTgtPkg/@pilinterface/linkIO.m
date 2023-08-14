function dataIn=linkIO(h,dataOut,dataInAmount)











    narginchk(3,3);

    CCS_Obj=h.getCCSObj;
    dataIn=[];


    if~isempty(dataOut)
        if(h.isByteAddressable)
            write(CCS_Obj,h.bufferAddress,uint8(dataOut));
        else
            write(CCS_Obj,h.bufferAddress,uint16(dataOut));
        end
    end

    run(CCS_Obj,'runtohalt');

    if dataInAmount>0
        if(h.isByteAddressable)
            dataIn=read(CCS_Obj,h.bufferAddress,'uint8',dataInAmount);
        else
            dataIn=read(CCS_Obj,h.bufferAddress,'uint16',dataInAmount);
        end
    end
