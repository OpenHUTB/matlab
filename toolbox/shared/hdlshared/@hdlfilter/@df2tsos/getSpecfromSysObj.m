function getSpecfromSysObj(this,hS,inputnumerictype)





    if strcmpi(inputnumerictype.DataTypeMode,'Double')
        fixedMode=0;
    else
        fixedMode=1;
    end



    if fixedMode
        roundMode=getRoundingMode(hS);
        overflowMode=getOverflowMode(hS);


        this.InputSLType=sltypefromntype(inputnumerictype);


        dtinfo=hS.getCompiledFixedPointInfo;


        this.DenAccumSLtype=sltypefromntype(dtinfo.DenominatorAccumulatorDataType);


        this.NumAccumSLtype=sltypefromntype(dtinfo.NumeratorAccumulatorDataType);


        this.DenCoeffSLtype=sltypefromntype(dtinfo.DenominatorCoefficientsDataType);


        this.NumCoeffSLtype=sltypefromntype(dtinfo.NumeratorCoefficientsDataType);


        this.DenProdSLtype=sltypefromntype(dtinfo.DenominatorProductDataType);


        this.NumProdSLtype=sltypefromntype(dtinfo.NumeratorProductDataType);


        this.ScaleSLtype=sltypefromntype(dtinfo.ScaleValuesDataType);


        this.SectionInputSLtype=sltypefromntype(dtinfo.SectionInputDataType);


        this.SectionOutputSLtype=sltypefromntype(dtinfo.SectionOutputDataType);


        this.StateSLtype=sltypefromntype(dtinfo.StateDataType);


        this.OutputSLtype=sltypefromntype(dtinfo.OutputDataType);

    else
        roundMode='floor';
        overflowMode=false;
        this.InputSLType='double';
        this.DenAccumSLtype='double';
        this.NumAccumSLtype='double';
        this.DenCoeffSLtype='double';
        this.NumCoeffSLtype='double';
        this.DenProdSLtype='double';
        this.NumProdSLtype='double';
        this.ScaleSLtype='double';
        this.SectionInputSLtype='double';
        this.SectionOutputSLtype='double';
        this.StateSLtype='double';
        this.OutputSLtype='double';
    end

    this.RoundMode=roundMode;
    this.OverflowMode=overflowMode;

    this.setCommonSOSSettings(hS);

end


function sltype=sltypefromntype(ntype)


    [size,bp,sign]=hdlfilter.getSizesfromNumericType(ntype);
    sltype=hdlgetsltypefromsizes(size,bp,sign);

end



function overflowMode=getOverflowMode(hS)


    if(strncmpi(hS.OverflowAction,'wrap',4))
        overflowMode=false;
    else
        overflowMode=true;
    end

end



function roundMode=getRoundingMode(hS)


    if(strncmpi(hS.RoundingMethod,'ceiling',7))
        roundMode='ceil';
    elseif(strncmpi(hS.RoundingMethod,'convergent',10))
        roundMode='convergent';
    elseif(strncmpi(hS.RoundingMethod,'floor',5))
        roundMode='floor';
    elseif(strncmpi(hS.RoundingMethod,'nearest',7))
        roundMode='nearest';
    elseif(strncmpi(hS.RoundingMethod,'round',5))
        roundMode='round';
    elseif(strncmpi(hS.RoundingMethod,'simplest',8))
        roundMode='floor';
    else
        roundMode='fix';
    end

end


