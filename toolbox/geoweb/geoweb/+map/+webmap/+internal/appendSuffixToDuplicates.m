function names=appendSuffixToDuplicates(names,suffix)
    names=convertCharsToStrings(names);
    suffix=convertCharsToStrings(suffix);

    if~(isempty(suffix)||isempty(names))&&isstring(names)&&isstring(suffix)
        if length(suffix)~=length(names)
            suffix(1:length(names))=suffix(1);
        end

        names(ismissing(names))="";
        suffix(ismissing(suffix))="";
        names=strip(names);

        index=names=="";
        specifiedNames=names(~index);

        if~isempty(specifiedNames)

            uniqueSpecifiedNames=unique(replace(lower(specifiedNames),' ',''));
            names_lower=replace(lower(names),' ','');

            if length(uniqueSpecifiedNames)~=length(specifiedNames)

                for k=1:length(uniqueSpecifiedNames)
                    uindex=find(ismember(names_lower,uniqueSpecifiedNames{k}));
                    if length(uindex)>1

                        names(uindex)=names(uindex)+suffix(uindex);
                    end
                end
            end
        end
    end
end
