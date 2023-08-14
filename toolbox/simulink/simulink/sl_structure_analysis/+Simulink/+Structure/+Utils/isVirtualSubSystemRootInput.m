


function y=isVirtualSubSystemRootInput(block)

    y=false;

    BlockObj=get_param(block,'Object');

    isIn=strcmp(BlockObj.BlockType,'Inport');

    if isIn
        Howner=BlockObj.Parent;
        ownerObj=get_param(Howner,'Object');

        if strcmp(ownerObj.Type,'block')
            if strcmp(ownerObj.BlockType,'SubSystem')
                if(strcmp(ownerObj.IsSubsystemVirtual,'on'))
                    y=true;
                end
            end
        end
    end

end