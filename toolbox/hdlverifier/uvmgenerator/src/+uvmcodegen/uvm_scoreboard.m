classdef(Hidden)uvm_scoreboard<uvmcodegen.uvm_component

    methods(Access=private)
        function str=sequence_items(this,SpaceInd)



            str='';
            for n=1:length(this.sources)
                str=sprintf('%s%s %s_trans;\n',str,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                if this.mwcfg.sl2uvmtopo.Seq2ScrConnection
                    str=sprintf(['%s',repmat(' ',1,SpaceInd),'%s %s_trans_input;\n'],str,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                end
                if this.mwcfg.sl2uvmtopo.Seq2GldConnection&&this.mwcfg.sl2uvmtopo.Gld2ScrConnection
                    str=sprintf(['%s',repmat(' ',1,SpaceInd),'%s %s_trans_input_pred;\n'],str,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                end
            end
        end

        function str=analysis_ports(this,SpaceInd)



            ap_imp='';
            ap_fifo='';

            for n=1:length(this.sources)
                ap_imp=sprintf('%suvm_analysis_export   #(%s) %s_imp;\n',ap_imp,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                ap_fifo=sprintf(['%s',repmat(' ',1,SpaceInd),'uvm_tlm_analysis_fifo #(%s) %s_fifo;\n'],ap_fifo,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                if this.mwcfg.sl2uvmtopo.Seq2ScrConnection
                    ap_imp=sprintf(['%s',repmat(' ',1,SpaceInd),'uvm_analysis_export   #(%s) %s_imp_input;\n'],ap_imp,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                    ap_fifo=sprintf(['%s',repmat(' ',1,SpaceInd),'uvm_tlm_analysis_fifo #(%s) %s_fifo_input;\n'],ap_fifo,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                end
                if this.mwcfg.sl2uvmtopo.Seq2GldConnection&&this.mwcfg.sl2uvmtopo.Gld2ScrConnection
                    ap_imp=sprintf(['%s',repmat(' ',1,SpaceInd),'uvm_analysis_export   #(%s) %s_imp_input_pred;\n'],ap_imp,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                    ap_fifo=sprintf(['%s',repmat(' ',1,SpaceInd),'uvm_tlm_analysis_fifo #(%s) %s_fifo_input_pred;\n'],ap_fifo,this.sources{n}.uvmobj_name,this.sources{n}.uvmcmp_name);
                end
            end

            str=sprintf('%s%s',ap_imp,ap_fifo);
        end

        function str=build_phase(this,SpaceInd)



            itm='';
            imp='';
            fifo='';

            for n=1:length(this.sources)
                itm=sprintf('%s%s_trans = new ("%s_trans");\n',itm,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                imp=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_imp   = new ("%s_imp", this);\n'],imp,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                fifo=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_fifo  = new ("%s_fifo", this);\n'],fifo,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);

                if this.mwcfg.sl2uvmtopo.Seq2ScrConnection
                    itm=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_trans_input = new ("%s_trans_input");\n'],itm,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                    imp=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_imp_input   = new ("%s_imp_input", this);\n'],imp,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                    fifo=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_fifo_input  = new ("%s_fifo_input", this);\n'],fifo,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                end
                if this.mwcfg.sl2uvmtopo.Seq2GldConnection&&this.mwcfg.sl2uvmtopo.Gld2ScrConnection
                    itm=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_trans_input_pred = new ("%s_trans_input_pred");\n'],itm,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                    imp=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_imp_input_pred   = new ("%s_imp_input_pred", this);\n'],imp,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                    fifo=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_fifo_input_pred  = new ("%s_fifo_input_pred", this);\n'],fifo,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                end
            end

            str=sprintf('%s%s%s',itm,imp,fifo);
        end

        function str=connect_phase(this,SpaceInd)



            str='';

            for n=1:length(this.sources)
                str=sprintf('%s%s_imp.connect (%s_fifo.analysis_export);\n',str,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);

                if this.mwcfg.sl2uvmtopo.Seq2ScrConnection
                    str=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_imp_input.connect (%s_fifo_input.analysis_export);\n'],str,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                end

                if this.mwcfg.sl2uvmtopo.Seq2GldConnection&&this.mwcfg.sl2uvmtopo.Gld2ScrConnection
                    str=sprintf(['%s',repmat(' ',1,SpaceInd),'%s_imp_input_pred.connect (%s_fifo_input_pred.analysis_export);\n'],str,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                end
            end

        end

        function str=dpi_inits(this)



            str=sprintf('objhandle = %s(null);\n',...
            this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.InitializeFunction.FunctionName{1});

            if this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                str=sprintf('\n%s%s',str,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSVerifyInfoInstantiation);
            end
        end

        function str=dpi_term(obj)
            str=[obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TerminateFunction.FunctionName{1},'(',...
            obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TerminateFunction.ArgumentIdentifiers{1},...
            ');\n'];
        end

        function str=get_cfg_obj_from_cfgdb(obj,space_ind,TunPrmStruct)

            [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,1);
            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end
            str=sprintf(['//Get scoreboard configuration object from the database\n',...
            ind_base,'if(!uvm_config_db#(',obj.scr_cfg_obj.ScrCfgObjType,')::get(null,get_full_name(),"',obj.scr_cfg_obj.ScrCfgObjID,'",',obj.scr_cfg_obj.ScrCfgObjID,')) begin\n',...
            ind_lvl{1},'//If configuration object is not in the database then use Simulink default configuration\n',...
            ind_lvl{1},obj.scr_cfg_obj.ScrCfgObjID,'=',obj.scr_cfg_obj.ScrCfgObjType,'::type_id::create("',obj.scr_cfg_obj.ScrCfgObjID,'",this);\n',...
            ind_base,'end\n\n']);
        end

        function str=run_phase(this,SpaceIndentation)



            get_seqitm='';
            dpi_output='';
            dpi_update='';
            err_action='';


            [~,~,~,scrinFromMonin]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('scoreboard');
            [~,~,~,scrinFromPred]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('predictor');
            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();
            scrinFromMonin_key=cellfun(@(x)getFirstElementOfCell(x),scrinFromMonin,'UniformOutput',false);
            scrinFromPred_key=cellfun(@(x)getFirstElementOfCell(x),scrinFromPred,'UniformOutput',false);
            function res=getFirstElementOfCell(id)
                if iscell(id)
                    res=id{1};
                else
                    res=id;
                end
            end
            function n_suffix=n_getCorrectTrans(n_x)
                n_x=getFirstElementOfCell(n_x);
                if any(strcmp(n_x,scrinFromMonin_key))
                    n_suffix='_trans_input';
                elseif any(strcmp(n_x,scrinFromPred_key))
                    n_suffix='_trans_input_pred';
                else
                    n_suffix='_trans';
                end
            end

            function n_str=n_get_scr_fcn_sig(sigid,sigsz,agentname,sufix)
                if sigsz>1&&IsScalarizePortsEnabled
                    n_str='';
                    for idx=1:sigsz
                        if iscell(sigid)
                            n_str=sprintf('%s,.%s(%s)',n_str,sigid{idx},[agentname,sufix,'.',sigid{idx}]);
                        else
                            n_str=sprintf('%s,.%s_%d(%s_%d)',n_str,sigid,idx-1,[agentname,sufix,'.',sigid],idx-1);
                        end
                    end
                else
                    n_str=sprintf(',.%s(%s)',sigid,[agentname,sufix,'.',sigid]);
                end
            end

            for n=1:length(this.sources)



                outputfcn_args=char(join([this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(1),...
                cellfun(@(x,sz)n_get_scr_fcn_sig(x,sz,this.sources{n}.uvmcmp_name,n_getCorrectTrans(x)),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(2:end),...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentSizes(2:end),...
                'UniformOutput',false)]));

                updatefcn_args=char(join([this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.ArgumentIdentifiers(1),...
                cellfun(@(x,sz)n_get_scr_fcn_sig(x,sz,this.sources{n}.uvmcmp_name,n_getCorrectTrans(x)),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.ArgumentIdentifiers(2:end),...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.ArgumentSizes(2:end),...
                'UniformOutput',false)]));

                get_seqitm=sprintf('%s%s_fifo.get (%s_trans);\n',get_seqitm,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);

                if this.mwcfg.sl2uvmtopo.Seq2ScrConnection
                    get_seqitm=sprintf(['%s',repmat(' ',1,SpaceIndentation),'%s_fifo_input.get (%s_trans_input);\n'],get_seqitm,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                end

                if this.mwcfg.sl2uvmtopo.Seq2GldConnection&&this.mwcfg.sl2uvmtopo.Gld2ScrConnection
                    get_seqitm=sprintf(['%s',repmat(' ',1,SpaceIndentation),'%s_fifo_input_pred.get (%s_trans_input_pred);\n'],get_seqitm,this.sources{n}.uvmcmp_name,this.sources{n}.uvmcmp_name);
                end

                dpi_output=sprintf(['%s',repmat(' ',1,SpaceIndentation),'%s(%s);\n'],dpi_output,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.FunctionName{1},...
                outputfcn_args);
                dpi_update=sprintf(['%s',repmat(' ',1,SpaceIndentation),'%s(%s);\n'],dpi_update,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.FunctionName{1},...
                updatefcn_args);

            end
            reportRunTimeErrStr=this.printUVMRunTimeReporting(SpaceIndentation);
            if this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionPresent
                err_action=this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionQueryingSVCode;
            end

            if this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                err_action=sprintf('\n%s%s',err_action,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionQueryingSVCode);
            end



            tmp_f=split((repmat('%s ',1,count(err_action,'%s'))))';
            tmp_f=tmp_f(1:end-1);
            err_action_ca=split(err_action,newline);
            err_action=sprintf(char(join(cellfun(@(x)[repmat(' ',1,SpaceIndentation),x,'\n'],err_action_ca,'UniformOutput',false),'')),tmp_f{:});
            str=[get_seqitm,dpi_output,dpi_update,reportRunTimeErrStr,err_action];
        end

        function str=report_phase(this,SpaceIndentation)
            str='';
            if this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                str=sprintf('\n%s%s',str,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSVerifyInfoReporting);
            end
        end



        function str=getDefValLiteral(~,z)
            if numel(z)>1
                str=['''{',char(join(arrayfun(@(v)num2str(v),reshape(z,1,numel(z)),'UniformOutput',false),',')),'}'];
            else
                str=num2str(z);
            end
        end


    end


    methods
        function this=uvm_scoreboard(varargin)



            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'uvmcmp_name',replace([this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.scr_suffix],newline,''));
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_scr_tmplt));
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_type='uvm_scoreboard';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;

            this.uvmobj_name=this.sources{1}.dut_handle.uvmobj_name;


        end

        function set_uvmscr_cfg(obj,scr_cfg_obj)

            obj.scr_cfg_obj=scr_cfg_obj;
        end

        function str=prtuvmcmp(this)


            dpigenerator_disp(['Generating UVM scoreboard ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);

            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//',this.mwpath,bdroot(this.mwpath)));
            tpl=replace(tpl,'%IMPORTS%',sprintf('import %s::*;\n',this.mwcfg.sl2uvmtopo.getPackageNameSpace('scr')));
            tpl=replace(tpl,'%SCRNAME%',this.uvmcmp_name);
            tpl=replace(tpl,'%RUNTIME_ERROR_VAR_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.ReturnValDecl);
            tpl=replace(tpl,'%ASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionInfoStructDecl);
            tpl=replace(tpl,'%TSASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionInfoStructDecl);
            tpl=replace(tpl,'%SCR_CFG_OBJ_VAR_DECL%',this.get_scr_cfg_obj_var_decl(this.getSpaceIndentation(tpl,'%SCR_CFG_OBJ_VAR_DECL%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
            tpl=replace(tpl,'%GET_CFG_OBJ_FROM_CFGDB%',this.get_cfg_obj_from_cfgdb(this.getSpaceIndentation(tpl,'%GET_CFG_OBJ_FROM_CFGDB%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
            tpl=replace(tpl,'%TUN_PRM_FCN_CALL%',this.tunable_prm_fcn_call(this.getSpaceIndentation(tpl,'%TUN_PRM_FCN_CALL%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
            tpl=replace(tpl,'%ANALYSIS_PORTS%',this.analysis_ports(this.getSpaceIndentation(tpl,'%ANALYSIS_PORTS%')));
            tpl=replace(tpl,'%SEQITMS%',this.sequence_items(this.getSpaceIndentation(tpl,'%SEQITMS%')));
            tpl=replace(tpl,'%BUILD%',this.build_phase(this.getSpaceIndentation(tpl,'%BUILD%')));
            tpl=replace(tpl,'%CONNECTS%',this.connect_phase(this.getSpaceIndentation(tpl,'%CONNECTS%')));
            tpl=replace(tpl,'%DPI_INIT%',this.dpi_inits());
            tpl=replace(tpl,'%RUN%',this.run_phase(this.getSpaceIndentation(tpl,'%RUN%')));
            tpl=replace(tpl,'%DPI_TERM%',this.dpi_term());
            tpl=replace(tpl,'%REPORT%',this.report_phase(this.getSpaceIndentation(tpl,'%REPORT%')));
            str=tpl;
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('scoreboard'),[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,scrdir,~]=fileparts(obj.ucfg.component_paths('scoreboard'));
            str=obj.replaceBackS(fullfile('..',scrdir,[obj.uvmcmp_name,'.sv']));
        end

    end
end



