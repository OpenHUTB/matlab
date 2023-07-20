function v=validBlockMask(~,slbh)





    v=true;
    if slbh<0
        return;
    end
    blkFunction=get_param(slbh,'Function');
    blkAlgorithm=get_param(slbh,'AlgorithmType');

    if strcmpi(blkFunction,'rSqrt')&&strcmpi(blkAlgorithm,'Newton-Raphson')
        v=false;
    end

end
