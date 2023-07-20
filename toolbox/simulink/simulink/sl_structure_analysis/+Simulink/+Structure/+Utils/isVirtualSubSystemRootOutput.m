



function y=isVirtualSubSystemRootOutput(block)

    y=false;

    BlockObj=get_param(block,'Object');

    isOut=strcmp(BlockObj.BlockType,'Outport');

    if isOut
        hOwner=BlockObj.Parent;
        ownerObj=get_param(hOwner,'Object');

        if strcmp(ownerObj.Type,'block')
            if strcmp(ownerObj.BlockType,'SubSystem')
                if(strcmp(ownerObj.IsSubsystemVirtual,'on'))
                    y=true;
                end
            end
        end
    end

end