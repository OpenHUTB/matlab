function[cplxprodSLtype,cplxsumSLtype]=getScaleSLTypes(this)








    [iwl,ifl]=hdlgetsizesfromtype(this.InputSLType);
    [swl,sfl]=hdlgetsizesfromtype(this.ScaleSLType);

    [sowl,sofl]=hdlgetsizesfromtype(this.SectionOutputSLtype);


    cpfl=max(ifl,sofl)+sfl;
    cpwl=cpfl+max(iwl+swl-ifl-sfl,sowl+swl-sofl-sfl);

    csfl=cpfl;
    if cpwl==0
        cswl=cpwl;
    else
        cswl=cpwl+1;
    end
    cplxprodSLtype=hdlgetsltypefromsizes(cpwl,cpfl,1);
    cplxsumSLtype=hdlgetsltypefromsizes(cswl,csfl,1);

