%#codegen
function qPostCorrected=hdleml_divide_postCorrection(qin,isSignsNotEqual,outType,maxV,minV)



    coder.allowpcode('plain')
    eml_prefer_const(outType,maxV,minV)
    nt_qin=numerictype(qin);
    satFimath=eml_al_div_fimath(outType);
    positiveMaxValue=fi(maxV,numerictype(outType),satFimath);
    negativeMinValue=fi(minV,numerictype(outType),satFimath);
    if(isSignsNotEqual==1)
        qtemp=fi(-qin,nt_qin,fimath(outType));
    else
        qtemp=fi(qin,nt_qin,fimath(outType));
    end
    sel1=hdleml_bitsliceget(nt_qin.WordLength,nt_qin.WordLength,qtemp);
    sel0=hdleml_bitsliceget(nt_qin.WordLength-1,nt_qin.WordLength-1,qtemp);
    sel=hdleml_bitconcat(sel1,sel0);
    qtempdtc=hdleml_dtc(qtemp,numerictype(outType),satFimath,2);
    qPostCorrected=hdleml_switch_multiport(1,0,sel,positiveMaxValue,negativeMinValue,qtempdtc);
end

function cordicFimath=eml_al_div_fimath(y_in)

    if isfloat(y_in)


        eml_assert(0);
    else
        y_inType=numerictype(y_in);


        cordicFimath=fimath(...
        'ProductMode','SpecifyPrecision',...
        'ProductWordLength',y_inType.WordLength,...
        'ProductFractionLength',y_inType.FractionLength,...
        'SumMode','SpecifyPrecision',...
        'SumWordLength',y_inType.WordLength,...
        'SumFractionLength',y_inType.FractionLength,...
        'RoundMode','floor',...
        'OverflowMode','wrap');
    end
end
function y=hdleml_dtc(u,nt,dsfimath,mode)
    if(mode==2)
        nt_u=numerictype(u);
        nt_new=numerictype(nt.SignednessBool,nt.WordLength,nt_u.FractionLength);
        ut=fi(u,nt_new,dsfimath);
        y=eml_reinterpret(ut,nt);
    else
        y=fi(u,nt,dsfimath);
    end
end




