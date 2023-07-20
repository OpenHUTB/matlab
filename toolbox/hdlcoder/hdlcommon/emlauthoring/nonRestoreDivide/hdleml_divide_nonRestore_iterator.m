%#codegen
function[q,dout]=hdleml_divide_nonRestore_iterator(r,d,outType1,outType2,idx)



    coder.allowpcode('plain')
    eml_prefer_const(outType1,outType2)
    eml_prefer_const(idx);
    nt_r=numerictype(r);
    nt_d=numerictype(d);
    WLd=outType2.WordLength;
    WLr=nt_r.WordLength;
    intermPartialReminderFimath=eml_al_div_fimath(outType1);
    intermDivisorFimath=eml_al_div_fimath(outType2);



    if(WLr~=WLd)
        rLSBits=hdleml_bitsliceget(WLr-WLd,1,r);
    end
    rMSBits=hdleml_bitsliceget(WLr,WLr-WLd+1,r);
    rMSBit=hdleml_bitsliceget(WLr,WLr,r);
    rMSBitneg=hdleml_bitnot(rMSBit);

    x=hdleml_dtc(rMSBits,nt_d,intermDivisorFimath,1);

    if(idx==1)

        y=fi(-d,nt_d,intermDivisorFimath);
    else
        if(rMSBitneg==0)
            y=fi(d,nt_d,intermDivisorFimath);
        else
            y=fi(-d,nt_d,intermDivisorFimath);
        end

    end
    temp=fi(x+y,nt_d,intermDivisorFimath);
    rMSBNextBits=hdleml_bitsliceget(WLd-1,1,temp);
    tempSignBit=hdleml_bitsliceget(WLd-1,WLd-1,temp);
    qBit=hdleml_bitnot(tempSignBit);
    if(WLr~=WLd)
        rNextTemp=hdleml_bitconcat(rMSBNextBits,rLSBits,qBit);
    else
        rNextTemp=hdleml_bitconcat(rMSBNextBits,qBit);
    end
    q=hdleml_dtc(rNextTemp,nt_r,intermPartialReminderFimath,1);
    dout=fi(d,nt_d,intermDivisorFimath);
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



