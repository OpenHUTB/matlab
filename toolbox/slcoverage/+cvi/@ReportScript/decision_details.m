function decision_details(this,blkEntry,cvstruct,options,decIdx)






    if options.elimFullCovDetails&&...
        ~isempty(blkEntry.decision)&&all(blkEntry.decision.flags.fullCoverage)
        return;
    end
    if(~isempty(blkEntry.decision)&&isfield(blkEntry.decision,'decisionIdx')&&...
        ~isempty(blkEntry.decision.decisionIdx))

        decData=cvstruct.decisions(blkEntry.decision.decisionIdx);
        if nargin<5
            decIdx=1:numel(blkEntry.decision.decisionIdx);
        end
    else
        return;
    end

    decData([decData.isFiltered]==1)=[];

    totalCol=length(cvstruct.tests)+1;
    metricDesc=getString(message('Slvnv:simcoverage:cvhtml:DecisionsAnalyzed'));

    decision_details_script(this,decData,decIdx,totalCol,options,metricDesc);


