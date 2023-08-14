function sl_postprocess(h)





    srm_block=sprintf('ee_lib/Electromechanical/Reluctance & Stepper/Switched Reluctance Machine');
    srm_LoadFcn=get_param(srm_block,'LoadFcn');
    new_srm_LoadFcn=sprintf([srm_LoadFcn,'\nif get_param(bdroot,''VersionLoaded'') <= 9.2 && strcmp(get_param(gcbh,''stator_param''),''2'')',...
    '\n   ee.internal.line_mover(gcbh, {2,3,4,5},{4,2,5,3});','\nend']);
    set_param(srm_block,'LoadFcn',new_srm_LoadFcn);


    pmsm_block=sprintf('ee_lib/Electromechanical/Permanent Magnet/PMSM (Six-Phase)');
    pmsm_LoadFcn=get_param(pmsm_block,'LoadFcn');
    new_pmsm_LoadFcn=sprintf([pmsm_LoadFcn,'\nif get_param(bdroot,''VersionLoaded'') <= 10.2',...
    '\n   ee.internal.line_mover(gcbh, {2,3},{3,2});','\nend']);
    set_param(pmsm_block,'LoadFcn',new_pmsm_LoadFcn);


    im1ph_block=sprintf('ee_lib/Electromechanical/Asynchronous/Induction Machine (Single-Phase)');
    im1ph_LoadFcn=get_param(im1ph_block,'LoadFcn');
    new_im1ph_LoadFcn=sprintf([im1ph_LoadFcn,'\nif get_param(bdroot,''VersionLoaded'') <= 10.3 && strcmp(get_param(gcbh,''type_option''),''ee.enum.asm.singlePhaseConfig.twowindings'')',...
    '\n   ee.internal.line_mover(gcbh, {2,3},{3,2});','\nend']);
    set_param(im1ph_block,'LoadFcn',new_im1ph_LoadFcn);


    sm_block=sprintf('ee_lib/Electromechanical/Synchronous/Synchronous Machine (Six-Phase)');
    sm_LoadFcn=get_param(sm_block,'LoadFcn');
    new_sm_LoadFcn=sprintf([sm_LoadFcn,'\nif get_param(bdroot,''VersionLoaded'') <= 10.2',...
    '\n   ee.internal.line_mover(gcbh, {6,7},{7,6});','\nend']);
    set_param(sm_block,'LoadFcn',new_sm_LoadFcn);


    pcm_block=sprintf('ee_lib/Semiconductors & Converters/P-Channel MOSFET');
    pcm_LoadFcn=get_param(pcm_block,'LoadFcn');
    new_pcm_LoadFcn=sprintf([pcm_LoadFcn,'\nif get_param(bdroot,''VersionLoaded'') <= 10 && strcmp(get_param(gcbh,''ComponentPath''),''ee.semiconductors.sp_pmos'')',...
    '\n   ee.internal.line_mover(gcbh, {2,3},{3,2});\nend',...
    '\nif get_param(bdroot,''VersionLoaded'') <= 10 && strcmp(get_param(gcbh,''ComponentPath''),''ee.semiconductors.sp_pmos_thermal'')',...
    '\n   ee.internal.line_mover(gcbh, {3,4},{4,3});\nend']);
    set_param(pcm_block,'LoadFcn',new_pcm_LoadFcn);


    dltp_block=sprintf('ee_lib/Passive/Dynamic Load (Three-Phase)');
    dltp_LoadFcn=get_param(dltp_block,'LoadFcn');
    new_dltp_LoadFcn=sprintf([dltp_LoadFcn,'\nif get_param(bdroot,''VersionLoaded'') <= 10.1 && strcmp(get_param(gcbh,''ComponentPath''),''ee.passive.dynamic_load_3ph.abc'')',...
    '\n   ee.internal.line_mover(gcbh, {1,2,3},{2,3,1});','\nend',...
    '\nif get_param(bdroot,''VersionLoaded'') <= 10.1 && strcmp(get_param(gcbh,''ComponentPath''),''ee.passive.dynamic_load_3ph.Xabc'')',...
    '\n   ee.internal.line_mover(gcbh, {1,2,3,4,5},{4,5,1,2,3});\nend']);
    set_param(dltp_block,'LoadFcn',new_dltp_LoadFcn);


    sn_block=sprintf('ee_lib/Additional Components/SPICE Semiconductors/SPICE NMOS');
    sn_LoadFcn=get_param(sn_block,'LoadFcn');
    new_sn_LoadFcn=sprintf([sn_LoadFcn,'\nif get_param(bdroot,''VersionLoaded'') <= 10.1',...
    '\n   ee.internal.param_set(gcbh,''ee.additional.spice_semiconductors.spice_nmos'',''C_param'', ''Cov_param'');',...
    '\nend']);
    set_param(sn_block,'LoadFcn',new_sn_LoadFcn);


    sp_block=sprintf('ee_lib/Additional Components/SPICE Semiconductors/SPICE PMOS');
    sp_LoadFcn=get_param(sp_block,'LoadFcn');
    new_sp_LoadFcn=sprintf([sp_LoadFcn,'\nif get_param(bdroot,''VersionLoaded'') <= 10.1',...
    '\n   ee.internal.param_set(gcbh,''ee.additional.spice_semiconductors.spice_pmos'',''C_param'', ''Cov_param'');',...
    '\nend']);
    set_param(sp_block,'LoadFcn',new_sp_LoadFcn);


    md_block=sprintf('ee_lib/Electromechanical/Motor & Drive (System Level)');
    set_param(md_block,'BlockKeywords',["Motor and Drive","Motor and Drive (System Level)"]);


    thisLibraryPath=fullfile(matlabroot,'toolbox','physmod','elec','library','m','ee_lib.slx');
    addLibraryLinks(h,thisLibraryPath);


    reorganizeLibrary(h);


    updateAnnotationPosition(h);


    addLibraryIcons(h);





    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Asynchronous/Induction Machine (Single-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Asynchronous/Induction Machine Squirrel Cage'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Asynchronous/Induction Machine Wound Rotor'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Brushed Motors/Compound Motor'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Brushed Motors/DC Motor'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Mechatronic Actuators/FEM-Parameterized Linear Actuator'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Mechatronic Actuators/FEM-Parameterized Rotary Actuator'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Mechatronic Actuators/Generic Linear Actuator'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Mechatronic Actuators/Generic Rotary Actuator'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Mechatronic Actuators/Piezo Linear Actuator'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Mechatronic Actuators/Piezo Rotary Actuator'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Mechatronic Actuators/Piezo Stack'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Motor & Drive (System Level)'),''})

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/BLDC'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/FEM-Parameterized PMSM'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/Hybrid Excitation PMSM'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/PMLSM'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/PMSM (Five-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/PMSM (Single-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/PMSM (Six-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/PMSM'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Permanent Magnet/Simplified PMSM Drive'),...
    sprintf('ee_lib/Electromechanical/Motor & Drive (System Level)')});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Reluctance & Stepper/Switched Reluctance Machine'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Reluctance & Stepper/Synchronous Reluctance Machine'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Synchronous/Simplified Synchronous Machine'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Synchronous/Synchronous Machine (Six-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Synchronous/Synchronous Machine Model 1.0'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Synchronous/Synchronous Machine Model 2.1'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Synchronous/Synchronous Machine Round Rotor'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Synchronous/Synchronous Machine Round Rotor'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Synchronous/Synchronous Machine Salient Pole'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Electromechanical/Synchronous/Synchronous Machine Salient Pole'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Capacitor'),'0.0','10000000.1'});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Constant Current\nLoad (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Constant Current\nLoad'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Constant Power Load'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Constant Power Load\n(Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Dynamic Load'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Dynamic Load\n(Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Incandescent Lamp'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Lines/Transmission\nLine\n(Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/RLC Assemblies/Dynamic Load (Three-Phase)'),sprintf('ee_lib/Passive/Dynamic Load (Three-Phase)')});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/RLC Assemblies/Wye-Connected Load'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Reluctance with Hysteresis'),...
    sprintf('ee_lib/Passive/Nonlinear Reluctance')});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Thermal/Cauer Thermal Model\nElement'),sprintf('ee_lib/Passive/Thermal/Cauer Thermal Model')});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Thermal/Cauer Thermal Model'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Transformers/Mutual Inductor'),''})

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/RLC Assemblies/RLC (Three-Phase)'),''})

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/RLC Assemblies/Delta-Connected Load'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Transformers/Three-Winding Transformer (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Transformers/Two-Winding Transformer (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Transformers/Zigzag-Delta-Wye Transformer'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Transformers/Zigzag-Delta1-Wye Transformer'),...
    sprintf('ee_lib/Passive/Transformers/Zigzag-Delta-Wye Transformer')});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Transformers/Zigzag-Delta11-Wye Transformer'),...
    sprintf('ee_lib/Passive/Transformers/Zigzag-Delta-Wye Transformer')});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Passive/Winding'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Average-Value Inverter (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Average-Value Rectifier (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Average-Value Voltage Source Converter (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Boost Converter'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Buck Converter'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Buck-Boost Converter'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Converter (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/DC-DC Converter'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Four-Pulse Gate Multiplexer'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Modular Multilevel Converter (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/One-Quadrant Chopper'),''});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Rectifier (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Six-Pulse Gate Multiplexer'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Three-Level Converter (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Twelve-Pulse Gate Multiplexer'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Converters/Two-Pulse Gate Multiplexer'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Diode'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/GTO'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Ideal Semiconductor Switch'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/IGBT\n(Ideal, Switching)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/MOSFET\n(Ideal, Switching)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/N-Channel IGBT'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/N-Channel JFET'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/N-Channel LDMOS FET'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/N-Channel MOSFET'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/NPN Bipolar Transistor'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Optocoupler'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/P-Channel JFET'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/P-Channel LDMOS FET'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/P-Channel MOSFET'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/PNP Bipolar Transistor'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Thyristor'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Semiconductors & Converters/Thyristor\n(Piecewise Linear)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Sensors & Transducers/Light-Emitting Diode'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Sensors & Transducers/Photodiode'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Sensors &\nTransducers/Power Sensor\n(Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Sources/Battery'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Sources/Battery (Table-Based)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Sources/Programmable Voltage Source (Three-Phase)'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)'),...
    ''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Switches & Breakers/Circuit Breaker (with arc)'),...
    ''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Switches & Breakers/Circuit Breaker'),...
    ''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Switches & Breakers/Relay'),...
    sprintf('ee_lib/Switches & Breakers/Relays/SPDT Relay')});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Switches & Breakers/SPMT Switch'),''});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Utilities/Enabled Fault'),...
    sprintf('ee_lib/Utilities/Fault (Three-Phase)')});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('ee_lib/Utilities/Time-Based Fault'),...
    sprintf('ee_lib/Utilities/Fault (Three-Phase)')});


    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('pe_lib/Machines/Synchronous Machine Field Circuit (pu)'),''});



    copyFcnStr=sprintf('set_param(gcb,''auto_seed'',num2str(randi(2^32-1)))');
    set_param(sprintf('ee_lib/Passive/Resistor'),'copyFcn',copyFcnStr);
    set_param(sprintf('ee_lib/Sources/Current Source'),'copyFcn',copyFcnStr);
    set_param(sprintf('ee_lib/Sources/Voltage Source'),'copyFcn',copyFcnStr);
    set_param(sprintf('ee_lib/Passive/Diffusion Resistor'),'copyFcn',copyFcnStr);
    copyFcnStr=sprintf('set_param(gcb,''auto_seed_v'',num2str(randi(2^32-1))); set_param(gcb,''auto_seed_ip'',num2str(randi(2^32-1))); set_param(gcb,''auto_seed_in'',num2str(randi(2^32-1)));');
    set_param(sprintf('ee_lib/Integrated Circuits/Finite-Gain Op-Amp'),'copyFcn',copyFcnStr);
    set_param(sprintf('ee_lib/Connectors & References/Busbar'),...
    'stopFcn','ee.internal.loadflow.setBusbarTag',...
    'startFcn','ee.internal.loadflow.clearBusbarTag',...
    'AttributesFormatString','%<Tag>');


    foundation.internal.parameterization.updateLibraryPartsSupport(h,...
    fullfile(matlabroot,'toolbox/physmod/elec/library/m'));




    subLibraries=find_system(h,'SearchDepth',1);
    subLibraries=subLibraries(2:end);
    nSubLibraries=length(subLibraries);
    positionData=cell(nSubLibraries,1);
    for i=1:nSubLibraries
        positionData{i}=get_param(subLibraries(i),'Position');

        if contains(get_param(subLibraries(i),'Name'),sprintf('Additional\nComponents'))
            idx=i;
        end
        if contains(get_param(subLibraries(i),'Name'),sprintf('Specialized Power\nSystems'))
            jdx=i;
        end
    end


    oldOrder=1:nSubLibraries;
    oldOrderMinusIdx=setdiff(oldOrder,[idx,jdx]);
    newOrder=[oldOrderMinusIdx,idx,jdx];


    for i=1:nSubLibraries
        set_param(subLibraries(newOrder(i)),'Position',positionData{i});
    end



    if exist(thisLibraryPath,'file')
        delete(thisLibraryPath);
    end
    save_system(h,thisLibraryPath);

end

function addLibraryLinks(thisLibrary,thisLibraryPath)



    fromBlockToSublibrary={'fl_lib/Electrical/Electrical Elements/Open Circuit','Connectors & References';...
    'fl_lib/Electrical/Electrical Elements/Electrical Reference','Connectors & References';...
    'fl_lib/Electrical/Electrical Sensors/Current Sensor','Sensors & Transducers';...
    'fl_lib/Electrical/Electrical Sensors/Voltage Sensor','Sensors & Transducers';...
    'ee_lib/Additional Components/SPICE Sources/Piecewise Linear Current Source','Sources';...
    'ee_lib/Additional Components/SPICE Sources/Piecewise Linear Voltage Source','Sources';...
    'ee_lib/Additional Components/SPICE Sources/Pulse Current Source','Sources';...
    'ee_lib/Additional Components/SPICE Sources/Pulse Voltage Source','Sources';...
    'mosfetslib/SPICE-Imported MOSFET','Semiconductors & Converters';...
    'batteryecm_lib/Battery','Sources';...
    ['batteryecm_lib/Battery',newline,'(Table-Based)'],'Sources';...
    };
    thisLibraryName=get_param(thisLibrary,'Name');


    allLibraries=strtok(fromBlockToSublibrary(:,1),'/');
    allLibraries=unique(allLibraries);
    otherLibraries=setdiff(allLibraries,thisLibraryName);
    load_system(otherLibraries);



    if exist(thisLibraryPath,'file')
        delete(thisLibraryPath);
    end
    save_system(thisLibrary,thisLibraryPath);

    for blockIdx=1:size(fromBlockToSublibrary,1)

        source=fromBlockToSublibrary{blockIdx,1};
        [~,shortBlockName,~]=fileparts(source);

        dest=[thisLibraryName,'/',fromBlockToSublibrary{blockIdx,2},'/',shortBlockName];
        h=add_block(source,dest);
        set_param(h,'ShowName','on','HideAutomaticName','on');
    end


    nesl_libautolayout(thisLibrary);


    bdclose(otherLibraries);
end

function reorganizeLibrary(thisLibrary)



    horizontalSpacingFactor=1;
    verticalSpacingFactor=1.3;


    if ishandle(thisLibrary)
        thisPath=get_param(thisLibrary,'Path');
        thisName=get_param(thisLibrary,'Name');
        if~isempty(thisPath)
            thisLibrary=[thisPath,'/',thisName];
        else
            thisLibrary=thisName;
        end
    end


    blocks=find_system(thisLibrary,'SearchDepth',1,'Type','Block');

    blocks=blocks(~strcmp(thisLibrary,blocks));
    nBlocks=length(blocks);


    if isempty(blocks)
        return
    end


    if ischar(blocks)



        blocks={blocks};
    end

    blockTypes=get_param(blocks,'BlockType');

    for idx=1:nBlocks
        block=blocks{idx};
        blockType=blockTypes{idx};
        if strcmp('SubSystem',blockType)
            reorganizeLibrary(block);
        end
    end


    if strcmp(thisLibrary,bdroot(thisLibrary))
        verticalSpacingFactor=1.15;

        sliSubSystem=sprintf('%s/Control',thisLibrary);
        set_param(sliSubSystem,'OpenFcn','ee_sl_lib');
        mask=Simulink.Mask.get(sliSubSystem);
        mask.addParameter('Type','checkbox','Name','ShowInLibBrowser','Value','on','Evaluate','off','Tunable','off','ReadOnly','on','Hidden','on','NeverSave','off');






        addedSubSystem=sprintf('%s/Specialized Power Systems',thisLibrary);
        set_param(addedSubSystem,'OpenFcn','sps_lib');
        mask=Simulink.Mask.get(addedSubSystem);
        mask.addParameter('Type','checkbox','Name','ShowInLibBrowser','Value','on','Evaluate','off','Tunable','off','ReadOnly','on','Hidden','on','NeverSave','off');



        newBlockOrder=[find(~strcmp(addedSubSystem,blocks));
        find(strcmp(addedSubSystem,blocks))];
    else

        newBlockOrder=[find(strcmp('SubSystem',blockTypes));
        find(strcmp('SimscapeBlock',blockTypes))];
    end


    newPositions=zeros(nBlocks,4);
    for idx=1:nBlocks



        oldBlock=blocks{idx};
        newBlock=blocks{newBlockOrder(idx)};

        oldPosition=get_param(oldBlock,'Position');
        newPosition=get_param(newBlock,'Position');

        oldCenterX=mean(oldPosition([1,3]));
        oldCenterY=mean(oldPosition([2,4]));

        newCenterX=horizontalSpacingFactor*oldCenterX;
        newCenterY=verticalSpacingFactor*oldCenterY;

        if strcmp(get_param(newBlock,'Tag'),'simscape_sublibrary')
            blockWidth=60;
            blockHeight=60;
        else
            blockWidth=newPosition(3)-newPosition(1);
            blockHeight=newPosition(4)-newPosition(2);
        end

        newLeft=floor(newCenterX-blockWidth/2);
        newTop=floor(newCenterY-blockHeight/2);
        newRight=floor(newCenterX+blockWidth/2);
        newBottom=floor(newCenterY+blockHeight/2);

        newPositions(idx,:)=[newLeft,newTop,newRight,newBottom];
    end

    for idx=1:nBlocks
        newBlock=blocks{newBlockOrder(idx)};
        newPosition=newPositions(idx,:);
        set_param(newBlock,'Position',newPosition);
    end
end

function updateAnnotationPosition(thisLibrary)
    dy_top=60;
    dy_bot=20;




    libAnnotation=find_system(bdroot(thisLibrary),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','Type','Annotation');
    oldPos=get_param(libAnnotation,'Position');
    newPos=[oldPos(1),oldPos(2)+dy_top,oldPos(3),oldPos(4)+dy_bot];
    set_param(libAnnotation,'Position',newPos);


    oldLoc=get_param(bdroot(thisLibrary),'Location');
    set_param(bdroot(thisLibrary),'Location',[oldLoc(1:3),oldLoc(4)+dy_top]);
end

function addLibraryIcons(h)


    lib=get_param(h,'Name');


    subLibraries=find_system(lib,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Tag','simscape_sublibrary');
    subLibSvgNames=lower(regexprep(strrep(subLibraries,lib,''),'[(\s&-/)]',''));

    DVG.Registry.addIconPackage(fullfile(matlabroot,'toolbox','physmod','elec','library','m','libIcons'));

    for idx=1:numel(subLibraries)
        subLib=subLibraries{idx};

        subLibSvgName=subLibSvgNames{idx};

        set_param(subLib,'ShowName','on');
        maskObj=Simulink.Mask.get(subLib);
        maskObj.Display='';
        maskObj.IconFrame='on';

        iconName=['eeLibraryIcons.',subLibSvgName];
        maskObj.BlockDVGIcon=iconName;

    end

end
