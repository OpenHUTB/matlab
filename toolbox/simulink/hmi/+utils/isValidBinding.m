



function bValidBinding=isValidBinding(boundElem)
    bValidBinding=true;


    if isempty(boundElem)||...
        strcmp(boundElem.BindingRule_,'not found')||...
        strcmp(boundElem.BindingRule_,'not bound')||...
        ~locIsValidBlock(boundElem.BlockPath.getBlock(1))
        bValidBinding=false;
    end


    if isprop(boundElem,'OutputPortIndex')&&boundElem.OutputPortIndex<1&&isempty(boundElem.DomainType_)
        bValidBinding=false;
    end


    if isa(boundElem,'Simulink.HMI.ParamSourceInfo')
        try
            boundElem.getDoubleValue;
        catch me
            bValidBinding=false;
        end
    end
end


function bValid=locIsValidBlock(blk)
    bValid=true;
    try
        get_param(blk,'handle');
    catch me %#ok<NASGU>
        bValid=false;
    end
end
