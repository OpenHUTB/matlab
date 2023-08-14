function[changeIdx,isZero]=findPeaksPropertyChanges(p,forceDatasetIdx)













    if nargin>1&&~isempty(forceDatasetIdx)






        changeIdx=1:numel(p.pPeaks);
        isZero=p.pPeaks==0;
    else


        p0=p.pPeaksLast;
        p1=p.pPeaks;
        N0=numel(p0);
        N1=numel(p1);

        if N1>N0
            p0(N1)=0;
        end
        N0=numel(p0);
        if N0>N1
            p1(N0)=0;
        end

        p.pPeaks=p1;
        p.pPeaksLast=p1;


        sel=p0~=p1;
        changeIdx=find(sel);
        isZero=p1(sel)==0;
    end
