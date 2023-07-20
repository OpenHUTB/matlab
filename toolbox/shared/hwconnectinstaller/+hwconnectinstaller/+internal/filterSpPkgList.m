function filteredList=filterSpPkgList(spPkgList,filterCriteria)























































    if isempty(filterCriteria)
        filteredList=spPkgList;
        return
    end


    assert(isa(spPkgList,'hwconnectinstaller.SupportPackage'));
    assert(isstruct(filterCriteria));

    filterProps=fields(filterCriteria);

    spPkgProps=properties('hwconnectinstaller.SupportPackage');
    assert(numel(filterProps)==numel(intersect(spPkgProps,filterProps)));

    matches=false(numel(spPkgList),numel(filterProps));

    for i=1:numel(filterProps)
        prop=filterProps{i};
        desiredValue=filterCriteria.(prop);
        for k=1:numel(spPkgList)
            if iscell(desiredValue)
                if iscell(spPkgList(k).(prop))
                    matches(k,i)=~isempty(intersect(lower(spPkgList(k).(prop)),lower(desiredValue)));
                else
                    matches(k,i)=any(strcmpi(spPkgList(k).(prop),desiredValue));
                end
            else
                if iscell(spPkgList(k).(prop))
                    matches(k,i)=any(strcmpi(desiredValue,spPkgList(k).(prop)));
                else
                    if ischar(desiredValue)
                        matches(k,i)=strcmpi(desiredValue,spPkgList(k).(prop));
                    elseif islogical(desiredValue)||isnumeric(desiredValue)
                        matches(k,i)=spPkgList(k).(prop)==desiredValue;
                    else
                        assert('Unsupported comparison type');
                    end
                end
            end
        end
    end





    filteredList=spPkgList(all(matches,2));
