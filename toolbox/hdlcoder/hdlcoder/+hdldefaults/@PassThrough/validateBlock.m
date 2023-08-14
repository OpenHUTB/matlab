function v=validateBlock(~,hC)


    v=hdlvalidatestruct;

    inport=hC.PirInputSignals;
    outport=hC.PirOutputSignals;



    if(length(inport)>1)||(length(outport)>1)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:invalidports'));
        return;
    end


    if inport.SimulinkRate~=outport.SimulinkRate
        hInT=inport.Type;
        hOutT=outport.Type;
        inMatrix=hInT.isArrayType&&hInT.NumberOfDimensions>1;
        outMatrix=hOutT.isArrayType&&hOutT.NumberOfDimensions>1;

        if inMatrix~=outMatrix&&~hInT.isEqual(hOutT)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:MatrixRateMismatch'));
        end
    end
end
