function[u1,u2,u3,u4]=calculate_target_checksum(modelName)



    [ctxInfo,nonChecksumFields]=construct_context_info(modelName);

    advancedOptControl=get_param(modelName,'AdvancedOptControl');


    targetChecksum=CGXE.Utils.md5(...
    advancedOptControl);



    ctxInfoForCksum=rmfield(ctxInfo,nonChecksumFields);
    targetChecksum=CGXE.Utils.md5(targetChecksum,ctxInfoForCksum);

    tflChecksum=ctxInfo.usedTargetFunctionLibH.getIncrBuildNum();
    targetChecksum=CGXE.Utils.md5(targetChecksum...
    ,tflChecksum.NUM1...
    ,tflChecksum.NUM2...
    ,tflChecksum.NUM3...
    ,tflChecksum.NUM4);
    u1=targetChecksum(1);
    u2=targetChecksum(2);
    u3=targetChecksum(3);
    u4=targetChecksum(4);
end
