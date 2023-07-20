function updatedType=scaleDataType(dataType,value,varargin)





    optargs={numerictype(1,16,1,-10,0)};
    optargs(1:numel(varargin))=varargin;
    templateType=optargs{:};

    if isfloat(dataType)

        updatedType=dataType;
    else

        wl=dataType.WordLength;
        signedNess=any(value(:)<0);
        slAdj=templateType.SlopeAdjustmentFactor;
        bias=templateType.Bias;

        if(slAdj==1)&&(bias==0)



            fl=fixed.GetBestPrecision(value(:),wl,signedNess);
            updatedType=numerictype(signedNess,wl,fl);
        else



            newValue=(value-bias)/slAdj;

            updatedType=FunctionApproximation.internal.scaleDataType(dataType,newValue);


            updatedType=numerictype(updatedType.SignednessBool,updatedType.WordLength,slAdj,updatedType.FixedExponent,bias);
        end

        if fixed.isSignedOneBit(updatedType)
            updatedType.WordLength=2;
        end
    end
end
