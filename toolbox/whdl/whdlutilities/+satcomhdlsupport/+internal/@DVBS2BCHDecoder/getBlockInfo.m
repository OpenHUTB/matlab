function blockInfo=getBlockInfo(this,hC)



    bfp=hC.Simulinkhandle;

    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    if isempty(blockInfo.synthesisTool)
        blockInfo.ramAttr_dist='';
        blockInfo.ramAttr_block='';
    else
        if strcmpi(blockInfo.synthesisTool(1:6),'Xilinx')
            blockInfo.ramAttr_dist='distributed';
            blockInfo.ramAttr_block='block';
        elseif strcmpi(blockInfo.synthesisTool(1:5),'Intel')||strcmpi(blockInfo.synthesisTool(1:6),'Altera')
            blockInfo.ramAttr_dist='MLAB';
            blockInfo.ramAttr_block='M20K';
        else
            blockInfo.ramAttr_dist='';
            blockInfo.ramAttr_block='';
        end
    end

    blockInfo.FECFrameType=get_param(bfp,'FECFrameType');
    blockInfo.CodeRateSource=get_param(bfp,'CodeRateSource');
    if strcmpi(blockInfo.FECFrameType,'Normal')
        blockInfo.CodeRate=get_param(bfp,'CodeRateNormal');
    else
        blockInfo.CodeRate=get_param(bfp,'CodeRateShort');
    end
    switch(blockInfo.CodeRate)
    case '1/4'
        blockInfo.CodeRateIdx=0;
    case '1/3'
        blockInfo.CodeRateIdx=1;
    case '2/5'
        blockInfo.CodeRateIdx=2;
    case '1/2'
        blockInfo.CodeRateIdx=3;
    case '3/5'
        blockInfo.CodeRateIdx=4;
    case '2/3'
        blockInfo.CodeRateIdx=5;
    case '3/4'
        blockInfo.CodeRateIdx=6;
    case '4/5'
        blockInfo.CodeRateIdx=7;
    case '5/6'
        blockInfo.CodeRateIdx=8;
    case '8/9'
        blockInfo.CodeRateIdx=9;
    otherwise
        blockInfo.CodeRateIdx=10;
    end

    blockInfo.NumErrorsOutputPort=strcmp(get_param(bfp,'NumErrorsOutputPort'),'on');

end
