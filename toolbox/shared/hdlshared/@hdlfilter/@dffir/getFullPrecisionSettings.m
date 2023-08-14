function fpset=getFullPrecisionSettings(this)







    [inpsize,inpbp]=hdlgetsizesfromtype(this.InputSltype);
    if inpsize>0


        [cwl,cbp]=hdlgetsizesfromtype(this.CoeffSLType);

        if(this.coeffPort)
            maxcoeff=2^(cwl-cbp-1);

            prevCoefficients=this.Coefficients;

            this.Coefficients=maxcoeff*ones(1,this.getfilterlengths.coeff_len);
        end;

        inputmax=2^(inpsize-1);


        prodfl=inpbp+cbp;
        coeffmax=norm(this.Coefficients,'inf');
        coeffmax=coeffmax*2^cbp;
        maxproduct=inputmax*coeffmax;
        prodwl=ceil(log2(maxproduct+1))+1;

        fpset.product=[prodwl,prodfl];


        if(this.coeffPort)
            accumwl=prodwl+ceil(log2(maxcoeff*length(this.coefficients)));
            this.Coefficients=prevCoefficients;

        else
            summax=sum(abs(this.Coefficients));
            summax=summax*2^cbp;
            summax=inputmax*summax;
            accumwl=ceil(log2(summax+1))+1;
        end;

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


