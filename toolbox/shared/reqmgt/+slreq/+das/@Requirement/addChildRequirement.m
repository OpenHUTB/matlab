function reqDasObj=addChildRequirement(this)






    this.eventListener.Enabled=false;
    newReq=this.dataModelObj.addChildRequirement();
    this.eventListener.Enabled=true;

    reqDasObj=slreq.das.Requirement();
    reqDasObj.postConstructorProcess(newReq,this,this.view,this.eventListener);

    this.addChildObject(reqDasObj);



    mgr=slreq.app.MainManager.getInstance;
    mgr.updateRollupStatusLocally(newReq);

    this.notifyViewChange(true);
end
