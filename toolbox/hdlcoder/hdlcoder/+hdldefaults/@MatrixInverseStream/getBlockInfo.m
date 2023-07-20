function blockInfo=getBlockInfo(~,hC)






    slbh=hC.SimulinkHandle;

    blockInfo=struct;
    blockInfo.MatrixSize=hdlslResolve('MatrixSize',slbh);
    blockInfo.RowSize=blockInfo.MatrixSize;
    blockInfo.ColumnSize=blockInfo.MatrixSize;
    blockInfo.latencyStrategy=get_param(slbh,'LatencyStrategyType');
    blockInfo.AlgorithmType=get_param(slbh,'AlgorithmType');
    if isSingleType(hC.PirInputSignals(1).Type)
        blockInfo.inputDataType='SINGLE';
    else
        blockInfo.inputDataType='DOUBLE';
    end
end
