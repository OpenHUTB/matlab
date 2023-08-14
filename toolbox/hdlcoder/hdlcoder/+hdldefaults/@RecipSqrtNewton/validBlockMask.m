function v=validBlockMask(~,slbh)





    v=true;
    if slbh<0
        return;
    end
    blkFunction=get_param(slbh,'Function');
    blkAlgorithm=get_param(slbh,'AlgorithmType');

    if strcmpi(blkFunction,'sqrt')||strcmpi(blkFunction,'signedSqrt')||strcmpi(blkAlgorithm,'exact')
        v=false;
    end
