classdef(Hidden)uvm_scripts<uvmcodegen.uvm_component




    properties(Access=private,Constant)
        mq_script_name='run_tb_mq.do'
        xcelium_script_name='run_tb_xcelium.sh'
        vcs_script_name='run_tb_vcs.sh'
    end

    properties(Access=private)
        timescale_flag;
    end

    methods
        function this=uvm_scripts(varargin)
            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'ucfg','');
            addParameter(p,'mwcfg','');
            parse(p,varargin{:});
            this.ucfg=p.Results.ucfg;
            this.mwcfg=p.Results.mwcfg;


            this.timescale_flag=containers.Map;
            if~isempty(this.ucfg.timescale)
                this.timescale_flag('mq')=[' -timescale "',this.ucfg.timescale,'"'];
                this.timescale_flag('cad')=[' -timescale "',this.ucfg.timescale,'"'];
                this.timescale_flag('vcs')=[' -timescale=',this.ucfg.timescale];
            else
                this.timescale_flag('mq')='';
                this.timescale_flag('cad')='';
                this.timescale_flag('vcs')='';
            end
        end

        function str=prt_mq_script(this)
            dpigenerator_disp(['Generating UVM test bench simulation script for Mentor Graphics QuestaSim/Modelsim ',dpigenerator_getfilelink(this.get_mq_script_name_fileLoc())]);


            DPI_pkg_list=this.getDPIPkgList();
            DPI_ShrLib_list=this.getDPIShrLibList();
            shl_cell=cellfun(@(x)(sprintf('-sv_lib %s',x)),DPI_ShrLib_list,'UniformOutput',false);
            if~hdlverifierfeature('VERBOSE_VERIFY')
                verboseV='';
            else
                verboseV='+VERBOSE_VERIFY';
            end
            top_name=[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.top_suffix];
            test_name=[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.tst_suffix];
            WaveForms=this.get_mq_waveforms(this.top_handle.uvmcmp_name);

            header=addFLBanner(this.get_mq_script_name_fileLoc(),'#','',bdroot(this.mwcfg.sldut_path));


            scr_tunprm_comment=this.get_tun_prm_pargs_comments(false);


            tcl_env_args_cell={
'# Arbitrary compilation arguments can be placed in $(EXTRA_UVM_COMP_ARGS) environment variable'
'if { [info exists ::env(EXTRA_UVM_COMP_ARGS)] } {'
'    set EXTRA_UVM_COMP_ARGS $env(EXTRA_UVM_COMP_ARGS)'
'} else {'
'    set EXTRA_UVM_COMP_ARGS ""'
'}'
'# Arbitrary simulation arguments can be placed in $(EXTRA_UVM_SIM_ARGS) environment variable'
'if { [info exists ::env(EXTRA_UVM_SIM_ARGS)] } {'
'    set EXTRA_UVM_SIM_ARGS $env(EXTRA_UVM_SIM_ARGS)'
'} else {'
'    set EXTRA_UVM_SIM_ARGS ""'
'}'
'# Override top-level module if desired. One must add the new top module to'
'# EXTRA_UVM_COMP_ARGS to make sure it is compiled.'
'if { [info exists ::env(UVM_TOP_MODULE)] && [string length $::env(UVM_TOP_MODULE)] != 0 } {'
'    set UVM_TOP_MODULE $env(UVM_TOP_MODULE)'
'    set _UVM_TOP_MODULE_SOURCE_FILE ""'
'} else {'
            ['    set UVM_TOP_MODULE ',top_name]
            ['    set _UVM_TOP_MODULE_SOURCE_FILE ',top_name,'.sv']
'}'
''
            };

            vlib_cell={['vlib ',this.ucfg.mq_lib_name]};

            comp_cell=[{['eval vlog',this.timescale_flag('mq')]};...
            DPI_pkg_list(:);...
            {[bdroot(this.mwcfg.sldut_path),'_pkg.sv']};...
            {'$EXTRA_UVM_COMP_ARGS'};...
            {'$_UVM_TOP_MODULE_SOURCE_FILE'};...
            {'+define+MG_SIM'}...
            ];
            comp_cont_cell=strcat(comp_cell,' \\');

            sim_cell=[{'eval vsim'};...
            {'$EXTRA_UVM_SIM_ARGS'};...
            {['-L ',this.ucfg.mq_lib_name]};...
            {'-voptargs=+acc'};...
            shl_cell(:);...
            {[verboseV,' +UVM_TESTNAME=',test_name]};...
            {'$UVM_TOP_MODULE'};...
            {'+define+MG_SIM'}...
            ];
            sim_cont_cell=strcat(sim_cell,' \\');

            full_file_cell=[{header};...
            {scr_tunprm_comment};...
            {this.get_verify_plusargs_comments()};...
            tcl_env_args_cell(:);...
            vlib_cell(:);{''};...
            comp_cont_cell(:);{''};...
            sim_cont_cell(:);{''};...
            {WaveForms};{''};...
            {'run -all'};{''}...
            ];

            str=sprintf('%s\n',full_file_cell{:});

        end

        function str=prt_xrun_script(this)
            str=prt_cadence_script(this,'xrun');
        end

        function str=prt_cadence_script(this,cadence_tool)

            fileloc=this.get_xcelium_script_name_fileLoc();
            dpigenerator_disp(['Generating UVM test bench simulation script for Cadence Xcelium ',dpigenerator_getfilelink(fileloc)]);

            DPI_pkg_list=this.getDPIPkgList();
            DPI_ShrLib_list=this.getDPIShrLibList();
            shl_cell=cellfun(@(x)(sprintf('-sv_lib %s',x)),DPI_ShrLib_list,'UniformOutput',false);
            if~hdlverifierfeature('VERBOSE_VERIFY')
                verboseV='';
            else
                verboseV='+VERBOSE_VERIFY';
            end
            top_name=[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.top_suffix];
            test_name=[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.tst_suffix];



            header=addFLBanner(fileloc,'#','',bdroot(this.mwcfg.sldut_path));


            scr_tunprm_comment=this.get_tun_prm_pargs_comments(true);

            env_args_cell={
'if [ ! -z ${UVM_TOP_MODULE:-} ];'
'then'
'  echo "Found UVM_TOP_MODULE override. Expecting override top-level source file in EXTRA_UVM_COMP_ARGS."'
'  _UVM_TOP_MODULE_SOURCE_FILE=""'
'else'
'  echo "No UVM_TOP_MODULE override.  Using default top-level source and interface files."'
            ['  UVM_TOP_MODULE=',top_name]
            ['  _UVM_TOP_MODULE_SOURCE_FILE=',top_name,'.sv']
'fi'
''
            };

            sim_cell=[{[cadence_tool,this.timescale_flag('cad')]};...
            {'$EXTRA_UVM_SIM_ARGS'};...
            {'-coverage u -covoverwrite'};...
            {'-64bit -uvm -sv -access +rwc'};...
            {[verboseV,' +UVM_TESTNAME=',test_name]};...
            shl_cell(:);...
            DPI_pkg_list(:);...
            {[bdroot(this.mwcfg.sldut_path),'_pkg.sv']};...
            {'$EXTRA_UVM_COMP_ARGS'};...
            {'$_UVM_TOP_MODULE_SOURCE_FILE'}...
            ];
            sim_cont_cell=strcat(sim_cell,' \\');

            full_file_cell=[{'#!/bin/sh'};...
            {header};...
            {scr_tunprm_comment};...
            {this.get_verify_plusargs_comments()};...
            env_args_cell(:);{''};...
            sim_cont_cell(:);{''}...
            ];

            str=sprintf('%s\n',full_file_cell{:});
        end

        function str=prt_vcs_script(this)
            dpigenerator_disp(['Generating UVM test bench simulation script for Synopsys VCS ',dpigenerator_getfilelink(this.get_vcs_script_name_fileLoc())]);

            DPI_pkg_list=this.getDPIPkgList();
            DPI_ShrLib_list=this.getDPIShrLibList();
            shl_cell=cellfun(@(x)(sprintf('-sv_lib %s',x)),DPI_ShrLib_list,'UniformOutput',false);
            if~hdlverifierfeature('VERBOSE_VERIFY')
                verboseV='';
            else
                verboseV='+VERBOSE_VERIFY';
            end
            top_name=[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.top_suffix];
            test_name=[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.tst_suffix];
            header=addFLBanner(this.get_vcs_script_name_fileLoc(),'#','',bdroot(this.mwcfg.sldut_path));


            scr_tunprm_comment=this.get_tun_prm_pargs_comments(true);

            env_args_cell={
'if [ ! -z ${UVM_TOP_MODULE:-} ];'
'then'
'  echo "Found UVM_TOP_MODULE override. Expecting override top-level source file in EXTRA_UVM_COMP_ARGS."'
'  _UVM_TOP_MODULE_SOURCE_FILE=""'
'else'
'  echo "No UVM_TOP_MODULE override.  Using default top-level source and interface files."'
            ['  UVM_TOP_MODULE=',top_name]
            ['  _UVM_TOP_MODULE_SOURCE_FILE=',top_name,'.sv']
'fi'
''
            };

            comp_cell=[{'vcs'};...
            {['-full64 -sverilog',this.timescale_flag('vcs'),' -ntb_opts uvm-1.1']};...
            DPI_pkg_list(:);...
            {[bdroot(this.mwcfg.sldut_path),'_pkg.sv']};...
            {'$EXTRA_UVM_COMP_ARGS'};...
            {'$_UVM_TOP_MODULE_SOURCE_FILE'}...
            ];
            comp_cont_cell=strcat(comp_cell,' \\');

            sim_cell=[{'./simv'};...
            {'$EXTRA_UVM_SIM_ARGS'};...
            shl_cell(:);...
            {[verboseV,' +UVM_TESTNAME=',test_name]};...
            {'$UVM_TOP_MODULE'}...
            ];
            sim_cont_cell=strcat(sim_cell,' \\');

            full_file_cell=[{'#!/bin/sh'};...
            {header};...
            {scr_tunprm_comment};...
            {this.get_verify_plusargs_comments()};...
            env_args_cell(:);{''};...
            comp_cont_cell(:);{''};...
            sim_cont_cell(:);{''}...
            ];

            str=sprintf('%s\n',full_file_cell{:});
        end


        function str=get_mq_script_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('top'),obj.mq_script_name));
        end



        function str=get_xcelium_script_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('top'),obj.xcelium_script_name));
        end


        function str=get_vcs_script_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('top'),obj.vcs_script_name));
        end
    end

    methods(Access=private)
        function cstr=getDPIPkgList(obj)
            cstr=cellfun(@(x)n_AbsPath2PkgFile(x.UVMBuildInfo.DPIPkg),obj.mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj,'UniformOutput',false)';


            if obj.containNonFlatStructOrEnumPort()
                [~,commonDpiPkgDir,~]=fileparts(obj.ucfg.component_paths('uvm_artifacts'));
                str=obj.replaceBackS(fullfile('..',commonDpiPkgDir,[obj.common_dpi_pkg,'.sv']));
                cstr=[{str},cstr];
            end
            function str=n_AbsPath2PkgFile(fullpath)
                [~,file,ext]=fileparts(fullpath);
                [~,UVMComponentDir,~]=fileparts(obj.ucfg.DirFromDPIArtifact([file,ext]));
                str=obj.replaceBackS(fullfile('..',UVMComponentDir,[file,ext]));
            end
        end

        function cstr=getDPIShrLibList(obj)
            cstr=cellfun(@(x)n_AbsPath2Shrlib(x.UVMBuildInfo.SharedLib),obj.mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj,'UniformOutput',false)';
            function str=n_AbsPath2Shrlib(fullpath)
                [~,file,~]=fileparts(fullpath);
                if ispc
                    str_dll=[file,'_win64'];
                else
                    str_dll=file;
                end
                [~,UVMComponentDir,~]=fileparts(obj.ucfg.DirFromDPIArtifact(file));
                str=obj.replaceBackS(fullfile('..',UVMComponentDir,str_dll));
            end
        end

        function str=get_mq_waveforms(obj,top_name)%#ok<INUSD>


            str='add wave -position end sim:/${UVM_TOP_MODULE}/dutif/*';
        end



        function str=get_tun_prm_pargs_comments(obj,needQuotes)
            if obj.ucfg.TunPrmPargsMap.isempty

                str='';
                return;
            end

            if needQuotes
                Quote='"';
            else
                Quote='';
            end

            str=sprintf(['\n#The following plusargs are available to set the tunable parameters in the scoreboard:\n',...
            char(join(cellfun(@(x)['# +',x,'=',Quote,obj.ucfg.TunPrmPargsMap(x),Quote,'\n'],keys(obj.ucfg.TunPrmPargsMap),...
            'UniformOutput',false),'')),...
            '\n']);

        end
        function str=get_verify_plusargs_comments(obj)
            comments_cell={
'# Using plusarg to determine coverage count for verify() PASS'
'# result.  If filtered, NO covergroup is created. '
'# Examples:'
'#   NO PLUSARG          : at_least=1 (default value)'
'#   +my_model:33:8      : FILTER -- DO NOT COVER (backward compatible behavior)'
'#   +my_model:33:8=0    : FILTER (alternative form)'
'#   +my_model:33:8=-1   : FILTER (alternative form)'
'#   +my_model:33:8=13   : at_least=13'
''
'# Using plusarg to get an INFO message for every unfiltered verify()'
'# result.'
'#   +VERBOSE_VERIFY'
''
            };
            str=sprintf('%s\n',comments_cell{:});
        end
    end
end



