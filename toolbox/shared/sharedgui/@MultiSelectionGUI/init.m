function init(hObj,lhsObjs,rhsObjs,callbackFcnHandle,docInfo,ItemInfo,config)



    hObj.availableObjs=lhsObjs;
    hObj.selectedObjs=rhsObjs;
    hObj.okCallBackFcn=callbackFcnHandle;
    hObj.helpDocLocation=docInfo.docMapLocation;
    hObj.configsetTag=docInfo.configsetTag;
    hObj.itemNamesAndDescription=ItemInfo;
    hObj.currentConfig=config;
    hObj.numOfObjs=length(lhsObjs)+length(rhsObjs);
    hObj.highlightObjDescription='';
    hObj.rhsChosenItem=-1;
end
