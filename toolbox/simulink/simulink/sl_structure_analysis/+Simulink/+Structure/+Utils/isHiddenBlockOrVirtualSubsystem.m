


function y=isHiddenBlockOrVirtualSubsystem(hBlock)
    y=false;

    ob=get_param(hBlock,'Object');

    if strcmp(ob.BlockType,'SubSystem')
        if(strcmp(ob.IsSubsystemVirtual,'on'))
            y=ob.isSynthesized;
        end
    elseif strcmp(ob.Type,'block')
        y=ob.isSynthesized;
    end
end
