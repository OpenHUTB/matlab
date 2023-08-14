function validateInterfaceParameter(obj,RDAPIExampleStr)





    AXI4StreamExampleStr=...
    [sprintf('\nhRD.addAXI4StreamInterface( ...\n'),...
    sprintf('    ''InterfaceID'',              ''AXI4-Stream'', ...\n'),...
    sprintf('    ''MasterChannelEnable'',      true, ...\n'),...
    sprintf('    ''SlaveChannelEnable'',       true, ...\n'),...
    sprintf('    ''MasterChannelConnection'', ''axi_dma_0/S_AXIS_S2MM'', ...\n'),...
    sprintf('    ''SlaveChannelConnection'',  ''axi_dma_0/M_AXIS_MM2S'', ...\n'),...
    sprintf('    ''MasterChannelMaxDataWidth'',   1024, ...\n'),...
    sprintf('    ''SlaveChannelMaxDataWidth'',    1024, ...\n')];


    hdlturnkey.plugin.validateBooleanProperty(...
    obj.MasterChannelEnable,'MasterChannelEnable',RDAPIExampleStr);
    hdlturnkey.plugin.validateBooleanProperty(...
    obj.SlaveChannelEnable,'SlaveChannelEnable',RDAPIExampleStr);

    hdlturnkey.plugin.validateNonNegIntegerProperty(...
    obj.MasterChannelNumber,'MasterChannelNumber',RDAPIExampleStr);
    hdlturnkey.plugin.validateNonNegIntegerProperty(...
    obj.SlaveChannelNumber,'SlaveChannelNumber',RDAPIExampleStr);


    if obj.isMaxDataWidthDefined
        hdlturnkey.plugin.validateNonNegIntegerProperty(...
        obj.MasterChannelMaxDataWidth,'MasterChannelMaxDataWidth',AXI4StreamExampleStr);
        hdlturnkey.plugin.validateNonNegIntegerProperty(...
        obj.SlaveChannelMaxDataWidth,'SlaveChannelMaxDataWidth',AXI4StreamExampleStr);
    end


    if obj.IsGenericIP
        if obj.isNonDefaultChannelConnection
            error(message('hdlcommon:interface:AXIStreamGenericIP'));
        end


        return;
    end


    if obj.MasterChannelNumber>1||obj.SlaveChannelNumber>1
        error(message('hdlcommon:interface:LimitChannelNumber'));
    end


    if obj.MasterChannelNumber>0

        hdlturnkey.plugin.validateStringProperty(...
        obj.MasterChannelConnection,'MasterChannelConnection',RDAPIExampleStr);
        hdlturnkey.plugin.validateRequiredParameter(...
        obj.MasterChannelConnection,'MasterChannelConnection',RDAPIExampleStr);
        hdlturnkey.plugin.validateNonNegIntegerProperty(...
        obj.MasterChannelDataWidth,'MasterChannelDataWidth',RDAPIExampleStr);
    end


    if obj.SlaveChannelNumber>0

        hdlturnkey.plugin.validateStringProperty(...
        obj.SlaveChannelConnection,'SlaveChannelConnection',RDAPIExampleStr);
        hdlturnkey.plugin.validateRequiredParameter(...
        obj.SlaveChannelConnection,'SlaveChannelConnection',RDAPIExampleStr);
        hdlturnkey.plugin.validateNonNegIntegerProperty(...
        obj.SlaveChannelDataWidth,'SlaveChannelDataWidth',RDAPIExampleStr);
    end

end

