classdef(Hidden)uvm_top<uvmcodegen.uvm_component

    properties


        vif_handle;
        agt_handle;
    end

    methods
        function this=uvm_top(varargin)



            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'vif_handle','');
            addParameter(p,'dut_handle','');
            addParameter(p,'agt_handle','');
            addParameter(p,'uvmcmp_name',[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.top_suffix]);
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_top_tmplt));
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_type='uvm_top';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;
            this.vif_handle=p.Results.vif_handle;
            this.agt_handle=p.Results.agt_handle;

        end

        function string=prtuvmcmp(this)


            dpigenerator_disp(['Generating UVM top ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);

            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//','',bdroot(this.mwcfg.sldut_path)));
            tpl=replace(tpl,'%DUT_RELPATH%',this.getRelPath('DPI_dut'));
            tpl=replace(tpl,'%UVM_TB_RELPATH%',this.getRelPath('uvm_artifacts'));

            tpl=replace(tpl,'%TOP_NAME%',this.uvmcmp_name);
            tpl=replace(tpl,'%DUT_NAME%',[this.dut_handle.mwblkname,'_dpi']);
            tpl=replace(tpl,'%AGTNAME%',this.agt_handle.uvmcmp_name);
            tpl=replace(tpl,'%AGTBEHNAME%',this.agt_handle.uvmbehcmp_name);
            tpl=replace(tpl,'%INFNAME%',this.vif_handle.sv_ifnam);
            tpl=replace(tpl,'%MODEL_NAME%',bdroot(this.dut_handle.mwpath));
            [~,~,DutSize,DutIfId]=this.mwcfg.sl2uvmtopo.getDutIfInfo();
            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();
            tpl=replace(tpl,'%DUT_PORT_CNT%',sprintf(char(join(cellfun(@(id,sz)n_get_dut_instantiation_args(id,sz,IsScalarizePortsEnabled),DutIfId,DutSize,'UniformOutput',false),','))));
            string=tpl;
            function str=n_get_dut_instantiation_args(id,sz,IsScalarizePortsEnabled)
                if sz>1&&IsScalarizePortsEnabled
                    str='';
                    for idx=1:sz
                        if iscell(id)
                            str=sprintf('%s.%s (dutif.%s),',str,id{idx},id{idx});
                        else
                            str=sprintf('%s.%s_%d (dutif.%s_%d),',str,id,idx-1,id,idx-1);
                        end
                    end
                    str=sprintf('%s',str(1:end-1));
                else
                    str=sprintf('.%s (dutif.%s)',id,id);
                end
            end
        end

        function string=prtuvmobj(this)



            string='';
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('top'),[obj.uvmcmp_name,'.sv']));
        end

    end

    methods(Access=private)
        function str=getRelPath(obj,component_type)
            [~,comp_dir,~]=fileparts(obj.ucfg.component_paths(component_type));
            str=obj.replaceBackS([fullfile('..',comp_dir),filesep]);
        end
    end
end
