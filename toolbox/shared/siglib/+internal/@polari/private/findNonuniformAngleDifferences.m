function[mostCommonGap,angGapIdx]=findNonuniformAngleDifferences(ang)
















    adiff=internal.polariCommon.angleAbsDiff([ang;ang(1)]);
    q=round(adiff*1e10)/1e10;











    [uq,~,iu]=unique(q);
    bins=1:max(iu);
    hc=hist(iu,bins);
    [~,mostCommonDiffIdx]=max(hc);



    adiff_gaps=bins;
    mostCommonGap=uq(mostCommonDiffIdx);
    adiff_gaps(mostCommonDiffIdx)=[];


    angGapIdx=find(ismember(iu,adiff_gaps));
