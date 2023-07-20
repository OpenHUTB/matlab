function[success,error]=postApplyCallBack(hObj)
    [success,error]=hObj.okCallBackFcn(hObj.selectedObjs,hObj.currentConfig);
end