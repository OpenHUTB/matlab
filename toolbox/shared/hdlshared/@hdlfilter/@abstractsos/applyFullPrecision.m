function v=applyFullPrecision(this)






    v=hdlvalidatestruct;

    fpvalues=this.getFullPrecisionSettings;

    this.NumAccumSLtype=hdlgetsltypefromsizes(fpvalues.accumulator(1),fpvalues.accumulator(2),1);
    this.DenAccumSLtype=hdlgetsltypefromsizes(fpvalues.accumulator(1),fpvalues.accumulator(2),1);

    this.OutputSLtype=hdlgetsltypefromsizes(fpvalues.output(1),fpvalues.output(2),1);

    if isa(this,'hdlfilter.df2sos')
        this.StateSltype=hdlgetsltypefromsizes(fpvalues.state(1),fpvalues.state(2),1);
    end
