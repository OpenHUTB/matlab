


function[isFiltered,isJustified]=isFilteredOutcome(filteredOutcomes,filteredOutcomeModes,idx)
    isFiltered=false;
    isJustified=false;

    if~isempty(filteredOutcomes)
        fidx=find(filteredOutcomes==idx);
        if~isempty(fidx)
            mode=filteredOutcomeModes(fidx);
            isFiltered=double(mode==0);
            isJustified=double(mode==1);
        end
    end

