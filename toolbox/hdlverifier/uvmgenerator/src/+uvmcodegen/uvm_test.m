classdef(Hidden)uvm_test<uvmcodegen.uvm_component

    methods(Access=private)
        function string=startseq(this)

            agtinst=replace(this.sources{1}.scrs{1}.sources{1}.uvmcmp_name,this.ucfg.prefix,'');

            string=sprintf('      seq.start (env.%s.sqr);',agtinst);

        end

    end

    methods
        function this=uvm_test(varargin)


            this=this@uvmcodegen.uvm_component(varargin{:});

            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'uvmcmp_name',[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.tst_suffix]);
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_tst_tmplt));
            addParameter(p,'env','');
            addParameter(p,'seq','');
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_type='uvm_test';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;

            this.addSrc(p.Results.env);
            this.addSrc(p.Results.seq);
        end

        function str=prtuvmcmp(this)
            dpigenerator_disp(['Generating UVM test ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);

            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//','',bdroot(this.mwcfg.sldut_path)));
            tpl=replace(tpl,'%TESTNAME%',this.uvmcmp_name);
            tpl=replace(tpl,'%ENV%',this.sources{1}.uvmcmp_name);
            tpl=replace(tpl,'%SEQ%',this.sources{2}.uvmcmp_name);
            tpl=replace(tpl,'%SCR_CFG_OBJ_VAR_DECL%',this.get_scr_cfg_obj_var_decl(this.getSpaceIndentation(tpl,'%SCR_CFG_OBJ_VAR_DECL%'),this.sources{1}.scrs{1}.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
            tpl=replace(tpl,'%SET_PRM_VALS_IN_CFGDB%',this.set_prm_vals_in_cfgdb(this.getSpaceIndentation(tpl,'%SET_PRM_VALS_IN_CFGDB%'),this.sources{1}.scrs{1}.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
            tpl=replace(tpl,'%startseq%',this.startseq());

            str=tpl;
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('uvm_artifacts'),[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,tstdir,~]=fileparts(obj.ucfg.component_paths('uvm_artifacts'));
            str=obj.replaceBackS(fullfile('..',tstdir,[obj.uvmcmp_name,'.sv']));
        end

        function str=set_prm_vals_in_cfgdb(obj,space_ind,TunPrmStruct)

            [ind_base,~]=obj.getIndentationLevels(space_ind,0);
            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end
            str=sprintf(['//Create scoreboard configuration object\n',...
            ind_base,obj.scr_cfg_obj.ScrCfgObjID,'=',obj.scr_cfg_obj.ScrCfgObjType,'::type_id::create("',obj.scr_cfg_obj.ScrCfgObjID,'",this);\n',...
            ind_base,'//Set tunable parameter values in the configuration database\n',...
            ind_base,'uvm_config_db#(',obj.scr_cfg_obj.ScrCfgObjType,')::set(this,"env.',obj.mwcfg.sldut_name,'_scoreboard","',obj.scr_cfg_obj.ScrCfgObjID,'",',obj.scr_cfg_obj.ScrCfgObjID,');\n']);
        end

    end
end
