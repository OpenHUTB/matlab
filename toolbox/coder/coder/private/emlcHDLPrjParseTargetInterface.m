function emlcHDLPrjParseTargetInterface(javaConfig,hdlCfg)



    try
        hdlCfg.ReferenceDesignPath=char(javaConfig.getParamAsString('param.hdl.ReferenceDesignPath'));
        tableData=javaConfig.getParamReader('param.hdl.TargetInterface');
    catch
        return;
    end
    port=tableData.getChild('Port');
    while port.isPresent()
        portName=char(port.readText('Name'));
        portInterface=char(port.readText('SelectedInterface'));
        portBitRange=char(port.readText('BitRange'));
        hdlCfg.setTargetInterface(portName,portInterface,portBitRange);
        port=port.next();
    end
end