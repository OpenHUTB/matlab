function need=needModifyforFullPrecision(this)







    fpvalues=this.getFullPrecisionSettings;
    fpsumsize=fpvalues.accumulator(1);
    fpsumbp=fpvalues.accumulator(2);

    [accumwl,accumfl_num]=hdlgetsizesfromtype(this.NumAccumSLtype);
    [~,accumfl_den]=hdlgetsizesfromtype(this.DenAccumSLtype);

    mults=this.getHDLParameter('filter_nummultipliers');
    uff=this.getHDLParameter('userspecified_foldingfactor');

    if(mults==-1)
        [mults,~]=this.getSerialPartForFoldingFactor('foldingfactor',uff);
    end

    if(mults==1)

        need=(accumfl_num~=accumfl_den);
    else


        need=(accumwl-accumfl_num)<(fpsumsize-fpsumbp)||accumfl_num<fpsumbp||...
        (accumwl-accumfl_den)<(fpsumsize-fpsumbp)||accumfl_den<fpsumbp||...
        (accumfl_num~=accumfl_den);
    end

