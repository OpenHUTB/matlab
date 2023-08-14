function[bp_data_typed,bpType_ex,kType_ex,fType_ex,idxOnly,powerof2,diagnostics]=getBlockInfo(~,hC)







    slbh=hC.SimulinkHandle;

    diagnostics=get_param(slbh,'DiagnosticForOutOfRangeInput');



    rndMode=get_param(slbh,'RndMeth');
    bpType_ex=pirelab.getTypeInfoAsFi(hC.PirInputSignals(1).Type,rndMode);
    rto=get_param(slbh,'RuntimeObject');
    if~isfi(rto.RuntimePrm(1).Data)
        bpType_ex=pirelab.getTypeInfoAsFi(hC.PirInputSignals(1).Type,rndMode);
    else
        rto_data_in=rto.RuntimePrm(1).Data;
        bpType=numerictype(rto_data_in);
        if any([bpType.issingle,bpType.isdouble])
            bpType_ex=pirelab.getTypeInfoAsFi(hC.PirInputSignals(1).Type,rndMode);
        else
            bpType_nt=numerictype(bpType_ex);
            bpType_nt.WordLength=bpType.WordLength;
            bpType_nt.FractionLength=bpType.FractionLength;
            bpType_nt.Signedness=bpType.Signedness;
            bpType_ex=fi(bpType_ex,bpType_nt);
        end
    end
    if bpType_ex.WordLength==128
        bpType_ex.SumMode='SpecifyPrecision';
        bpType_ex.SumWordLength=bpType_ex.WordLength;
        bpType_ex.SumFractionLength=bpType_ex.FractionLength;
        bpType_ex.ProductMode='SpecifyPrecision';
        bpType_ex.ProductWordLength=bpType_ex.WordLength;
        bpType_ex.ProductFractionLength=bpType_ex.FractionLength;
    end











    bp_fimath=fimath(bpType_ex);
    bp_fimath.RoundMode='Nearest';
    bp_fimath.OverflowMode='Saturate';

    slobj=get_param(slbh,'Object');
    if strcmpi(slobj.BreakpointsSpecification,'Even spacing')
        N_dim=slResolve(slobj.BreakpointsNumPoints,getfullname(slbh));
        bp_start_pt=rto.RuntimePrm(1).Data;
        bp_spacing=slResolve(slobj.BreakpointsSpacing,getfullname(slbh));
        evenly_spaced_fixpt=false;%#ok<NASGU>
        if(isfi(bp_start_pt))

            bp_spacing=fi(bp_spacing,numerictype(bp_start_pt));
            bp_end_pt=fi(bp_start_pt+(N_dim-1)*bp_spacing,numerictype(bp_start_pt));

            if(bp_start_pt.Signed)
                bp_res_reint_type=numerictype(1,bp_start_pt.WordLength,0);
            else
                bp_res_reint_type=numerictype(0,bp_start_pt.WordLength,0);
            end

            bp_data=fi(storedInteger(bp_start_pt):storedInteger(bp_spacing):storedInteger(bp_end_pt),bp_res_reint_type);
            evenly_spaced_fixpt=true;
        else
            bp_end_pt=bp_start_pt+(N_dim-1)*bp_spacing;
            bp_data=double(bp_start_pt):double(bp_spacing):double(bp_end_pt);
            evenly_spaced_fixpt=false;
        end

        if(evenly_spaced_fixpt)
            bp_data_typed=reinterpretcast(bp_data,numerictype(bp_start_pt));

            stride=reinterpretcast(fi(storedInteger(bp_data(2))-storedInteger(bp_data(1)),1,bp_start_pt.WordLength,0),numerictype(bp_start_pt));
            stride=double(stride);
        else
            bp_data_typed=fi(bp_data,numerictype(bpType_ex),bp_fimath);
            stride=double(bp_data(2)-bp_data(1));
        end
    else
        bp_rawdata=get_param(slbh,'BreakpointsData');

        bp_data=slResolve(bp_rawdata,slbh);


        stride=double(bp_data(2)-bp_data(1));
        bp_data_typed=fi(bp_data,numerictype(bpType_ex),bp_fimath);
    end


    idxOnly=strcmpi(get_param(slbh,'OutputOnlyTheIndex'),'on');


    kType_ex=pirelab.getTypeInfoAsFi(hC.SLOutputSignals(1).Type,'Floor');
    if~idxOnly

        fType_ex=pirelab.getTypeInfoAsFi(hC.SLOutputSignals(2).Type,rndMode);
    else

        fType_ex=kType_ex;
    end


    powerof2=nextpow2(stride);
    if stride~=2^powerof2
        powerof2=-9999;
    end


