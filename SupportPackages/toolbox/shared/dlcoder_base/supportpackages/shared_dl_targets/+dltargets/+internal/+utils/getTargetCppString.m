
















function targetCppString=getTargetCppString(targetString)




    targetCppString='';
    if strcmpi(targetString,'cudnn')
        targetCppString='Cudnn';
    elseif strcmpi(targetString,'tensorrt')
        targetCppString='Tensorrt';
    elseif strcmpi(targetString,'mkldnn')||strcmpi(targetString,'onednn')
        targetCppString='Onednn';
    elseif strcmpi(targetString,'arm_neon')||strcmpi(targetString,'arm-compute')


        targetCppString='Armneon';
    elseif strcmpi(targetString,'arm-compute-mali')
        targetCppString='Armmali';
    else
        assert(false,'Unrecognized targetString passed to getTargetCppString()');
    end
end
