%#codegen
function varargout=hdleml_prelookup(bp,bpType_ex,kType_ex,fType_ex,...
    idxOnly,powerof2,u)

























    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(bp);
    eml_prefer_const(bpType_ex);
    eml_prefer_const(kType_ex);
    eml_prefer_const(fType_ex);
    eml_prefer_const(idxOnly);
    eml_prefer_const(powerof2);



    nt=fixed.aggregateType(u,bpType_ex);
    fm=fimath(bpType_ex);
    nt_k=numerictype(kType_ex);
    fm_k=fimath(kType_ex);

    floatF=isfloat(fType_ex);

    nt_m=numerictype(nt.Signed,nt.WordLength,0);



    if nt.FractionLength<0
        nt_in=numerictype(nt.Signed,nt.WordLength-nt.FractionLength,0);
    else
        nt_in=nt_m;
    end

    in_u=fi(u,nt,fm);


    my_fm=fimath('SumMode','SpecifyPrecision',...
    'SumWordLength',nt.WordLength,...
    'SumFractionLength',nt.FractionLength);
    diff_tmp=fi(fi(u,nt,my_fm)-fi(bp(1),nt,my_fm),nt,my_fm);
    diff=fi(diff_tmp,nt,fm);


    bp_spacing=fi(fi(bp(2),nt,fm)-fi(bp(1),nt,fm),nt,fm);


    if in_u<=fi(bp(1),nt,fm)

        k=fi(0,nt_k,fm_k);
    elseif in_u>=fi(bp(end),nt,fm)

        k=fi(length(bp)-1,nt_k,fm_k);
    else

        if powerof2==0


            k=fi(diff,nt_k,fm_k);
        elseif powerof2>0


            if nt_m.WordLength==1||nt_m.WordLength<powerof2

                k=fi(0,nt_k,fm_k);
            else
                dr=fi(diff,nt_in,fm);

                k=fi(bitsra(dr,powerof2),nt_k,fm_k);
            end
        elseif powerof2~=-9999


            k1=bitshift(diff,-(powerof2+nt.FractionLength));
            k2=rescale(k1,0);
            k=fi(k2,nt_k,fm_k);
        else



            if nt.Signed
                sub_o=numerictype(nt.Signed,nt.WordLength+1,nt.FractionLength);
            else
                sub_o=nt;
            end
            sub_fm=fimath('SumMode','SpecifyPrecision',...
            'SumWordLength',sub_o.WordLength,...
            'SumFractionLength',sub_o.FractionLength);
            d2=fi(fi(u,sub_o,sub_fm)-fi(bp(1),sub_o,sub_fm),sub_o,sub_fm);
            bp_s2=fi(bp_spacing,nt,fm_k);





            fm_d=fimath(...
            'RoundMode','Fix',...
            'OverflowMode',fm_k.OverflowMode,...
            'ProductMode',fm_k.ProductMode,...
            'MaxProductWordLength',128,...
            'SumMode',fm_k.SumMode,...
            'MaxSumWordLength',128);
            k=fi(divide(nt_k,fi(d2,sub_o,fm_d),fi(bp_s2,nt,fm_d)),nt_k,fm_k);
        end
    end
    varargout{1}=k;


    if~idxOnly
        if floatF
            f=cast(0,'like',fType_ex);
        else
            nt_f=numerictype(fType_ex);
            fm_f=fimath(fType_ex);
            if in_u<=fi(bp(1),nt,fm)||in_u>=fi(bp(end),nt,fm)
                f=fi(0,nt_f,fm_f);
            else
                if powerof2==0
                    maskValue=fi(pow2(fi(1,0,nt.WordLength,0),...
                    int32(nt.FractionLength))-1,nt_m,fm);
                    rescaleMask=rescale(maskValue,nt.FractionLength);
                    maskExpr=bitand(fi(u,nt,fm),fi(rescaleMask,nt,fm));
                    f=fi(maskExpr,nt_f,fm_f);
                elseif powerof2>0
                    if nt_m.WordLength==1

                        maskValue=fi(1,nt_m,fm);
                    else
                        maskValue=fi(pow2(fi(1,nt_m,fm),...
                        int32(powerof2+nt.FractionLength))-1,nt_m,fm);
                    end
                    dr=rescale(diff,0);
                    maskExpr=bitand(dr,maskValue);
                    rescaleDiff=rescale(maskExpr,powerof2+nt.FractionLength);
                    f=fi(rescaleDiff,nt_f,fm_f);
                elseif powerof2~=-9999
                    if nt_m.WordLength==1

                        maskValue=fi(1,nt_m,fm);
                    else
                        maskValue=fi(pow2(fi(1,nt_m,fm),...
                        int32(powerof2+nt.FractionLength))-1,nt_m,fm);
                    end
                    dr=rescale(diff,0);
                    maskExpr=bitand(dr,maskValue);
                    rescaleDiff=rescale(maskExpr,powerof2+nt.FractionLength);
                    f=fi(rescaleDiff,nt_f,fm_f);
                else
                    bpLeft=fi(bp(1),nt,fm)+fi(bp_spacing,nt,fm)*fi(k,nt,fm);
                    if nt.WordLength==1

                        subType_ex=fi(0,1,2,0);
                    else
                        subType_ex=bpType_ex;
                    end
                    mod=hdleml_sub(in_u,fi(bpLeft,nt,fm),subType_ex);





                    nt_sub=numerictype(subType_ex);
                    if nt_sub.WordLength+nt_f.FractionLength>128
                        divWordLen=128;
                    else
                        divWordLen=nt_sub.WordLength+nt_f.FractionLength;
                    end
                    nt_div=numerictype(nt_sub.Signed,...
                    divWordLen,...
                    nt_sub.FractionLength+nt_f.FractionLength);
                    fm_div=fimath(...
                    'RoundMode','Fix',...
                    'OverflowMode',fm.OverflowMode,...
                    'ProductMode',fm.ProductMode,...
                    'MaxProductWordLength',128,...
                    'SumMode',fm.SumMode,...
                    'MaxSumWordLength',128);

                    f=fi(fi(mod,nt_div,fm_div)/fi(bp_spacing,nt,fm_div),nt_f,fm_f);
                end
            end
        end
        varargout{2}=f;
    end
end

