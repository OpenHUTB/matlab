function isPhysmod=isPhysModBlk(block)







    ports=get_param(block,'Ports');

    isPhysmod=any(logical(ports(6:7)));
end


