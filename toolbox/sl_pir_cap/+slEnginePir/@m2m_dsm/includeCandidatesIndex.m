function this=includeCandidatesIndex(this,wishList)



    for i=1:length(wishList)
        for j=1:length(this.fCandidateIndex)
            if~isempty(find(this.fCandidateIndex{j}==wishList(i)))
                this.fFinalCandidateIndex{j}(end+1)=wishList(i);
                this.fFinalCandidateIndex{j}=unique(this.fFinalCandidateIndex{j});
            end
        end
    end
end
