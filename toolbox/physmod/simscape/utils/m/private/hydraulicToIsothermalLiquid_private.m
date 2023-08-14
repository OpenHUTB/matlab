function allNewFiles=hydraulicToIsothermalLiquid_private(varargin)











































    [hOldFiles,oldFiles,newPath,...
    report_name,report_file_path,custom_block_update_map,custom_library_roots]=processInputs(varargin{:});


    s=suppressWarnings;




    source_function_temp_map=get_source_functions;


    source_function_Interface_map=containers.Map('fluids.interfaces.interface_TL_IL','update_interface_TL_IL');



    oldFilesToConvert=findBlocksToConvert(oldFiles,source_function_temp_map,source_function_Interface_map,custom_block_update_map,custom_library_roots);


    source_function_map=[source_function_temp_map;source_function_Interface_map];


    oldFilesThatOnlyPointToConvertedFile=findFilesThatPointToConvertedFiles(hOldFiles,oldFilesToConvert);


    [newFilesToConvert,orig_library_lock,orig_editing_mode]=...
    createNewFilesToConvert(oldFilesToConvert,newPath);




    [newFilesThatOnlyPointToConvertedFile,orig_library_lock_FilesThatOnlyPoint,orig_editing_mode_FilesThatOnlyPoint]=...
    createNewFilesToConvert(oldFilesThatOnlyPointToConvertedFile,newPath);


    [connections_list,broken_connections_list,parameter_warnings_list,removed_blocks_list,missing_properties_block]...
    =convertBlocks(newFilesToConvert,source_function_map,custom_block_update_map);


    allNewFiles=[newFilesToConvert(:);newFilesThatOnlyPointToConvertedFile(:)];
    updateLinks(allNewFiles,oldFilesToConvert,newFilesToConvert);


    broken_connections_list=addConnections(newFilesToConvert,connections_list,broken_connections_list);


    restoreLocksRestrictions(oldFilesToConvert,newFilesToConvert,orig_library_lock,orig_editing_mode);
    restoreLocksRestrictions(oldFilesThatOnlyPointToConvertedFile,newFilesThatOnlyPointToConvertedFile,orig_library_lock_FilesThatOnlyPoint,orig_editing_mode_FilesThatOnlyPoint);


    if~isempty(newFilesToConvert)
        HtoIL_generate_report(newFilesToConvert,report_name,report_file_path,broken_connections_list,removed_blocks_list,parameter_warnings_list,missing_properties_block);
    end


    warning(s);

end


function source_function_map=get_source_functions

    source_functions={...
...
    'foundation.hydraulic.elements.constant_area_orifice','update_constant_area_orifice'
    'foundation.hydraulic.elements.variable_area_orifice','update_variable_area_orifice'
    'foundation.hydraulic.elements.constant_chamber','update_constant_volume_chamber'
    'foundation.hydraulic.elements.fluid_inertia','update_fluid_inertia'
    'foundation.hydraulic.elements.cap','update_cap'
    'foundation.hydraulic.elements.piston_chamber','update_hydraulic_piston_chamber'
    'foundation.hydraulic.elements.variable_volume_chamber','update_variable_volume_chamber'
    'foundation.hydraulic.elements.reference','update_reference'
    'foundation.hydraulic.elements.resistive_tube','update_resistive_tube'
    'foundation.hydraulic.elements.infinite_hydraulic_resistance','update_infinite_hydraulic_resistance'
    'foundation.hydraulic.elements.linear_resistance','update_linear_hydraulic_resistance'
    'foundation.hydraulic.elements.rotational_converter','update_rotational_hydro_mechanical_converter'
    'foundation.hydraulic.elements.translational_converter','update_translational_hydro_mechanical_converter'
...
    'foundation.hydraulic.sensors.flow_rate','update_flow_rate_sensor'
    'foundation.hydraulic.sensors.pressure','update_pressure_sensor'
...
    'foundation.hydraulic.sources.hydraulic_constant_flow_rate_source','update_constant_flow_rate_source'
    'foundation.hydraulic.sources.hydraulic_constant_pressure_source','update_constant_pressure_source'
    'foundation.hydraulic.sources.hydraulic_constant_mass_flow_source','update_constant_mass_flow_rate_source'
    'foundation.hydraulic.sources.flow_rate','update_flow_rate_source'
    'foundation.hydraulic.sources.hydraulic_mass_flow_source','update_mass_flow_rate_source'
    'foundation.hydraulic.sources.pressure','update_pressure_source'
...
    'foundation.hydraulic.utilities.custom_fluid','update_custom_hydraulic_fluid'
...
...
    'sh.accumulators.accumulator_gas','update_accumulator_gas'
    'sh.accumulators.accumulator_spr','update_accumulator_spr'
...
    'sh.cylinders.rotating_cylinder_force','update_rotating_cylinder_force'
    'sh.cylinders.cylinder_cushion','update_cylinder_cushion'
    'sh.cylinders.cylinder_friction','update_cylinder_friction'
    'sh.cylinders.rotary_actuator_da','update_double_acting_rotary_actuator'
    'sh.cylinders.rotary_actuator_sa','update_single_acting_rotary_actuator'
    'sh.cylinders.cylinder_da','update_double_acting_hydraulic_cylinder'
    'sh.cylinders.cylinder_da_simple','update_double_acting_hydraulic_cylinder_simple'
    'sh.cylinders.cylinder_sa','update_single_acting_hydraulic_cylinder'
    'sh.cylinders.cylinder_sa_simple','update_single_acting_hydraulic_cylinder_simple'
...
    'sh.utilities.hydraulic_fluid','update_hydraulic_fluid'
    'sh.utilities.reservoir','update_reservoir'
...
    'sh.local_resistances.elbow','update_elbow'
    'sh.local_resistances.gradual_area_change','update_area_change'
    'sh.local_resistances.local_resistance','update_local_resistance'
    'sh.local_resistances.pipe_bend','update_pipe_bend'
    'sh.local_resistances.sudden_area_change','update_area_change'
    'sh.local_resistances.t_junction','update_t_junction'
...
    'sh.low_pressure_blocks.tank_const_head','update_tank_const_head'
    'sh.low_pressure_blocks.pipe_low_press','update_hydraulic_pipeline'
    'sh.low_pressure_blocks.pipe_low_press_var_elevation','update_hydraulic_pipeline'
    'sh.low_pressure_blocks.vert_pipe_partially_filled','update_vert_pipe_partially_filled'
    'sh.low_pressure_blocks.pipe_res_low_press','update_pipe_res_low_press'
    'sh.low_pressure_blocks.pipe_res_low_press_var_elevation','update_pipe_res_low_press'
    'sh.low_pressure_blocks.pipe_low_press_segm','update_segmented_pipeline'
    'sh.low_pressure_blocks.tank_var_head','update_tank_var_head'
    'sh.low_pressure_blocks.tank_var_head_two_arm','update_tank_var_head'
    'sh.low_pressure_blocks.tank_var_head_three_arm','update_tank_var_head'
...
    'sh.orifices.orifice_annular','update_orifice_annular'
    'sh.orifices.orifice_fixed','update_orifice_fixed'
    'sh.orifices.orifice_fixed_inertia','update_orifice_fixed_inertia'
    'sh.orifices.orifice_fixed_empirical','update_orifice_fixed_empirical'
    'sh.orifices.journal_bearing_pressure_fed','update_journal_bearing_pressure_fed'
    'sh.orifices.orifice_vrb_rnd_holes','update_orifice_vrb_rnd_holes'
    'sh.orifices.orifice_vrb_slot','update_orifice_vrb_slot'
    'sh.orifices.orifice_variable','update_orifice_variable'
    'sh.orifices.orifice_between_rnd_holes','update_orifice_between_rnd_holes'
...
    'sh.pipelines.pipeline_hyd','update_hydraulic_pipeline'
    'sh.pipelines.pipeline_hyd_segm','update_segmented_pipeline'
    'sh.pipelines.rotating_pipe','update_rotating_pipe'
...
    'sh.pumps_motors.angle_sensor','update_angle_sensor'
    'sh.pumps_motors.swash_plate','update_swash_plate'
    'sh.pumps_motors.porting_plate_variable_orifice','update_porting_plate_variable_orifice'
    'sh.pumps_motors.fx_displ_pump','update_fx_displ_pump'
    'sh.pumps_motors.fixed_displacement_pump_input_efficiency','update_fx_displ_pump'
    'sh.pumps_motors.fixed_displacement_pump_input_loss','update_fx_displ_pump'
    'sh.pumps_motors.hydraulic_motor','update_hydraulic_motor'
    'sh.pumps_motors.fx_displ_motor_ext_efficiencies','update_hydraulic_motor'
    'sh.pumps_motors.fixed_displacement_motor_input_loss','update_hydraulic_motor'
    'sh.pumps_motors.pump_var_displ','update_pump_var_displ'
    'sh.pumps_motors.variable_displacement_pump_input_efficiency','update_pump_var_displ'
    'sh.pumps_motors.variable_displacement_pump_input_loss','update_pump_var_displ'
    'sh.pumps_motors.motor_var_displ','update_motor_var_displ'
    'sh.pumps_motors.variable_displacement_motor_input_efficiency','update_motor_var_displ'
    'sh.pumps_motors.variable_displacement_motor_input_loss','update_motor_var_displ'
    'sh.pumps_motors.pump_var_displ_p_comp','update_pump_var_displ_p_comp'
    'sh.pumps_motors.centrifugal_pump','update_centrifugal_pump'
    'sh.pumps_motors.jet_pump','update_jet_pump'
...
    'sh.valves.directional_valves.valve_dir_2_way','update_valve_dir_2_way'
    'sh.valves.directional_valves.valve_dir_3_way','update_valve_dir_3_way'
    'sh.valves.directional_valves.valve_dir_4_way','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_a','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_b','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_c','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_d','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_e','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_f','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_g','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_h','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_dir_4_way_k','update_valve_dir_4_way'
    'sh.valves.directional_valves.valve_4_way_ideal','update_valve_4_way_ideal'
    'sh.valves.directional_valves.valve_dir_6_way_a','update_valve_dir_6_way_a'
    'sh.valves.directional_valves.cartridge_valve_insert','update_cartridge_valve_insert'
    'sh.valves.directional_valves.cartridge_valve_insert_conical_seat','update_cartridge_valve_insert_conical_seat'
    'sh.valves.directional_valves.check_valve','update_check_valve'
    'sh.valves.directional_valves.remote_control_valve_po','update_remote_control_valve_po'
    'sh.valves.directional_valves.check_valve_po','update_check_valve_po'
    'sh.valves.directional_valves.shuttle_valve','update_shuttle_valve'
...
    'sh.valves.flow_control_valves.ball_valve','update_ball_valve'
    'sh.valves.flow_control_valves.counterbalance_valve','update_counterbalance_valve'
    'sh.valves.flow_control_valves.flow_divider','update_flow_divider'
    'sh.valves.flow_control_valves.flow_divider_combiner','update_flow_divider_combiner'
    'sh.valves.flow_control_valves.gate_valve','update_gate_valve'
    'sh.valves.flow_control_valves.valve_needle','update_valve_needle'
    'sh.valves.flow_control_valves.valve_poppet','update_valve_poppet'
    'sh.valves.flow_control_valves.fl_contr_pc_3_way','update_fl_contr_pc_3_way'
    'sh.valves.flow_control_valves.flow_cntr_vlv_pc','update_flow_cntr_vlv_pc'
...
    'sh.valves.pressure_control_valves.pressure_compensator','update_pressure_control_valves'
    'sh.valves.pressure_control_valves.pressure_reducing_vlv','update_pressure_control_valves'
    'sh.valves.pressure_control_valves.pressure_red_3_way','update_pressure_red_3_way'
    'sh.valves.pressure_control_valves.pressure_relief_vlv','update_pressure_control_valves'
...
    'sh.valves.valve_actuators.elm_2_pos','update_elm_2_pos'
    'sh.valves.valve_actuators.elm_3_pos','update_elm_3_pos'
    'sh.valves.valve_actuators.servo_cylinder_double_acting','update_servo_cylinder_double_acting'
    'sh.valves.valve_actuators.hyd_cartridge_valve_act_four_port','update_hyd_cartridge_valve_act_four_port'
    'sh.valves.valve_actuators.hyd_cartridge_valve_act','update_hyd_cartridge_valve_act'
    'sh.valves.valve_actuators.hyd_valve_act_da','update_hyd_valve_act_da'
    'sh.valves.valve_actuators.hyd_valve_act_sa','update_hyd_valve_act_sa'
    'sh.valves.valve_actuators.act_prop_valve','update_act_prop_valve'
    'sh.valves.valve_actuators.act_valve','update_act_valve'
...
    'sh.valves.valve_forces.spool_orifice_hydr_force','update_spool_orifice_hydr_force'
    'sh.valves.valve_forces.valve_hydr_force','update_valve_hydr_force'
...
    'sh_legacy.hydraulic_machines.hyd_machine_var_displ_ext_efficiencies','update_hyd_machine_var_displ_ext_efficiencies'
    'sh_legacy.hydraulic_machines.hyd_machine_var_displ_var_efficiency','update_hyd_machine_var_displ_var_efficiency'
...
    'fluids.interfaces.actuators.double_actuator_H_G','update_double_actuator_H_G'};

    source_function_map=containers.Map(source_functions(:,1),source_functions(:,2));
end




function[hOldFiles,oldFiles,newPath,...
    report_name,report_file_path,...
    custom_block_update_map,custom_library_roots]=processInputs(varargin)



    nargin=length(varargin{:});


    if nargin==1
        newPath=pwd;
    elseif nargin==2
        newPath=varargin{:}{2};
    else
        newPath=[];
    end
    if nargin>2


        oldBlocks_in=varargin{:}{nargin-1};
        newBlocks_in=varargin{:}{nargin};
        validateattributes(oldBlocks_in,{'char','cell'},{},'hydraulicToIsothermalLiquid','OLDCUSTOMBLOCKS');
        validateattributes(newBlocks_in,{'char','cell'},{},'hydraulicToIsothermalLiquid','NEWCUSTOMBLOCKS');
        oldBlocks=pm_cellstr(oldBlocks_in);
        newBlocks=pm_cellstr(newBlocks_in);
        assert(length(oldBlocks)==length(newBlocks),message('physmod:simscape:compiler:patterns:checks:LengthEqualLength','OLDCUSTOMBLOCKS','NEWCUSTOMBLOCKS'));


        oldBlocks=regexprep(oldBlocks,newline,' ');
        newBlocks=regexprep(newBlocks,newline,' ');


        hOldBlocks=getSimulinkBlockHandle(oldBlocks,true);
        invalid_oldBlocks=hOldBlocks<0;

        if any(invalid_oldBlocks)

            invalid_hOldBlocks_str=sprintf('\n%s',oldBlocks{invalid_oldBlocks});
            error(message('physmod:simscape:utils:hydraulicToIsothermalLiquid:InvalidCustomBlocks','OLDCUSTOMBLOCKS',invalid_hOldBlocks_str));
        end

        hNewBlocks=getSimulinkBlockHandle(newBlocks,true);
        invalid_newBlocks=hNewBlocks<0;
        if any(invalid_newBlocks)

            invalid_hNewBlocks_str=sprintf('\n%s',newBlocks{invalid_newBlocks});
            error(message('physmod:simscape:utils:hydraulicToIsothermalLiquid:InvalidCustomBlocks','NEWCUSTOMBLOCKS',invalid_hNewBlocks_str));
        end


        custom_block_update_map=containers.Map(oldBlocks,newBlocks);


        fileRoots=extractBefore(oldBlocks,'/');
        custom_library_roots=unique(fileRoots);
    else
        custom_block_update_map=[];
        custom_library_roots=[];
    end


    input1=pm_cellstr(varargin{:}{1});
    if length(input1)==1&&isfolder(input1{:})
        topPath=input1{1};

        allFilesStruct=dir(fullfile(topPath,['**',filesep,'*.*']));

        filesKeep=~cellfun(@isempty,regexp({allFilesStruct.name},'\w*(.mdl)$|\w*(.slx)$'))';
        filesStruct=allFilesStruct(filesKeep);

        fileslist_cell=struct2cell(filesStruct);

        oldFiles=cellfun(@fullfile,fileslist_cell(2,:),fileslist_cell(1,:),'UniformOutput',false)';
        report_name='HtoIL_report';
        report_file_path=topPath;
        newPath=[];
    else
        numFiles=length(input1);
        oldFiles=cell(numFiles,1);
        try
            for i=1:numFiles
                oldFiles{i}=Simulink.MDLInfo(input1{i}).FileName;
            end
        catch ME

            msg=message('physmod:simscape:utils:hydraulicToIsothermalLiquid:InvalidInput');
            causeException=MException(msg);
            ME=addCause(ME,causeException);
            throwAsCaller(ME);
        end
        if numFiles==1
            report_name=[Simulink.MDLInfo(input1{1}).BlockDiagramName,'_converted'];
            if nargin==2
                report_file_path=newPath;
                newPath=varargin{:}{2};
            else
                report_file_path=pwd;
                newPath=pwd;
            end
        else
            report_name='HtoIL_report';
            firstFileName=Simulink.MDLInfo(input1{1}).FileName;
            [report_file_path,~,~]=fileparts(firstFileName);
            newPath=[];
        end
    end



    try
        hOldFiles=load_system(oldFiles);
    catch ME

        msg=message('physmod:simscape:utils:hydraulicToIsothermalLiquid:UnableToLoad');
        causeException=MException(msg);
        ME=addCause(ME,causeException);
        throwAsCaller(ME);
    end

end


function s=suppressWarnings
    s=warning;
    warning('off','Simulink:Engine:MdlFileShadowing');
    warning('off','Simulink:Engine:UnableToLoadBd');
    warning('off','Simulink:Commands:ParamUnknown');
    warning('off','SL_SERVICES:utils:TooManyErrorsErr');
    warning('off','diagram_autolayout:autolayout:layoutRejectedCommandLine');
    warning('off','Simulink:Engine:SaveWithDisabledLinks_Warning');
    warning('off','Simulink:Masking:Invalid_MaskType');
end


function oldFilesToConvert=findBlocksToConvert(oldFiles,source_function_temp_map,source_function_Interface_map,...
    custom_block_update_map,custom_library_roots)



    oldFilesToConvert={};



    numFiles=length(oldFiles);
    for m=1:numFiles
        oldFileName=oldFiles{m};
        load_system(oldFileName);
        [~,oldModel,~]=fileparts(oldFileName);

        fl_sh_blocks=find_system(oldModel,...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookInsideSubsystemReference','Off',...
        'LookUnderMasks','all',...
        'Regexp','on',...
        'BlockType','SimscapeBlock');

        SourceFiles=get_param(fl_sh_blocks,'SourceFile');
        TF_fl_sh=isKey(source_function_temp_map,SourceFiles);

        if~isempty(custom_library_roots)
            custom_blocks_regexp=strjoin(custom_library_roots,'|');
            custom_blocks=find_system(oldModel,...
            'MatchFilter',@Simulink.match.allVariants,...
            'LookInsideSubsystemReference','Off',...
            'LookUnderMasks','all',...
            'Regexp','on',...
            'ReferenceBlock',['^',custom_blocks_regexp,'/']);
            ReferenceBlocks=get_param(custom_blocks,'ReferenceBlock');


            ReferenceBlocks=regexprep(ReferenceBlocks,newline,' ');
            TF_custom=isKey(custom_block_update_map,ReferenceBlocks);
        else
            TF_custom=0;
        end

        if any([TF_fl_sh(:);TF_custom(:)])
            oldFilesToConvert(end+1,1)=oldFiles(m);
        elseif sum(isKey(source_function_Interface_map,SourceFiles)>0)



            for i=1:length(fl_sh_blocks)
                if isKey(source_function_Interface_map,SourceFiles{i})
                    interface_domain_spec=eval(get_param(fl_sh_blocks{i},'interface_domain_spec'));
                    if interface_domain_spec==2
                        oldFilesToConvert(end+1,1)=oldFiles(m);
                    end
                end
            end
        end
    end
end


function oldFilesThatOnlyPointToConvertedFile=...
    findFilesThatPointToConvertedFiles(hOldFiles,oldFilesToConvert)




    oldFilesThatOnlyPointToConvertedFile={};

    for m=1:length(oldFilesToConvert)
        hydraulicFile=oldFilesToConvert{m};

        fileType=Simulink.MDLInfo(hydraulicFile).BlockDiagramType;
        hydraulicFileName=Simulink.MDLInfo(hydraulicFile).BlockDiagramName;

        switch fileType
        case 'Library'
            blockType='SubSystem';
            blockParameter='ReferenceBlock';
            blockParameterValue=['^',hydraulicFileName,'/'];
        case 'Subsystem'
            blockType='SubSystem';
            blockParameter='ReferencedSubsystem';
            blockParameterValue=['^',hydraulicFileName];
        case 'Model'
            blockType='ModelReference';
            blockParameter='ModelFile';
            blockParameterValue=['^',hydraulicFileName,'.'];
        end

        linkedOrReferencedBlocks=find_system(hOldFiles,'MatchFilter',@Simulink.match.allVariants,'LookInsideSubsystemReference','Off',...
        'LookUnderMasks','all','Regexp','on','BlockType',blockType,blockParameter,blockParameterValue);

        for i=1:length(linkedOrReferencedBlocks)

            h=bdroot(linkedOrReferencedBlocks(i));
            modelName=get_param(h,'Name');
            fileNames{m,i}=Simulink.MDLInfo(modelName).FileName;




            if~sum(strcmp(fileNames{m,i},oldFilesToConvert))
                oldFilesThatOnlyPointToConvertedFile{end+1}=fileNames{m,i};
            end
        end
    end
end


function[newFilesToConvert,orig_library_lock,orig_editing_mode]=...
    createNewFilesToConvert(oldFilesToConvert,newPathIn)

    numFilesToConvert=length(oldFilesToConvert);
    orig_library_lock=cell(numFilesToConvert,1);
    orig_editing_mode=cell(numFilesToConvert,1);
    newFilesToConvert=cell(numFilesToConvert,1);
    for m=1:numFilesToConvert


        load_system(oldFilesToConvert{m});
        oldModel=Simulink.MDLInfo(oldFilesToConvert{m}).BlockDiagramName;


        if bdIsDirty(oldModel)
            warning(message('physmod:simscape:utils:hydraulicToIsothermalLiquid:DirtyModelWarning',oldFilesToConvert{m}))
        end


        pmsl_validatelibrarylinks(oldModel);


        newModel=[oldModel,'_converted'];

        oldFileName=get_param(oldModel,'FileName');
        [oldPath,~,ext]=fileparts(oldFileName);

        bdclose(newModel)
        h=new_system(newModel,'FromFile',oldFileName);


        if isempty(newPathIn)
            newPath=oldPath;
        else
            newPath=newPathIn;
        end

        newFileName=fullfile(newPath,[newModel,ext]);
        save_system(h,newFileName);
        newFilesToConvert{m}=newModel;


        load_system(newModel);
        if strcmp('on',get_param(oldModel,'Shown'))
            open_system(newModel);
        end

        if bdIsLibrary(newModel)

            orig_library_lock{m}=get_param(newModel,'Lock');
            set_param(newModel,'Lock','off')
        else

            oldModelParameters=get_param(oldModel,'ObjectParameters');
            if isfield(oldModelParameters,'EditingMode')
                orig_editing_mode{m}=get_param(oldModel,'EditingMode');

                try
                    set_param(newModel,'EditingMode','full');
                catch ME
                    msg=message('physmod:simscape:utils:hydraulicToIsothermalLiquid:FullModeConverterTool');
                    causeException=MException(msg);
                    ME=addCause(ME,causeException);
                    throwAsCaller(ME);
                end
            end
        end
    end
    if numFilesToConvert>0
        save_system(newFilesToConvert);
        for i=1:numFilesToConvert
            pmsl_validatelibrarylinks(newFilesToConvert{i});
        end
    end

    try
        load_system('fl_lib');
        load_system('SimscapeFluids_lib')
    catch
    end
end

function[connections_list,broken_connections_list,parameter_warnings_list,removed_blocks_list,missing_properties_block]...
    =convertBlocks(newFilesToConvert,source_function_map,custom_block_update_map)

    numFilesToConvert=length(newFilesToConvert);


    connections_list=cell(numFilesToConvert,1);
    broken_connections_list=cell(numFilesToConvert,1);
    parameter_warnings_list=cell(numFilesToConvert,1);
    removed_blocks_list=cell(numFilesToConvert,1);
    missing_properties_block=cell(numFilesToConvert,1);


    try
        for m=1:numFilesToConvert

            newmodel=newFilesToConvert{m};
            fileType=Simulink.MDLInfo(newmodel).BlockDiagramType;





            connections_list_m=struct('subsystem',{},'source_ports',{},'destination_ports',{});


            parameter_warnings_list_m=struct('subsystem',{},'messages',{});
            removed_blocks_list_m=struct('subsystem',{},'messages',{});
            broken_connections_list_m=struct('subsystem',{},'messages',{});
            detected_properties_block_m=0;




            if~isempty(custom_block_update_map)

                Blocks=find_system(newmodel,...
                'MatchFilter',@Simulink.match.allVariants,...
                'LookInsideSubsystemReference','Off',...
                'LookUnderMasks','all',...
                'Regexp','on');
                Blocks=Blocks(2:end);

                referenceBlocks=get_param(Blocks,'ReferenceBlock');


                referenceBlocks=regexprep(referenceBlocks,newline,' ');

                customBlock_inds=isKey(custom_block_update_map,referenceBlocks);
                customBlocksToConvert=Blocks(customBlock_inds);



                SimscapeBlock_inds=strcmp(get_param(Blocks,'BlockType'),'SimscapeBlock');
                SimscapeBlocks=Blocks(SimscapeBlock_inds&~customBlock_inds);

                for j=1:length(customBlocksToConvert)
                    content=get_param(customBlocksToConvert{j},'handle');

                    referenceBlock=get_param(content,'ReferenceBlock');

                    referenceBlock=regexprep(referenceBlock,newline,' ');

                    if isKey(custom_block_update_map,referenceBlock)

                        out=custom_update(content,custom_block_update_map(referenceBlock));

                        if isfield(out,'broken_connections')&&~isempty(out.broken_connections)
                            broken_connections_list_m(length(broken_connections_list_m)+1)=out.broken_connections;
                        end
                    end
                end
            else

                SimscapeBlocks=find_system(newmodel,...
                'MatchFilter',@Simulink.match.allVariants,...
                'LookInsideSubsystemReference','Off',...
                'LookUnderMasks','all',...
                'Regexp','on',...
                'BlockType','SimscapeBlock');
            end



            for j=1:length(SimscapeBlocks)
                content=get_param(SimscapeBlocks{j},'handle');

                SourceFile=get_param(content,'SourceFile');
                if isKey(source_function_map,SourceFile)

                    out=feval(source_function_map(SourceFile),content);


                    if isfield(out,'warnings')&&~isempty(out.warnings)&&~isempty(out.warnings.messages)
                        parameter_warnings_list_m(length(parameter_warnings_list_m)+1)=out.warnings;
                    end
                    if isfield(out,'removed_block_warning')&&~isempty(out.removed_block_warning)
                        removed_blocks_list_m(length(removed_blocks_list_m)+1)=out.removed_block_warning;
                    end
                    if isfield(out,'connections')&&~isempty(out.connections)
                        connections_list_m(length(connections_list_m)+1)=out.connections;
                    end


                    if strcmp(SourceFile,'foundation.hydraulic.utilities.custom_fluid')||...
                        strcmp(SourceFile,'sh.utilities.hydraulic_fluid')
                        detected_properties_block_m=1;
                    end
                end
            end


            connections_list{m}=connections_list_m;
            broken_connections_list{m}=broken_connections_list_m;
            parameter_warnings_list{m}=parameter_warnings_list_m;
            removed_blocks_list{m}=removed_blocks_list_m;


            missing_properties_block{m}=~detected_properties_block_m&&~strcmp(fileType,'Library');

            try

                set_param(gcbh,'Selected','off')
            catch
            end

            save_system(newFilesToConvert{m});
        end
    catch ME
        blockPath=getfullname(content);
        errMsg=message('physmod:simscape:utils:hydraulicToIsothermalLiquid:ParameterUpdateError',blockPath);
        causeException=MException('physmod:simscape:utils:hydraulicToIsothermalLiquid:ParameterUpdateError',errMsg);
        ME=addCause(ME,causeException);
        throwAsCaller(ME);
    end
end


function updateLinks(allNewFiles,oldFilesToConvert,newFilesToConvert)







    numFilesToConvert=length(oldFilesToConvert);
    for m=1:numFilesToConvert
        hydraulicFile=oldFilesToConvert{m};
        hydraulicFileName=Simulink.MDLInfo(hydraulicFile).BlockDiagramName;
        fileType=Simulink.MDLInfo(hydraulicFile).BlockDiagramType;


        convertedFile=newFilesToConvert{m};

        switch fileType
        case 'Library'
            blockType='SubSystem';
            blockParameter='ReferenceBlock';
            blockParameterValue=['^',hydraulicFileName,'/'];
        case 'Subsystem'
            blockType='SubSystem';
            blockParameter='ReferencedSubsystem';
            blockParameterValue=['^',hydraulicFileName];
        case 'Model'
            blockType='ModelReference';
            blockParameter='ModelFile';
            blockParameterValue=['^',hydraulicFileName,'.'];
        end

        linkedOrReferencedBlocks=find_system(allNewFiles,'MatchFilter',@Simulink.match.allVariants,'LookInsideSubsystemReference','Off',...
        'LookUnderMasks','all','Regexp','on','BlockType',blockType,blockParameter,blockParameterValue);

        for i=1:length(linkedOrReferencedBlocks)
            oldLibraryOrReference=get_param(linkedOrReferencedBlocks{i},blockParameter);
            newLibraryOrReference=strrep(oldLibraryOrReference,hydraulicFileName,convertedFile);
            set_param(linkedOrReferencedBlocks{i},blockParameter,newLibraryOrReference);
        end
    end
    save_system(allNewFiles,[],'SaveDirtyReferencedModels',1)
end


function broken_connections_list=addConnections(newFilesToConvert,connections_list,broken_connections_list)
    numFilesToConvert=length(newFilesToConvert);
    for m=1:numFilesToConvert
        connections_list_m=connections_list{m};
        broken_connections_m=broken_connections_list{m};
        for i=1:length(connections_list_m)
            for j=1:length(connections_list_m(i).source_ports)
                try
                    add_line(connections_list_m(i).subsystem,connections_list_m(i).source_ports(j),connections_list_m(i).destination_ports(j),'autorouting','on');
                catch
                    broken_connections_m(end+1).subsystem=connections_list_m(i).subsystem;%#ok<AGROW>
                    broken_connections_m(end).messages='';%#ok<AGROW>
                end
            end

            Simulink.BlockDiagram.arrangeSystem(connections_list_m(i).subsystem);
        end
        broken_connections_list{m}=broken_connections_m;
    end
end


function restoreLocksRestrictions(oldFiles,newFiles,orig_library_lock,orig_editing_mode)
    for m=1:length(newFiles)
        newModel=newFiles{m};
        [~,oldModel,~]=fileparts(oldFiles{m});
        if bdIsLibrary(newModel)
            if~isempty(orig_library_lock{m})
                set_param(newModel,'Lock',orig_library_lock{m});
                set_param(oldModel,'Lock',orig_library_lock{m});
            end
        else

            set_param(newModel,'EditingMode',orig_editing_mode{m});
        end
        save_system(newModel,[],'SaveDirtyReferencedModels',1);
    end
end