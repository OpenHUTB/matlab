function fpset=getFullPrecisionSettings(this)







    [inpsize,inpbp]=hdlgetsizesfromtype(this.InputSltype);

    if inpsize>0

        tapsumsize=inpsize+1;
        tapsumbp=inpbp;
        inputmax=2^(tapsumsize-1);

        fpset.tapsum=[tapsumsize,tapsumbp];
        [~,cbp]=hdlgetsizesfromtype(this.CoeffSLType);


        prodfl=tapsumbp+cbp;
        coeffmax=norm(this.Coefficients,'inf');
        coeffmax=coeffmax*2^cbp;
        maxproduct=inputmax*coeffmax;
        prodwl=ceil(log2(maxproduct+1))+1;

        fpset.product=[prodwl,prodfl];


        naccum=ceil(length(this.Coefficients)/2);

        summax=sum(abs(this.Coefficients(1:naccum)));
        summax=summax*2^cbp;
        summax=inputmax*summax;
        accumwl=ceil(log2(summax+1))+1;

        accumfl=prodfl;
        fpset.accumulator=[accumwl,accumfl];


        [opsize,opbp]=hdlgetsizesfromtype(this.OutputSltype);
        fpset.output=[opsize,opbp];
    else
        fpset.tapsum=[0,0];
        fpset.product=[0,0];
        fpset.output=[0,0];
        fpset.accumulator=[0,0];
    end


