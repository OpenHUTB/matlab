function cStr=cExpressionIntMinMaxValue(isMax,isSigned,wordLength,cNativeTypeName,maxBitsStraightIntMin,maxBitsDecUintMax)









































































    if nargin<5
        maxBitsStraightIntMin=16;
    end

    if nargin<6
        maxBitsDecUintMax=16;
    end

    suffix2=cSuffix(cNativeTypeName);

    if isMax
        cStr=getMaxValue(isSigned,wordLength,maxBitsDecUintMax,suffix2);
    else
        cStr=getMinValue(isSigned,wordLength,maxBitsStraightIntMin,suffix2);
    end
end

function suffix1=getSuffix1(isSigned)
    if isSigned
        suffix1='';
    else
        suffix1='U';
    end
end

function str=cSuffix(cNativeTypeName)

    if contains(cNativeTypeName,'long long')
        str='LL';
    elseif contains(cNativeTypeName,'long')
        str='L';
    else
        str='';
    end
end

function cStr=getMaxValue(isSigned,wordLength,maxBitsDecUintMax,suffix2)

    doHex=~isSigned&&wordLength>maxBitsDecUintMax;

    if wordLength>64



        temp=fi(0,isSigned,wordLength,0);
        r=temp.range;
        maxNumeric=r(2);
        if doHex
            maxStr=upper(maxNumeric.hex);
        else
            maxStr=maxNumeric.Value;
        end
    else
        if doHex
            nFullF=floor(wordLength/4);
            partialF=wordLength-nFullF*4;
            leadStr={'','1','3','7'};
            maxStr=[leadStr{partialF+1},repmat('F',1,nFullF)];
        else
            pow2Exp=wordLength-isSigned;
            if pow2Exp==64
                vPositive=intmax('uint64');
            else
                vPositive=uint64(2^pow2Exp)-uint64(1);
            end
            maxStr=num2str(vPositive,30);
        end
    end

    if doHex
        maxStr=['0x',upper(maxStr)];
    end

    suffix1=getSuffix1(isSigned);

    cStr=sprintf('((%sint%d_T)(%s%s%s))',...
    lower(suffix1),...
    wordLength,...
    maxStr,...
    suffix1,...
    suffix2);
end

function cStr=getMinValue(isSigned,wordLength,maxBitsStraightIntMin,suffix2)

    suffix1=getSuffix1(isSigned);

    if~isSigned
        innerStr=sprintf('0%s%s',suffix1,suffix2);
    else
        useMinusOne=isSigned&&wordLength>maxBitsStraightIntMin;

        if wordLength>64



            temp=fi(0,isSigned,wordLength,0);
            r=temp.range;
            minNumeric=r(1);
            fiOne=cast(1,'like',minNumeric);
            if useMinusOne
                minNumeric=cast(minNumeric+fiOne,'like',minNumeric);
            end
            minStr=minNumeric.Value;
        else
            pow2Exp=wordLength-1;
            vPositive=uint64(2^pow2Exp);
            if useMinusOne
                vPositive=vPositive-uint64(1);
            end
            minStr=['-',num2str(vPositive,30)];
        end

        if useMinusOne
            innerStr=sprintf('%s%s%s-1%s%s',...
            minStr,...
            suffix1,...
            suffix2,...
            suffix1,...
            suffix2);
        else
            innerStr=sprintf('%s%s%s',...
            minStr,...
            suffix1,...
            suffix2);
        end

    end

    cStr=sprintf('((%sint%d_T)(%s))',...
    lower(suffix1),...
    wordLength,...
    innerStr);
end
