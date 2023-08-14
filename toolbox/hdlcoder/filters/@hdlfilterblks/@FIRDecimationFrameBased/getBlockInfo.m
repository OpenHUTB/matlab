function blockInfo=getBlockInfo(this,slbh)




    blockInfo=struct();

    ud=get_param(slbh,'UserData');
    block=get_param(slbh,'Object');
    switch block.FilterSource
    case 'Filter object'
        coeffs=ud.filter.Numerator;
        decimfact=ud.filter.DecimationFactor;
    otherwise
        decimfact=ud.filterConstructorArgs{1};
        coeffs=ud.filterConstructorArgs{2};
    end

    blockInfo.rateChangeFactor=1/decimfact;
    blockInfo.Coefficients=coeffs;

    blockInfo.dataTypes=getCompiledFixedPointInfo(slbh);
    blockInfo.RoundingMethod=get_param(slbh,'roundingMode');
    blockInfo.Saturation=strcmpi(get_param(slbh,'overflowMode'),'on');


    blockInfo.is_symm=0;
    blockInfo.is_asymm=0;
    blockInfo.no_symm=1;
    blockInfo.odd_symm=0;


    blockInfo.progCoeff=false;
