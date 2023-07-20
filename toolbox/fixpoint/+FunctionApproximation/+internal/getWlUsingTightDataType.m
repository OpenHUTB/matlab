function[isValid,snappedWL,newType]=getWlUsingTightDataType(data,maxWL,options,useHalf)















    if nargin<4
        useHalf=false;
    end

    isValid=false;
    snappedWL=[];
    newType=[];

    if~options.ExploreFixedPoint&&~options.ExploreFloatingPoint
        return;
    end

    isValidFixed=false;
    if options.ExploreFixedPoint
        newTypeFixed=fixed.internal.type.tightFixedPointType(data,maxWL);
        smallestWL=newTypeFixed.WordLength;
        wlDiff=options.WordLengths-smallestWL;
        wlDiff(wlDiff<0)=Inf;
        if all(isinf(wlDiff))
            snappedWLFixed=max(options.WordLengths);
            isValidFixed=false;
        else
            [~,location]=min(wlDiff);
            snappedWLFixed=options.WordLengths(location);
            isValidFixed=true;
        end
    end

    isValidFloat=false;
    if options.ExploreFloatingPoint
        wls=FunctionApproximation.internal.ApproximateGeneratorEngine.getFloatingPointWLs(options);
        floatingPointStrings=FunctionApproximation.internal.ApproximateGeneratorEngine.getFloatingPointStrings(options);
        if~useHalf
            validTypes=floatingPointStrings~="half";
            floatingPointStrings=floatingPointStrings(validTypes);
            wls=wls(validTypes);
        end
        isValidFloat=false;
        for ii=1:numel(wls)
            if any(wls(ii)==options.WordLengths)
                quantizedValues=fixed.internal.math.castUniversal(data(:),floatingPointStrings(ii));
                if all(data(:)==quantizedValues)
                    newTypeFloat=numerictype(floatingPointStrings(ii));
                    isValidFloat=true;
                    snappedWLFloat=wls(ii);
                    break;
                end
            end
        end
    end

    if isValidFloat&&isValidFixed
        if snappedWLFloat<=snappedWLFixed
            newType=newTypeFloat;
            snappedWL=snappedWLFloat;
        else
            newType=newTypeFixed;
            snappedWL=snappedWLFixed;
        end
        isValid=true;
    elseif isValidFloat
        newType=newTypeFloat;
        isValid=true;
        snappedWL=snappedWLFloat;
    elseif isValidFixed
        newType=newTypeFixed;
        isValid=true;
        snappedWL=snappedWLFixed;
    else
        if options.ExploreFixedPoint
            newType=newTypeFixed;
            isValid=false;
            snappedWL=snappedWLFixed;
        end
    end
end


