%#codegen
function y=hdleml_sub_withcast(u,v,outtp_ex,sumtp_ex,castInputsToSumType)

    coder.allowpcode('plain')
    eml_prefer_const(sumtp_ex,outtp_ex,castInputsToSumType);

    if isfloat(outtp_ex)
        y=hdleml_sub(u,v,outtp_ex);
    elseif(castInputsToSumType)
        nt_s=numerictype(sumtp_ex);
        fm_s=fimath(sumtp_ex);
        fm=fimath(...
        'RoundMode',fm_s.RoundMode,...
        'OverflowMode',fm_s.OverflowMode,...
        'SumMode','SpecifyPrecision',...
        'SumWordLength',nt_s.WordLength,...
        'SumFractionLength',nt_s.FractionLength);

        y=fi(hdleml_sub(fi(u,nt_s,fm),fi(v,nt_s,fm),sumtp_ex),numerictype(outtp_ex),fimath(outtp_ex));
    else
        y=hdleml_sub(u,v,outtp_ex);
    end
