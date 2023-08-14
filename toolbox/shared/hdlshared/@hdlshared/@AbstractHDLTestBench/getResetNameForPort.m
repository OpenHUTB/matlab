function ResetName=getResetNameForPort(portObj,instance,portDirection)









    if strcmpi(portDirection,'in')
        ports=portObj.InportSrc;
    else
        ports=portObj.OutportSnk;
    end

    ResetName=ports(instance).ResetName;
    if isempty(ResetName)
        for i=1:length(ports)
            if~strcmpi(ports(i).ResetName,'')
                ResetName=ports(i).ResetName;
                break;
            end
        end
    end

    if isempty(ResetName)
        ResetName='reset';
    end

end