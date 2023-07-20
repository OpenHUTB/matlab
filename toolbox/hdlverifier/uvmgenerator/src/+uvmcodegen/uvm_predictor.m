classdef(Hidden)uvm_predictor<uvmcodegen.uvm_component

    methods(Access=private)
        function str=sequence_items(this,SpaceInd)
            str='';
            if~isempty(this.sources)
                str=sprintf('%s preditm;\n',this.uvmobj_name);
                str=sprintf('%s%s%s scritm;\n',str,repmat(' ',1,SpaceInd),this.sources{1}.dut_handle.uvmobj_name);
            end
        end

        function str=fifos(this,~)
            str='';
            if~isempty(this.sources)
                str=sprintf('uvm_tlm_analysis_fifo  #(%s) %s_fifo;\n',this.uvmobj_name,this.uvmcmp_name);
            end
        end

        function str=ports(this,SpaceInd)
            str='';




            if~isempty(this.sources)
                analysis_export=sprintf('uvm_analysis_export   #(%s) aexp;\n',this.uvmobj_name);
                analysis_port=sprintf('uvm_analysis_port   #(%s) ap;\n',this.sources{1}.dut_handle.uvmobj_name);
                str=sprintf('%s%s%s',analysis_export,repmat(' ',1,SpaceInd),analysis_port);
            end
        end

        function str=build_phase(this,SpaceInd)

            str='';

            if~isempty(this.sources)
                build_trans=sprintf('preditm = new ("preditm");\n');
                build_get=sprintf([repmat(' ',1,SpaceInd),'aexp = new ("aexp",this);\n']);
                build_fifo=sprintf([repmat(' ',1,SpaceInd),'%s_fifo = new ("%s_fifo",this);\n'],this.uvmcmp_name,this.uvmcmp_name);
                build_put=sprintf([repmat(' ',1,SpaceInd),'ap = new ("ap",this);\n']);
                str=sprintf('%s%s%s%s',build_trans,build_get,build_fifo,build_put);
            end

        end

        function str=connect_phase(this)
            str='';
            if~isempty(this.sources)
                str=sprintf('aexp.connect (%s_fifo.analysis_export);\n',this.uvmcmp_name);
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

        function str=run_phase(this,SpaceIndentation,IsScalarizePortsEnabled)

            str='';
            err_action='';

            [~,predin,predinSZ]=this.get_pred_ports('input');
            [~,predout,predoutSZ]=this.get_pred_ports('output');

            [~,~,predoutToScr,scrinFromPred,~,~,~,scrinFromPredSZ]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('predictor');
            space=repmat(' ',1,SpaceIndentation);
            seq2gld=this.mwcfg.sl2uvmtopo.Seq2GldConnection;

            function c_str=n_put_comments(seq2gld)
                if seq2gld
                    c_str='';
                else
                    c_str='//';
                end
            end

            function sub_sig=n_get_sub_sigid(sigid,type,seq2gld)
                if seq2gld
                    if strcmp(type,'input')
                        sub_sig=['preditm.',sigid];
                    else
                        sub_sig=[sigid,'_temp'];
                    end
                else
                    sub_sig='';
                end
            end


            function n_str=n_get_prd_fcn_sig(leftsigid,rightsigid,leftsigsz,type,seq2gld)
                if leftsigsz>1&&IsScalarizePortsEnabled
                    n_str='';
                    for idx_1=1:leftsigsz
                        if iscell(leftsigid)
                            n_str=sprintf('%s,.%s(%s)',n_str,leftsigid{idx_1},n_get_sub_sigid(rightsigid{idx_1},type,seq2gld));
                        else
                            n_str=sprintf('%s,.%s_%d(%s)',n_str,leftsigid,idx_1-1,...
                            n_get_sub_sigid([rightsigid,'_',num2str(idx_1-1)],type,seq2gld));
                        end
                    end
                else
                    n_str=sprintf(',.%s(%s)',leftsigid,n_get_sub_sigid(rightsigid,type,seq2gld));
                end
            end
            function n_str=n_get_tempPredout2scr_assign(leftsig,rightsig,leftsigsz)
                if leftsigsz>1&&IsScalarizePortsEnabled
                    n_str='';
                    for idx_2=1:leftsigsz
                        if iscell(leftsig)
                            n_str=sprintf(['%s',space,'scritm.%s=%s_temp;\n'],...
                            n_str,leftsig{idx_2},rightsig{idx_2});
                        else
                            n_str=sprintf(['%s',space,'scritm.%s_%d=%s_%d_temp;\n'],...
                            n_str,leftsig,idx_2-1,rightsig,idx_2-1);
                        end
                    end
                else
                    n_str=sprintf([space,'scritm.%s=%s_temp;\n'],leftsig,rightsig);
                end
            end

            if~isempty(this.sources)




                outputfcn_args=char(join([this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(1),...
                cellfun(@(x,y,sz)n_get_prd_fcn_sig(x,y,sz,'input',seq2gld),predin,predin,predinSZ,'UniformOutput',false),...
                cellfun(@(x,y,sz)n_get_prd_fcn_sig(x,y,sz,'output',seq2gld),predout,predout,predoutSZ,'UniformOutput',false)]));

                updatefcn_args=char(join([this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.ArgumentIdentifiers(1),...
                cellfun(@(x,y,sz)n_get_prd_fcn_sig(x,y,sz,'input',seq2gld),predin,predin,predinSZ,'UniformOutput',false)]));

                dpi_assign=[space,'//Assign DPI output temporary variables to scoreboard trans\n'];
                if this.mwcfg.sl2uvmtopo.Gld2ScrConnection
                    dpi_assign=[dpi_assign,char(join(cellfun(@(x,y,sz)n_get_tempPredout2scr_assign(x,y,sz),scrinFromPred,predoutToScr,scrinFromPredSZ,'UniformOutput',false),''))];
                end

                get_seqitm=sprintf('%s_fifo.get_export.get (preditm);\n',this.uvmcmp_name);

                create_scritm=sprintf([space,'scritm = %s::type_id::create("pred2scrTrans",this);\n'],this.sources{1}.dut_handle.uvmobj_name);

                dpi_output=sprintf([space,'//Call DPI component\n',space,'%s%s(%s);\n'],n_put_comments(seq2gld),...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.FunctionName{1},...
                outputfcn_args);

                dpi_update=sprintf([space,'%s%s(%s);\n'],n_put_comments(seq2gld),...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.FunctionName{1},...
                updatefcn_args);

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
                err_action=sprintf(char(join(cellfun(@(x)[space,x,'\n'],err_action_ca,'UniformOutput',false),'')),tmp_f{:});

                write_scritm=sprintf([space,'//Send scoreboard trans to predictor analysis port\n'...
                ,space,'ap.write (scritm);\n']);

                str=[get_seqitm,create_scritm,dpi_output,dpi_update,reportRunTimeErrStr,err_action,dpi_assign,write_scritm];
            end

        end

        function str=report_phase(this,~)
            str='';
            if this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                str=sprintf('\n%s%s',str,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSVerifyInfoReporting);
            end
        end

    end

    methods
        function this=uvm_predictor(varargin)

            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'uvmcmp_name',replace([this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.gld_suffix],newline,''));
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_gld_tmplt));
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_type='uvm_predictor';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;

            dut_handle=this.sources{1}.dut_handle;
            this.uvmobj_name=[dut_handle.ucfg.prefix,dut_handle.mwblkname,dut_handle.ucfg.gld_suffix,dut_handle.ucfg.obj_suffix];
            this.uvmobj_type=this.sources{1}.dut_handle.uvmobj_type;

            if this.IsPredObjPresent()
                this.sources{1}.addPred(this);
            end
        end

        function IsPredPresent=IsPredObjPresent(obj)
            IsPredPresent=~isempty(obj.mwblkUVMVCodeInfo);
        end

        function str=prtuvmcmp(this)
            dpigenerator_disp(['Generating UVM Reference Model ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);

            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);

            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//',this.mwpath,bdroot(this.mwpath)));
            tpl=replace(tpl,'%IMPORTS%',sprintf('import %s::*;\n',this.mwcfg.sl2uvmtopo.getPackageNameSpace('gld')));
            tpl=replace(tpl,'%PREDNAME%',this.uvmcmp_name);
            tpl=replace(tpl,'%RUNTIME_ERROR_VAR_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.ReturnValDecl);
            tpl=replace(tpl,'%ASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionInfoStructDecl);
            tpl=replace(tpl,'%TSASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionInfoStructDecl);
            tpl=replace(tpl,'%PREDITMS%',this.sequence_items(this.getSpaceIndentation(tpl,'%PREDITMS%')));
            tpl=replace(tpl,'%FIFOS%',this.fifos(this.getSpaceIndentation(tpl,'%FIFOS%')));
            tpl=replace(tpl,'%PORTS%',this.ports(this.getSpaceIndentation(tpl,'%PORTS%')));
            tpl=replace(tpl,'%BUILD%',this.build_phase(this.getSpaceIndentation(tpl,'%BUILD%')));
            tpl=replace(tpl,'%CONNECT%',this.connect_phase);
            tpl=replace(tpl,'%DPI_INIT%',this.dpi_inits());
            tpl=replace(tpl,'%TEMPOUTDELC%',this.predout_sig_tempdecl(this.getSpaceIndentation(tpl,'%TEMPOUTDELC%'),IsScalarizePortsEnabled));
            tpl=replace(tpl,'%RUN%',this.run_phase(this.getSpaceIndentation(tpl,'%RUN%'),IsScalarizePortsEnabled));
            tpl=replace(tpl,'%DPI_TERM%',this.dpi_term());
            tpl=replace(tpl,'%REPORT%',this.report_phase(this.getSpaceIndentation(tpl,'%REPORT%')));
            str=tpl;
        end


        function string=prtuvmobj(this)

            dpigenerator_disp(['Generating UVM transaction object ',dpigenerator_getfilelink(this.get_uvmobj_name_fileLoc())]);
            fid=fopen(this.uvmobj_tmplt,'rt');
            tpl=fscanf(fid,'%c');
            fclose(fid);
            tpl=mw_findreplace(tpl);
            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();
            [dec,mac]=this.uvmobj_dec_pred_input(IsScalarizePortsEnabled);

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmobj_name_fileLoc(),'//',this.mwpath,bdroot(this.mwpath)));
            tpl=replace(tpl,'%IMPORT_COMMON_TYPES_PKG%','');
            tpl=replace(tpl,'%CLASSNAME%',this.uvmobj_name);
            tpl=replace(tpl,'%CLASSTYPE%',this.uvmobj_type);
            tpl=replace(tpl,'%DECLARATIONS%',dec);
            tpl=replace(tpl,'%FIELDMACROS%',mac);
            string=tpl;
        end


        function[st,mac]=uvmobj_dec_pred_input(this,IsScalarizePortsEnabled)

            [inportsSVDT,inportsID,inportsSz]=this.get_pred_ports('input');
            st='';
            st=[st,sprintf('   // Predictor Inputs\n')];
            mac=sprintf('   `uvm_object_utils_begin(%s)\n',this.uvmobj_name);
            for n=1:length(inportsSVDT)
                if any(strcmp(inportsSVDT{n},{'real','shortreal'}))
                    RandQualifier='';
                else
                    RandQualifier='rand';
                end
                curInportsID=inportsID{n};
                if inportsSz{n}>1
                    if IsScalarizePortsEnabled
                        for idx_3=1:inportsSz{n}
                            if iscell(curInportsID)
                                st=[st,sprintf('   %s %s %s ;\n',RandQualifier,inportsSVDT{n},curInportsID{idx_3})];%#ok<AGROW>
                                mac=this.uvmobj_macro(mac,curInportsID{idx_3},inportsSVDT{n},inportsSz{n});
                            else
                                st=[st,sprintf('   %s %s %s_%d ;\n',RandQualifier,inportsSVDT{n},curInportsID,idx_3-1)];%#ok<AGROW>
                                mac=this.uvmobj_macro(mac,sprintf('%s_%d',curInportsID,idx_3-1),inportsSVDT{n},inportsSz{n});
                            end
                        end
                    else
                        st=[st,sprintf('   %s %s %s [%d] ;\n',RandQualifier,inportsSVDT{n},curInportsID,inportsSz{n})];%#ok<AGROW>
                        mac=this.uvmobj_macro(mac,curInportsID,inportsSVDT{n},inportsSz{n});
                    end
                else
                    st=[st,sprintf('   %s %s %s;\n',RandQualifier,inportsSVDT{n},curInportsID)];%#ok<AGROW>
                    mac=this.uvmobj_macro(mac,curInportsID,inportsSVDT{n},inportsSz{n});
                end
            end
            mac=[mac,'  `uvm_object_utils_end'];

        end


        function[portsSVDT,portsID,portsSZ]=get_pred_ports(this,type)
            [Predportsdir,PredportsSVDT,PredportsSz,PredportsID]=this.mwcfg.sl2uvmtopo.getGldIfInfo();
            portLA=strcmp(Predportsdir,type);
            portsSVDT=PredportsSVDT(portLA);
            portsSZ=PredportsSz(portLA);
            portsID=PredportsID(portLA);
        end

        function str=predout_sig_tempdecl(this,SpaceIndentation,IsScalarizePortsEnabled)
            space=repmat(' ',1,SpaceIndentation);
            [predoutDT,predout,predoutSZ]=this.get_pred_ports('output');
            str='//Temporary variables to hold DPI output results\n';
            str=[str,char(join(cellfun(@(dt,id,sz)n_predout_tmpdecl(dt,id,sz,space,IsScalarizePortsEnabled),predoutDT,predout,predoutSZ,'UniformOutput',false),''))];
            function n_str=n_predout_tmpdecl(dt,id,sz,space,IsScalarizePortsEnabled)
                if sz==1
                    n_str=sprintf('%s%s %s_temp;\n',space,dt,id);
                else
                    if IsScalarizePortsEnabled
                        n_str='';
                        for idx1=1:sz
                            if iscell(id)
                                n_str=sprintf('%s%s%s %s_temp;\n',n_str,space,dt,id{idx1});
                            else
                                n_str=sprintf('%s%s%s %s_%d_temp;\n',n_str,space,dt,id,idx1-1);
                            end
                        end
                    else
                        n_str=sprintf('%s%s %s_temp [%d];\n',space,dt,id,sz);
                    end
                end
            end
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('predictor'),[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,preddir,~]=fileparts(obj.ucfg.component_paths('predictor'));
            str=obj.replaceBackS(fullfile('..',preddir,[obj.uvmcmp_name,'.sv']));
        end

        function str=get_uvmobj_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('predictor'),[obj.uvmobj_name,'.sv']));
        end

        function str=get_uvmobj_name_fileRelLoc(obj)
            [~,preddir,~]=fileparts(obj.ucfg.component_paths('predictor'));
            str=obj.replaceBackS(fullfile('..',preddir,[obj.uvmobj_name,'.sv']));
        end

    end
end

