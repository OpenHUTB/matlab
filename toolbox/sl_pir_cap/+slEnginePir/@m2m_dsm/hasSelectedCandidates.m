function result=hasSelectedCandidates(this)

    result=false;
    for mIdx=1:length(this.fFinalCandidateIndex)
        if~isempty(this.fFinalCandidateIndex{mIdx})
            result=true;
            return;
        end
    end
end