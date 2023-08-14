function v=validateProductBlock(~,hC)



    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;


    blkName=get_param(bfp,'Name');




    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));

    numInputPorts=hC.NumberOfPirInputPorts;
    inType=hC.PirInputSignals(1).Type;
    outType=hC.PirOutputSignals(1).Type;


    if(numInputPorts==1&&inType.isMatrix)
        if(~inType.is2DMatrix&&outType.isArrayType)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:matrix:toomanydimsforblock',...
            blkName,inType.NumberOfDimensions,hC.PirInputSignals(1).Name));
        end
    end
