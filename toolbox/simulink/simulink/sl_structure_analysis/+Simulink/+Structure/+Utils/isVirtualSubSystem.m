


function y=isVirtualSubSystem(hBlk)

    oBlk=get_param(hBlk,'Object');
    y=false;

    if strcmp(oBlk.BlockType,'SubSystem')
        y=(strcmp(oBlk.IsSubsystemVirtual,'on'));
    end
end
