function setActiveDesignSuite(sessionDataModel,designSession,dataModelUUID)
    txn=sessionDataModel.beginTransaction();
    designSession.ActiveDesignSuiteUUID=dataModelUUID;
    designSession.ActiveDesignSuiteSet=true;
    txn.commit();
end