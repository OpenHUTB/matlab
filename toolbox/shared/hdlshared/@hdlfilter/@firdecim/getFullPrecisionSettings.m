function fpset=getFullPrecisionSettings(this)








    [inpsize,inpbp]=hdlgetsizesfromtype(this.InputSltype);
    if inpsize>0

        inputmax=2^(inpsize-1);

        [~,cbp]=hdlgetsizesfromtype(this.CoeffSLType);


        prodfl=inpbp+cbp;
        coeffmax=norm(this.PolyphaseCoefficients(:),'inf');
        coeffmax=coeffmax*2^cbp;
        maxproduct=inputmax*coeffmax;
        prodwl=ceil(log2(maxproduct+1))+1;

        fpset.product=[prodwl,prodfl];


        summax=sum(abs(this.PolyphaseCoefficients(:)));
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


