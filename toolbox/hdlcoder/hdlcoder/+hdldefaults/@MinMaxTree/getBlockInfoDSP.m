function blockDSPInfo=getBlockInfoDSP(this,hC)



    slbh=hC.SimulinkHandle;
    operOver=get_param(slbh,'operateOver');

    blockDSPInfo.operateOver='column';

    switch lower(operOver)
    case 'each column'
        blockDSPInfo.operateOver='column';

    case 'each row'
        blockDSPInfo.operateOver='row';

    case 'specified dimension'
        blockDSPInfo.operateOver='dim';

    end

    if strcmpi(blockDSPInfo.operateOver,'dim')
        blockDSPInfo.specifyDim=str2double(get_param(slbh,'Dimension'));
    else
        blockDSPInfo.specifyDim=1;
    end

end
