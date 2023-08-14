function y=trig_lut_fi_private(FI_TRIG_LUT,idxUFIX16,lut_overflow_action)




%#codegen

    coder.allowpcode('plain');

    if nargin<3





        lut_overflow_action='wrap';
    end

    inCodegenMode=~isempty(coder.target);

    if inCodegenMode
        eml_prefer_const(FI_TRIG_LUT);
    end


    fmResultSumProd=fimath(...
    'RoundMode','floor','OverflowMode','wrap',...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',32,'ProductFractionLength',30,...
    'SumMode','SpecifyPrecision',...
    'SumWordLength',32,'SumFractionLength',30);


    rFracNT=numerictype(0,8,8);
    rFraction=coder.nullcopy(fi(0,rFracNT,fmResultSumProd));


    tblValsNT=numerictype(FI_TRIG_LUT);
    lutValBelow=coder.nullcopy(fi(0,tblValsNT,fmResultSumProd));
    lutValAbove=coder.nullcopy(fi(0,tblValsNT,fmResultSumProd));
    temp=coder.nullcopy(fi(0,tblValsNT,fmResultSumProd));
    y=coder.nullcopy(fi(0,tblValsNT,fmResultSumProd));



    idxFrac8LSBs=reinterpretcast(bitsliceget(idxUFIX16,8,1),rFracNT);
    idxLUTLoZero=reinterpretcast(bitsliceget(idxUFIX16,16,9),numerictype(0,8,0));
    switch lut_overflow_action
    case 'wrap'



        idxLUTHiZero=accumpos(idxLUTLoZero,1);
    otherwise



        idxLUTHiZero=accumpos(int16(idxLUTLoZero),1);
    end

    idxLUTLoAddr=accumpos(int16(idxLUTLoZero),1);

    idxLUTHiAddr=accumpos(int16(idxLUTHiZero),1);



    if inCodegenMode
        lutValBelow(:)=FI_TRIG_LUT(idxLUTLoAddr);
        lutValAbove(:)=FI_TRIG_LUT(idxLUTHiAddr);
        rFraction(:)=idxFrac8LSBs;
        temp(:)=rFraction*(lutValAbove-lutValBelow);
        y(:)=lutValBelow+temp;
    else
        setElement(lutValBelow,getElement(FI_TRIG_LUT,idxLUTLoAddr),1);
        setElement(lutValAbove,getElement(FI_TRIG_LUT,idxLUTHiAddr),1);
        setElement(rFraction,idxFrac8LSBs,1);
        setElement(temp,(rFraction*(lutValAbove-lutValBelow)),1);
        setElement(y,(lutValBelow+temp),1);
    end

end


