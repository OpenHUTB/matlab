function configTSData(d,sigInfo)
    if strcmp(sigInfo.dataType,'fcn_call')
        return
    end
    d.DataType=sigInfo.dataType;
    if strcmp(sigInfo.size,'[-1]')
        d.Props.Array.Size='[1]';
    else
        d.Props.Array.Size=sigInfo.size;
    end
    if strcmp(sigInfo.sigType,'real')
        d.Props.Complexity='off';
    elseif strcmp(sigInfo.sigType,'complex')
        d.Props.Complexity='on';
    end
    d.Props.Array.IsDynamic=strcmp(sigInfo.varsize,'Yes');

end
