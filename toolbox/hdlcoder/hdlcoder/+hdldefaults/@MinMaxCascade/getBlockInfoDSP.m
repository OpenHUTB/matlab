function[operateOver,specifyDim]=getBlockInfoDSP(this,slbh)



    operOver=get_param(slbh,'operateOver');
    switch lower(operOver)
    case 'each column'
        operateOver='column';

    case 'each row'
        operateOver='row';

    case 'specified dimension'
        operateOver='dim';

    case 'entire input'
        error(message('hdlcoder:validate:unsupportedoption',this.localGetBlockName(slbh)));

    otherwise
        error(message('hdlcoder:validate:emlunsupported',this.localGetBlockName(slbh)));
    end

    if strcmpi(operateOver,'dim')
        specifyDim=str2num(get_param(slbh,'Dimension'));
    else
        specifyDim=1;
    end


