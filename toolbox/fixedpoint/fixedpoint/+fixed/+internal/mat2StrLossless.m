function stringRepresentation=mat2StrLossless(value,extraPretty)











    validateattributes(value,{'numeric','logical','embedded.fi'},{});

    if nargin<2
        extraPretty=false;
    end

    [doHandleComplexSpecial,imagAllZeros]=handleComplexSpecial(value);

    if doHandleComplexSpecial

        strReal=fixed.internal.mat2StrLossless(real(value),extraPretty);

        if imagAllZeros
            strImag=fixed.internal.mat2StrLossless(imag(value(1)),extraPretty);
        else
            strImag=fixed.internal.mat2StrLossless(imag(value),extraPretty);
        end

        stringRepresentation=sprintf('complex(%s,%s)',strReal,strImag);
        return
    end

    dims=size(value);
    nDims=numel(dims);
    multiDim=nDims>2;

    nt=fixed.extractNumericType(value);

    if multiDim
        value=reshape(value,[1,numel(value)]);
    end

    if isfi(value)

        stringRepresentation=fixed.internal.fiToSimpleString(value,extraPretty);

        if isempty(stringRepresentation)
            nDigitPrec=max(17,1+ceil(log10(2^nt.WordLength)));
            stringRepresentation=mat2str(value,nDigitPrec,'class');
        end

    elseif isfloat(value)

        stringRepresentation=fixed.internal.compactButAccurateMat2Str(double(value));
        if~isdouble(nt)
            stringRepresentation=sprintf('%s(%s)',class(value),stringRepresentation);
        end

    else
        assert(islogical(value)||isinteger(value))

        if prettyInteger(value,nt,extraPretty)

            stringRepresentation=mat2str(value,21,'class');
        else


            s1=fixed.internal.mat2StrLossless(castIntToFi(value));
            stringRepresentation=sprintf('%s(%s)',class(value),s1);
        end
    end

    if multiDim
        stringRepresentation=sprintf('reshape(%s,%s)',stringRepresentation,mat2str(dims,21));
    end
end

function b=prettyInteger(value,nt,extraPretty)

    if isscalar(value)||nt.WordLength<=32
        b=true;
    elseif~extraPretty
        b=false;
    else
        ntTight=fixed.internal.type.tightFixedPointType(value,2^16);
        b=fixed.internal.type.isTypeSuperset('double',ntTight);
    end
end


function[b,imagAllZeros]=handleComplexSpecial(value)

    b=false;

    imagAllZeros=false;

    if~isreal(value)

        imagAllZeros=all(0==imag(value(:)));

        if imagAllZeros




            b=true;

        elseif any(isnan(imag(value(:))))



            b=true;

        elseif isfi(value)&&~all(isfinite(imag(value(:))))



            b=true;

        elseif isinteger(value)




            nt=fixed.extractNumericType(value);

            if nt.WordLength>32



                b=true;

            elseif nt.SignednessBool

                lo=castFiToInt(lowerbound(nt));

                b=any(lo==imag(value(:)));
            end
        end
    end
end
