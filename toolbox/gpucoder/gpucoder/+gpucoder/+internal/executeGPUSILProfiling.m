function executeGPUSILProfiling(funcName,numIterations,inputs)



    for idx=1:numIterations
        feval(funcName,inputs{:});
    end
    clear(funcName);

end
