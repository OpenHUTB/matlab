function need=needModifyforFullPrecision(this)







    fpvalues=this.getFullPrecisionSettings;

    [prodwl,prodfl]=hdlgetsizesfromtype(this.ProductSLType);
    [accumwl,accumfl]=hdlgetsizesfromtype(this.AccumSLType);


    fpprodwl=fpvalues.product(1);
    fpprodfl=fpvalues.product(2);

    fpaccumwl=fpvalues.accumulator(1);
    fpaccumfl=fpvalues.accumulator(2);


    ssi=this.getHDLParameter('filter_serialsegment_inputs');
    if~isscalar(ssi)&&isequal(ones(1,length(ssi)),ssi)
        need=false;
    else
        need=(prodwl-prodfl)<(fpprodwl-fpprodfl)||prodfl<fpprodfl||...
        (accumwl-accumfl)<(fpaccumwl-fpaccumfl)||accumfl<fpaccumfl;
    end



