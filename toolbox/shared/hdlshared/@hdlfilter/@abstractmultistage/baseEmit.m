function baseEmit(this,varargin)





    bdt=hdlgetparameter('base_data_type');
    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));
    hdlentitysignalsinit;

    if hdlgetparameter('clockinputs')~=1
        error(message('HDLShared:hdlfilter:unsupportedcascadearch'));
    end

    basename=hdlgetparameter('filter_name');
    if isempty(basename)
        basename='filter';
    end

    fprintf('%s\n',hdlcodegenmsgs(1));

    addinreg=hdlgetparameter('filter_registered_input');
    addoutreg=hdlgetparameter('filter_registered_output');
    inputslv=hdlgetparameter('filter_input_type_std_logic');
    outputslv=hdlgetparameter('filter_output_type_std_logic');
    inname=hdlgetparameter('filter_input_name');
    outname=hdlgetparameter('filter_output_name');
    ceinname=hdlgetparameter('clockenablename');
    ceoutname=hdlgetparameter('clockenableoutputname');
    ceout_inname=hdlgetparameter('clockenableinputname');
    ceout_vldname=hdlgetparameter('clockenableoutputvalidname');
    clkname=hdlgetparameter('clockname');
    clkenname=hdlgetparameter('clockenablename');
    resetname=hdlgetparameter('resetname');

    nstages=length(this.Stage);
    castype=getCascadeType(this);
    cascade_latency=0;
    rcf=this.RateChangeFactors;
    if size(rcf,1)~=nstages
        rcf=repmat(rcf,nstages,1);
    end

    isinterp=isInterpolating(this);

    if isinterp
        rcf=rcf(:,1);
        last_rate_delta=prod(rcf(2:end,:));
    else
        rcf=rcf(:,2);
        last_rate_delta=1;
    end


    arithisdouble=strcmpi(this.Stage(1).InputSLtype,'double');

    if arithisdouble
        stage_roundmode='floor';
        stage_saturation='wrap';
        [~,~,~,inputvtype,inputsltype]=setportfordouble();
        [~,~,~,outputvtype,outputsltype]=setportfordouble();
    else
        stage_roundmode='nearest';
        stage_saturation='saturate';

        inputall=hdlgetallfromsltype(get(this.Stage(1),'InputSLType'),'inputport');
        inputvtype=inputall.portvtype;
        inputsltype=inputall.portsltype;
        outputall=hdlgetallfromsltype(get(this.Stage(end),'outputSLType'),'outputport');
        outputvtype=outputall.portvtype;
        outputsltype=outputall.portsltype;
    end




    hdl_entity_comment=this.Comment;

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];


    hdl_arch_functions=[indentedcomment,'Local Functions\n'];
    hdl_arch_typedefs=[indentedcomment,'Type Definitions\n'];
    hdl_arch_constants=[indentedcomment,'Constants\n'];
    hdl_arch_signals=[indentedcomment,'Signals\n'];
    hdl_arch_body_blocks=['\n',indentedcomment,'Block Statements\n'];
    hdl_arch_body_output_assignments=[indentedcomment,'Assignment Statements\n'];

    if hdlgetparameter('isverilog')
        hdl_arch_decl='';
        hdl_arch_comment='';
        hdl_arch_end=['endmodule',indentedcomment,basename,'\n'];
        hdl_arch_component_decl='';
        hdl_arch_component_config='';
        hdl_arch_begin='';
        hdl_arch_body_component_instances='';
        hdl_entity_library='';
        hdl_entity_package=hdlverilogtimescale;
        hdl_entity_decl=['module ',basename,' '];
        hdl_entity_end='';
    elseif hdlgetparameter('isvhdl')
        hdl_arch_decl=['ARCHITECTURE rtl OF ',basename,' IS\n'];
        if hdlgetparameter('split_entity_arch')==1
            hdl_arch_comment=hdl_entity_comment;
        else
            hdl_arch_comment=hdldefarchheader(basename);
        end
        hdl_arch_end='END rtl;\n';
        hdl_arch_component_decl='';
        hdl_arch_component_config='';
        hdl_arch_begin='\n\nBEGIN\n';
        hdl_arch_body_component_instances='';
        [hdl_entity_library,...
        hdl_entity_package,...
        hdl_entity_decl,...
        hdl_entity_end]=vhdlentityinit(basename);
    end




    if hdlgetparameter('split_entity_arch')==1
        hdl_arch_comment=hdl_entity_comment;
    else
        hdl_arch_comment=hdldefarchheader(basename);
    end



    stagehasceout=logical(zeros(1,nstages));
    stagelatency=zeros(1,nstages);

    fin_namelist={};
    fin_vtypelist={};
    fin_sltypelist={};

    fout_namelist={};
    fout_vtypelist={};
    fout_sltypelist={};

    cein_namelist={};
    cein_vtypelist={};
    cein_sltypelist={};

    ceout_namelist=cell(1,length(this.Stage));
    ceout_vtypelist=cell(1,length(this.Stage));
    ceout_sltypelist=cell(1,length(this.Stage));

    ceoutvalid_namelist=cell(1,length(this.Stage));
    ceoutvalid_vtypelist=cell(1,length(this.Stage));
    ceoutvalid_sltypelist=cell(1,length(this.Stage));

    if isinterp
        lastce='';
        ce_name_list={};
    else
        lastce=ceinname;
        ce_name_list={ceinname};
    end

    entity_ports={};
    entityportnames={};
    entitynames={};
    for n=1:nstages
        thisfilter=this.Stage(n);

        PersistentHDLPropSet(thisfilter.HDLParameters);
        updateINI(thisfilter.HDLParameters);
        hprop=PersistentHDLPropSet;
        thisfilter.resetINIOnlyProps();

        stagename=[basename,'_stage',num2str(n)];


        if strcmpi(hdlgetparameter('target_language'),'vhdl')
            hdlsetpackagename(basename);
        end
        hdlsetparameter('filter_name',stagename);
        hdlsetparameter('filter_input_name',[inname,'_stage',num2str(n)]);
        hdlsetparameter('filter_output_name',[outname,'_stage',num2str(n)]);
        hdlsetparameter('clockenablename',[ceinname,'_stage',num2str(n)]);
        hdlsetparameter('clockenableoutputname',[ceoutname,'_stage',num2str(n)]);
        hdlsetparameter('clockenableinputname',[ceout_inname,'_stage',num2str(n)]);
        hdlsetparameter('clockenableoutputvalidname',[ceout_vldname,'_stage',num2str(n)]);
        hdlsetparameter('filter_excess_latency',0);

        if isa(thisfilter,'hdlfilter.abstractmultirate')||...
            isa(thisfilter,'hdlfilter.abstractsrc')
            stagehasceout(n)=true;
        end
        stimes=this.getSampleTimes;
        if needCeoutValid(this,n)
            hdlsetparameter('filter_generate_datavalid_output',1)
        end
        setInputOutputRegs(this,n);
        disp(sprintf([hdlcodegenmsgs(10),' # ','%d'],n));




        oldcbs=hdlgetparameter('cast_before_sum');
        cbs=strcmpi(thisfilter.HDLParameter.CLI.castbeforesum,'on');
        hdlsetparameter('cast_before_sum',cbs);

        hdluniqueprocessname(0);

        emit(thisfilter);

        hdlsetparameter('cast_before_sum',oldcbs);


        if isinterp
            if n>=nstages-1
                rate_delta=1;
            else
                rate_delta=max(prod(rcf(end:-1:n+2,:)));
            end
        else
            rate_delta=max(prod(rcf(1:n,:)));
        end

        cascade_latency=cascade_latency+hdlgetparameter('filter_excess_latency')*last_rate_delta;

        stagelatency(n)=hdlgetparameter('filter_excess_latency');

        if hdlgetparameter('filter_pipelined')&&n<nstages
            if isinterp
                cascade_latency=cascade_latency+last_rate_delta;
                stagelatency(n)=0;
            else
                cascade_latency=cascade_latency+1;
                stagelatency(n)=stagelatency(n)+1;
            end
        end

        if isinterp&&rcf(n)~=1&&n~=1
            cascade_latency=cascade_latency+max(prod(rcf(end:-1:n)));
        end

        if n==1&&addinreg&&n==nstages
            stagelatency(n)=stagelatency(n)+1;
        elseif n==1&&addinreg
            if isinterp
                stagelatency(n)=0;
            else
                stagelatency(n)=stagelatency(n)+1;
            end
        end

        if n==nstages&&addoutreg
            stagelatency(n)=stagelatency(n)+1;
        end

        last_rate_delta=rate_delta;

        [hdl_ports,not_used,hdl_inst]=hdlentityports(stagename);

        if hdlgetparameter('isvhdl')
            hdl_arch_component_decl=[hdl_arch_component_decl,...
            '  COMPONENT ',stagename,'\n',...
            hdl_ports,...
            '    END COMPONENT;\n\n'];
        end

        if hdlgetparameter('isvhdl')&&hdlgetparameter('inline_configurations')
            hdl_arch_component_config=[hdl_arch_component_config,...
            '  FOR ALL : ',stagename,'\n',...
            '    USE ENTITY work.',stagename,'(rtl);\n\n'];
        end

        hdl_arch_body_component_instances=[hdl_arch_body_component_instances,hdl_inst];
        sfx='';
        if hdlgetparameter('filter_complex_inputs')
            sfx=hdlgetparameter('complex_real_postfix');
        end
        fin=hdlsignalfindname([hdlgetparameter('filter_input_name'),sfx]);
        fout=hdlsignalfindname([hdlgetparameter('filter_output_name'),sfx]);
        cein=hdlsignalfindname(hdlgetparameter('clockenablename'));
        ceout=hdlsignalfindname(hdlgetparameter('clockenableoutputname'));
        if needCeoutValid(this,n)
            ceoutvld=hdlsignalfindname(hdlgetparameter('clockenableoutputvalidname'));
        end
        if isempty(fin)||isempty(fout)||isempty(cein)||(isempty(ceout)&&stagehasceout(n))
            error(message('HDLShared:hdlfilter:cascadeinternalerror'));
        end

        hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(fin)];
        hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(fout)];
        hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(cein)];

        if~strcmpi(this.Implementation,'localmultirate')
            if stagehasceout(n)
                hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(ceout)];
                ceout_namelist{n}=hdlsignalname(ceout);
                ceout_vtypelist{n}=hdlsignalvtype(ceout);
                ceout_sltypelist{n}=hdlsignalsltype(ceout);

            elseif stagelatency(n)~=0
                ceout_namelist{n}=hdlgetparameter('clockenableoutputname');
                ceout_vtypelist{n}=bdt;
                ceout_sltypelist{n}='boolean';
                [~,ceout]=hdlnewsignal(hdlgetparameter('clockenableoutputname'),...
                'filter',-1,0,0,bdt,'boolean');
                hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(ceout)];
            else
                ceout_namelist{n}='';
                ceout_vtypelist{n}='';
                ceout_sltypelist{n}='';
            end
        else
            if stagehasceout(n)
                hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(ceout)];
                ceout_namelist{n}=hdlsignalname(ceout);
                ceout_vtypelist{n}=hdlsignalvtype(ceout);
                ceout_sltypelist{n}=hdlsignalsltype(ceout);
                if needCeoutValid(this,n)

                    hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(ceoutvld)];
                    ceoutvalid_namelist{n}=hdlsignalname(ceoutvld);
                    ceoutvalid_vtypelist{n}=hdlsignalvtype(ceoutvld);
                    ceoutvalid_sltypelist{n}=hdlsignalsltype(ceoutvld);
                end
            else

                if needCeoutValid(this,n)


                    hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(ceoutvld)];
                    ceoutvalid_namelist{n}=hdlsignalname(ceoutvld);
                    ceoutvalid_vtypelist{n}=hdlsignalvtype(ceoutvld);
                    ceoutvalid_sltypelist{n}=hdlsignalsltype(ceoutvld);
                else
                    ceout_namelist{n}='';
                    ceout_vtypelist{n}='';
                    ceout_sltypelist{n}='';
                end
            end


        end
        fin_name=hdlsignalname(fin);
        fin_name(end-length(sfx)+1:end)='';
        fin_namelist{end+1}=fin_name;
        fin_vtypelist{end+1}=hdlsignalvtype(fin);
        fin_sltypelist{end+1}=hdlsignalsltype(fin);

        fout_name=hdlsignalname(fout);
        fout_name(end-length(sfx)+1:end)='';
        fout_namelist{end+1}=fout_name;
        fout_vtypelist{end+1}=hdlsignalvtype(fout);
        fout_sltypelist{end+1}=hdlsignalsltype(fout);

        cein_namelist{end+1}=hdlsignalname(cein);
        cein_vtypelist{end+1}=hdlsignalvtype(cein);
        cein_sltypelist{end+1}=hdlsignalsltype(cein);

        [entity_ports{n},entityportnames{n}]=hdlentityports;
        entitynames{n}=stagename;

        thisfilter.resetINIOnlyProps();

    end




    PersistentHDLPropSet(this.HDLParameters);

    hdlentitysignalsinit;




    hdlsetparameter('filter_name',basename);
    hdlsetparameter('filter_registered_input',addinreg);
    hdlsetparameter('filter_registered_output',addoutreg);
    hdlsetparameter('filter_input_type_std_logic',inputslv);
    hdlsetparameter('filter_output_type_std_logic',outputslv);
    hdlsetparameter('filter_input_name',inname);
    hdlsetparameter('filter_output_name',outname);
    hdlsetparameter('clockenablename',ceinname);
    hdlsetparameter('clockenableoutputname',ceoutname);
    hdlsetparameter('clockenableinputname',ceout_inname);
    hdlsetparameter('clockname',clkname);
    hdlsetparameter('clockenablename',clkenname);
    hdlsetparameter('resetname',resetname);

    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));

    hdlsetparameter('filter_excess_latency',cascade_latency);

    [~,entity_clk]=hdlnewsignal(hdlgetparameter('clockname'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(entity_clk);
    hdladdclocksignal(entity_clk);
    hdlsetcurrentclock(entity_clk);

    [~,entity_cein]=hdlnewsignal(hdlgetparameter('clockenablename'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(entity_cein);
    hdladdclockenablesignal(entity_cein);
    hdlsetcurrentclockenable(entity_cein);
    [~,entity_reset]=hdlnewsignal(hdlgetparameter('resetname'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(entity_reset);
    hdladdresetsignal(entity_reset);
    hdlsetcurrentreset(entity_reset);
    [~,entity_input]=hdlnewsignal(hdlgetparameter('filter_input_name'),...
    'filter',-1,this.isInputPortComplex,0,...
    inputvtype,inputsltype);
    hdladdinportsignal(entity_input);

    if hdlgetparameter('RateChangePort')
        esigs=createVarRatePorts(this);
        entitysigs.loadenb=esigs.loadenb;
        entitysigs.rate=esigs.rate;
    end
    [~,entity_output]=hdlnewsignal(hdlgetparameter('filter_output_name'),...
    'filter',-1,this.isOutputPortComplex,0,...
    outputvtype,outputsltype);
    hdladdoutportsignal(entity_output);
    if isa(this,'hdlfilter.mfiltcascade')
        [~,entity_ceout]=hdlnewsignal(hdlgetparameter('clockenableoutputname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entity_ceout);
    end
    if isa(this.Stage(end),'hdlfilter.abstractsrc')
        [~,entity_ceout_in]=hdlnewsignal(hdlgetparameter('clockenableinputname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entity_ceout_in);
    end
    if strcmpi(this.Implementation,'localmultirate')&&...
        (strcmpi(castype,'singlerate')||strcmpi(castype,'interpolating'))
        [~,entity_ceout_vld]=hdlnewsignal(hdlgetparameter('clockenableoutputvalidname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entity_ceout_vld);
    end

    [hdl_entity_ports,hdl_entity_portdecls]=hdlentityports;

    for n=1:length(this.Stage)
        hdladdtoentitylist('filter',entitynames{n},entity_ports{n},entityportnames{n});
    end

    hdladdtoentitylist('filter',basename,hdl_entity_ports,hdlentityportnames);

    finsignals=zeros(1,nstages);
    fouttmpsignals=zeros(1,nstages);
    foutsignals=zeros(1,nstages);
    ceinsignals=zeros(1,nstages);
    ceoutsignals=zeros(1,nstages);
    ceoutvldsignals=zeros(1,nstages);


    for n=1:nstages
        [~,finsignals(n)]=hdlnewsignal(fin_namelist{n},'filter',-1,this.isInputPortComplex,0,...
        fin_vtypelist{n},fin_sltypelist{n});
        if n>1
            [sz,bp,signed]=hdlwordsize(fin_sltypelist{n});
            [tmpvtype,tmpsltype]=hdlgettypesfromsizes(sz,bp,signed);
            [~,fouttmpsignals(n)]=hdlnewsignal([fin_namelist{n},'_tmp'],'filter',-1,this.isOutputPortComplex,0,...
            tmpvtype,tmpsltype);
            hdl_arch_signals=[hdl_arch_signals,...
            makehdlsignaldecl(fouttmpsignals(n))];
        end
        [~,foutsignals(n)]=hdlnewsignal(fout_namelist{n},'filter',-1,this.isOutputPortComplex,0,...
        fout_vtypelist{n},fout_sltypelist{n});

        [~,ceinsignals(n)]=hdlnewsignal(cein_namelist{n},'filter',-1,0,0,...
        cein_vtypelist{n},cein_sltypelist{n});
        hdladdclockenablesignal(ceinsignals(n));
        if~isempty(ceout_namelist{n})
            [~,ceoutsignals(n)]=hdlnewsignal(ceout_namelist{n},'filter',-1,0,0,...
            ceout_vtypelist{n},ceout_sltypelist{n});
        end
        if needCeoutValid(this,n)
            [~,ceoutvldsignals(n)]=hdlnewsignal(ceoutvalid_namelist{n},'filter',-1,0,0,...
            ceoutvalid_vtypelist{n},ceoutvalid_sltypelist{n});
        end
    end


    if isa(this.Stage(end),'hdlfilter.abstractsrc')
        [~,ce_insig]=hdlnewsignal(['ce_in_stage',num2str(nstages)],...
        'filter',-1,0,0,bdt,'boolean');
        hdl_arch_signals=[hdl_arch_signals,...
        makehdlsignaldecl(ce_insig)];
    end

    [tempbody,tempsignals]=hdlfinalassignment(entity_input,finsignals(1));
    hdl_arch_signals=[hdl_arch_signals,tempsignals];
    hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];

    if~strcmpi(this.Implementation,'localmultirate')

        for n=1:nstages-1
            hdl_arch_body_blocks=[hdl_arch_body_blocks,...
            hdldatatypeassignment(foutsignals(n),...
            fouttmpsignals(n+1),...
            stage_roundmode,stage_saturation)];
            [tempbody,tempsignals]=hdlfinalassignment(fouttmpsignals(n+1),finsignals(n+1));
            hdl_arch_signals=[hdl_arch_signals,tempsignals];
            hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
        end

        [tempbody,tempsignals]=hdlfinalassignment(foutsignals(end),entity_output);
        hdl_arch_signals=[hdl_arch_signals,tempsignals];
        hdl_arch_body_output_assignments=[hdl_arch_body_output_assignments,tempbody];
    end
    const_one=0;
    if isinterp&&isfarrowcascade(this)
        [hdl_tc,ce_in]=local_emit_timingcontrol(this.Stage(end));






        rcf=this.Ratechangefactors;
        rcfarray=[rcf(1:end-1,1)',ceil(rcf(end,1)/rcf(end,2))];
        delayint=prod(rcfarray);
        while length(rcfarray)>2
            rcfarray=rcfarray(1,2:end);
            delayint=delayint+prod(rcfarray);
        end
        delayint=delayint+1;
        [uname,delayedsig]=hdlnewsignal('ce_delayed',...
        'filter',-1,0,0,bdt,'boolean');
        hdl_arch_signals=[hdl_arch_signals,...
        makehdlsignaldecl(delayedsig)];
        obj=hdl.intdelay('clock',hdlgetcurrentclock,...
        'clockenable',hdlgetcurrentclockenable,...
        'reset',hdlgetcurrentreset,...
        'inputs',entity_cein,...
        'outputs',delayedsig,...
        'processName',['clken_delay',hdlgetparameter('clock_process_label')],...
        'resetvalues',0,...
        'nDelays',delayint);
        if~strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
            obj.setResetNone;
        end
        intdelaycode=obj.emit;
        hdl_arch_signals=[hdl_arch_signals,hdl_tc.signals,intdelaycode.arch_signals];
        hdl_arch_body_blocks=[hdl_arch_body_blocks,hdl_tc.body_blocks,intdelaycode.arch_body_blocks];
    end


    if strcmpi(this.Implementation,'localmultirate')
        ceenabtemps=zeros(1,length(this.Stage)-1);
        for n=1:length(this.stage)

            if n~=1
                [~,ceenabtemps(n-1)]=hdlnewsignal(['clk_enable_stage',num2str(n),'_tmp'],...
                'filter',-1,0,0,bdt,'boolean');
            end

        end

        hdl_arch_signals=[hdl_arch_signals,...
        makehdlsignaldecl(ceenabtemps(ceenabtemps>0))];
        if~isinterp
            [~,ceouttemp]=hdlnewsignal('ce_out_temp',...
            'filter',-1,0,0,bdt,'boolean');
            hdl_arch_signals=[hdl_arch_signals,...
            makehdlsignaldecl(ceouttemp)];

        end
        clkreqs=analyzeImplementation(this);

        hdlsharedTC=hdlfilter.TimingController;
        hdlsharedTC.tcinfo(1).clk=hdlgetcurrentclock;
        hdlsharedTC.tcinfo(1).reset=hdlgetcurrentreset;
        hdlsharedTC.tcinfo(1).clkenable=hdlgetcurrentclockenable;

        if isinterp
            hdlsharedTC.tcinfo(1).outputsignals=[ceinsignals(1),ceenabtemps];
        else
            hdlsharedTC.tcinfo(1).outputsignals=[ceinsignals(1),ceenabtemps,ceouttemp];
        end

        [hdlsharedTC.tcinfo(1).nstates,...
        ~,hdlsharedTC.tcinfo(1).outputoffsets]=...
        this.designTimingController(clkreqs);
        hdlsetparameter('foldingfactor',hdlsharedTC.tcinfo(1).nstates);

        tccode=hdlsharedTC.emit;
        hdl_arch_signals=[hdl_arch_signals,tccode.arch_signals];
        hdl_arch_body_blocks=[hdl_arch_body_blocks,tccode.arch_body_blocks];


        for n=1:nstages-1

            hdl_arch_body_blocks=[hdl_arch_body_blocks,...
            hdldatatypeassignment(foutsignals(n),...
            fouttmpsignals(n+1),...
            stage_roundmode,stage_saturation)];

            [tempbody,tempsignals]=hdlfinalassignment(fouttmpsignals(n+1),finsignals(n+1));
            hdl_arch_signals=[hdl_arch_signals,tempsignals];
            hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];

        end




        [tempbody,tempsignals]=hdlfinalassignment(foutsignals(end),entity_output);
        hdl_arch_signals=[hdl_arch_signals,tempsignals];
        hdl_arch_body_output_assignments=[hdl_arch_body_output_assignments,tempbody];


        [~,const_one]=hdlnewsignal('logical_one','filter',-1,0,0,bdt,'boolean');
        value=hdlconstantvalue(1,1,0,0);
        hdl_arch_constants=[hdl_arch_constants,makehdlconstantdecl(const_one,value)];
        switch castype
        case 'decimating'
            if length(unique(stimes))~=length(stimes)

                ceoutvldstages=ceoutsignals==0;
                ceoutsignals(ceoutsignals==0)=ceoutvldsignals(ceoutvldstages);
                entity_ce_outfinal=entity_ceout;
            else

                entity_ce_outfinal=entity_ceout;
            end
        case 'singlerate'
            ceoutsignals=ceoutvldsignals;
            entity_ce_outfinal=entity_ceout_vld;
        case 'interpolating'
            realceoutsigs=ceoutsignals(ceoutsignals>0);
            ceoutfirst=realceoutsigs(1);
            ceoutsignals=ceoutvldsignals;
            entity_ce_outfinal=entity_ceout_vld;
        otherwise
            error(message('HDLShared:hdlfilter:wrongcascadetype'));
        end
        for stn=1:nstages-1
            [clkenblogic_code,clkenblogic_sig]=...
            genLogicForClkenable(this,ceoutsignals(stn),ceenabtemps(stn),...
            ceinsignals(stn+1),const_one,stn);

            hdl_arch_signals=[hdl_arch_signals,clkenblogic_sig];
            hdl_arch_body_blocks=[hdl_arch_body_blocks,clkenblogic_code];
        end
        if~isinterp

            [clkenblogic_code,clkenblogic_sig]=...
            genLogicForClkenable(this,ceoutsignals(end),ceouttemp,...
            entity_ce_outfinal,const_one,nstages);

            hdl_arch_signals=[hdl_arch_signals,clkenblogic_sig];
            hdl_arch_body_blocks=[hdl_arch_body_blocks,clkenblogic_code];
        else
            [tempbody,tempsignals]=hdlfinalassignment(ceoutfirst,entity_ceout);
            bdt=hdlgetparameter('base_data_type');

            hdl_arch_body_blocks=[hdl_arch_body_blocks,...
            hdlbitop([ceoutvldsignals(end),ceinsignals(end)],entity_ce_outfinal,'AND')];
            hdl_arch_signals=[hdl_arch_signals,tempsignals];
            hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
        end

    end

    if~strcmpi(this.Implementation,'localmultirate')

        if isinterp
            if isfarrowcascade(this)
                lastce=delayedsig;
            else
                lastce=entity_cein;
            end
            for n=nstages:-1:1
                [tempbody,tempsignals]=hdlfinalassignment(lastce,ceinsignals(n));
                hdl_arch_signals=[hdl_arch_signals,tempsignals];
                hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
                if stagehasceout(n)
                    if isfarrowcascade(this)
                        if n==nstages
                            lastce=ce_in;
                        elseif n==1
                            lastce=ceoutsignals(end);
                        else
                            lastce=ceoutsignals(n);
                        end
                    else
                        lastce=ceoutsignals(n);
                    end
                elseif stagelatency(n)==0

                else
                    oldcename=hdlgetcurrentclockenable;
                    hdlsetcurrentclockenable(ceinsignals(n));
                    if const_one==0
                        [~,const_one]=hdlnewsignal('logical_one','filter',-1,0,0,bdt,'boolean');
                        value=hdlconstantvalue(1,1,0,0);
                        hdl_arch_constants=[hdl_arch_constants,makehdlconstantdecl(const_one,value)];
                    end
                    delays=zeros(1,stagelatency(n));
                    for lat=1:stagelatency(n)
                        [~,delays(lat)]=hdlnewsignal(['cedelay',num2str(lat),'_stage',num2str(n)],...
                        'filter',-1,0,0,bdt,'boolean');
                        hdlregsignal(delays(lat));
                        hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(delays(lat))];
                    end
                    [tempbody,tempsignals]=hdlunitdelay([const_one,delays(1:end-1)],delays,...
                    ['cedelay_stage',num2str(n),hdlgetparameter('clock_process_label')],...
                    zeros(1,stagelatency(n)));
                    hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
                    hdl_arch_signals=[hdl_arch_signals,tempsignals];

                    tempbody=hdllogop([ceinsignals(n),delays(end)],ceoutsignals(n),'AND');
                    hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
                    hdlsetcurrentclockenable(oldcename);
                    lastce=ceoutsignals(n);
                end
            end
            if isa(this,'hdlfilter.mfiltcascade')
                [tempbody,tempsignals]=hdlfinalassignment(lastce,entity_ceout);
                hdl_arch_signals=[hdl_arch_signals,tempsignals];
                hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
            end
            if isa(this.Stage(end),'hdlfilter.farrowsrc')

                [tempbody,tempsignals]=hdlfinalassignment(ceoutsignals(1),entity_ceout_in);
                hdl_arch_signals=[hdl_arch_signals,tempsignals];
                hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
            end
        else
            lastce=entity_cein;
            for n=1:nstages
                [tempbody,tempsignals]=hdlfinalassignment(lastce,ceinsignals(n));
                hdl_arch_signals=[hdl_arch_signals,tempsignals];
                hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
                if stagehasceout(n)
                    lastce=ceoutsignals(n);
                elseif stagelatency(n)==0

                else
                    oldcename=hdlgetcurrentclockenable;
                    hdlsetcurrentclockenable(ceinsignals(n));
                    if const_one==0
                        [~,const_one]=hdlnewsignal('logical_one','filter',-1,0,0,bdt,'boolean');
                        value=hdlconstantvalue(1,1,0,0);
                        hdl_arch_constants=[hdl_arch_constants,makehdlconstantdecl(const_one,value)];
                    end
                    delays=zeros(1,stagelatency(n));
                    for lat=1:stagelatency(n)
                        [~,delays(lat)]=hdlnewsignal(['cedelay',num2str(lat),'_stage',num2str(n)],...
                        'filter',-1,0,0,bdt,'boolean');
                        hdlregsignal(delays(lat));
                        hdl_arch_signals=[hdl_arch_signals,makehdlsignaldecl(delays(lat))];
                    end
                    [tempbody,tempsignals]=hdlunitdelay([const_one,delays(1:end-1)],delays,...
                    ['cedelay_stage',num2str(n),hdlgetparameter('clock_process_label')],...
                    zeros(1,stagelatency(n)));
                    hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
                    hdl_arch_signals=[hdl_arch_signals,tempsignals];

                    tempbody=hdllogop([ceinsignals(n),delays(end)],ceoutsignals(n),'AND');
                    hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
                    hdlsetcurrentclockenable(oldcename);
                    lastce=ceoutsignals(n);
                end
            end
            if isa(this,'hdlfilter.mfiltcascade')
                [tempbody,tempsignals]=hdlfinalassignment(lastce,entity_ceout);
                hdl_arch_signals=[hdl_arch_signals,tempsignals];
                hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
            end
            if isa(this.Stage(end),'hdlfilter.farrowsrc')


                [tempbody,tempsignals]=hdlfinalassignment(entity_cein,entity_ceout_in);
                hdl_arch_signals=[hdl_arch_signals,tempsignals];
                hdl_arch_body_blocks=[hdl_arch_body_blocks,tempbody];
            end
        end

    end









    if strcmpi(hdlgetparameter('target_language'),'vhdl')
        vhdl_pkg_reqd=0;
        for n=1:length(this.stage)
            vhdl_pkg_reqd=vhdl_pkg_reqd||this.Stage(n).getHDLParameter('vhdl_package_required');
            vhdl_type_defs=this.Stage(n).getHDLParameter('vhdl_package_type_defs');
            if~isempty(vhdl_type_defs)

                vhdl_type_defs=strrep(vhdl_type_defs,'  -- Type Definitions\n','');
                vhdlpackageaddtypedef(vhdl_type_defs);
            end
        end

        hdlsetparameter('vhdl_package_required',vhdl_pkg_reqd);
    end
    this.hdlwritepackage;
    if hdlgetparameter('vhdl_package_required')==1
        hdl_entity_library=[hdl_entity_library,'USE work.',hdlgetparameter('vhdl_package_name'),'.ALL;\n\n'];
    else
        hdl_entity_library=[hdl_entity_library,'\n'];
    end

    codegendir=hdlGetCodegendir;
    fileprefix=hdlgetparameter('module_prefix');
    if hdlgetparameter('split_entity_arch')==1
        entityfilename=fullfile(codegendir,[fileprefix,basename,...
        hdlgetparameter('split_entity_file_postfix'),...
        hdlgetparameter('filename_suffix')]);
        archfilename=fullfile(codegendir,[fileprefix,basename,...
        hdlgetparameter('split_arch_file_postfix'),...
        hdlgetparameter('filename_suffix')]);
        opentype='w';
    else
        entityfilename=fullfile(codegendir,[fileprefix,basename,...
        hdlgetparameter('filename_suffix')]);
        archfilename=entityfilename;
        opentype='a';
    end

    entityfid=fopen(entityfilename,'w');

    if entityfid==-1
        error(message('HDLShared:hdlfilter:fileerror',entityfilename));
    end

    hdl_entity=[hdl_entity_comment,...
    hdl_entity_library,...
    hdl_entity_package,...
    hdl_entity_decl,...
    hdl_entity_ports,...
    hdl_entity_portdecls,...
    hdl_entity_end];

    fprintf(entityfid,hdl_entity);
    fclose(entityfid);

    archfid=fopen(archfilename,opentype);
    if archfid==-1
        error(message('HDLShared:hdlfilter:fileerror',archfilename));
    end

    hdl_arch=[hdl_arch_comment,...
    hdl_arch_decl,...
    hdl_arch_component_decl,...
    hdl_arch_component_config,...
    hdl_arch_functions,...
    hdl_arch_typedefs,...
    hdl_arch_constants,...
    hdl_arch_signals,...
    hdl_arch_begin,...
    hdl_arch_body_component_instances,...
    hdl_arch_body_blocks,...
    hdl_arch_body_output_assignments,...
    hdl_arch_end];
    fprintf(archfid,hdl_arch);
    fclose(archfid);
    fprintf('%s\n',hdlcodegenmsgs(7,latency(this)));


    function[size,bp,signed,vtype,sltype]=setportfordouble()

        size=0;
        bp=0;
        signed=true;
        if hdlgetparameter('isverilog')
            vtype='wire [63:0]';
        else
            vtype='real';
        end
        sltype='double';

        function yesno=isfarrowcascade(this)

            yesno=isa(this.Stage(end),'hdlfilter.farrowsrc');



            function[hdlcode,phasesig]=local_emit_timingcontrol(this)




                arch_signals='';
                arch_body_blocks='';

                phases=this.InterpolationFactor;
                decim_factor=this.DecimationFactor;

                count_to=ceil(phases/decim_factor)-1;

                countsize=max(2,ceil(log2(count_to+1)));

                [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
                [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
                hdlregsignal(counter_out);
                arch_signals=[arch_signals,makehdlsignaldecl(counter_out)];
                [tempprocessbody,phasesig]=hdlcounter(counter_out,count_to+1,'aux_clk_enable',1,0,count_to);
                arch_signals=[arch_signals,makehdlsignaldecl(phasesig)];
                hdladdclockenablesignal(phasesig);
                arch_body_blocks=[arch_body_blocks,tempprocessbody];

                hdlcode.signals=arch_signals;
                hdlcode.body_blocks=arch_body_blocks;



                function setInputOutputRegs(this,n)

                    nstages=length(this.Stage);
                    addinreg=hdlgetparameter('filter_registered_input');
                    addoutreg=hdlgetparameter('filter_registered_output');
                    rcf=this.RatechangeFactors;
                    isinterp=isInterpolating(this);
                    if~strcmpi(this.Implementation,'localmultirate')
                        if n==1&&n==nstages
                            hdlsetparameter('filter_registered_input',addinreg);
                            hdlsetparameter('filter_registered_output',hdlgetparameter('filter_pipelined'));
                            hdlsetparameter('filter_registered_output',addoutreg);
                        elseif n==1
                            hdlsetparameter('filter_registered_input',addinreg);
                            hdlsetparameter('filter_registered_output',hdlgetparameter('filter_pipelined'));
                        elseif n==nstages
                            if isinterp&&rcf(n)~=1
                                hdlsetparameter('filter_registered_input',true);
                            else
                                if isfarrowcascade(this)
                                    hdlsetparameter('filter_registered_input',true);
                                else
                                    hdlsetparameter('filter_registered_input',false);
                                end
                            end
                            hdlsetparameter('filter_registered_output',addoutreg);
                        elseif hdlgetparameter('filter_pipelined')
                            hdlsetparameter('filter_registered_output',true);
                            if isinterp&&rcf(n)~=1
                                hdlsetparameter('filter_registered_input',true);
                            else
                                hdlsetparameter('filter_registered_input',false);
                            end
                        else
                            if isinterp&&rcf(n)~=1
                                hdlsetparameter('filter_registered_input',true);
                            else
                                hdlsetparameter('filter_registered_input',false);
                            end
                            hdlsetparameter('filter_registered_output',false);
                        end
                    else
                        if n==1&&n==nstages
                            hdlsetparameter('filter_registered_input',addinreg);
                            hdlsetparameter('filter_registered_output',hdlgetparameter('filter_pipelined'));
                            hdlsetparameter('filter_registered_output',addoutreg);
                        elseif n==1
                            if strcmpi(this.Stage(n).Implementation,'distributedarithmetic')
                                hdlsetparameter('filter_registered_input',true);
                                hdlsetparameter('filter_registered_output',true);
                            else
                                if isinterp
                                    if all(rcf(n,:))
                                        hdlsetparameter('filter_registered_input',true);
                                    else
                                        hdlsetparameter('filter_registered_input',false);
                                    end
                                    hdlsetparameter('filter_registered_output',false);
                                else
                                    hdlsetparameter('filter_registered_input',addinreg);
                                    hdlsetparameter('filter_registered_output',hdlgetparameter('filter_pipelined'));
                                end
                            end
                        elseif n==nstages
                            if isinterp
                                if all(rcf(n,:))
                                    hdlsetparameter('filter_registered_input',true);
                                else
                                    hdlsetparameter('filter_registered_input',false);
                                end
                            else
                                if isfarrowcascade(this)
                                    hdlsetparameter('filter_registered_input',true);
                                else
                                    hdlsetparameter('filter_registered_input',false);
                                end
                            end
                            if isinterp
                                hdlsetparameter('filter_registered_input',false);
                            elseif strcmpi(this.Stage(n).Implementation,'distributedarithmetic')
                                hdlsetparameter('filter_registered_input',true);
                                hdlsetparameter('filter_registered_output',true);
                            else
                                hdlsetparameter('filter_registered_output',addoutreg);
                            end
                        elseif hdlgetparameter('filter_pipelined')
                            hdlsetparameter('filter_registered_output',true);
                            if isinterp&&rcf(n)~=1
                                hdlsetparameter('filter_registered_input',true);
                            else
                                hdlsetparameter('filter_registered_input',false);
                            end
                            if strcmpi(this.Stage(n).Implementation,'distributedarithmetic')
                                hdlsetparameter('filter_registered_input',true);
                                hdlsetparameter('filter_registered_output',true);
                            end
                        else
                            if isinterp
                                if all(rcf(n,:))
                                    hdlsetparameter('filter_registered_input',true);
                                else
                                    hdlsetparameter('filter_registered_input',false);
                                end
                            else
                                hdlsetparameter('filter_registered_input',false);
                            end
                            hdlsetparameter('filter_registered_output',false);
                            if strcmpi(this.Stage(n).Implementation,'distributedarithmetic')
                                hdlsetparameter('filter_registered_input',true);
                                hdlsetparameter('filter_registered_output',true);
                            end
                        end
                    end



                    function[hdlbody,hdlsignals]=genLogicForClkenable(~,...
                        ceout_prev,clkenb_tc,clkenb_this,const_one,stagenum)

                        stgnumstr=num2str(stagenum);
                        bdt=hdlgetparameter('base_data_type');
                        [~,prelocked_ceoutsig]=hdlnewsignal(['prelocked_ceout',stgnumstr],...
                        'filter',-1,0,0,bdt,'boolean');
                        [~,locking_muxoutsig]=hdlnewsignal(['locking_muxout',stgnumstr],...
                        'filter',-1,0,0,bdt,'boolean');
                        [~,locked_ceoutsig]=hdlnewsignal(['locked_ceout_stage',stgnumstr],...
                        'filter',-1,0,0,bdt,'boolean');

                        hdlregsignal(prelocked_ceoutsig);

                        hdlsignals=[makehdlsignaldecl(prelocked_ceoutsig),...
                        makehdlsignaldecl(locking_muxoutsig),...
                        makehdlsignaldecl(locked_ceoutsig)];

                        [ud_bdy,ud_signal]=hdlunitdelay(locking_muxoutsig,prelocked_ceoutsig,...
                        ['stage',stgnumstr,'ceout_locking',hdlgetparameter('clock_process_label')],0);
                        hdlsignals=[hdlsignals,ud_signal];

                        hdlbody=[ud_bdy,hdlmux([ceout_prev,const_one],locking_muxoutsig,prelocked_ceoutsig,{'='},...
                        0,'when-else')];
                        hdlbody=[hdlbody,hdlmux([prelocked_ceoutsig,ceout_prev],locked_ceoutsig,prelocked_ceoutsig,{'='},...
                        1,'when-else')];

                        hdlbody=[hdlbody,hdlbitop([clkenb_tc,locked_ceoutsig],clkenb_this,'AND')];


                        function success=needCeoutValid(this,n)

                            castype=getCascadeType(this);
                            stimes=this.getSampleTimes;
                            success=strcmpi(this.Implementation,'localmultirate')&&...
                            ((stimes(n)==stimes(n+1))||...
                            strcmpi(castype,'interpolating'));





