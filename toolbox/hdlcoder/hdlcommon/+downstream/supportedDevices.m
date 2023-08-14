







function supportedDevices()
    hDDI=downstream.DownstreamIntegrationDriver('',false,false,'',downstream.queryflowmodesenum.MATLAB,'',true);
    availableTools=hDDI.set('Tool');

    if(strcmpi(availableTools,'No synthesis tool available on system path'))
        fprintf(message('hdlcoder:optimization:NoSynthesisToolForSupportedDevices').getString());
        fprintf('\n');
    else
        for i=1:length(availableTools)
            hDDI.set('Tool',availableTools{i});
            pluginPath=hDDI.getPluginPath();
            if(~isempty(pluginPath))
                fprintf('<a href="matlab:web(fullfile(''%s''));">%s Device List</a>\n',fullfile(pluginPath,'device_list.xml'),hDDI.hToolDriver.hTool.ToolName);
            end
        end
    end
end