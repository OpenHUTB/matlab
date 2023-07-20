function ret=getIsReferenceSubsystem(~,block)
    ret=true;
    if isempty(block.ReferencedSubsystem)
        ret=false;
    end
end
