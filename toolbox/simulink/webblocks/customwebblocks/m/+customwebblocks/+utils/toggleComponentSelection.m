
function toggleComponentSelection(blockHandle,componentName,rowId,visibility,flag)



    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end

    if~isnumeric(rowId)
        rowId=str2double(rowId);
    end


    metadata=get_param(blockHandle,'dlgMetadata');


    if~isempty(metadata)
        metadata=jsondecode(metadata);
    else
        metadata=struct;
    end

    metadata=arrayfun(@(s)setfield(s,'selected',false),metadata);

    index=rowId+1;
    metadata(index).name=componentName;
    metadata(index).rowId=rowId;
    metadata(index).selected=flag;
    metadata(index).state=visibility;


    set_param(blockHandle,'dlgMetadata',jsonencode(metadata));
end

