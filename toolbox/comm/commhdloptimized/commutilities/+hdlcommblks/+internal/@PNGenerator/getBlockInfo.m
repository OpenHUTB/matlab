function blockInfo=getBlockInfo(this,hC)








    blockInfo=struct();

    hBlock=hC.SimulinkHandle;
    rto=get_param(hBlock,'RunTimeObject');




    blockInfo.Polynomial=rto.RuntimePrm(1).Data;


    blockInfo.InitialStates=this.hdlslResolve('ini_sta',hBlock);


    blockInfo.OutputMaskSrc=get_param(hBlock,'outBitMaskSource');

    if~strcmp(blockInfo.OutputMaskSrc,'Input port')

        blockInfo.OutputMaskVec=rto.RuntimePrm(3).Data;
    else
        blockInfo.OutputMaskVec=[];
    end


    blockInfo.Reset=get_param(hBlock,'reset');


    if strcmp(blockInfo.OutputMaskSrc,'Input port')&&strcmp(blockInfo.Reset,'off')
        blockInfo.InportMaskIdx=1;
    elseif~strcmp(blockInfo.OutputMaskSrc,'Input port')&&strcmp(blockInfo.Reset,'on')
        blockInfo.InportResetIdx=1;
    else
        blockInfo.InportMaskIdx=1;
        blockInfo.InportResetIdx=2;
    end


    blockInfo.OutputDataBits=1;
    blockInfo.OutputDataSign='off';

    blockInfo.OutputPacked=get_param(hBlock,'bitPackedOutputs');
    if strcmp(blockInfo.OutputPacked,'on')

        blockInfo.OutputDataBits=this.hdlslResolve('numPackedBits',hBlock);

        blockInfo.OutputDataSign=get_param(hBlock,'bitPackDataSigned');
    end
    blockInfo.SimulinkRate=hC.PirOutputSignals(1).SimulinkRate;
