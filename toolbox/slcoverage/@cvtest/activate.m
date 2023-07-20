function activate(test,modelcovId)

    testId=test.id;
    cv('set',modelcovId,'.activeTest',testId);


    if cv('get',testId,'.linkNode.parent')==modelcovId,
        cv('PendingTestRemove',modelcovId,testId);
    end

