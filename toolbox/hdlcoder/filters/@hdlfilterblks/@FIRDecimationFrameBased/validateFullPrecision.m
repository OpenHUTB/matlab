function v=validateFullPrecision(this,hC)




    v=hdlvalidatestruct;

    FilterStructure=get_param(hC.SimulinkHandle,'filtStruct');
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




    blockInfo=getBlockInfo(this,hC.SimulinkHandle);
    decimfact=1/blockInfo.rateChangeFactor;
    coeffs=blockInfo.Coefficients;

    PolyphaseCoefficients=polyphase_coeffs(coeffs,decimfact);

    if decimfact>1
        coefficients=PolyphaseCoefficients(2,:);
    else
        coefficients=PolyphaseCoefficients;
    end

    inpsize=hC.PirInputSignals(1).Type.getLeafType.WordLength;
    inpbp=-hC.PirInputSignals(1).Type.getLeafType.FractionLength;

    cbp=compiledDataTypes.CoefficientsDataType.FractionLength;


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

end



function pp_coeffs=polyphase_coeffs(coeffs,decimfact)
    rows=decimfact;
    columns=ceil(length(coeffs)/decimfact);
    pp_coeffs=zeros(rows,columns);
    coeffs_expand=zeros(1,rows*columns);
    coeffs_expand(1:length(coeffs))=coeffs;
    for n=1:columns
        pp_coeffs(:,n)=coeffs_expand((n-1)*decimfact+1:n*decimfact).';
    end
end