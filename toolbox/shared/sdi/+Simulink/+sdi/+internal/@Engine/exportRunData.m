function[varName,runData]=exportRunData(this,runID)






    runData=this.getRunData(runID);




    runName=this.getRunName(runID);

    varName=['SDILog_',runName];

    charsToRemove=isstrprop(varName,'alphanum');
    underScores=strfind(varName,'_');
    charsToRemove(underScores)=1;
    varName(~charsToRemove)=[];


    assignin('base',varName,runData);
