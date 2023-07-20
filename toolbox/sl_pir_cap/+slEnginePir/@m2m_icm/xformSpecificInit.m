function xformSpecificInit(this)



    this.fXformedBlks={};
    for cIdx=1:length(this.fCandidateInfo)
        if this.fCandidateInfo(cIdx).isExcluded==0
            for oIdx=1:length(this.fCandidateInfo(cIdx).Objects)
                if this.fCandidateInfo(cIdx).Objects(oIdx).isExcluded==0
                    this.fXformedBlks=[this.fXformedBlks;{this.fCandidateInfo(cIdx).Objects(oIdx).FcnCalls.LinkedSS}'];
                end
            end
        end
    end

    this.fXformedBlks=unique(get_param(this.fXformedBlks,'Parent'));
    getXformedModels(this);
end
