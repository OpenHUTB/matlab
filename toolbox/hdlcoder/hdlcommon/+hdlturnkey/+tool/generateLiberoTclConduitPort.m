function generateLiberoTclConduitPort(fid,portName,portWidth,conduitPortType,topDutName)




    if conduitPortType==hdlturnkey.IOType.IN
        dirStr='Input';
    elseif conduitPortType==hdlturnkey.IOType.OUT
        dirStr='Output';
    else
        dirStr='bidir';
    end

    lenStr=num2str(portWidth);

    portlist={
    {portName,'pin',dirStr,lenStr},...
    };


    hdlturnkey.tool.generateLiberoTclInterfaceDefinition(fid,portName,hdlturnkey.IOType.IN,'conduit',portlist,topDutName);
end
