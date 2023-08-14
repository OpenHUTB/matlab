function v=validateBlock(this,hC)




    v=hdlvalidatestruct;

    CInfo=getBlockInfo(this,hC);
    ratioNumber=CInfo.Ratio;

    thresholdNumber=hdlgetparameter('SerializerRatioThreshold');
    isVerilog=strcmpi(hdlgetparameter('target_language'),'Verilog');

    if isVerilog&&ratioNumber>thresholdNumber


        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:SerializerRatioThreshold','Serializer1D',thresholdNumber));
    end


