classdef(Hidden)uvm_env<uvmcodegen.uvm_component
    properties


        scrs={};
        preds={};
    end

    methods(Access=private)
        function string=agents(this)



            string='';
            for n=1:length(this.scrs)
                scrsrc=this.scrs{n}.sources;
                for m=1:length(scrsrc)
                    src=scrsrc{m};
                    string=sprintf('%s    %s %s;\n',string,src.uvmcmp_name,replace(src.uvmcmp_name,this.ucfg.prefix,''));
                end
            end

            string=regexprep(string,'\n$',' ');
        end

        function string=scoreboards(this)



            string='';
            for n=1:length(this.scrs)
                scr=this.scrs{n};
                string=sprintf('%s    %s %s;\n',string,scr.uvmcmp_name,replace(scr.uvmcmp_name,this.ucfg.prefix,''));
            end

            string=regexprep(string,'\n$',' ');
        end

        function string=predictors(this)
            string='';

            for n=1:length(this.preds)
                pred=this.preds{n};
                if IsPredObjPresent(pred)
                    string=sprintf('%s    %s %s;\n',string,pred.uvmcmp_name,replace(pred.uvmcmp_name,this.ucfg.prefix,''));
                    string=regexprep(string,'\n$',' ');
                end
            end
        end

        function string=build_phase(this)



            string='';
            for n=1:length(this.scrs)
                scrsrc=this.scrs{n}.sources;
                for m=1:length(scrsrc)
                    src=scrsrc{m};
                    instname=replace(src.uvmcmp_name,this.ucfg.prefix,'');
                    string=sprintf('%s      %s = %s::type_id::create ("%s", this);\n',string,instname,src.uvmcmp_name,instname);
                end
            end

            for n=1:length(this.scrs)
                scr=this.scrs{n};
                instname=replace(scr.uvmcmp_name,this.ucfg.prefix,'');
                string=sprintf('%s      %s = %s::type_id::create ("%s", this);\n',string,instname,scr.uvmcmp_name,instname);
            end

            for n=1:length(this.preds)
                pred=this.preds{n};
                if(IsPredObjPresent(pred))
                    instname=replace(pred.uvmcmp_name,this.ucfg.prefix,'');
                    string=sprintf('%s      %s = %s::type_id::create ("%s", this);\n',string,instname,pred.uvmcmp_name,instname);
                end
            end
            string=regexprep(string,'\n$',' ');
        end

        function str=conec_phase(this)



            str='';
            if(IsPredObjPresent(this.preds{1}))
                pred=this.preds{1};
            end

            for n=1:length(this.scrs)
                scr=this.scrs{n};
                scrsrc=this.scrs{n}.sources;
                for m=1:length(scrsrc)
                    src=scrsrc{m};
                    instname=replace(scr.uvmcmp_name,this.ucfg.prefix,'');

                    str=sprintf('%s     %s.ap.connect (%s.%s_imp);\n',str,replace(src.uvmcmp_name,this.ucfg.prefix,''),instname,src.uvmcmp_name);
                    if this.mwcfg.sl2uvmtopo.Seq2ScrConnection
                        str=sprintf('%s     %s.ap_input.connect (%s.%s_imp_input);\n',str,replace(src.uvmcmp_name,this.ucfg.prefix,''),instname,src.uvmcmp_name);
                    end
                    if this.mwcfg.sl2uvmtopo.Seq2GldConnection&&this.mwcfg.sl2uvmtopo.Gld2ScrConnection
                        str=sprintf('%s     %s.ap_input_pred.connect (%s.aexp);\n',str,replace(src.uvmcmp_name,this.ucfg.prefix,''),replace(pred.uvmcmp_name,this.ucfg.prefix,''));
                        str=sprintf('%s     %s.ap.connect (%s.%s_imp_input_pred);\n',str,replace(pred.uvmcmp_name,this.ucfg.prefix,''),instname,src.uvmcmp_name);
                    end
                end
            end

            str=regexprep(str,'\n$',' ');
        end

    end

    methods
        function this=uvm_env(varargin)



            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'uvmcmp_name',[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.env_suffix]);
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_env_tmplt));
            addParameter(p,'scr','');
            addParameter(p,'gld','');
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_type='uvm_environment';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;

            this.addScr(p.Results.scr);
            this.addGld(p.Results.gld);
        end

        function status=addScr(this,h)



            if(~isempty(h))
                this.scrs{end+1}=h;
                status=false;
            else
                status=true;
            end

        end

        function status=addGld(this,h)



            if(~isempty(h))
                this.preds{end+1}=h;
                status=false;
            else
                status=true;
            end

        end

        function status=addCmp(this,h)



            if(~isempty(h))
                this.cmps{end+1}=h;
                status=false;
            else
                status=true;
            end
        end

        function string=prtuvmcmp(this)


            dpigenerator_disp(['Generating UVM environment ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);

            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//','',bdroot(this.mwcfg.sldut_path)));
            tpl=replace(tpl,'%ENVNAME%',this.uvmcmp_name);
            tpl=replace(tpl,'%AGENTS%',this.agents());
            tpl=replace(tpl,'%PREDICTOR%',this.predictors());
            tpl=replace(tpl,'%SCOREBOARDS%',this.scoreboards());
            tpl=replace(tpl,'%BUILD%',this.build_phase());
            tpl=replace(tpl,'%CONNECTS%',this.conec_phase());

            string=tpl;
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('uvm_artifacts'),[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,envdir,~]=fileparts(obj.ucfg.component_paths('uvm_artifacts'));
            str=obj.replaceBackS(fullfile('..',envdir,[obj.uvmcmp_name,'.sv']));
        end

    end

end
