function v=validateBlock(this,hC)




    v=hdlvalidatestruct;
    slbh=hC.SimulinkHandle;

    inputTable=getBlockInfo(this,slbh);

    inputSignal=hC.PirInputSignals;
    inputSignalSize=inputSignal.Type.getDimensions;


    if(size(inputTable,2)~=inputSignalSize)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:LogicTableInputDimensionsMismatch',size(inputTable,2),inputSignalSize));
    end
end
