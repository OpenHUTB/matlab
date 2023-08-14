function[numSatisfied,numJustified,numTotal]=getHitCount(data,model,metric)










    numSatisfied=0;
    numJustified=0;
    numTotal=0;

    if isenum(metric)

        [cov,desc]=getCoverageInfo(data,model,metric);
        if~isempty(cov)
            numJustified=sum([desc.justifiedCoverage]);
            numSatisfied=cov(1)-numJustified;
            numTotal=cov(2);
        end
    else

        [hitCount,~,~,~,~,justified]=cvi.ReportData.getHitCount(...
        data,model,metric,false,false,[]);
        if~isempty(hitCount)
            numJustified=justified;
            numSatisfied=hitCount(1);
            numTotal=hitCount(2);
        end
    end

