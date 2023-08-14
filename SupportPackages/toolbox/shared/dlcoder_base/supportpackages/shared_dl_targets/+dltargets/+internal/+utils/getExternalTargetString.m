




function externalTargetString=getExternalTargetString(target)
    externalTargetString='';
    switch target
    case 'arm_mali'
        externalTargetString='ARMMALI';
    case 'arm_neon'
        externalTargetString='ARMNEON';
    case 'cudnn'
        externalTargetString='CuDNN';
    case 'mkldnn'
        externalTargetString='MKLDNN';
    case 'onednn'
        externalTargetString='ONEDNN';
    case 'tensorrt'
        externalTargetString='TensorRT';
    otherwise
        assert(false,'Unrecognized target passed to getExternalTargetString()');
    end
end
