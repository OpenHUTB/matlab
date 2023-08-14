


function onCodeViewerClick(~,varargin)
    eventData=varargin{2};
    modelName=eventData.model;
    fileName=eventData.file;
    lineNo=eventData.line;
    blockSID=eventData.sids{1};


    slci.view.internal.hiliteCodeSingleLine(fileName,...
    lineNo,...
    modelName,...
    blockSID);

    mdlHandle=get_param(modelName,'Handle');
    obj.setClickEventData(mdlHandle,eventData);
end