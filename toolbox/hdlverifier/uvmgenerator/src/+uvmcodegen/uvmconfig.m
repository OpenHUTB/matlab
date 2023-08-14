classdef uvmconfig<handle&matlab.mixin.CustomDisplay












    properties
        timescale(1,:)char{checkTimescaleFmt_1}='1ns/1ns';
        buildDirectory=['.',filesep,'uvm_build'];
    end

    properties(Hidden,SetAccess=private)
component_paths
        uvm_testbenchdir(1,:)char=''

DirFromDPIArtifact
    end

    properties(Constant,Hidden)
        prefix='mw_'
        suffix=''
        obj_suffix='_trans'
        clkname='clk'
        clkenable='clk_enable'
        rstname='rst'
        rst_activehigh=false
        scr_name='myscr'
        seq_suffix='_sequence'
        sqr_suffix='_sequencer'
        drv_suffix='_driver'
        top_suffix='_top'
        agt_suffix='_agent'
        env_suffix='_environment'
        mon_suffix='_monitor'
        mon_input_suffix='_monitor_input'
        scr_suffix='_scoreboard'
        scr_cfg_obj_suffix='_cfg_obj'
        inf_suffix='_if'
        tst_suffix='_test'
        gld_suffix='_predictor'
        mwuvm_keymap='uvmcodegen_semaphore.mat'
        mwuvm_tmplt_path='lib'
        mwuvm_cmp_tmplt='mw_component.sv'
        mwuvm_obj_tmplt='mw_object.sv'
        mwuvm_bfm_tmplt='mw_bfm.sv'
        mwuvm_seq_tmplt='mw_sequence.sv'
        mwuvm_sqr_tmplt='mw_sequencer.sv'
        mwuvm_agt_tmplt='mw_agent.sv'
        mwuvm_agt_bypass_tmplt='mw_agent_bypass.sv'
        mwuvm_drv_tmplt='mw_driver.sv'
        mwuvm_top_tmplt='mw_top.sv'
        mwuvm_mon_tmplt='mw_monitor.sv'
        mwuvm_mon_input_tmplt='mw_monitor_input.sv'
        mwuvm_scr_tmplt='mw_scoreboard.sv'
        mwuvm_scr_cfg_obj_tmplt='mw_scoreboard_cfg_obj.sv'
        mwuvm_tst_tmplt='mw_test.sv'
        mwuvm_env_tmplt='mw_environment.sv'
        mwsv_intf_tmplt='mw_interface.sv'
        mwuvm_gld_tmplt='mw_predictor.sv'


        mq_lib_name='work'
    end

    properties(Hidden)


TunPrmPargsMap
    end

    methods
        function obj=uvmconfig(varargin)
            p=inputParser;
            addParameter(p,'timescale',obj.timescale);
            addParameter(p,'buildDirectory',obj.buildDirectory);
            parse(p,varargin{:});
            obj.timescale=p.Results.timescale;
            obj.buildDirectory=p.Results.buildDirectory;

            obj.DirFromDPIArtifact=containers.Map;
            obj.TunPrmPargsMap=containers.Map;
        end


    end

    methods(Hidden)
        function CreateUVMDirHierarchy(obj,base_dir,DrvMonGld_exist)
            obj.uvm_testbenchdir='';
            obj.component_paths=containers.Map({'top',...
            'sequence',...
            'scoreboard',...
            'DPI_dut',...
            'uvm_artifacts'},...
            {fullfile(base_dir,obj.uvm_testbenchdir,'top'),...
            fullfile(base_dir,obj.uvm_testbenchdir,'sequence'),...
            fullfile(base_dir,obj.uvm_testbenchdir,'scoreboard'),...
            fullfile(base_dir,obj.uvm_testbenchdir,'DPI_dut'),...
            fullfile(base_dir,obj.uvm_testbenchdir,'uvm_artifacts')});
            if all(DrvMonGld_exist)

                obj.component_paths('driver')=fullfile(base_dir,obj.uvm_testbenchdir,'driver');
                obj.component_paths('monitor')=fullfile(base_dir,obj.uvm_testbenchdir,'monitor');
                obj.component_paths('predictor')=fullfile(base_dir,obj.uvm_testbenchdir,'predictor');
            elseif(DrvMonGld_exist(1)&&DrvMonGld_exist(2))

                obj.component_paths('driver')=fullfile(base_dir,obj.uvm_testbenchdir,'driver');
                obj.component_paths('monitor')=fullfile(base_dir,obj.uvm_testbenchdir,'monitor');
            elseif(DrvMonGld_exist(1)&&DrvMonGld_exist(3))

                obj.component_paths('driver')=fullfile(base_dir,obj.uvm_testbenchdir,'driver');
                obj.component_paths('predictor')=fullfile(base_dir,obj.uvm_testbenchdir,'predictor');
            elseif(DrvMonGld_exist(2)&&DrvMonGld_exist(3))

                obj.component_paths('monitor')=fullfile(base_dir,obj.uvm_testbenchdir,'monitor');
                obj.component_paths('predictor')=fullfile(base_dir,obj.uvm_testbenchdir,'predictor');
            elseif DrvMonGld_exist(1)

                obj.component_paths('driver')=fullfile(base_dir,obj.uvm_testbenchdir,'driver');
            elseif DrvMonGld_exist(2)

                obj.component_paths('monitor')=fullfile(base_dir,obj.uvm_testbenchdir,'monitor');
            elseif DrvMonGld_exist(3)

                obj.component_paths('predictor')=fullfile(base_dir,obj.uvm_testbenchdir,'predictor');
            end


            cellfun(@(x)mkdir(obj.component_paths(x)),keys(obj.component_paths));
        end

        function setDirFromDPIArtifact(obj,mapk,mapv)
            obj.DirFromDPIArtifact(mapk)=mapv;
        end

        function str=getTopPkgHeader(~,test_pkg_fileLoc,top_mdl)
            str=addFLBanner(test_pkg_fileLoc,'//','',top_mdl);
        end
    end

    methods
        function set.buildDirectory(obj,dirval)
            validateattributes(dirval,{'char'},{'nonempty'});
            if(all(isstrprop(dirval,'wspace')))
                error(message('HDLLink:uvmgenerator:InvalidBuildDir'));
            end
            trimdir=strtrim(dirval);
            if(~strcmp(trimdir,dirval))
                error(message('HDLLink:uvmgenerator:InvalidBuildDirSpaces'));
            end
            obj.buildDirectory=dirval;
        end
    end

end

function checkTimescaleFmt_1(ts)
    [sidx,eidx]=regexp(ts,...
    '\s*10{0,2}\s*[m|u|n|p|f]?s\s*/\s*10{0,2}\s*[m|u|n|p|f]?s\s*',...
    'ONCE');
    assert((~isempty(sidx)||~isempty(eidx))&&...
    all([sidx,eidx]==size(ts)),...
    message('HDLLink:uvmgenerator:InvalidTimescale'));

end



