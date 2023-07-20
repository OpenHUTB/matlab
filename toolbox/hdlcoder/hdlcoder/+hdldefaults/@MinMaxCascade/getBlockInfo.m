function[fcnString,compType,blockType,idxBase,rndMode,satMode]=getBlockInfo(this,slbh)



    if strcmp(this.Blocks,'built-in/MinMax')
        fcnString='Value';
        compType=get_param(slbh,'Function');
        blockType='builtin';
        idxBase='One';
        rndMode=get_param(slbh,'RndMeth');
        if strcmpi(get_param(slbh,'DoSatur'),'on')
            satMode='Saturate';
        else
            satMode='Wrap';
        end

    elseif strcmp(this.Blocks,'dspstat3/Minimum')
        fcnString=get_param(slbh,'fcn');
        compType='min';
        blockType='dsp';
        idxBase=get_param(slbh,'indexBase');
        rndMode='Floor';
        satMode='Wrap';

    elseif strcmp(this.Blocks,'dspstat3/Maximum')
        fcnString=get_param(slbh,'fcn');
        compType='max';
        blockType='dsp';
        idxBase=get_param(slbh,'indexBase');
        rndMode='Floor';
        satMode='Wrap';

    else
        error(message('hdlcoder:validate:emlunsupported',this.localGetBlockName(slbh)));
    end

end
