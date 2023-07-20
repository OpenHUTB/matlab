function v=validateFullPrecision(this,hC)




    v=hdlvalidatestruct;

    FilterStructure=get_param(hC.SimulinkHandle,'FilterStructure');
    noTapSum=strcmp(FilterStructure,'Direct form')||strcmp(FilterStructure,'Direct form transposed');

    compiledDataTypes=getCompiledFixedPointInfo(hC.SimulinkHandle);
    fpvalues=getFullPrecision(this,hC,compiledDataTypes);

    prodwl=compiledDataTypes.ProductDataType.WordLength;
    prodfl=compiledDataTypes.ProductDataType.FractionLength;
    accumwl=compiledDataTypes.AccumulatorDataType.WordLength;
    accumfl=compiledDataTypes.AccumulatorDataType.FractionLength;

    fpprodwl=fpvalues.product(1);
    fpprodfl=fpvalues.product(2);

    fpaccumwl=fpvalues.accumulator(1);
    fpaccumfl=fpvalues.accumulator(2);

    if noTapSum
        notFullPrecision=(prodwl<fpprodwl)||(prodfl<fpprodfl)||...
        (accumwl<fpaccumwl)||(accumfl<fpaccumfl);
    else
        tapwl=compiledDataTypes.TapSumDataType.WordLength;
        tapfl=compiledDataTypes.TapSumDataType.FractionLength;
        fptapwl=fpvalues.tapsum(1);
        fptapfl=fpvalues.tapsum(2);
        notFullPrecision=(tapwl<fptapwl)||(tapfl<fptapfl)||...
        (prodwl<fpprodwl)||(prodfl<fpprodfl)||...
        (accumwl<fpaccumwl)||(accumfl<fpaccumfl);
    end

    if notFullPrecision
        if noTapSum
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validateFrameBased:datapathNotFullPrecision',...
            fpvalues.product(1),fpvalues.product(2),fpvalues.accumulator(1),fpvalues.accumulator(2)));
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validateFrameBased:datapathNotFullPrecisionTapSum',...
            fpvalues.tapsum(1),fpvalues.tapsum(2),...
            fpvalues.product(1),fpvalues.product(2),...
            fpvalues.accumulator(1),fpvalues.accumulator(2)));
        end
        return;
    end

end

function fpset=getFullPrecision(this,hC,compiledDataTypes)


    coefSource=get_param(hC.SimulinkHandle,'CoefSource');
    FilterStructure=get_param(hC.SimulinkHandle,'FilterStructure');
    switch coefSource
    case 'Input port'
        inpsize=hdlsignalsizes(hC.PirInputSignals(1));
        inpwl=inpsize(1);
        inpbp=inpsize(2);
        coeffsize=hdlsignalsizes(hC.PirInputSignals(2));
        coeffwl=coeffsize(1);
        coeffbp=coeffsize(2);

        fpset.product=[inpwl+coeffwl,inpbp+coeffbp];

        numCoeff=prod(hdlsignalvector(hC.PirInputSignals(2)));
        fpset.accumulator=[fpset.product(1)+ceil(log2(numCoeff)),fpset.product(2)];

        if~(strcmp(FilterStructure,'Direct form')||strcmp(FilterStructure,'Direct form transposed'))
            tapsumwl=inpwl+1;
            tapsumbp=inpbp;
            fpset.tapsum=[tapsumwl,tapsumbp];
            fpset.product(1)=fpset.product(1)+1;
        end
    otherwise

        coefficients=double(this.hdlslResolve('Coefficients',hC.SimulinkHandle));

        inpsize=hC.PirInputSignals(1).Type.getLeafType.WordLength;
        inpbp=-hC.PirInputSignals(1).Type.getLeafType.FractionLength;

        cbp=compiledDataTypes.CoefficientsDataType.FractionLength;

        if strcmp(FilterStructure,'Direct form')||strcmp(FilterStructure,'Direct form transposed')

            inputmax=2^(inpsize-1);


            prodfl=inpbp+cbp;
            coeffmax=norm(coefficients,'inf');
            coeffmax=coeffmax*2^cbp;
            maxproduct=inputmax*coeffmax;
            prodwl=ceil(log2(maxproduct+1))+1;

            fpset.product=[prodwl,prodfl];


            summax=sum(abs(coefficients));
            summax=summax*2^cbp;
            summax=inputmax*summax;
            accumwl=ceil(log2(summax+1))+1;

            accumfl=prodfl;
            fpset.accumulator=[accumwl,accumfl];
        else

            tapsumsize=inpsize+1;
            tapsumbp=inpbp;
            inputmax=2^(tapsumsize-1);

            fpset.tapsum=[tapsumsize,tapsumbp];


            prodfl=tapsumbp+cbp;
            coeffmax=norm(coefficients,'inf');
            coeffmax=coeffmax*2^cbp;
            maxproduct=inputmax*coeffmax;
            prodwl=ceil(log2(maxproduct+1))+1;

            fpset.product=[prodwl,prodfl];


            naccum=ceil(length(coefficients)/2);

            summax=sum(abs(coefficients(1:naccum)));
            summax=summax*2^cbp;
            summax=inputmax*summax;
            accumwl=ceil(log2(summax+1))+1;

            accumfl=prodfl;
            fpset.accumulator=[accumwl,accumfl];
        end
    end
end
