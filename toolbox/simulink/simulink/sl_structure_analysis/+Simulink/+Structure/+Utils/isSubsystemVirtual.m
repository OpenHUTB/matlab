

function y=isSubsystemVirtual(so)
    y=false;
    if strcmp(so.BlockType,'SubSystem')
        y=(strcmp(so.IsSubsystemVirtual,'on'));
    end
end