function need=needModifyforFullPrecision(this)







    fpvalues=this.getFullPrecisionSettings;
    [tapsumwl,tapsumfl]=hdlgetsizesfromtype(this.TapsumSLtype);
    [prodwl,prodfl]=hdlgetsizesfromtype(this.ProductSLType);
    [accumwl,accumfl]=hdlgetsizesfromtype(this.AccumSLType);

    fptapsumwl=fpvalues.tapsum(1);
    fptapsumfl=fpvalues.tapsum(2);

    fpprodwl=fpvalues.product(1);
    fpprodfl=fpvalues.product(2);

    fpaccumwl=fpvalues.accumulator(1);
    fpaccumfl=fpvalues.accumulator(2);

    need=(tapsumwl-tapsumfl)<(fptapsumwl-fptapsumfl)||tapsumfl<fptapsumfl||...
    (prodwl-prodfl)<(fpprodwl-fpprodfl)||prodfl<fpprodfl||...
    (accumwl-accumfl)<(fpaccumwl-fpaccumfl)||accumfl<fpaccumfl;



