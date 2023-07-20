classdef(Hidden)uvm_driver<uvmcodegen.uvm_component


    properties(GetAccess=public,SetAccess=private)
        vif_handle;
        DrvMode uvmcodegen.ConvertorMode;
        DrvComp;
        FormatSequence={};
    end

    properties(Constant,Access=private)
        call_dpi_fcns_id='call_dpi_fcns';
    end

    methods
        function this=uvm_driver(varargin)

            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'vif_handle','');
            addParameter(p,'seq_handle','');
            addParameter(p,'dut_handle','');
            addParameter(p,'uvmcmp_name',[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.drv_suffix]);
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_drv_tmplt));
            addParameter(p,'DrvMode',uvmcodegen.ConvertorMode.PT);
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_type='uvm_driver';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;
            this.vif_handle=p.Results.vif_handle;
            this.DrvMode=p.Results.DrvMode;

            if this.DrvMode==uvmcodegen.ConvertorMode.DPISUB
                this.DrvComp='driver';
            else
                this.DrvComp='uvm_artifacts';
            end
            this.addSrc(p.Results.seq_handle);
            this.addDst(p.Results.dut_handle);
        end

        function str=prtuvmcmp(this)
            dpigenerator_disp(['Generating UVM driver ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);

            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);

            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();

            seq=this.sources{1};
            if isempty(this.mwpath)
                tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//',this.mwcfg.sldut_path,bdroot(this.mwcfg.sldut_path)));
            else
                tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//',this.mwpath,bdroot(this.mwpath)));
            end

            tpl=replace(tpl,'%IMPORTS%',this.get_DPI_import_pkg());
            tpl=replace(tpl,'%DRVNAME%',this.uvmcmp_name);
            tpl=replace(tpl,'%OBJHANDLE_DECL%',this.get_DPI_objhandle());
            if this.DrvMode==uvmcodegen.ConvertorMode.DPISUB
                tpl=replace(tpl,'%ASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionInfoStructDecl);
                tpl=replace(tpl,'%TSASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionInfoStructDecl);
            else
                tpl=replace(tpl,'%ASSERTION_STRUCT_INFO_DECL%','');
                tpl=replace(tpl,'%TSASSERTION_STRUCT_INFO_DECL%','');
            end
            tpl=replace(tpl,'%INFNAME%',this.vif_handle.sv_ifnam);
            tpl=replace(tpl,'%TEMP_VAR_DECL%',this.drv_tmp_var_decl(this.getSpaceIndentation(tpl,'%TEMP_VAR_DECL%'),IsScalarizePortsEnabled));
            tpl=replace(tpl,'%DPI_INIT%',this.dpi_inits());
            tpl=replace(tpl,'%DPI_TERM%',this.dpi_term());
            tpl=replace(tpl,'%CALL_DPI_FCNS%',this.call_dpi_fcns(this.getSpaceIndentation(tpl,'%CALL_DPI_FCNS%'),IsScalarizePortsEnabled,false));
            tpl=replace(tpl,'%REPORT%',this.report_phase(this.getSpaceIndentation(tpl,'%REPORT%')));



            [seqout_by_pred,~,~,~,seqout_by_pred_sz]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('predictor');
            [seqout_by_scr,~,~,~,seqout_by_scr_sz]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('scoreboard');


            seqout_by_pred_key=cellfun(@(x)getFirstElementOfCell(x),seqout_by_pred,'UniformOutput',false);
            seqout_by_scr_key=cellfun(@(x)getFirstElementOfCell(x),seqout_by_scr,'UniformOutput',false);


            [unique_seqout_by_key,unique_seqout_by_idx]=unique([seqout_by_pred_key,seqout_by_scr_key]);
            seqout_by=[seqout_by_pred,seqout_by_scr];
            seqout_by_sz=[seqout_by_pred_sz,seqout_by_scr_sz];
            unique_seqout_by=seqout_by(unique_seqout_by_idx);
            unique_seqout_by_sz=seqout_by_sz(unique_seqout_by_idx);
            function res=getFirstElementOfCell(id)
                if iscell(id)
                    res=id{1};
                else
                    res=id;
                end
            end
            bypassSpace=repmat(' ',1,this.getSpaceIndentation(tpl,'%BYPASSSIG%'));
            seqout_by_vif=cellfun(@(x)this.vif_handle.SeqIdMap(x),unique_seqout_by_key,'UniformOutput',false);

            BYPASSSIG=sprintf(char(join(cellfun(@(x,y,sz)l_get_drv_sig(x,y,sz,bypassSpace,IsScalarizePortsEnabled),seqout_by_vif,unique_seqout_by,unique_seqout_by_sz,'UniformOutput',false),...
            '')));
            if~isempty(BYPASSSIG)
                BYPASSSIG=extractAfter(BYPASSSIG,this.getSpaceIndentation(tpl,'%BYPASSSIG%'));
            end
            tpl=replace(tpl,'%SEQITM%',seq.uvmobj_name);
            tpl=replace(tpl,'%BYPASSSIG%',BYPASSSIG);
            tpl=replace(tpl,'%DRIVESIG%',this.drivesig(this.getSpaceIndentation(tpl,'%DRIVESIG%'),IsScalarizePortsEnabled));

            if hdlverifierfeature('TRANSACTION_RECORDING')
                tpl=replace(tpl,'%TRANSREC_START%',sprintf('void''(this.begin_tr(req, "mwdrvtrans"));'));
                tpl=replace(tpl,'%TRANSREC_STOP%',sprintf('@(negedge dutvif.clk);\n                this.end_tr(req);\n'));
            else
                tpl=replace(tpl,'%TRANSREC_START%','');
                tpl=replace(tpl,'%TRANSREC_STOP%','');
            end

            this.FormatSequence=this.StrFormatting(tpl);
            str=tpl;
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths(obj.DrvComp),[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,drvdir,~]=fileparts(obj.ucfg.component_paths(obj.DrvComp));
            str=obj.replaceBackS(fullfile('..',drvdir,[obj.uvmcmp_name,'.sv']));
        end

    end


    methods(Access=private)
        function str=get_DPI_import_pkg(obj)
            if obj.DrvMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
            else
                str=sprintf('import %s::*;\n',obj.mwcfg.sl2uvmtopo.getPackageNameSpace('drv'));
            end
        end

        function str=get_DPI_objhandle(obj)
            if obj.DrvMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
            else
                str='chandle objhandle;\n';
            end
        end

        function str=dpi_inits(obj)
            if obj.DrvMode~=uvmcodegen.ConvertorMode.DPISUB
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
            if obj.DrvMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
            else
                str=[obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TerminateFunction.FunctionName{1},'(',...
                obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TerminateFunction.ArgumentIdentifiers{1},...
                ');\n'];
            end
        end

        function str=call_dpi_fcns(obj,space_ind,IsScalarizePortsEnabled,tem2vif)
            if obj.DrvMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
                return;
            end


            [seqout,drvin,drvout,dutin,~,drvinsz,drvoutsz,dutinsz]=obj.mwcfg.sl2uvmtopo.getDriverConnectionSigId();
            objh_id=obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(1);
            input_arglist=[sprintf('.%s(%s)',objh_id{1},objh_id{1}),...
            char(join(cellfun(@(drv_in_id,seqout_id,sz)n_get_drv_dpi_args('input',drv_in_id,seqout_id,sz),drvin,seqout,drvinsz,'UniformOutput',false)))];
            output_arglist=char(join(cellfun(@(drv_out_id,sz)n_get_drv_dpi_args('output',drv_out_id,drv_out_id,sz),drvout,drvoutsz,'UniformOutput',false)));
            output_tmp2vif_assign=char(join(cellfun(@(dut_vif,drv_out_id,sz)n_get_drv_dpi_args('output_temp',dut_vif,drv_out_id,sz),...
            dutin,drvout,dutinsz,'UniformOutput',false),''));
            function n_str=n_get_drv_dpi_args(type,leftId,rightId,sz)
                n_str='';
                switch type
                case 'input'
                    if sz>1&&IsScalarizePortsEnabled
                        for idx1=1:sz
                            if iscell(leftId)
                                n_str=sprintf('%s,.%s(req.%s)',n_str,leftId{idx1},rightId{idx1});
                            else
                                n_str=sprintf('%s,.%s_%d(req.%s_%d)',n_str,leftId,idx1-1,rightId,idx1-1);
                            end
                        end
                    else
                        n_str=sprintf(',.%s(req.%s)',leftId,rightId);
                    end
                case 'output'
                    if sz>1&&IsScalarizePortsEnabled
                        for idx2=1:sz
                            if iscell(leftId)
                                n_str=sprintf('%s,.%s(%s)',n_str,leftId{idx2},rightId{idx2});
                            else
                                n_str=sprintf('%s,.%s_%d(%s_%d)',n_str,leftId,idx2-1,rightId,idx2-1);
                            end
                        end
                    else
                        n_str=sprintf(',.%s(%s)',leftId,rightId);
                    end
                case 'output_temp'
                    if sz>1&&IsScalarizePortsEnabled
                        for idx3=1:sz
                            if iscell(leftId)
                                n_str=sprintf('%s%sdutvif.%s<=%s;\n',n_str,repmat(' ',1,space_ind),leftId{idx3},rightId{idx3});
                            else
                                n_str=sprintf('%s%sdutvif.%s_%d<=%s_%d;\n',n_str,repmat(' ',1,space_ind),leftId,idx3-1,rightId,idx3-1);
                            end
                        end
                    else
                        n_str=sprintf('%sdutvif.%s<=%s;\n',repmat(' ',1,space_ind),leftId,rightId);
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


            if tem2vif
                str=output_tmp2vif_assign;
            else
                str=['//Call DPI component\n',...
                repmat(' ',1,space_ind),sprintf('%s(%s%s);',obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.FunctionName{1},input_arglist,output_arglist),'\n',...
                repmat(' ',1,space_ind),sprintf('%s(%s);',obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.FunctionName{1},input_arglist),'\n',...
                err_action];
            end
        end

        function str=report_phase(this,SpaceIndentation)
            str='';
            if this.DrvMode==uvmcodegen.ConvertorMode.DPISUB&&this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                str=sprintf('\n%s%s',str,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSVerifyInfoReporting);
            end
        end

        function str=drv_tmp_var_decl(obj,space_ind,IsScalarizePortsEnabled)
            if obj.DrvMode~=uvmcodegen.ConvertorMode.DPISUB
                str='';
                return;
            end

            [Drvportdir,DrvportsSVDT,DrvportSz,DrvportsID]=obj.mwcfg.sl2uvmtopo.getDrvIfInfo();
            outportLA=strcmp(Drvportdir,'output');
            str=['//Temporary variables to hold DPI output results\n',...
            char(join(cellfun(@(dt,sz,id)n_gen_drv_tmp_decl(dt,sz,id),...
            DrvportsSVDT(outportLA),...
            DrvportSz(outportLA),...
            DrvportsID(outportLA),...
            'UniformOutput',false),''))];

            function n_tmp_dec_str=n_gen_drv_tmp_decl(n_dt,n_sz,n_id)
                if n_sz>1
                    if IsScalarizePortsEnabled
                        n_tmp_dec_str='';
                        for idx4=1:n_sz
                            if iscell(n_id)
                                n_tmp_dec_str=sprintf('%s%s%s %s;\n',n_tmp_dec_str,repmat(' ',1,space_ind),n_dt,n_id{idx4});
                            else
                                n_tmp_dec_str=sprintf('%s%s%s %s_%d;\n',n_tmp_dec_str,repmat(' ',1,space_ind),n_dt,n_id,idx4-1);
                            end
                        end
                    else
                        n_tmp_dec_str=[repmat(' ',1,space_ind),sprintf('%s %s [%d];',n_dt,n_id,n_sz),'\n'];
                    end
                else
                    n_tmp_dec_str=[repmat(' ',1,space_ind),sprintf('%s %s;',n_dt,n_id),'\n'];
                end

            end
        end

        function str=drivesig(obj,space_ind,IsScalarizePortsEnabled)
            space=repmat(' ',1,space_ind);
            if obj.DrvMode~=uvmcodegen.ConvertorMode.DPISUB
                [seqout,~,~,dutin,~,~,~,dutinsz]=obj.mwcfg.sl2uvmtopo.getDriverConnectionSigId();
                if obj.DrvMode==uvmcodegen.ConvertorMode.PT
                    DrvComment='//Passthrough driver\n';
                    str=[DrvComment,...
                    char(join(cellfun(@(x,y,sz)l_get_drv_sig(x,y,sz,space,IsScalarizePortsEnabled),dutin,seqout,dutinsz,'UniformOutput',false),''))];
                else
                    DrvComment='//Passthrough driver with delay\n';
                    str=[DrvComment,...
                    char(join(cellfun(@(x,y,sz)l_get_drv_sig(x,y,sz,space,IsScalarizePortsEnabled),dutin,seqout,dutinsz,'UniformOutput',false),'')),...
                    obj.seqit_delay(space_ind,seqout,dutin,dutinsz,IsScalarizePortsEnabled)];
                end
            else
                DrvComment='//Drive vif signals by calling DPI component\n';
                str=[DrvComment,...
                space,obj.call_dpi_fcns_id,'();\n',...
                obj.call_dpi_fcns(space_ind,IsScalarizePortsEnabled,true),...
                obj.seqit_delay(space_ind,{},{},{},IsScalarizePortsEnabled)];
            end
        end

        function str=seqit_delay(obj,space_ind,seqout,dutin,dutinsz,IsScalarizePortsEnabled)



            assert(obj.DrvMode~=uvmcodegen.ConvertorMode.PT,'schedule dpi calls is being called withouth a driver');
            [ind_base,ind_lvl,num_ind_lvl]=obj.getIndentationLevels(space_ind,3);
            ClkDelay=obj.getClkCyclesDelay();
            if str2double(ClkDelay)==0
                str='';
            else
                if obj.DrvMode==uvmcodegen.ConvertorMode.DPISUB
                    str=[ind_base,'repeat(',ClkDelay,') begin\n',...
                    ind_lvl{1},'@(negedge dutvif.clk)\n',...
                    ind_lvl{2},obj.call_dpi_fcns_id,'();\n',...
                    obj.call_dpi_fcns(num_ind_lvl{2},IsScalarizePortsEnabled,true),...
                    ind_base,'end\n'];
                else
                    str=[ind_base,'repeat(',ClkDelay,') begin\n',...
                    ind_lvl{1},'@(negedge dutvif.clk)\n',...
                    char(join(cellfun(@(x,y,sz)l_get_drv_sig(x,y,sz,ind_lvl{2},IsScalarizePortsEnabled),dutin,seqout,dutinsz,'UniformOutput',false),'')),...
                    ind_base,'end\n'];
                end
            end
        end
    end
end


function str=l_get_drv_sig(dutinid,seqoutid,sz,space,IsScalarizePortsEnabled)
    if sz>1&&IsScalarizePortsEnabled
        str='';
        for idx=1:sz
            if iscell(dutinid)
                str=sprintf('%s%sdutvif.%s <= req.%s;\n',str,space,dutinid{idx},seqoutid{idx});
            else
                str=sprintf('%s%sdutvif.%s_%d <= req.%s_%d;\n',str,space,dutinid,idx-1,seqoutid,idx-1);
            end
        end
    else
        str=sprintf('%sdutvif.%s <= req.%s;\n',space,dutinid,seqoutid);
    end
end
