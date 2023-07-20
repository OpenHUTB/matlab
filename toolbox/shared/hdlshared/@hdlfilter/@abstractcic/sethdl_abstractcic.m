function sethdl_abstractcic(this,Hd)








    numsections=length(this.SectionSLtypes);
    Hd.NumberOfSections=this.numberofsections;

    this.sethdl_abstractfilter(Hd);




    Hd.DifferentialDelay=this.differentialdelay;

    sltype=this.SectionSLtype;
    swl=[];
    sfl=[];
    for n=1:numsections
        [nswl,nsfl]=hdlgetsizesfromtype(sltype{n});
        swl=[swl,nswl];
        sfl=[sfl,nsfl];
    end
    Hd.SectionWordLengths=swl;
    Hd.SectionFracLengths=sfl;



