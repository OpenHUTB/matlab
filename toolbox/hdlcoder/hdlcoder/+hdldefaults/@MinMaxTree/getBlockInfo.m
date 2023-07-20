function blockInfo=getBlockInfo(this,hC)



    slbh=hC.SimulinkHandle;
    if strcmp(this.Blocks,'built-in/MinMax')
        blockInfo.fcnString='Value';
        blockInfo.compType=get_param(slbh,'Function');
        blockInfo.blockType='builtin';
        blockInfo.idxBase='One';
        blockInfo.rndMode=get_param(slbh,'RndMeth');
        if strcmpi(get_param(slbh,'DoSatur'),'on')
            blockInfo.satMode='Saturate';
        else
            blockInfo.satMode='Wrap';
        end
        blockInfo.isDSP=false;
        blockInfo.InputSameDT=get_param(slbh,'InputSameDT');
    elseif strcmp(this.Blocks,'dspstat3/Minimum')
        blockInfo.fcnString=get_param(slbh,'fcn');
        blockInfo.compType='min';
        blockInfo.blockType='dsp';
        blockInfo.idxBase=get_param(slbh,'indexBase');
        blockInfo.rndMode='Floor';
        blockInfo.satMode='Wrap';
        blockInfo.isDSP=true;
        blockInfo.InputSameDT='off';
    elseif strcmp(this.Blocks,'dspstat3/Maximum')
        blockInfo.fcnString=get_param(slbh,'fcn');
        blockInfo.compType='max';
        blockInfo.blockType='dsp';
        blockInfo.idxBase=get_param(slbh,'indexBase');
        blockInfo.rndMode='Floor';
        blockInfo.satMode='Wrap';
        blockInfo.isDSP=true;
        blockInfo.InputSameDT='off';
    else
        error(message('hdlcoder:validate:emlunsupported',this.localGetBlockName(slbh)));
    end

end
