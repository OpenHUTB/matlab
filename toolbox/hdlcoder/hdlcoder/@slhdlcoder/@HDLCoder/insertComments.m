function insertComments(this,p)




    this.forAllComponents(p,@insertDescCommentsForComp);

    if this.getParameter('TraceabilityProcessing')
        this.forAllComponents(p,@insertTraceInfoForComp);
    end

    if this.getParameter('emitRequirementComments')
        this.forAllComponents(p,@insertRequirementInfoForComp,true);
    end
end
