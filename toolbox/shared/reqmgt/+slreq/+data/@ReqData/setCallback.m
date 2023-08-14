function updated=setCallback(this,dataObj,callbackName,callbackText)














    updated=false;
    mfObj=this.getModelObj(dataObj);
    if isempty(mfObj.(callbackName))
        mfObj.(callbackName)=slreq.datamodel.Callback(this.model);
    end

    if~strcmp(mfObj.(callbackName).text,callbackText)
        mfObj.(callbackName).text=callbackText;
        updated=true;
    end
end

