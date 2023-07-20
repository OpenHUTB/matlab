function blockInfo=getBlockInfo(this,hC,slbh)




    blockInfo=struct();

    blockInfo.rateChangeFactor=1;

    blockInfo.dataTypes=getCompiledFixedPointInfo(slbh);

    blockInfo.RoundingMethod=get_param(slbh,'RndMeth');
    blockInfo.Saturation=strcmpi(get_param(slbh,'SaturateOnIntegerOverflow'),'on');

    if strcmpi(get_param(slbh,'CoefSource'),'Input port')

        blockInfo.progCoeff=true;
        coeffsize=prod(hdlsignalvector(hC.PirInputSignals(2)));
        if hdlsignaliscomplex(hC.PirInputSignals(2))
            blockInfo.Coefficients=repmat(0.5+0.5i,1,coeffsize);
        else
            blockInfo.Coefficients=repmat(0.5,1,coeffsize);
        end
        filtstruct=get_param(slbh,'FilterStructure');
        if strcmpi(filtstruct,'Direct form symmetric')
            blockInfo.is_symm=true;
            blockInfo.is_asymm=false;
            blockInfo.no_symm=false;
            blockInfo.odd_symm=(mod(coeffsize,2)==1);
        elseif strcmpi(filtstruct,'Direct form antisymmetric')
            blockInfo.is_symm=false;
            blockInfo.is_asymm=true;
            blockInfo.no_symm=false;
            blockInfo.odd_symm=(mod(coeffsize,2)==1);
        else
            blockInfo.is_symm=false;
            blockInfo.is_asymm=false;
            blockInfo.no_symm=true;
            blockInfo.odd_symm=false;
        end
    else
        blockInfo.progCoeff=false;
        blockInfo.Coefficients=this.hdlslResolve('Coefficients',slbh);
        numbCoeffs=length(blockInfo.Coefficients);
        symmetric_str=checksymmetry(blockInfo.Coefficients);
        blockInfo.is_symm=strcmp(symmetric_str,'symmetric');
        blockInfo.is_asymm=strcmp(symmetric_str,'antisymmetric');
        blockInfo.no_symm=~(blockInfo.is_symm||blockInfo.is_asymm);
        blockInfo.odd_symm=(numbCoeffs/2~=ceil(numbCoeffs/2));
    end


