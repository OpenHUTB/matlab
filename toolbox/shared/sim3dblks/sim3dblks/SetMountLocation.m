function SetMountLocation(Block,child)
    transform=BlockTransform(Block);

    if isempty(transform)
        return;
    end

    set_param(Block,'mountPoint',mat2str(transform.translation));
    set_param(Block,'mountOrientation',mat2str(transform.rotation));


    set_param(sprintf("%s/%s",Block,child),"translation",mat2str(transform.translation));
    set_param(sprintf("%s/%s",Block,child),"rotation",mat2str(transform.rotation));
end