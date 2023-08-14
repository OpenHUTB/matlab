function runData=getRunData(this,runID,bFlatten)









    if nargin<3
        bFlatten=false;
    end
    runData=this.exportRun(runID,bFlatten);
end
