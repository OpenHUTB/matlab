function comments=getCommentsForAbstractSimulinkObjectResult(this,result)





    comments={};


    comments=[comments;getCommentsForAbstractResult(this,result)];

    stringID=[this.stringIDPrefix,'AbstractSimulinkObjectResultClassAndWorkspace'];
    [classOfOwner,sourceOfOwner]=result.getObjectClassAndSource;
    comments=[comments;{getString(message(stringID,classOfOwner,sourceOfOwner))}];

    stringID=[this.stringIDPrefix,'AbstractSimulinkObjectResultUsedIn'];
    usedIn=result.getUniqueIdentifier().DataObjectWrapper.ContextName;
    comments=[comments;{getString(message(stringID,usedIn))}];
end
