function result=iscomponentblock(hBlock)





    if isa(hBlock,'Simscape.SimscapeComponentBlock')
        result=true;
    elseif isa(hBlock,'Simulink.Block')
        result=false;
    else
        blkType=get_param(hBlock,'BlockType');
        result=strcmp(blkType,'SimscapeComponentBlock');
    end

end
