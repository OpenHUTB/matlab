function setBlockPositionFromPanel(blockHandle,left,top,right,bottom)

    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end
    set_param(blockHandle,'Position',[left,top,right,bottom]);
end
