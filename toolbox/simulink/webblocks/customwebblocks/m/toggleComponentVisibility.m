
function toggleComponentVisibility(blockHandle,componentName,rowId,flag)



    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end


    metadata=get_param(blockHandle,'dlgMetadata');


    if~isempty(metadata)
        metadata=jsondecode(metadata);
    else
        metadata=struct;
    end

    index=str2double(rowId)+1;
    metadata(index).name=componentName;
    metadata(index).rowId=rowId;
    metadata(index).state=flag;


    set_param(blockHandle,'dlgMetadata',jsonencode(metadata));
end

