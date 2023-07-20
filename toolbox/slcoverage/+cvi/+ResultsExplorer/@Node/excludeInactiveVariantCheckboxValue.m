function value=excludeInactiveVariantCheckboxValue(obj)



    try
        if(isa(obj.data.cvd,'cvdata'))
            allCvd={obj.data.cvd};
        else
            allCvd=obj.data.cvd.getAll;
        end

        if(obj.isActiveRoot)
            if(obj.rememberToExcludeVariant)
                value=obj.rememberToExcludeVariantValue;
                for i=1:length(allCvd)
                    [allCvd{i}.excludeInactiveVariants]=deal(value);
                end
            else

                value=all(cellfun(@(cvd)all([cvd.excludeInactiveVariants]),allCvd));
            end

        else
            excludeInactiveTestVals=cellfun(@(cvd)([~isempty(cvd)]&&any([cvd.excludeInactiveVariants])),allCvd);
            value=all(excludeInactiveTestVals);
            obj.rememberToExcludeVariantValue=value;
        end
    catch MEx
        rethrow(MEx);
    end
end