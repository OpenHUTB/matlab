function subComparison=validateParamSubComparison(subComparison)












    if isempty(subComparison)
        return
    end

    paramComparisonType='LightweightNode comparison';
    if subComparison.getType().getDescription.equals(paramComparisonType)
        return
    end

    if subComparison.getType().getDescription.equals('Combined Comparison')
        comparisons=subComparison.getComparisons();
        for ii=0:comparisons.size()-1
            comparison=comparisons.get(ii);
            if comparison.getType().getDescription.equals(paramComparisonType)
                subComparison=comparison;
                return
            end
        end
    end
    subComparison=[];
end
