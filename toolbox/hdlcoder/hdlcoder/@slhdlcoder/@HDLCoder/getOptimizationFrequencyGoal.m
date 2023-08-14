function freq=getOptimizationFrequencyGoal(this)
    targetFrequency=this.getParameter('targetfrequency');
    if(targetFrequency==0)
        targetFrequency=200;
    end
    freq=targetFrequency*this.getParameter('extraEffortMargin');
end