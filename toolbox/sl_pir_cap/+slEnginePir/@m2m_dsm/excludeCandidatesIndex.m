function this=excludeCandidatesIndex(this,wishList)





    for i=1:length(wishList)
        for j=1:length(this.fFinalCandidateIndex)
            idx=find(this.fFinalCandidateIndex{j}==wishList(i));
            if~isempty(idx)
                this.fFinalCandidateIndex{j}(idx)=[];
            end
        end
    end
end
