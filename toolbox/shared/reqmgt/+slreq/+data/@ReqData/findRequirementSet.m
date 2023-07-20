function mfReqSet=findRequirementSet(this,rsFileName)





    mfReqSet=[];

    if isempty(this.repository)
        return;
    end

    mfReqSet=this.repository.findReqSetByShortName(rsFileName);
end