function eliminated=isModelEliminated(modelcovId)




    currentTestId=cv('get',modelcovId,'.currentTest');
    eliminated=(currentTestId==0);
end
