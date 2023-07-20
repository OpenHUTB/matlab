function v=applyFullPrecision(this)






    v=hdlvalidatestruct;

    fpvalues=this.getFullPrecisionSettings;

    fptapsumwl=fpvalues.tapsum(1);
    fptapsumfl=fpvalues.tapsum(2);

    fpprodwl=fpvalues.product(1);
    fpprodfl=fpvalues.product(2);

    fpaccumwl=fpvalues.accumulator(1);
    fpaccumfl=fpvalues.accumulator(2);

    this.TapsumSLtype=hdlgetsltypefromsizes(fptapsumwl,fptapsumfl,1);
    this.ProductSLtype=hdlgetsltypefromsizes(fpprodwl,fpprodfl,1);
    this.AccumSLType=hdlgetsltypefromsizes(fpaccumwl,fpaccumfl,1);

    err=3;

    v(end+1)=hdlvalidatestruct(err,...
    message('HDLShared:filters:symfir:datapathNotFullPrecision',...
    fpvalues.tapsum(1),fpvalues.tapsum(2),...
    fpvalues.product(1),fpvalues.product(2),...
    fpvalues.accumulator(1),fpvalues.accumulator(2)));


    if hdlgetparameter('generatevalidationmodel')==1
        v(end+1)=hdlvalidatestruct(err,...
        message('HDLShared:filters:symfir:validationModelAssertionsLikely'));
    end



