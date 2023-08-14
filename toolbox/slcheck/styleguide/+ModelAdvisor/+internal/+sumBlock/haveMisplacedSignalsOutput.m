function ret=haveMisplacedSignalsOutput(sumBlock)


    ret=false;
    if isempty(sumBlock)
        return;
    end

    lnH=get_param(sumBlock.PortHandles.Outport,'object');

    if~isequal(0,lnH.Rotation)
        ret=true;
        return;
    end
end

