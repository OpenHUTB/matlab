function need=needModifyforFullPrecision(this)







    fpvalues=this.getFullPrecisionSettings;

    [prodwl,prodfl]=hdlgetsizesfromtype(this.ProductSLType);
    [accumwl,accumfl]=hdlgetsizesfromtype(this.AccumSLType);


    fpprodwl=fpvalues.product(1);
    fpprodfl=fpvalues.product(2);

    fpaccumwl=fpvalues.accumulator(1);
    fpaccumfl=fpvalues.accumulator(2);

    need=~strcmpi(this.InputSLType,'double')&&...
    (prodwl-prodfl)<(fpprodwl-fpprodfl)||prodfl<fpprodfl||...
    (accumwl-accumfl)<(fpaccumwl-fpaccumfl)||accumfl<fpaccumfl;



