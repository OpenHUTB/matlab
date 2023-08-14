function[equal,mismatches,drr]=compare(this,other,varargin)







    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    equal=0;
    mismatches=0;
    drr=fw.compareRuns();
    if~isscalar(this)
        Simulink.SimulationData.utError('InvalidDatasetArray');
    end

    if isa(other,class(this))
        validateattributes(other,{class(this)},{'scalar'},'compare','other',2);
        runID2=other.RunID;
    else
        runName=other.Name;
        if isempty(runName)
            runName='untitled';
        end
        runID2=Simulink.sdi.createRun(runName,'vars',other);
        if length(runID2)~=1
            mismatches=this.numElements;
            return
        end
    end

    if this.RunID==runID2
        equal=this.numElements;
    else
        drr=fw.compareRuns(this.RunID,runID2);
        for idx=1:drr.Count
            dsr=getResultByIndex(drr,idx);
            if dsr.Match
                equal=equal+1;
            else
                mismatches=mismatches+1;
            end
        end
    end
end
