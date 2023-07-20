classdef(Hidden)uvm_monitor<uvmcodegen.uvm_component

    properties(GetAccess=public,SetAccess=private)
        vif_handle;


        uvmcmp_input_name;
        MonMode uvmcodegen.ConvertorMode;
        MonComp;
        FormatSequence={};
    end

    properties(Constant,Access=private)
        call_dpi_fcns_id='call_dpi_fcns';
    end

    methods
        function this=uvm_monitor(varargin)






            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'vif_handle','');
            addParameter(p,'dut_handle','');
            addParameter(p,'uvmcmp_name',[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.mon_suffix]);
            addParameter(p,'uvmcmp_input_name',[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.mon_input_suffix]);
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_mon_tmplt));
            addParameter(p,'uvmcmp_input_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_mon_input_tmplt));
            addParameter(p,'MonMode',uvmcodegen.ConvertorMode.PT);

            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_input_name=p.Results.uvmcmp_input_name;
            this.uvmcmp_type='uvm_monitor';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;
            this.uvmcmp_input_tmplt=p.Results.uvmcmp_input_tmplt;
            this.vif_handle=p.Results.vif_handle;
            this.MonMode=p.Results.MonMode;

            if this.MonMode==uvmcodegen.ConvertorMode.DPISUB
                this.MonComp='monitor';
            else
                this.MonComp='uvm_artifacts';
            end
            this.addSrc(p.Results.dut_handle);
        end

        function str=prtuvmcmp(this,varargin)


            tpl=prtuvmcmp@uvmcodegen.uvm_component(this,varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'MonitorInput',false);
            parse(p,varargin{:});
            MonitorInput=p.Results.MonitorInput;



            src=this.sources{1};
            if MonitorInput||isempty(this.mwpath)
                tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//',this.mwcfg.sldut_path,bdroot(this.mwcfg.sldut_path)));
            else
                tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//',this.mwpath,bdroot(this.mwpath)));
            end

            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();

            if MonitorInput
                dpigenerator_disp(['Generating UVM input monitor ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc_input())]);

                tpl=replace(tpl,'%MONNAME%',this.uvmcmp_input_name);

                [seqoutToPred,predin,~,~]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('predictor');
                [~,predinSZ,~,~]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSZ('predictor');

                [seqoutToScr,~,~,scrinFromMonInp]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('scoreboard');
                [~,~,~,scrinFromMonInpSZ]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSZ('scoreboard');



                pred_tran_name=[src.ucfg.prefix,src.mwblkname,src.ucfg.gld_suffix,src.ucfg.obj_suffix];
                scr_tran_name=src.uvmobj_name;

                tpl=replace(tpl,'%DELAY_AP_WR%',this.delay_ap_wr_inp(this.getSpaceIndentation(tpl,'%DELAY_AP_WR%'),...
                seqoutToPred,predin,predinSZ,seqoutToScr,scrinFromMonInp,scrinFromMonInpSZ,IsScalarizePortsEnabled));

                if this.mwcfg.sl2uvmtopo.Seq2GldConnection

                    tpl=replace(tpl,'%MONSIG2PRED%',this.monitorsig_inp(this.getSpaceIndentation(tpl,'%MONSIG2PRED%'),predin,seqoutToPred,predinSZ,IsScalarizePortsEnabled,'predictor'));

                    tpl=replace(tpl,'%PREDAPPORT%',['uvm_analysis_port #(',pred_tran_name,') ap_input_pred;']);

                    tpl=replace(tpl,'%PREDITM%',[pred_tran_name,'                      preditm;']);

                    tpl=replace(tpl,'%CREATEPREDAPPORT%',['ap_input_pred = new("',this.uvmcmp_input_name,'_analysis_port_pred", this);']);

                    tpl=replace(tpl,'%CREATEPREDITM%',['preditm = ',pred_tran_name,'::type_id::create("predTrans", this);']);

                    tpl=replace(tpl,'%WPREDITM%','ap_input_pred.write(preditm);');
                else
                    tpl=replace(tpl,'%MONSIG2PRED%','');
                    tpl=replace(tpl,'%PREDAPPORT%','');
                    tpl=replace(tpl,'%PREDITM%','');
                    tpl=replace(tpl,'%CREATEPREDAPPORT%','');
                    tpl=replace(tpl,'%CREATEPREDITM%','');
                    tpl=replace(tpl,'%WPREDITM%','');
                end

                if this.mwcfg.sl2uvmtopo.Seq2ScrConnection()

                    tpl=replace(tpl,'%MONSIG2SCR%',this.monitorsig_inp(this.getSpaceIndentation(tpl,'%MONSIG2SCR%'),scrinFromMonInp,seqoutToScr,scrinFromMonInpSZ,IsScalarizePortsEnabled,'scoreboard'));

                    tpl=replace(tpl,'%SCRAPPORT%',['uvm_analysis_port #(',scr_tran_name,') ap_input;']);

                    tpl=replace(tpl,'%SCRITM%',[scr_tran_name,'                      scritm;']);

                    tpl=replace(tpl,'%CREATESCRAPPORT%',['ap_input = new("',this.uvmcmp_input_name,'_analysis_port", this);']);

                    tpl=replace(tpl,'%CREATESCRITM%',['scritm = ',scr_tran_name,'::type_id::create("scrTrans", this);']);

                    tpl=replace(tpl,'%WSCRITM%','ap_input.write(scritm);');
                else
                    tpl=replace(tpl,'%MONSIG2SCR%','');
                    tpl=replace(tpl,'%SCRAPPORT%','');
                    tpl=replace(tpl,'%SCRITM%','');
                    tpl=replace(tpl,'%CREATESCRAPPORT%','');
                    tpl=replace(tpl,'%CREATESCRITM%','');
                    tpl=replace(tpl,'%WSCRITM%','');
                end
            else
                dpigenerator_disp(['Generating UVM monitor ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);
                tpl=replace(tpl,'%IMPORTS%',this.get_DPI_import_pkg());
                tpl=replace(tpl,'%MONNAME%',this.uvmcmp_name);
                tpl=replace(tpl,'%OBJHANDLE_DECL%',this.get_DPI_objhandle());
                if this.MonMode==uvmcodegen.ConvertorMode.DPISUB
                    tpl=replace(tpl,'%ASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionInfoStructDecl);
                    tpl=replace(tpl,'%TSASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionInfoStructDecl);
                else
                    tpl=replace(tpl,'%ASSERTION_STRUCT_INFO_DECL%','');
                    tpl=replace(tpl,'%TSASSERTION_STRUCT_INFO_DECL%','');
                end
                tpl=replace(tpl,'%DPI_INIT%',this.dpi_inits());
                tpl=replace(tpl,'%DPI_TERM%',this.dpi_term());
                tpl=replace(tpl,'%CALL_DPI_FCNS%',this.call_dpi_fcns(this.getSpaceIndentation(tpl,'%CALL_DPI_FCNS%'),IsScalarizePortsEnabled));
                tpl=replace(tpl,'%REPORT%',this.report_phase(this.getSpaceIndentation(tpl,'%REPORT%')));
                tpl=replace(tpl,'%MONITORSIG%',this.monitorsig(this.getSpaceIndentation(tpl,'%MONITORSIG%'),IsScalarizePortsEnabled));
                if hdlverifierfeature('TRANSACTION_RECORDING')
                    tpl=replace(tpl,'%TRANSREC_START%',sprintf('void''(this.begin_tr(seqitm, "mw_montrans"));'));
                    tpl=replace(tpl,'%TRANSREC_STOP%',sprintf('@(negedge dutvif.clk);\n                this.end_tr(seqitm);\n'));
                else
                    tpl=replace(tpl,'%TRANSREC_START%','');
                    tpl=replace(tpl,'%TRANSREC_STOP%','');
                end
                tpl=replace(tpl,'%DELAY_AP_WR%',this.delay_ap_wr(this.getSpaceIndentation(tpl,'%DELAY_AP_WR%'),IsScalarizePortsEnabled));
                tpl=replace(tpl,'%DUTITM%',src.uvmobj_name);
            end
            tpl=replace(tpl,'%INFNAME%',this.vif_handle.sv_ifnam);
            this.FormatSequence=this.StrFormatting(tpl);
            str=tpl;



        end



        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths(obj.MonComp),[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileLoc_input(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('uvm_artifacts'),[obj.uvmcmp_input_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,mondir,~]=fileparts(obj.ucfg.component_paths(obj.MonComp));
            str=obj.replaceBackS(fullfile('..',mondir,[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc_input(obj)
            [~,mondir,~]=fileparts(obj.ucfg.component_paths('uvm_artifacts'));
            str=obj.replaceBackS(fullfile('..',mondir,[obj.uvmcmp_input_name,'.sv']));
        end

        function r=Seq2ScrConnection(obj)
            r=obj.mwcfg.sl2uvmtopo.Seq2ScrConnection;
        end

        function r1=Seq2GldConnection(obj)
            r1=obj.mwcfg.sl2uvmtopo.Seq2GldConnection;
        end

        function r2=Gld2ScrConnection(obj)
            r2=obj.mwcfg.sl2uvmtopo.Gld2ScrConnection;
        end
    end

    methods(Access=private)
        function str=get_DPI_import_pkg(obj)
            if obj.MonMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
            else
                str=sprintf('import %s::*;\n',obj.mwcfg.sl2uvmtopo.getPackageNameSpace('mon'));
            end
        end

        function str=get_DPI_objhandle(obj)
            if obj.MonMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
            else
                str='chandle objhandle;\n';
            end
        end

        function str=dpi_inits(obj)
            if obj.MonMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
            else
                str=['objhandle=',obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.InitializeFunction.FunctionName{1},'(null);\n'];
                if obj.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                    str=sprintf('\n%s%s',str,...
                    obj.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSVerifyInfoInstantiation);
                end
            end
        end

        function str=dpi_term(obj)
            if obj.MonMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
            else
                str=[obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TerminateFunction.FunctionName{1},'(',...
                obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TerminateFunction.ArgumentIdentifiers{1},...
                ');\n'];
            end
        end

        function str=call_dpi_fcns(obj,space_ind,IsScalarizePortsEnabled)
            if obj.MonMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
                return;
            end

            [dutout,monin,monout,scrin,~,moninsz,monoutsz,~]=obj.mwcfg.sl2uvmtopo.getMonitorConnectionSigId();
            MonComment='//Call DPI component\n';
            objh_id=obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(1);
            input_arglist=[sprintf('.%s(%s)',objh_id{1},objh_id{1}),...
            char(join(cellfun(@(mon_in_id,dutout_id,sz)get_mon_dpi_args('input',mon_in_id,dutout_id,sz),monin,dutout,moninsz,'UniformOutput',false)))];
            output_arglist=char(join(cellfun(@(mon_out_id,scr_in_id,sz)get_mon_dpi_args('output',mon_out_id,scr_in_id,sz),monout,scrin,monoutsz,'UniformOutput',false)));

            function n_str=get_mon_dpi_args(type,leftId,rightId,sz)
                n_str='';
                switch type
                case 'input'
                    if sz>1&&IsScalarizePortsEnabled
                        for idx4=1:sz
                            if iscell(leftId)
                                n_str=sprintf('%s,.%s(dutvif.%s)',n_str,leftId{idx4},rightId{idx4});
                            else
                                n_str=sprintf('%s,.%s_%d(dutvif.%s_%d)',n_str,leftId,idx4-1,rightId,idx4-1);
                            end
                        end
                    else
                        n_str=sprintf(',.%s(dutvif.%s)',leftId,rightId);
                    end
                case 'output'
                    if sz>1&&IsScalarizePortsEnabled
                        for idx5=1:sz
                            if iscell(leftId)
                                n_str=sprintf('%s,.%s(seqitm.%s)',n_str,leftId{idx5},rightId{idx5});
                            else
                                n_str=sprintf('%s,.%s_%d(seqitm.%s_%d)',n_str,leftId,idx5-1,rightId,idx5-1);
                            end
                        end
                    else
                        n_str=sprintf(',.%s(seqitm.%s)',leftId,rightId);
                    end
                end
            end


            err_action='';
            if obj.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionPresent
                err_action=obj.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionQueryingSVCode;
            end

            if obj.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                err_action=sprintf('\n%s%s',err_action,...
                obj.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionQueryingSVCode);
            end

            str=[MonComment,...
            repmat(' ',1,space_ind),sprintf('%s(%s%s);',obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.FunctionName{1},input_arglist,output_arglist),'\n',...
            repmat(' ',1,space_ind),sprintf('%s(%s);',obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.FunctionName{1},input_arglist),'\n',...
            err_action];
        end

        function str=report_phase(this,SpaceIndentation)
            str='';
            if this.MonMode==uvmcodegen.ConvertorMode.DPISUB&&this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                str=sprintf('\n%s%s',str,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSVerifyInfoReporting);
            end
        end

        function str=monitorsig(obj,space_ind,IsScalarizePortsEnabled)

            if obj.MonMode==uvmcodegen.ConvertorMode.PT||obj.MonMode==uvmcodegen.ConvertorMode.PTWD
                [dutout,~,~,scrin,dutoutsz]=obj.mwcfg.sl2uvmtopo.getMonitorConnectionSigId();
                space=repmat(' ',1,space_ind);
                MonComment='//Passthrough monitor\n';


                str=[MonComment,...
                char(join(cellfun(@(x,y,sz)l_get_mon_sig(x,y,sz,space,IsScalarizePortsEnabled),...
                scrin,dutout,dutoutsz,'UniformOutput',false),''))];
            else
                [ind_base,~]=obj.getIndentationLevels(space_ind,3);
                MonComment='//Monitor vif signals and generate transactions by calling DPI component\n';
                str=[MonComment,...
                ind_base,obj.call_dpi_fcns_id,'();'];
            end
        end

        function str=delay_ap_wr(obj,space_ind,IsScalarizePortsEnabled)
            if obj.MonMode==uvmcodegen.ConvertorMode.PT
                str='';
            else
                [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,3);
                ClkDelay=obj.getClkCyclesDelay();
                if str2double(ClkDelay)==0
                    str='';
                else
                    Mon_inp_Comment='//Sample VIF but do not write to AP\n';
                    if obj.MonMode==uvmcodegen.ConvertorMode.PTWD
                        [dutout,~,~,scrin,dutoutsz]=obj.mwcfg.sl2uvmtopo.getMonitorConnectionSigId();
                        str=[Mon_inp_Comment,...
                        ind_base,'repeat(',ClkDelay,') begin\n',...
                        ind_lvl{1},'@(negedge dutvif.clk)\n',...
                        char(join(cellfun(@(x,y,sz)l_get_mon_sig(x,y,sz,ind_lvl{2},IsScalarizePortsEnabled),...
                        scrin,dutout,dutoutsz,'UniformOutput',false),'')),...
                        ind_base,'end\n'];
                    else
                        str=[Mon_inp_Comment,...
                        ind_base,'repeat(',ClkDelay,') begin\n',...
                        ind_lvl{1},'@(negedge dutvif.clk)\n',...
                        ind_lvl{2},obj.call_dpi_fcns_id,'();\n',...
                        ind_base,'end\n'];
                    end
                end
            end
        end



        function str=monitorsig_inp(obj,space_ind,monin,seqout,moninSZ,IsScalarizePortsEnabled,type)
            prefix='scritm';
            if strcmp(type,'predictor')
                prefix='preditm';
            end

            space=repmat(' ',1,space_ind);
            seqout_key=cellfun(@(x)l_getFirstElementOfCell(x),seqout,'UniformOutput',false);
            seqout_vif=cellfun(@(x)obj.vif_handle.SeqIdMap(x),seqout_key,'UniformOutput',false);
            str=char(join(cellfun(@(x,y,sz)n_monitorsig_inp(x,y,sz,space,IsScalarizePortsEnabled),monin,seqout_vif,moninSZ,'UniformOutput',false),''));
            if~isempty(str)
                str=extractAfter(str,space_ind);
            end
            function n_str=n_monitorsig_inp(x,y,sz,space,IsScalarizePortsEnabled)
                if sz>1&&IsScalarizePortsEnabled
                    n_str='';
                    for idx2=1:sz
                        if iscell(x)
                            n_str=sprintf('%s%s%s.%s = dutvif.%s;\n',n_str,space,prefix,x{idx2},y{idx2});
                        else
                            n_str=sprintf('%s%s%s.%s_%d = dutvif.%s_%d;\n',n_str,space,prefix,x,idx2-1,y,idx2-1);
                        end
                    end
                else
                    n_str=sprintf('%s%s.%s = dutvif.%s;\n',space,prefix,x,y);
                end
            end
        end

        function str=delay_ap_wr_inp(obj,space_ind,seqoutToPred,predin,predinSZ,seqoutToScr,scrinFromMonInp,scrinFromMonInpSZ,IsScalarizePortsEnabled)
            if obj.MonMode==uvmcodegen.ConvertorMode.PT
                str='';
            else
                ClkDelay=obj.getClkCyclesDelay();
                if str2double(ClkDelay)==0
                    str='';
                else
                    [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,3);
                    Mon_inp_Comment='//Sample VIF but do not write to AP\n';
                    assign_vif2pred='';
                    assign_vif2scrFromMonInp='';
                    if~isempty(seqoutToPred)
                        assign_vif2pred=[ind_lvl{2},obj.monitorsig_inp(0,predin,seqoutToPred,predinSZ,IsScalarizePortsEnabled,'predictor')];
                    end
                    if~isempty(seqoutToScr)
                        assign_vif2scrFromMonInp=[ind_lvl{2},obj.monitorsig_inp(0,scrinFromMonInp,seqoutToScr,scrinFromMonInpSZ,IsScalarizePortsEnabled,'scoreboard')];
                    end
                    str=[Mon_inp_Comment,...
                    ind_base,'repeat(',ClkDelay,') begin\n',...
                    ind_lvl{1},'@(negedge dutvif.clk)\n',...
                    assign_vif2pred,...
                    assign_vif2scrFromMonInp,...
                    ind_base,'end\n'];

                end
            end
        end
    end

end

function str=l_get_mon_sig(scrinid,dutoutid,sz,space,IsScalarizePortsEnabled)
    if sz>1&&IsScalarizePortsEnabled
        str='';
        for idx=1:sz
            if iscell(scrinid)
                str=sprintf('%s%sseqitm.%s = dutvif.%s;\n',str,space,scrinid{idx},dutoutid{idx});
            else
                str=sprintf('%s%sseqitm.%s_%d = dutvif.%s_%d;\n',str,space,scrinid,idx-1,dutoutid,idx-1);
            end
        end
    else
        str=sprintf('%sseqitm.%s = dutvif.%s;\n',space,scrinid,dutoutid);
    end
end


function res=l_getFirstElementOfCell(id)
    if iscell(id)
        res=id{1};
    else
        res=id;
    end
end
