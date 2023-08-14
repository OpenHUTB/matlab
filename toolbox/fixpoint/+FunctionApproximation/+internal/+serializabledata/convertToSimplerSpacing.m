function sData=convertToSimplerSpacing(sData)







    if sData.Spacing~="EvenPow2Spacing"
        nD=sData.NumberOfDimensions;
        dx=cell(1,nD);
        for ii=1:nD
            dx{ii}=diff(sData.Data{ii});
        end
        if sData.Spacing=="ExplicitValues"

            isEven=false(1,nD);
            for ii=1:nD
                deltaX=dx{ii}(1);
                allSpacingAreEqual=all(dx{ii}-deltaX==0);



                spacingFitsInStorageType=deltaX==double(fixed.internal.math.castUniversal(deltaX,sData.StorageTypes(ii)));
                isEven(ii)=allSpacingAreEqual&&spacingFitsInStorageType;
            end
        else

            isEven=true(1,nD);
        end


        isEvenPow2=false(1,nD);
        if all(isEven)
            for ii=1:nD
                isEvenPow2(ii)=mod(log2(dx{ii}(1)),1)==0;
            end
        end


        if all(isEvenPow2)
            sData.Spacing=FunctionApproximation.BreakpointSpecification.EvenPow2Spacing;
        elseif all(isEven)
            sData.Spacing=FunctionApproximation.BreakpointSpecification.EvenSpacing;
        end
    end
end


