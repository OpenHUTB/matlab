function result=hasIdentifiedCandidates(this)

    result=false;
    for mIdx=1:length(this.fCandidateIndex)
        if~isempty(this.fCandidateIndex{mIdx})
            result=true;
            return;
        end
    end
end