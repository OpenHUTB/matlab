
function updateConfiguration(blockHandle,update)
    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end
    updateObj=jsondecode(update);
    if isfield(updateObj,'property')
        propertyName=updateObj.property;
    else
        propertyName=updateObj.propertyName;
    end
    if isequal(propertyName,'customBackgroundColor')
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'CustomBackgroundColor',jsonencode(updateObj.value),'undoable');
    elseif isequal(propertyName,'orientation')
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'orientation',jsonencode(updateObj.value),'undoable');
    elseif isequal(propertyName,'tickColor')
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'ForegroundColor',jsonencode(updateObj.value/255),'undoable');
    elseif isequal(propertyName,'ValuePreview')



        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,propertyName,updateObj.value,'');
    else
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'updateConfig',update,'undoable');
    end
end
