function isCtrlPort=isControlPort(h,ctrlPortBlock)%#ok



    blockType=get_param(ctrlPortBlock,'BlockType');

    switch(blockType)
    case{'EnablePort','TriggerPort'}
        isCtrlPort=true;

    otherwise
        isCtrlPort=false;
    end
end

