function[cplxprodSLtype,cplxsumSLtype]=getScaleSLTypes(this)








    [iwl,ifl]=hdlgetsizesfromtype(this.InputSLType);
    [swl,sfl]=hdlgetsizesfromtype(this.ScaleSLType);

    [dswl,dsfl]=hdlgetsizesfromtype(this.DenStateSLtype);


    cpfl=max(ifl,dsfl)+sfl;
    cpwl=cpfl+max(iwl+swl-ifl-sfl,dswl+swl-dsfl-sfl);

    csfl=cpfl;
    if cpwl==0
        cswl=cpwl;
    else
        cswl=cpwl+1;
    end
    cplxprodSLtype=hdlgetsltypefromsizes(cpwl,cpfl,1);
    cplxsumSLtype=hdlgetsltypefromsizes(cswl,csfl,1);

