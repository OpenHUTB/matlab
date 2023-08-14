function mfReqSet=getDefaultReqSet(this)






    if isempty(this.mfDefaultReqSet)||~isvalid(this.mfDefaultReqSet)
        this.mfDefaultReqSet=this.addRequirementSet('default.slreqx');
    end

    mfReqSet=this.mfDefaultReqSet;
end
