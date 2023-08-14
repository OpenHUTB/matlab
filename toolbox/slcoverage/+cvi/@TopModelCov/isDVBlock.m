function res=isDVBlock(blkH)
    try
        res=~isequal(blkH,0)&&ishandle(blkH)&&hasmask(blkH)&&...
        ~isempty(get_param(blkH,'MaskType'))&&...
        ~isempty(cvi.MetricRegistry.getDVSupportedMaskTypes(get_param(blkH,'MaskType')));catch MEx
        rethrow(MEx);
    end