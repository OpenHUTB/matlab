function[isPredExcluded,isPredJustified,predFilterRationale]=checkMcdcPredicateFiltering(...
    mcdcId,condId,predIdx,...
    isBlockExcluded,isBlockJustified,blockFilterRationale)









    isPredExcluded=0;
    isPredJustified=0;
    predFilterRationale='';

    if cv('get',condId,'.isDisabled')


        isPredExcluded=1;
        isPredJustified=0;
        predFilterRationale=cvi.ReportUtils.getFilterRationale(condId);
    else
        filteredOutcomes=cv('get',mcdcId,'.filteredOutcomes');
        fidx=find(filteredOutcomes==predIdx);
        if~isempty(fidx)

            filteredOutcomeModes=cv('get',mcdcId,'.filteredOutcomeModes');
            isPredJustified=(filteredOutcomeModes(fidx)==1);
            isPredExcluded=~isPredJustified;
            rationaleList=cvi.ReportUtils.getFilterRationale(mcdcId,true);
            predFilterRationale=rationaleList{fidx};
        end

        [isPredExcluded,isPredJustified,predFilterRationale]=...
        SlCov.CoverageAPI.filterInheritanceLogic(isPredExcluded,isPredJustified,...
        isBlockExcluded,isBlockJustified,...
        predFilterRationale,blockFilterRationale);
    end
