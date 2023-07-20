function v=validBlockMask(~,slbh)





    v=true;
    if slbh<0
        return;
    end

    blockType=get_param(slbh,'blockType');

    if strcmpi(blockType,'Math')&&~(strcmpi(get_param(slbh,'AlgorithmMethod'),'Newton-Raphson'))
        v=false;
    end


