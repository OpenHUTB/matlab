function v=applyFullPrecision(this)






    v=hdlvalidatestruct;

    fpvalues=this.getFullPrecisionSettings;

    fpprodwl=fpvalues.product(1);
    fpprodfl=fpvalues.product(2);

    fpaccumwl=fpvalues.accumulator(1);
    fpaccumfl=fpvalues.accumulator(2);

    this.ProductSLtype=hdlgetsltypefromsizes(fpprodwl,fpprodfl,1);
    this.AccumSLType=hdlgetsltypefromsizes(fpaccumwl,fpaccumfl,1);

    err=3;


    v(end+1)=hdlvalidatestruct(err,...
    message('HDLShared:filters:fir:datapathNotFullPrecision',...
    fpvalues.product(1),fpvalues.product(2),...
    fpvalues.accumulator(1),fpvalues.accumulator(2)));


    if hdlgetparameter('generatevalidationmodel')==1
        v(end+1)=hdlvalidatestruct(err,...
        message('HDLShared:filters:fir:validationModelAssertionsLikely'));
    end



