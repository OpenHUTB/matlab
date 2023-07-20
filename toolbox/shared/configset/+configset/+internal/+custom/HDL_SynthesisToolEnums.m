function enum=HDL_SynthesisToolEnums(cs,param)





    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end


    cli=hObj.getCLI;

    tool=cli.SynthesisTool;

    if isempty(tool)
        options={''};
        enum=struct('str',options,'disp',options);
        return;
    end


    switch(param)
    case 'SynthesisToolChipFamily'
        toolOptions=loc_getToolOptions(tool);
        if~isempty(toolOptions)
            options=toolOptions.keys;
        else
            options={''};
        end
    case 'SynthesisToolDeviceName'
        family=cli.SynthesisToolChipFamily;
        familyOptions=loc_getFamilyOptions(tool,family);
        if~isempty(familyOptions)
            options=familyOptions.keys;
        else
            options={''};
        end
    case 'SynthesisToolPackageName'
        family=cli.SynthesisToolChipFamily;
        device=cli.SynthesisToolDeviceName;
        deviceOptions=loc_getDeviceOptions(tool,family,device);
        if~isempty(deviceOptions)
            options=deviceOptions.pkNames;
        else
            options={''};
        end
    case 'SynthesisToolSpeedValue'
        family=cli.SynthesisToolChipFamily;
        device=cli.SynthesisToolDeviceName;
        deviceOptions=loc_getDeviceOptions(tool,family,device);
        if~isempty(deviceOptions)
            options=deviceOptions.spNames;
        else
            options={''};
        end
    end
    if isempty(options)
        options={''};
    end
    enum=struct('str',options,'disp',options);
end


function options=loc_getToolOptions(tool)
    switch(upper(tool))
    case 'XILINX VIVADO'
        options=downstream.scanDeviceLists('Vivado');
    case 'XILINX ISE'
        options=downstream.scanDeviceLists('ISE');
    case 'ALTERA QUARTUS II'
        options=downstream.scanDeviceLists('AlteraQuartus');
    case 'MICROCHIP LIBERO SOC'
        options=downstream.scanDeviceLists('MicrochipLiberoSoC');
    case 'INTEL QUARTUS PRO'
        options=downstream.scanDeviceLists('IntelQuartusPro');
    otherwise
        options=[];
    end
end


function options=loc_getFamilyOptions(tool,family)
    familyoptions=loc_getToolOptions(tool);
    if isempty(familyoptions)
        options=[];
        return;
    end
    try
        options=familyoptions(family);
    catch me



        if~strcmp(me.identifier,'MATLAB:Containers:Map:NoKey')
            me.rethrow;
        end
        options=containers.Map;

    end
end


function options=loc_getDeviceOptions(tool,family,device)
    deviceoptions=loc_getFamilyOptions(tool,family);
    if~isempty(deviceoptions)&&deviceoptions.isKey(device)
        options=deviceoptions(device);
    else
        options=[];
    end
end



