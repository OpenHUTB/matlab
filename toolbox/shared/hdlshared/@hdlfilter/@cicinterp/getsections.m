function sections=getsections(this)






    numsections=this.numberofsections;
    sections.numfactor=this.interpolationfactor;
    sections.first_combsection=1;
    sections.last_combsection=numsections;
    sections.first_intsection=numsections+1;
    sections.last_intsection=2*numsections;
    sections.diffindex=0;


