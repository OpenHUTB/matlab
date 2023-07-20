function fpset=getFullPrecisionSettings(this)






    fpset.tapsum=[0,0];
    fpset.product=hdlgetsizesfromtype(this.ProductSltype);
    fpset.output=hdlgetsizesfromtype(this.OutputSltype);
    fpset.accumulator=hdlgetsizesfromtype(this.PolyAccumSltype);

