classdef(Hidden)uvm_agent<uvmcodegen.uvm_component
    properties


        seq_handles={};



        drv_handles={};



        mon_handles={};



        pred_handles={};

        uvmbehcmp_name='';
    end

    methods(Access=private)
        function status=setObj(this,h)


            if(~isempty(h))
                this.uvmobj_name=h.dut_handle.uvmobj_name;
                this.uvmobj_type=h.dut_handle.uvmobj_type;
            end
        end
    end


    methods
        function this=uvm_agent(varargin)


            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'seq_handle','');
            addParameter(p,'drv_handle','');
            addParameter(p,'mon_handle','');

            addParameter(p,'uvmcmp_name',[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.agt_suffix]);
            addParameter(p,'uvmbehcmp_name',[this.ucfg.prefix,this.mwcfg.sldut_name,'_BEH',this.ucfg.agt_suffix]);
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_agt_tmplt));
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmbehcmp_name=p.Results.uvmbehcmp_name;
            this.uvmcmp_type='uvm_agent';
            if this.mwcfg.sl2uvmtopo.Seq2ScrConnection||this.mwcfg.sl2uvmtopo.Seq2GldConnection
                this.uvmcmp_tmplt=sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_agt_bypass_tmplt);
            else
                this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;
            end

            this.addMon(p.Results.mon_handle);
            this.addDrv(p.Results.drv_handle);
            this.addSeq(p.Results.seq_handle);

        end

        function status=addSeq(this,hseq)


            if(~isempty(hseq))
                this.seq_handles{end+1}=hseq;
            end

        end

        function status=addDrv(this,hdrv)


            if(~isempty(hdrv))
                this.drv_handles{end+1}=hdrv;
            end

        end

        function status=addMon(this,hmon)



            if(~isempty(hmon))
                this.mon_handles{end+1}=hmon;
                this.setObj(hmon);
            end

        end

        function status=addPred(this,hpred)


            if(~isempty(hpred))
                this.pred_handles{end+1}=hpred;
            end

        end

        function string=prtuvmcmp(this)


            dpigenerator_disp(['Generating UVM agent ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);

            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//','',bdroot(this.mwcfg.sldut_path)));
            tpl=replace(tpl,'%AGTNAME%',this.uvmcmp_name);
            tpl=replace(tpl,'%AGTBEHNAME%',this.uvmbehcmp_name);
            tpl=replace(tpl,'%SEQITM%',this.dut_handle.uvmobj_name);
            tpl=replace(tpl,'%SQRNAME%',this.seq_handles{1}.uvmsqr_name);
            tpl=replace(tpl,'%DRVNAME%',this.drv_handles{1}.uvmcmp_name);
            tpl=replace(tpl,'%MONNAME%',this.mon_handles{1}.uvmcmp_name);
            tpl=replace(tpl,'%MONNAME_BYPASS%',this.mon_handles{1}.uvmcmp_input_name);
            tpl=replace(tpl,'%INFNAME%',this.drv_handles{1}.vif_handle.sv_ifnam);


            if this.mwcfg.sl2uvmtopo.Seq2ScrConnection||this.mwcfg.sl2uvmtopo.Seq2GldConnection

                if this.mwcfg.sl2uvmtopo.Seq2ScrConnection
                    tpl=replace(tpl,'%SCRAPPORT%',['uvm_analysis_port #(',this.dut_handle.uvmobj_name,') ap_input;']);
                    tpl=replace(tpl,'%CREATESCRAPPORT%','ap_input = new ("ap_input", this);');
                    tpl=replace(tpl,'%CONSCRAPPORT%','mon_input.ap_input.connect (this.ap_input);');
                else
                    tpl=replace(tpl,'%SCRAPPORT%','');
                    tpl=replace(tpl,'%CREATESCRAPPORT%','');
                    tpl=replace(tpl,'%CONSCRAPPORT%','');
                end


                if this.mwcfg.sl2uvmtopo.Seq2GldConnection
                    tpl=replace(tpl,'%PREDAPPORT%',['uvm_analysis_port #(',this.pred_handles{1}.uvmobj_name,') ap_input_pred;']);
                    tpl=replace(tpl,'%CREATEPREDAPPORT%','ap_input_pred = new ("ap_input_pred", this);');
                    tpl=replace(tpl,'%CONPREDAPPORT%','mon_input.ap_input_pred.connect (this.ap_input_pred);');
                else
                    tpl=replace(tpl,'%PREDAPPORT%','');
                    tpl=replace(tpl,'%CREATEPREDAPPORT%','');
                    tpl=replace(tpl,'%CONPREDAPPORT%','');
                end
            end
            string=tpl;
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('uvm_artifacts'),[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,agtdir,~]=fileparts(obj.ucfg.component_paths('uvm_artifacts'));
            str=obj.replaceBackS(fullfile('..',agtdir,[obj.uvmcmp_name,'.sv']));
        end


    end

end
