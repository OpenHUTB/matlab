

function init(obj,blockObj)


    if isnumeric(blockObj)
        blockObj=get_param(blockObj,'Object');
    end
    obj.widgetId=utils.getInstanceId(blockObj);
    obj.blockObj=blockObj;
    obj.isLibWidget=utils.getIsLibWidget(blockObj);
    obj.srcBlockObj='';
    obj.OutputPortIndex=1;
end