function generateQsysTclConduitPort(fid,portName,portWidth,conduitPortType)




    proplist={...
    {'associatedClock','ip_clk'},...
    {'associatedReset','ip_rst'},...
    {'ENABLED','true'},...
    {'EXPORT_OF','""'},...
    {'PORT_NAME_MAP','""'},...
    {'CMSIS_SVD_VARIABLES','""'},...
    {'SVD_ADDRESS_GROUP','""'},...
    };

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


    hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,portName,hdlturnkey.IOType.IN,'conduit',proplist,portlist);
end

