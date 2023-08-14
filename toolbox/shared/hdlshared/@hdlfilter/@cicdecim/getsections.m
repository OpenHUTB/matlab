function sections=getsections(this)






    numsections=this.numberofsections;
    sections.numfactor=this.decimationfactor;
    sections.first_intsection=1;
    sections.last_intsection=numsections;
    sections.first_combsection=numsections+1;
    sections.last_combsection=2*numsections;
    sections.diffindex=numsections;

