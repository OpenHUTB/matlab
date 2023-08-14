function[allff,alldr,ff,dr]=getDAFoldingFactors(this)







    inputsize=hdlgetsizesfromtype(this.InputSLType);
    ff=1:inputsize;
    ff=ff(ceil(inputsize*ones(1,inputsize)./ff)==floor(inputsize*ones(1,inputsize)./ff));
    dr=2.^(max(ff)./ff);


    allff=ff;
    alldr=dr;


