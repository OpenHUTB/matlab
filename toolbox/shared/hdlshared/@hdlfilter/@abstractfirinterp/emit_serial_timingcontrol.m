function[hdl_arch,ce,counter_out,tcinfo]=emit_serial_timingcontrol(this,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    phases=this.phases;
    polycoeffs=this.polyphasecoefficients;

    if hdlgetparameter('clockinputs')==2
        [hdl_arch,ce,counter_out,tcinfo]=emit_serialtc_mclock(ce,polycoeffs,phases,hdl_arch);
    else
        ffactor=hdlgetparameter('foldingfactor');
        count_to=phases*ffactor;

        multcycles=hdlgetparameter('multiplier_input_pipeline')+...
        hdlgetparameter('multiplier_output_pipeline');

        ssi=hdlgetparameter('filter_serialsegment_inputs');
        ssi=sort(ssi,'descend');

        [summary,~,needSymmOptimization]=this.summaryofCoeffs;

        mults=numel(ssi);
        multslike=mults+sum(summary(:,3));

        if strcmpi(hdlgetparameter('filter_fir_final_adder'),'pipelined')
            excesslatency=ceil(log2(multslike));
            cycles2accum=(ffactor+1)+excesslatency;
            hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+excesslatency);
        else
            cycles2accum=(ffactor+1);
        end

        cycles2accum=cycles2accum+multcycles;













        if hdlgetparameter('filter_registered_input')==1
            phases_cell{1}=0;
            cycles2accum=cycles2accum+1;
        else
            phases_cell{1}=count_to-1;
        end

        if~this.needAccumulator
            cycles2accum=cycles2accum-1;

        end


        phasesaccumMux=mod([cycles2accum-1:ffactor:cycles2accum-1+count_to-1],count_to);
        phases_cell{2}=phasesaccumMux;

        if hdlgetparameter('filter_registered_output')==1

            phases_cell{3}=mod(phasesaccumMux+1,count_to);
            cycles2output=cycles2accum+1;
        else
            cycles2output=cycles2accum;
        end


        [mod_polycoeffs,power2coeffs]=modifypolycoeffsforpowerof2(this,polycoeffs);


        if needSymmOptimization

            mod_polycoeffs=this.modifypolycoeffsforsymm(mod_polycoeffs);
        end


        [~,coeffsindexVal]=getSerialMuxOrder(this,mod_polycoeffs,mod_polycoeffs,ssi);

        numphases=ssi(1)*phases;
        for n=1:numel(coeffsindexVal)
            if length(coeffsindexVal{n})<numphases
                if hdlgetparameter('filter_registered_input')==1
                    phases_cell{end+1}=mod(coeffsindexVal{n}+multcycles,numphases);
                else
                    phases_cell{end+1}=mod(coeffsindexVal{n}-1+multcycles,numphases);
                end
            end
        end

        indx_phasemuxes_end=length(phases_cell);




        ce.power2phasemux=zeros(1,phases);


        ro_power2coeffs=power2coeffs;
        numphases_before_pwr2=length(phases_cell);
        for n=1:size(ro_power2coeffs,1)
            if~isempty(find(ro_power2coeffs(n,:)))
                if hdlgetparameter('filter_registered_input')==1
                    phases_cell{end+1}=mod((n-1)*ffactor+1+multcycles,count_to);
                else
                    phases_cell{end+1}=mod((n-1)*ffactor+multcycles,count_to);
                end
                ce.power2phasemux(n)=1;
            end
        end
        numpwr2phases=length(phases_cell)-numphases_before_pwr2;


        if hdlgetparameter('filter_generate_datavalid_output')
            phases_cell{end+1}=mod((0:ffactor:count_to-1)+multcycles,count_to);
        end
        [u_phases_cell,indices_phases]=uniquifyphases(phases_cell);


        countsize=max(2,ceil(log2(count_to)));
        [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
        [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
        hdlregsignal(counter_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];
        [ctrbody,ctr_sigs]=hdlcounter(counter_out,count_to,'Counter',1,count_to-1,u_phases_cell);

        hdladdclockenablesignal(ctr_sigs);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,ctrbody];


        ctr_sigs=ctr_sigs(indices_phases);


        tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
        tcinfo.phases=u_phases_cell;
        tcinfo.enbsOut=ctr_sigs;
        tcinfo.maxCount=count_to;
        tcinfo.initValue=count_to-1;




        ce.delay=ctr_sigs(1);
        ce.ceout=ce.delay;
        ce.accummux=ctr_sigs(2);
        if hdlgetparameter('filter_registered_output')==1

            ce.output=ctr_sigs(3);
            indx_phasemuxes_strt=4;
        else
            indx_phasemuxes_strt=3;
        end


        ce.accum=hdlgetcurrentclockenable;
        phasemuxes=ctr_sigs(indx_phasemuxes_strt:indx_phasemuxes_end);


        if isempty(phasemuxes)
            ce.phasemux=[];
        else
            phasemuxes=[zeros(1,mults-length(phasemuxes)),phasemuxes];
            ce.phasemux=phasemuxes;
        end
        if numpwr2phases>0
            ce.power2phasemux(find(ce.power2phasemux))=ctr_sigs(indx_phasemuxes_end+1:indx_phasemuxes_end+numpwr2phases);
        else
            ce.power2phasemux(find(ce.power2phasemux))=[];
        end

        hdlsetparameter('foldingfactor',count_to/phases);
        fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrateinout',...
        count_to,count_to/phases)));
...
...
...
...




        if hdlgetparameter('filter_generate_datavalid_output')
            ce.outputvld=ctr_sigs(end);
            if hdlgetparameter('filter_registered_input')
                ceoutput_vld_delays=1;
            else
                ceoutput_vld_delays=0;
            end

            cyclestoaccum=count_to/phases;
            if cyclestoaccum==1
                cyclestoaccum=0;
            end
            ceoutput_vld_delays=ceoutput_vld_delays+1+cyclestoaccum;


            [intdbody,intdsignals,intdconst,delayedop]=emit_PhaseShiftRegisterDelay(this,ce.outputvld,...
            ['ceout_delay',hdlgetparameter('clock_process_label')],ceoutput_vld_delays);
            hdl_arch.signals=[hdl_arch.signals,intdsignals];
            hdl_arch.constants=[hdl_arch.constants,intdconst];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,intdbody];
            ce.outputvld=delayedop;

        end

    end

    function[uniq_phases,indices]=uniquifyphases(phases)



        if iscell(phases)
            phases_str=num2strings(phases);
            [uniq_phases,~,indices]=unique(phases_str);
            uniq_phases=strings2num(uniq_phases);
        else

        end


        function cellofstrings=num2strings(cellofnums)


            cellofstrings=cell(1,numel(cellofnums));
            for n=1:numel(cellofnums)
                cellofstrings{n}=num2str(cellofnums{n});
            end

            function cellofnums=strings2num(cellofstrings)

                cellofnums=cell(1,numel(cellofstrings));
                for n=1:numel(cellofstrings)
                    cellofnums{n}=str2num(cellofstrings{n});
                end


                function[hdl_arch,ce,counter_out,tcinfo]=emit_serialtc_mclock(ce,polycoeffs,phases,hdl_arch)



                    pp_firlen=size(polycoeffs,2);
                    count_to=phases*pp_firlen;
                    phases_cell{1}=count_to-1;
                    phases_cell{2}=0:pp_firlen:count_to-pp_firlen;
                    if hdlgetparameter('filter_registered_input')==1
                        if hdlgetparameter('filter_registered_output')==1

                        else
                            phases_cell{3}=count_to-pp_firlen;
                        end
                    else
                        if hdlgetparameter('filter_registered_output')==1

                            phases_cell{3}=count_to-1-pp_firlen;
                        else
                            phases_cell{3}=count_to-pp_firlen;
                        end
                    end
                    countsize=max(2,ceil(log2(count_to)));
                    [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
                    [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
                    hdlregsignal(counter_out);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];

                    tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
                    [ctrbody,ce.ctr_sigs]=hdlcounter(counter_out,count_to,'Counter',1,count_to-1,phases_cell);
                    tcinfo.enbsOut=ce.ctr_sigs;
                    tcinfo.maxCount=count_to;
                    tcinfo.phases=phases_cell;
                    tcinfo.initValue=count_to-1;

                    hdladdclockenablesignal(ce.ctr_sigs);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr_sigs)];
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,ctrbody];
                    cutbits=log2(pp_firlen);
                    if pp_firlen>1
                        if cutbits==floor(cutbits)

                            [countvtype,countsltype]=hdlgettypesfromsizes(cutbits,0,0);
                            [~,ce.ctr1_out]=hdlnewsignal('cur_count1','filter',-1,0,0,...
                            countvtype,countsltype);

                            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr1_out)];
                            ctr_body1=hdlsliceconcat(counter_out,{cutbits-1:-1:0},ce.ctr1_out);
                        else

                            count_to1=pp_firlen;
                            count_bits=max(2,ceil(log2(count_to1)));
                            [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
                            [~,ce.ctr1_out]=hdlnewsignal('cur_count1','filter',-1,0,0,...
                            countvtype,countsltype);
                            hdlregsignal(ce.ctr1_out);
                            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr1_out)];
                            ctr_body1=hdlcounter(ce.ctr1_out,count_to1,['Counter1',...
                            hdlgetparameter('clock_process_label')],1,count_to1-1,{});
                        end
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body1];
                    end
                    ce.delay=ce.ctr_sigs(1);
                    if hdlgetparameter('filter_registered_input')==1
                        if hdlgetparameter('filter_registered_output')==1
                            ce.ceout=ce.ctr_sigs(1);
                        else
                            ce.ceout=ce.ctr_sigs(3);
                        end
                    else
                        if hdlgetparameter('filter_registered_output')==1

                            ce.ceout=ce.ctr_sigs(3);
                        else
                            ce.ceout=ce.ctr_sigs(3);
                        end
                    end
                    hdladdclockenablesignal(ce.ceout);
                    ce.afinal=ce.ctr_sigs(2);
                    ce.accum=hdlgetcurrentclockenable;

                    ce.output=ce.afinal;
                    hdlsetparameter('foldingfactor',count_to/phases);
                    if hdlgetparameter('filter_registered_input')==1&&...
                        hdlgetparameter('filter_registered_output')~=1
                        hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+1);
                    else
                        hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+2);
                    end
                    fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrateinout',...
                    count_to,count_to/phases)));
...
...
...
...

