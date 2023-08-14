function edascript=hdlgetedascript(tool,varargin)


    projectdir_Q='q2dir';
    projectdir_I='synprj';
    projectdir_L='libero_prj';
    projectdir_V='vivado_prj';

    if nargin>2

        if strcmpi(tool,'ise')
            targetdir=['"',varargin{2},'"'];
        else
            targetdir=varargin{2};
        end
    else
        targetdir='[pwd]';
    end

    if(iscell(tool))
        tool=tool{1};
    end

    edascript=struct();

    switch(lower(tool))

    case 'ise'

        edascript.SynScriptPostFix='_ise.tcl';

        edascript.SynScriptInit=['set src_dir ',targetdir,'\n',...
        'set prj_dir "',projectdir_I,'"\n',...
        'file mkdir ../$prj_dir\n',...
        'cd ../$prj_dir\n',...
        'project new %s.xise\n',...
        'project set family Virtex4\n',...
        'project set device xc4vsx35\n',...
        'project set package ff668\n',...
        'project set speed -10\n'];

        edascript.SynScriptCmd='xfile add $src_dir/%s\n';

        edascript.SynScriptTerm='process run "Synthesize - XST"';
        edascript.SynLibCmd='lib_vhdl new %s';
        edascript.SynLibSpec='-lib_vhdl %s';
    case 'vivado'

        edascript.SynScriptPostFix='_vivado.tcl';

        edascript.SynScriptInit=['set src_dir ',targetdir,'\n',...
        'set prj_dir "',projectdir_V,'"\n',...
        'file mkdir ../$prj_dir\n',...
        'cd ../$prj_dir\n',...
        'create_project %s.xpr\n',...
        'set_property PART xc7vx485tffg1761-1 [current_project]\n'];


        edascript.SynScriptCmd='add_file $src_dir/%s\n';

        edascript.SynScriptTerm=['launch_runs synth_1 -force\n',...
        'wait_on_run synth_1\n'];
        edascript.SynLibCmd='';
        edascript.SynLibSpec='set_property LIBRARY %s\n';

    case 'libero'

        edascript.SynScriptPostFix='_libero.tcl';

        edascript.SynScriptInit=['set dutname %s\n',...
        'new_project -name $dutname -location ',projectdir_L,' -hdl %s ',...
        '-family ProASIC3 -die A3P1000 -package {484 FBGA}\n',...
        'import_files \\\n'];

        edascript.SynScriptCmd='  -hdl_source %s \\\n';

        edascript.SynScriptTerm='\nset_root -module $dutname\\::work';
        edascript.SynLibCmd='add_library -library %s';
        edascript.SynLibSpec='add_file_to_library -library %s -file %s';

    case 'precision'

        edascript.SynScriptPostFix='_precision.tcl';

        edascript.SynScriptInit=['set proj_folder [pwd]\n',...
        'set proj_name %s_proj\n',...
        'set impl_name my_impl\n',...
        '# Remove old project and implementation\n',...
        'file delete -force $proj_folder/$proj_name.psp\n',...
        'file delete -force $proj_folder/$impl_name\n',...
        'new_project -name $proj_name -folder $proj_folder\n',...
        'new_impl -name $impl_name\n'];

        edascript.SynScriptCmd='add_input_file %s\n';

        edascript.SynScriptTerm=['setup_design -frequency=200\n',...
        'setup_design -input_delay=1\n',...
        'setup_design -output_delay=1\n',...
        'setup_design -manufacturer Xilinx -family VIRTEX-4 -part 4VSX35FF668 -speed 12\n',...
        'compile\n',...
        'synthesize\n',...
        '# Uncomment the line below if $xilinx is set\n',...
        '# place_and_route\n',...
        'save_impl'];
        edascript.SynLibCmd='';
        edascript.SynLibSpec='-work %s';
    case 'quartus'

        edascript.SynScriptPostFix='_quartus.tcl';

        edascript.SynScriptInit=['load_package flow\n',...
        'set top_level %s\n',...
        'set src_dir "',targetdir,'"\n',...
        'set prj_dir "',projectdir_Q,'"\n',...
        'file mkdir ../$prj_dir\n',...
        'cd ../$prj_dir\n',...
        'project_new $top_level -revision $top_level -overwrite\n',...
        'set_global_assignment -name FAMILY "Stratix IV"\n',...
        'set_global_assignment -name DEVICE EP4SGX230KF40C2\n',...
        'set_global_assignment -name TOP_LEVEL_ENTITY $top_level\n',...
        ];

        edascript.SynScriptCmd='set_global_assignment -name %s_FILE "$src_dir/%s"\n';

        edascript.SynScriptTerm=['execute_flow -compile\n',...
        'project_close\n'];
        edascript.SynLibCmd='set_global_assignment -name SEARCH_PATH %s';
        edascript.SynLibSpec='-library %s';
    case 'synplify'

        edascript.SynScriptPostFix='_synplify.tcl';

        edascript.SynScriptInit='project -new %s.prj\n';

        edascript.SynScriptCmd='add_file %s\n';

        edascript.SynScriptTerm=['set_option -technology VIRTEX4\n',...
        'set_option -part XC4VSX35\n',...
        'set_option -synthesis_onoff_pragma 0\n',...
        'set_option -frequency auto\n',...
        'project -run synthesis\n'];
        edascript.SynLibCmd='add_file -library %s';
        edascript.SynLibSpec='-lib %s';
    case 'custom'

        edascript.SynScriptPostFix='_custom.tcl';


        edascript.SynScriptInit='init_script %s.prj\n';


        edascript.SynScriptCmd='command %s\n';


        edascript.SynScriptTerm='termination comments\n';

        edascript.SynLibCmd='add_file -library %s';
        edascript.SynLibSpec='-lib %s';
    otherwise
        edascript=struct('SynScriptPostFix','',...
        'SynScriptInit','',...
        'SynScriptCmd','',...
        'SynScriptTerm','',...
        'SynLibCmd','',...
        'SynLibSpec','');
    end


    if nargin>1

        switch varargin{1}
        case 'SynScriptPostFix'
            edascript=edascript.SynScriptPostFix;
        case 'SynScriptInit'
            edascript=edascript.SynScriptInit;
        case 'SynScriptCmd'
            edascript=edascript.SynScriptCmd;
        case 'SynScriptTerm'
            edascript=edascript.SynScriptTerm;
        case 'SynLibCmd'
            edascript=edascript.SynLibCmd;
        case 'SynLibSpec'
            edascript=edascript.SynLibSpec;
        otherwise
            edascript='';
        end
    end

end


