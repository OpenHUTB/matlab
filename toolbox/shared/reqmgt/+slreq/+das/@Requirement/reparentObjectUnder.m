function reparentObjectUnder(this,newParent)






    reqData=slreq.data.ReqData.getInstance();
    reqSet=this.dataModelObj.getReqSet;
    reqData.cutReqToClipboard(this.dataModelObj);
    reqData.pasteFromClipboard(newParent.dataModelObj);
    movedObj=newParent.children(end);

    reqSet.updateHIdx();
    movedObj.view.getCurrentView.setSelectedObject(movedObj);
end
