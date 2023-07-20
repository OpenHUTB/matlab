function updateDeps=HDL_SynthesisToolCallback(cs,msg)










    updateDeps=false;

    param=msg.name;
    value=msg.value;


    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end


    cli=hObj.getCLI;

    switch(param)
    case 'SynthesisTool'
        tool=value;
        [family,familyOptions]=loc_getFamily(tool,'');
        if isempty(family)
            device='';
            deviceOptions.pkNames={};
            deviceOptions.spNames={};
        else
            [device,deviceOptions]=loc_getDevice(familyOptions,'');
        end
        cli.SynthesisTool=tool;
        cli.SynthesisToolChipFamily=family;
        cli.SynthesisToolDeviceName=device;
    case 'SynthesisToolChipFamily'
        tool=cli.SynthesisTool;
        family=value;
        [~,familyOptions]=loc_getFamily(tool,family);
        [device,deviceOptions]=loc_getDevice(familyOptions,'');
        cli.SynthesisToolChipFamily=family;
        cli.SynthesisToolDeviceName=device;
    case 'SynthesisToolDeviceName'
        tool=cli.SynthesisTool;
        family=cli.SynthesisToolChipFamily;
        device=value;
        [~,familyOptions]=loc_getFamily(tool,family);
        [~,deviceOptions]=loc_getDevice(familyOptions,device);
        cli.SynthesisToolDeviceName=device;
    end

    if isempty(deviceOptions.pkNames)
        cli.SynthesisToolPackageName='';
    else
        cli.SynthesisToolPackageName=deviceOptions.pkNames{1};
    end
    if isempty(deviceOptions.spNames)
        cli.SynthesisToolSpeedValue='';
    else
        cli.SynthesisToolSpeedValue=deviceOptions.spNames{1};
    end

end



function[family,options]=loc_getFamily(tool,family)
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
        family='';
        options={};
        return;
    end
    families=options.keys;
    if isempty(family)
        family=families{1};
        options=options(family);
    else
        try
            options=options(family);
        catch

            options=options(families{1});
        end
    end
end




function[device,options]=loc_getDevice(familyoptions,device)
    devices=familyoptions.keys;
    if isempty(device)
        device=devices{1};
        options=familyoptions(device);
    else
        try
            options=familyoptions(device);
        catch

            options=familyoptions(devices{1});
        end
    end
end



