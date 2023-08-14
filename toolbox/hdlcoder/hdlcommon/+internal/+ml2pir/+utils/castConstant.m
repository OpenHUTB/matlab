
function[castedVal,newType]=castConstant(val,valType,siblingType,parentNode,relopconstLHS)









    if nargin<5










        relopconstLHS=false;
    end

    if(valType.isFi&&siblingType.isFi)


        newType=valType;
        castedVal=val;
        return;
    end

    if any(strcmp(parentNode.kind,...
        {'PLUS','MINUS','EQ','GE','GT','LE','LT','NE'}))

        getBestPrecision=false;
    else
        getBestPrecision=true;
    end

    dim=valType.Dimensions;
    newType=siblingType.copy;
    newType.setDimensions(dim);
    if newType.isNumeric&&valType.isNumeric


        newType.Complex=valType.Complex;
    end
    if getBestPrecision
        if newType.isFi


            nt=newType.Numerictype;
            bestPrecisionFiVal=fi(val,nt.SignednessBool,nt.WordLength,newType.Fimath);
            newType.Numerictype.FractionLength=...
            bestPrecisionFiVal.FractionLength;
        elseif newType.isInt&&any(newType.castValueToType(val)~=val,'all')


            bestPrecisionFiVal=fi(val,newType.Signedness,newType.Bits);
            isComplex=newType.Complex;
            newType=internal.mtree.Type.fromValue(bestPrecisionFiVal);
            newType.Complex=isComplex;
            newType.setDimensions(dim);
        end
    elseif any(strcmpi(parentNode.kind,{'eq','ge','gt','le','lt','ne'}))&&(newType.isInt||newType.isFi)
        thisOp=parentNode.kind;
        if relopconstLHS




            thisOp=coder.internal.getConverseRelop(thisOp);
        end
        if newType.isInt
            fiPrototype=fi([],siblingType.Signedness,siblingType.Bits,0);
        elseif siblingType.isFi
            fiPrototype=fi([],siblingType.Numerictype);
        end
        if fixed.internal.type.isAnyFloat(val)
            castedVal=removefimath(FiRelopFloatDtRules(fiPrototype,val,thisOp));
        else
            castedVal=fi(val);
        end
        newType=internal.mtree.Type.fromValue(castedVal);
        return
    end
    castedVal=newType.castValueToType(val);
end
