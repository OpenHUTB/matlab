classdef(Hidden)uvm_sequence<uvmcodegen.uvm_component

    properties
        uvmsqr_name;
        FormatSequence={};
    end

    properties(Access=private,Constant)
        rnd_result='rnd_result'
        TempSeqInputVarPostFix='_default_inp_val'
    end

    methods(Access=private)
        function str=input_var_decl(this,space_ind,OutputFcnStruct,IsScalarizePortsEnabled)
            if isempty(OutputFcnStruct.ArgumentValues)

                def_inp_tmp_var_decl='';
            else
                NumOfInputs=numel(OutputFcnStruct.ArgumentValues)-1;
                def_inp_tmp_var_decl=char(join(cellfun(@(dt,sz,id,val)n_gen_decl(dt,sz,id,val),OutputFcnStruct.ArgumentTypes(2:NumOfInputs+1),...
                OutputFcnStruct.ArgumentSizes(2:NumOfInputs+1),...
                OutputFcnStruct.ArgumentIdentifiers(2:NumOfInputs+1),...
                OutputFcnStruct.ArgumentValues(2:NumOfInputs+1),...
                'UniformOutput',false),''));
                if~isempty(def_inp_tmp_var_decl)

                    def_inp_tmp_var_decl=['//Sequence inputs default value (Min) variable holder\n',...
                    def_inp_tmp_var_decl];
                end
            end

            function n_tmp_inp_dec_str=n_gen_decl(n_dt,n_sz,n_id,n_v)
                n_tmp_inp_dec_str='';
                if~any(strcmp(n_dt,{'real','shortreal'}))&&~isempty(n_v)


                    if n_sz>1
                        if IsScalarizePortsEnabled
                            for idx2=1:n_sz
                                if iscell(n_id)
                                    n_tmp_inp_dec_str=sprintf('%s%s%s %s%s;\n',n_tmp_inp_dec_str,repmat(' ',1,space_ind),n_dt,n_id{idx2},this.TempSeqInputVarPostFix);
                                else
                                    n_tmp_inp_dec_str=sprintf('%s%s%s %s_%d%s;\n',n_tmp_inp_dec_str,repmat(' ',1,space_ind),n_dt,n_id,idx2-1,this.TempSeqInputVarPostFix);
                                end
                            end
                        else
                            n_tmp_inp_dec_str=[repmat(' ',1,space_ind),sprintf('%s %s%s [%d];',n_dt,n_id,this.TempSeqInputVarPostFix,n_sz),'\n'];
                        end
                    else
                        n_tmp_inp_dec_str=[repmat(' ',1,space_ind),sprintf('%s %s%s;',n_dt,n_id,this.TempSeqInputVarPostFix),'\n'];
                    end
                end
            end


            [Seqportdir,SeqportsSVDT,SeqportSz,SeqportsID]=this.mwcfg.sl2uvmtopo.getSeqIfInfo();

            inportLA=strcmp(Seqportdir,'input');
            inportsSVDT=SeqportsSVDT(inportLA);
            inportSz=SeqportSz(inportLA);
            inportsID=SeqportsID(inportLA);
            if isempty(def_inp_tmp_var_decl)
                str='';
                str=[str,sprintf('// Sequence inputs\n')];
            else
                str=def_inp_tmp_var_decl;
                str=[str,sprintf([repmat(' ',1,space_ind),'// Sequence inputs\n'])];
            end

            for n=1:length(inportsSVDT)
                if any(strcmp(inportsSVDT{n},{'real','shortreal'}))
                    RandQualifier='';
                else
                    RandQualifier='rand';
                end

                curInportsID=inportsID{n};
                if inportSz{n}>1
                    if IsScalarizePortsEnabled
                        for idx3=1:inportSz{n}
                            if iscell(curInportsID)
                                str=sprintf('%s%s%s %s %s;\n',str,repmat(' ',1,space_ind),RandQualifier,inportsSVDT{n},curInportsID{idx3});
                            else
                                str=sprintf('%s%s%s %s %s_%d;\n',str,repmat(' ',1,space_ind),RandQualifier,inportsSVDT{n},curInportsID,idx3-1);
                            end
                        end
                    else
                        str=[str,sprintf([repmat(' ',1,space_ind),'%s %s %s [%d];\n'],RandQualifier,inportsSVDT{n},curInportsID,inportSz{n})];%#ok<AGROW>
                    end
                else
                    str=[str,sprintf([repmat(' ',1,space_ind),'%s %s %s;\n'],RandQualifier,inportsSVDT{n},curInportsID)];%#ok<AGROW>
                end
            end
        end




        function str=input_def_val_set(obj,space_ind,OutputFcnStruct)
            if isempty(OutputFcnStruct.ArgumentValues)

                str='';
                return;
            end

            NumOfInputs=numel(OutputFcnStruct.ArgumentValues)-1;
            str=['//Allow plusargs for sequence input ports\n',...
            char(join(cellfun(@(id,dt,v)n_pargs_inp_assign(id,dt,v),OutputFcnStruct.ArgumentIdentifiers(2:NumOfInputs+1),...
            OutputFcnStruct.ArgumentTypes(2:NumOfInputs+1),...
            OutputFcnStruct.ArgumentValues(2:NumOfInputs+1),...
            'UniformOutput',false),''))];



            TmpFormatSequence=cellfun(@(dt,v)n_get_fmt(dt,v),OutputFcnStruct.ArgumentTypes(2:NumOfInputs+1),...
            OutputFcnStruct.ArgumentValues(2:NumOfInputs+1),...
            'UniformOutput',false);

            obj.FormatSequence=TmpFormatSequence(~strcmp('',TmpFormatSequence));


            function n_str=n_pargs_inp_assign(n_id,n_dt,n_v)
                n_str='';
                if~any(strcmp(n_dt,{'real','shortreal'}))&&~isempty(n_v)
                    n_str=[repmat(' ',1,space_ind),'if(!$value$plusargs("',n_id,obj.TempSeqInputVarPostFix,'=%s",',n_id,obj.TempSeqInputVarPostFix,'))begin\n',...
                    repmat(' ',1,space_ind+3),n_id,obj.TempSeqInputVarPostFix,'=',obj.getSVDefLiteral(n_dt,n_v),';\n',...
                    repmat(' ',1,space_ind),'end\n'];

                end
            end

            function n_fmt=n_get_fmt(n_dt,n_v)
                n_fmt='';
                if~any(strcmp(n_dt,{'real','shortreal'}))&&~isempty(n_v)
                    if isa(n_v,'embedded.fi')&&n_v.FractionLength~=0
                        n_fmt='%b';
                    else
                        n_fmt='%h';
                    end
                end
            end
        end

        function str=input_def_val(obj,space_ind,OutputFcnStruct)
            if isempty(OutputFcnStruct.ArgumentValues)

                str='';
                return;
            end
            NumOfInputs=numel(OutputFcnStruct.ArgumentValues)-1;
            str=sprintf(['//Simulink sequence subsystem input default value (Min)\n',...
            repmat(' ',1,space_ind),'constraint %s{\n',...
            char(join(cellfun(@(x,z,v)n_DirectTC4InpInt(x,z,v),OutputFcnStruct.ArgumentIdentifiers(2:NumOfInputs+1),...
            OutputFcnStruct.ArgumentTypes(2:NumOfInputs+1),...
            OutputFcnStruct.ArgumentValues(2:NumOfInputs+1),...
            'UniformOutput',false),'')),...
            repmat(' ',1,space_ind),'}\n'],[obj.uvmcmp_name,'_default_inp_val']);


            function n_str=n_DirectTC4InpInt(n_x,n_z,n_v)
                n_str='';
                if~any(strcmp(n_z,{'real','shortreal'}))&&~isempty(n_v)
                    n_str=[repmat(' ',1,space_ind+3),n_x,'==',n_x,obj.TempSeqInputVarPostFix,';\n'];
                end
            end
        end

        function str=input_rng_vals(obj,space_ind,OutputFcnStruct)
            if isempty(OutputFcnStruct.ArgumentRanges)

                str='';
                return;
            end
            NumOfInputs=numel(OutputFcnStruct.ArgumentRanges)-1;

            [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,1);
            str=sprintf(['//Simulink sequence subsystem input ranges\n',...
            ind_base,'constraint %s{\n',...
            char(join(cellfun(@(x,y,z,vals)obj.RangeCntr(x,y,z,vals,ind_lvl,'cntr_block'),OutputFcnStruct.ArgumentIdentifiers(2:NumOfInputs+1),...
            OutputFcnStruct.ArgumentRanges(2:end),...
            OutputFcnStruct.ArgumentTypes(2:NumOfInputs+1),...
            num2cell(zeros(1,numel(OutputFcnStruct.ArgumentValues(2:end)))),...
            'UniformOutput',false),'')),...
            ind_base,'}\n'],[obj.uvmcmp_name,'_inp_range_vals']);
        end



        function[st,mac]=uvmobj_dec(this)
            [Seqportdir,SeqportsSVDT,SeqportSz,SeqportsID]=this.mwcfg.sl2uvmtopo.getSeqIfInfo();
            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();


            outportLA=strcmp(Seqportdir,'output');
            outportSVDT=SeqportsSVDT(outportLA);
            outportSz=SeqportSz(outportLA);
            outportID=SeqportsID(outportLA);

            mac=sprintf('  `uvm_object_utils_begin(%s)\n',this.uvmobj_name);
            st=sprintf('\n   // Outputs\n');

            for n=1:length(outportSVDT)
                if any(strcmp(outportSVDT{n},{'real','shortreal'}))
                    RandQualifier='';
                else
                    RandQualifier='rand';
                end

                curOutportID=outportID{n};
                if outportSz{n}>1
                    if IsScalarizePortsEnabled
                        for idx1=1:outportSz{n}
                            if iscell(curOutportID)
                                st=[st,sprintf('   %s %s %s;\n',RandQualifier,outportSVDT{n},curOutportID{idx1})];%#ok<AGROW>
                                mac=this.uvmobj_macro(mac,curOutportID{idx1},outportSVDT{n},outportSz{n});
                            else
                                st=[st,sprintf('   %s %s %s_%d;\n',RandQualifier,outportSVDT{n},curOutportID,idx1-1)];%#ok<AGROW>
                                mac=this.uvmobj_macro(mac,sprintf('%s_%d',curOutportID,idx1-1),outportSVDT{n},outportSz{n});
                            end
                        end
                    else
                        st=[st,sprintf('   %s %s %s [%d];\n',RandQualifier,outportSVDT{n},curOutportID,outportSz{n})];%#ok<AGROW>
                        mac=this.uvmobj_macro(mac,curOutportID,outportSVDT{n},outportSz{n});
                    end
                else
                    st=[st,sprintf('   %s %s %s;\n',RandQualifier,outportSVDT{n},curOutportID)];%#ok<AGROW>
                    mac=this.uvmobj_macro(mac,curOutportID,outportSVDT{n},outportSz{n});
                end
            end

            mac=[mac,'  `uvm_object_utils_end'];

        end

        function[dec,cnt]=proc_srcs(this)
            dec='';
            cnt=[sprintf('   virtual function void connect_phase (uvm_phase phase);\n')];
            cnt=[cnt,sprintf('      super.connect_phase (phase);\n\n')];

            imp='';
            itm='';
            fifo='';
            sources=this.getAllSrcs();
            for n=1:length(sources)
                src=sources(n);
                imp=[imp,sprintf('   uvm_analysis_export #(%s) %s_imp;\n',this.uvmobj_name,get_param(src,'Name'))];
                itm=[itm,sprintf('   %s %s_itm;\n',this.uvmobj_name,get_param(src,'Name'))];
                fifo=[fifo,sprintf('   uvm_tlm_analysis_fifo #(%s) %s_fifo;\n',this.uvmobj_name,get_param(src,'Name'))];
                cnt=[cnt,sprintf('      %s_imp.connect (%s_fifo.analysis_export);\n',get_param(src,'Name'),get_param(src,'Name'))];
            end

            cnt=[cnt,sprintf('   endfunction // connect_phase\n')];
            dec=[imp,fifo,itm];

        end

        function str=prestart_phase(this,space_ind)

            [ind_base,ind_lvl]=this.getIndentationLevels(space_ind,3);

            str=['virtual task pre_start ();\n',...
            ind_lvl{1},sprintf('objhandle = %s(null);\n',this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.InitializeFunction.FunctionName{1})];

            if this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                str=sprintf('\n%s%s',str,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSVerifyInfoInstantiation);
            end
            str=[str,ind_base,'endtask // pre_start\n'];

        end

        function str=body_phase(this,space_ind)

            [ind_base,ind_lvl]=this.getIndentationLevels(space_ind,4);

            err_action='';

            if this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionPresent
                err_action=this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionQueryingSVCode;
            end

            if this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                err_action=sprintf('\n%s%s',err_action,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionQueryingSVCode);
            end

            stopSim='';
            if~isempty(this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMStopSimFcnInfo.FunctionName)
                stopSim=sprintf([ind_lvl{3},'if (%s(%s)) begin\n',ind_lvl{4},'this.kill();\n',ind_lvl{3},'end\n'],...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMStopSimFcnInfo.FunctionName,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMStopSimFcnInfo.ArgumentIdentifier);
            end
            tmp_f=split((repmat('%s ',1,count(err_action,'%s'))))';
            tmp_f=tmp_f(1:end-1);
            err_action_ca=split(err_action,newline);


            err_action=sprintf(char(join(cellfun(@(x)[repmat(' ',1,12),x,'\n'],err_action_ca,'UniformOutput',false),'')),tmp_f{:});


            str=sprintf('virtual task body ();\n');

            str=[str,sprintf([ind_lvl{1},'req = %s::type_id::create ("req");\n'],this.uvmobj_name)];

            NumberOfTransactions=this.getNumberOfTransactions();
            if isinf(NumberOfTransactions)
                str=[str,sprintf([ind_lvl{1},'//Run forever as Simulink has Inf stop time\n',...
                ind_lvl{1},'forever\n'],NumberOfTransactions)];
            else
                str=[str,sprintf([ind_lvl{1},'//Number of transactions based on Simulink stop time\n',...
                ind_lvl{1},'repeat(%d)\n'],NumberOfTransactions)];
            end
            str=[str,sprintf([ind_lvl{2},'begin\n'])];

            str=[str,sprintf([ind_lvl{3},'wait_for_grant ();\n'])];
            str=[str,stopSim];
            str=[str,sprintf([ind_lvl{3},'randomize_params();\n'])];
            str=[str,sprintf([ind_lvl{3},'call_dpi_fcns();\n'])];
            str=[str,err_action];
            str=[str,sprintf([ind_lvl{3},'send_request (req);\n'])];
            str=[str,sprintf([ind_lvl{3},'wait_for_item_done ();\n'])];
            str=[str,sprintf([ind_lvl{2},'end\n'])];



            if~isinf(NumberOfTransactions)
                str=[str,sprintf([ind_lvl{1},'repeat(1)\n'])];
                str=[str,sprintf([ind_lvl{2},'begin\n'])];
                str=[str,sprintf([ind_lvl{3},'start_item(req);\n'])];
                str=[str,sprintf([ind_lvl{3},'finish_item(req);\n'])];
                str=[str,sprintf([ind_lvl{2},'end\n'])];
            end
            str=[str,sprintf([ind_base,'endtask // body\n'])];
        end

        function str=post_body_phase(this,space_ind)

            [ind_base,ind_lvl]=this.getIndentationLevels(space_ind,2);
            vreport='';
            if this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionPresent
                vreport=[ind_lvl{1},this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSVerifyInfoReporting];
            end


            str=['virtual task post_body();\n',...
            vreport,...
            ind_lvl{1},this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TerminateFunction.FunctionName{1},'(',this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TerminateFunction.ArgumentIdentifiers{1},');\n',...
            ind_base,'endtask //post_body'];
        end



        function str=pre_randomize_override(obj,space_ind,TunPrmStruct)
            if isempty(TunPrmStruct.ArgumentIdentifiers)
                str='';
                return;
            end

            [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,1);
            str=sprintf(['function void pre_randomize();\n',...
            ind_lvl{1},'super.pre_randomize();\n',...
            ind_lvl{1},'//Initialize floating point parameters with default Simulink values\n',...
            char(join(cellfun(@(x,y,z)n_DirectTC4Fl(x,y,z),TunPrmStruct.ArgumentIdentifiers(:,2)',...
            TunPrmStruct.ArgumentValues(:,2)',...
            TunPrmStruct.ArgumentTypes(:,2)',...
            'UniformOutput',false),'')),...
            ind_base,'endfunction //pre_randomize\n']);

            function n_str=n_DirectTC4Fl(n_x,n_y,n_z)
                n_str='';
                if any(strcmp(n_z,{'real','shortreal'}))
                    n_str=char(join(arrayfun(@(indx,x)[ind_lvl{1},n_x,obj.getSVArrayIdxAccessor(indx,numel(n_y)),'=',obj.getSVDefLiteral(n_z,x),';\n'],(0:numel(n_y)-1),reshape(n_y,1,numel(n_y)),'UniformOutput',false),''));
                end
            end
        end

        function str=post_randomize_override(obj,space_ind,TunPrmStruct)
            if isempty(TunPrmStruct.ArgumentIdentifiers)
                str='';
                return;
            end

            [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,3);
            str=sprintf(['function void post_randomize();\n',...
            ind_lvl{1},'super.post_randomize();\n',...
            char(join(cellfun(@(x,y,z,vals)obj.RangeCntr(x,y,z,vals,ind_lvl,'post_rand'),TunPrmStruct.ArgumentIdentifiers(:,2)',...
            TunPrmStruct.ArgumentRanges(:,2)',...
            TunPrmStruct.ArgumentTypes(:,2)',...
            TunPrmStruct.ArgumentValues(:,2)',...
            'UniformOutput',false),'')),...
            ind_base,'endfunction //post_randomize\n']);
        end

        function str=randomize_params(this,space_ind)

            [ind_base,ind_lvl]=this.getIndentationLevels(space_ind,3);
            str=sprintf(['virtual task randomize_params();\n',...
            ind_lvl{1},'if(!randomize())\n',...
            ind_lvl{1},ind_lvl{1},'`uvm_error("RNDFAIL",{"Unable to randomize sequence parameters in ", get_full_name()});\n',...
            ind_base,'endtask // randomize_params\n']);
        end

        function str=call_dpi_fcns(this,space_ind,IsScalarizePortsEnabled)

            [ind_base,ind_lvl]=this.getIndentationLevels(space_ind,3);


            tun_prm_call=this.tunable_prm_fcn_call(numel(ind_lvl{1}),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction);



            outputfcn_args=char(join([this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(1),...
            cellfun(@(id,dir,sz)n_get_outputfcn_args(id,dir,sz),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(2:end),...
            this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end),...
            this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentSizes(2:end),...
            'UniformOutput',false)]));
            function n_str=n_get_outputfcn_args(id,dir,sz)
                if strcmp(dir,'input')
                    if sz>1&&IsScalarizePortsEnabled
                        n_str='';
                        for idx=1:sz
                            if iscell(id)
                                n_str=sprintf('%s,%s',n_str,id{idx});
                            else
                                n_str=sprintf('%s,%s_%d',n_str,id,idx-1);
                            end
                        end
                    else
                        n_str=sprintf(',%s',id);
                    end
                else
                    if sz>1&&IsScalarizePortsEnabled
                        n_str='';
                        for idx=1:sz
                            if iscell(id)
                                n_str=sprintf('%s,req.%s',n_str,id{idx});
                            else
                                n_str=sprintf('%s,req.%s_%d',n_str,id,idx-1);
                            end
                        end
                    else
                        n_str=sprintf(',req.%s',id);
                    end
                end
            end

            updatefcn_args=char(join([this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.ArgumentIdentifiers(1),...
            cellfun(@(x,sz)n_get_outputfcn_args(x,'input',sz),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.ArgumentIdentifiers(2:end),...
            this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.ArgumentSizes(2:end),...
            'UniformOutput',false)]));

            str=sprintf('virtual task call_dpi_fcns();\n');
            str=[str,sprintf([ind_lvl{1},'%s\n'],tun_prm_call)];
            str=[str,sprintf([ind_lvl{1},'%s(%s);\n'],this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.FunctionName{1},...
            outputfcn_args)];
            str=[str,sprintf([ind_lvl{1},'%s(%s);\n'],this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.UpdateFunction.FunctionName{1},...
            updatefcn_args)];
            str=[str,this.printUVMRunTimeReporting(length(ind_lvl{1}))];
            str=[str,sprintf([ind_base,'endtask // call_dpi_fcns\n'])];
        end

        function str=prebody_phase(obj,space_ind,TunPrmStruct)
            if isempty(TunPrmStruct.ArgumentIdentifiers)
                str='';
                return;
            end
            str=sprintf(['virtual task pre_body();\n',...
            repmat(' ',1,space_ind+3),'//Randomize the tunable parameters\n',...
            repmat(' ',1,space_ind+3),obj.rnd_result,'=randomize();\n',...
            repmat(' ',1,space_ind+3),'assert(',obj.rnd_result,')\n',...
            repmat(' ',1,space_ind+6),'else `uvm_error("RANDOMIZATION_FAILED","Unable to randomize the tunable parameters.");\n',...
            repmat(' ',1,space_ind),'endtask //pre_body\n']);

        end

        function NumTrans=getNumberOfTransactions(obj)
            NumTrans=ceil(obj.mwblkUVMVCodeInfo.UVMCodeInfo.TimingInfo.SimTime/obj.mwblkUVMVCodeInfo.UVMCodeInfo.TimingInfo.BaseRate)+1;
        end

        function str=rnd_cnrt_chck_var_decl(obj,space_ind,TunPrmStruct)

            if~isempty(TunPrmStruct.ArgumentIdentifiers)
                str=sprintf(['//Random constraint result\n',...
                repmat(' ',1,space_ind),'int %s;\n'],obj.rnd_result);
            else
                str='';
            end
        end

        function str=cntr_def_val(obj,space_ind,TunPrmStruct)
            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end
            str=sprintf(['//Simulink tunable parameter default values\n',...
            repmat(' ',1,space_ind),'constraint %s{\n',...
            char(join(cellfun(@(x,y,z)n_DirectTC4Int(x,y,z),TunPrmStruct.ArgumentIdentifiers(:,2)',...
            TunPrmStruct.ArgumentValues(:,2)',...
            TunPrmStruct.ArgumentTypes(:,2)',...
            'UniformOutput',false),'')),...
            repmat(' ',1,space_ind),'}\n'],[obj.uvmcmp_name,'_default_prm_val']);

            function n_str=n_DirectTC4Int(n_x,n_y,n_z)
                n_str='';
                if~any(strcmp(n_z,{'real','shortreal'}))
                    n_str=char(join(arrayfun(@(indx,vals)[repmat(' ',1,space_ind+3),n_x,obj.getSVArrayIdxAccessor(indx,numel(n_y)),'==',obj.getSVDefLiteral(n_z,vals),';\n'],...
                    (0:numel(n_y)-1),reshape(n_y,1,numel(n_y)),'UniformOutput',false),''));
                end
            end
        end

        function str=cntr_rng_vals(obj,space_ind,TunPrmStruct)
            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end

            [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,1);
            str=sprintf(['//Simulink tunable parameter ranges\n',...
            ind_base,'constraint %s{\n',...
            char(join(cellfun(@(x,y,z,vals)obj.RangeCntr(x,y,z,vals,ind_lvl,'cntr_block'),TunPrmStruct.ArgumentIdentifiers(:,2)',...
            TunPrmStruct.ArgumentRanges(:,2)',...
            TunPrmStruct.ArgumentTypes(:,2)',...
            TunPrmStruct.ArgumentValues(:,2)',...
            'UniformOutput',false),'')),...
            ind_base,'}\n'],[obj.uvmcmp_name,'_range_vals']);



        end


        function str=RangeCntr(obj,n_x,n_y,n_z,n_vals,ind_lvl,cntx)
            str='';



            switch cntx
            case 'cntr_block'
                if~any(strcmp(n_z,{'real','shortreal'}))
                    if isempty(n_y.Min)&&isempty(n_y.Max)
                        str='';
                    else
                        str=char(join(arrayfun(@(n_indx)n_getRngCntr(n_indx,numel(n_vals),cntx,n_z),(0:numel(n_vals)-1),'UniformOutput',false),''));
                    end
                end
            case 'post_rand'
                if any(strcmp(n_z,{'real','shortreal'}))
                    if isempty(n_y.Min)&&isempty(n_y.Max)
                        str='';
                    else
                        str=sprintf([ind_lvl{1},'assert(',...
                        char(join(arrayfun(@(n_indx)n_getRngCntr(n_indx,numel(n_vals),cntx,n_z),(0:numel(n_vals)-1),'UniformOutput',false),[' &&\n',ind_lvl{3}])),...
                        ')\n',...
                        ind_lvl{2},'else `uvm_error("PARAMETER_OUT_OF_RANGE","Parameter ',n_x,' is out of range.");\n']);
                    end
                end
            end

            function nn_str=n_getRngCntr(n_indx,ArrSz,n_cntx,svdt)


                if strcmp(n_cntx,'cntr_block')
                    LineEnd=';\n';
                    ExprInd=ind_lvl{1};
                    Sep=';';
                else
                    LineEnd='';
                    ExprInd='';
                    Sep=' && ';
                end

                if isempty(n_y.Min)&&~isempty(n_y.Max)

                    nn_str=[ExprInd,n_x,obj.getSVArrayIdxAccessor(n_indx,ArrSz),'<=',obj.getSVDefLiteral(svdt,n_y.Max),LineEnd];
                elseif~isempty(n_y.Min)&&isempty(n_y.Max)

                    nn_str=[ExprInd,n_x,obj.getSVArrayIdxAccessor(n_indx,ArrSz),'>=',obj.getSVDefLiteral(svdt,n_y.Min),LineEnd];
                else

                    nn_str=[ExprInd,n_x,obj.getSVArrayIdxAccessor(n_indx,ArrSz),'>=',obj.getSVDefLiteral(svdt,n_y.Min),Sep,...
                    n_x,obj.getSVArrayIdxAccessor(n_indx,ArrSz),'<=',obj.getSVDefLiteral(svdt,n_y.Max),LineEnd];
                end
            end
        end


    end


    methods
        function this=uvm_sequence(varargin)

            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'uvmcmp_name',replace([this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.seq_suffix],newline,''));
            addParameter(p,'uvmobj_name',replace([this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.seq_suffix,this.ucfg.obj_suffix],newline,''));
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_seq_tmplt));
            addParameter(p,'uvmsqr_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_sqr_tmplt));
            addParameter(p,'uvmobj_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_obj_tmplt));
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_type='uvm_sequence';
            this.uvmobj_name=p.Results.uvmobj_name;
            this.uvmobj_type='uvm_sequence_item';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;
            this.uvmsqr_tmplt=p.Results.uvmsqr_tmplt;
            this.uvmobj_tmplt=p.Results.uvmobj_tmplt;
            this.uvmsqr_name=[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.sqr_suffix];
        end

        function string=prtuvmcmp(this,varargin)
            tpl=prtuvmcmp@uvmcodegen.uvm_component(this,varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'Sequencer',false);
            parse(p,varargin{:});
            Sequencer=p.Results.Sequencer;
            tpl=replace(tpl,'%CLASSPARAM%',this.uvmobj_name);
            if Sequencer
                dpigenerator_disp(['Generating UVM sequencer ',dpigenerator_getfilelink(this.get_uvmsqr_name_fileLoc())]);
                tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmsqr_name_fileLoc(),'//',this.mwpath,bdroot(this.mwpath)));
                tpl=replace(tpl,'%SQRNAME%',this.uvmsqr_name);
            else
                dpigenerator_disp(['Generating UVM sequence ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);
                IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();

                tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//',this.mwpath,bdroot(this.mwpath)));
                tpl=replace(tpl,'%IMPORTS%',sprintf('import %s::*;\n',this.mwcfg.sl2uvmtopo.getPackageNameSpace('seq')));
                tpl=replace(tpl,'%CLASSNAME%',this.uvmcmp_name);
                tpl=replace(tpl,'%CLASSTYPE%',this.uvmcmp_type);
                tpl=replace(tpl,'%CLASSPARAM%',this.uvmobj_name);
                tpl=replace(tpl,'%RUNTIME_ERROR_VAR_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.ReturnValDecl);
                tpl=replace(tpl,'%ASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.AssertionInfo.AssertionInfoStructDecl);
                tpl=replace(tpl,'%TSASSERTION_STRUCT_INFO_DECL%',this.mwblkUVMVCodeInfo.UVMCodeInfo.TSAssertionInfo.TSAssertionInfoStructDecl);

                tpl=replace(tpl,'%INPUT_VAR_DECL%',this.input_var_decl(this.getSpaceIndentation(tpl,'%INPUT_VAR_DECL%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction,IsScalarizePortsEnabled));
                tpl=replace(tpl,'%INPUT_DEF_VAL%',this.input_def_val(this.getSpaceIndentation(tpl,'%INPUT_DEF_VAL%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction));
                tpl=replace(tpl,'%INPUT_RNG_VALS%',this.input_rng_vals(this.getSpaceIndentation(tpl,'%INPUT_RNG_VALS%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction));

                tpl=replace(tpl,'%TUN_PRM_VAR_DECL%',this.tunable_prm_var_decl(this.getSpaceIndentation(tpl,'%TUN_PRM_VAR_DECL%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
                tpl=replace(tpl,'%CNTR_DEF_VAL%',this.cntr_def_val(this.getSpaceIndentation(tpl,'%CNTR_DEF_VAL%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
                tpl=replace(tpl,'%CNTR_RNG_VALS%',this.cntr_rng_vals(this.getSpaceIndentation(tpl,'%CNTR_RNG_VALS%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));

                tpl=replace(tpl,'%SEQ_INPUT_DEF_VAL_SETTING%',this.input_def_val_set(this.getSpaceIndentation(tpl,'%SEQ_INPUT_DEF_VAL_SETTING%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction));

                tpl=replace(tpl,'%PRE_PHASE%',this.prestart_phase(this.getSpaceIndentation(tpl,'%PRE_PHASE%')));
                tpl=replace(tpl,'%PRE_RANDOMIZE_OVERRIDE%',this.pre_randomize_override(this.getSpaceIndentation(tpl,'%PRE_RANDOMIZE_OVERRIDE%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
                tpl=replace(tpl,'%POST_RANDOMIZE_OVERRIDE%',this.post_randomize_override(this.getSpaceIndentation(tpl,'%POST_RANDOMIZE_OVERRIDE%'),this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
                tpl=replace(tpl,'%RANDOMIZE_PARAMS%',this.randomize_params(this.getSpaceIndentation(tpl,'%RANDOMIZE_PARAMS%')));
                tpl=replace(tpl,'%CALL_DPI_FCNS%',this.call_dpi_fcns(this.getSpaceIndentation(tpl,'%CALL_DPI_FCNS%'),IsScalarizePortsEnabled));

                tpl=replace(tpl,'%BDY_PHASE%',this.body_phase(this.getSpaceIndentation(tpl,'%BDY_PHASE%')));
                tpl=replace(tpl,'%POST_BDY_PHASE%',this.post_body_phase(this.getSpaceIndentation(tpl,'%POST_BDY_PHASE%')));
                StrFmt=this.StrFormatting(tpl);
                this.FormatSequence=[this.FormatSequence,StrFmt(numel(this.FormatSequence)+1:end)];
            end
            string=tpl;
        end

        function string=prtuvmobj(this)
            dpigenerator_disp(['Generating UVM sequence transaction ',dpigenerator_getfilelink(this.get_uvmobj_name_fileLoc())]);

            fid=fopen(this.uvmobj_tmplt,'rt');
            tpl=fscanf(fid,'%c');
            fclose(fid);

            tpl=mw_findreplace(tpl);


            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmobj_name_fileLoc(),'//',this.mwpath,bdroot(this.mwpath)));

            if this.containNonFlatStructOrEnumPort()

                tpl=replace(tpl,'%IMPORT_COMMON_TYPES_PKG%',this.prtImportCommonDpiPkg());
            else
                tpl=replace(tpl,'%IMPORT_COMMON_TYPES_PKG%','');
            end

            [dec,mac]=this.uvmobj_dec();

            tpl=replace(tpl,'%CLASSNAME%',this.uvmobj_name);
            tpl=replace(tpl,'%CLASSTYPE%',this.uvmobj_type);
            tpl=replace(tpl,'%DECLARATIONS%',dec);
            tpl=replace(tpl,'%FIELDMACROS%',mac);

            string=tpl;
        end

        function res=prtImportCommonDpiPkg(this)
            res=sprintf('import %s::*;',this.common_dpi_pkg);
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('sequence'),[obj.uvmcmp_name,'.sv']));
        end

        function str=get_uvmobj_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('sequence'),[obj.uvmobj_name,'.sv']));
        end

        function str=get_uvmsqr_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('sequence'),[obj.uvmsqr_name,'.sv']));
        end


        function str=get_uvmobj_name_fileRelLoc(obj)
            [~,seqdir,~]=fileparts(obj.ucfg.component_paths('sequence'));
            str=obj.replaceBackS(fullfile('..',seqdir,[obj.uvmobj_name,'.sv']));
        end

        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,seqdir,~]=fileparts(obj.ucfg.component_paths('sequence'));
            str=obj.replaceBackS((fullfile('..',seqdir,[obj.uvmcmp_name,'.sv'])));
        end

        function str=get_uvmsqr_name_fileRelLoc(obj)
            [~,seqdir,~]=fileparts(obj.ucfg.component_paths('sequence'));
            str=obj.replaceBackS(fullfile('..',seqdir,[obj.uvmsqr_name,'.sv']));
        end



    end
end
