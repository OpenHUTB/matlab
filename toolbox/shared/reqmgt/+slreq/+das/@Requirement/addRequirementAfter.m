function reqDasObj=addRequirementAfter(this)







    this.eventListener.Enabled=false;
    newReq=this.dataModelObj.addRequirementAfter();
    this.eventListener.Enabled=true;

    reqDasObj=slreq.das.Requirement();

    reqDasObj.postConstructorProcess(newReq,this,this.view,this.eventListener);
    index=this.parent.findObjectIndex(this);
    if this.isJustification



        this.parent.insertChildObjectAt(reqDasObj,index);
    else
        this.parent.insertChildObjectAt(reqDasObj,index+1);
    end



    mgr=slreq.app.MainManager.getInstance;
    mgr.updateRollupStatusLocally(newReq);

    this.notifyViewChange(true);
end
