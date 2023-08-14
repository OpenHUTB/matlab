function value=hasInvisibleInput(blk)

















    blkType=get_param(blk,'BlockType');

    if strcmp(blkType,'Inport')
        parent=get_param(blk,'Parent');
        obj=get_param(parent,'Object');
        if strcmp(class(obj),'Simulink.BlockDiagram')
            value=false;
        else
            value=true;
        end
    elseif strcmp(blkType,'From')
        value=true;
    else
        value=false;
    end

end