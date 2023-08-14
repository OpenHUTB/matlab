function this=accumulator(varargin)



    this=hdl.accumulator;
    this.init(varargin{:});

    hN=this.hN;
    emitmode=isempty(hN);
    slrate=this.slrate;

    cplx=hdlsignaliscomplex(this.outputs);

    if isempty(this.use_default_emit)
        this.use_default_emit=false;
    end

    outname_root=rootname(this.outputs);

    outsizes=hdlsignalsizes(this.outputs);
    if emitmode
        outsltype=hdlsignalsltype(this.outputs);
        outvtype=hdlsignalvtype(this.outputs);
        [outWL,outBP,outSIGNED]=deal(outsizes(1),outsizes(2),outsizes(3));
        [sumvtype,sumsltype]=hdlgettypesfromsizes(this.sum_type(1),...
        this.sum_type(2),this.sum_type(3));
    end
    this.num_copies=length(hdlexpandvectorsignal(this.outputs));





    if isempty(this.accumulator_style)
        switch 2*(~isempty(this.load))+(~isempty(this.reg_enable_accumulation)),
        case 0,this.accumulator_style='none';
        case 1,this.accumulator_style='acc_enable_only';
        case 2,this.accumulator_style='load_only';
        case 3,this.accumulator_style='load_and_acc_enable';
        end
    end



    if isempty(this.load)
        this.reg_output=this.outputs;
    else
        if strcmpi(this.accumulator_style,'hwstyle_loadable')

            this.reg_output=this.outputs;
            cplxload=~isreal(this.load_val);
            if emitmode
                for ii=1:length(this.load_val)
                    this.load_val_hdlconst{ii}.real=hdlconstantvalue(real(this.load_val(ii)),outWL,outBP,outSIGNED);
                    if cplxload
                        this.load_val_hdlconst{ii}.imag=hdlconstantvalue(imag(this.load_val(ii)),outWL,outBP,outSIGNED);
                    end
                end
            end
        else
            this.use_default_emit=true;
            if emitmode

                [~,this.load_val_idx]=hdlnewsignal([(outname_root),'_load_val'],'block',-1,cplx,...
                this.num_copies,outvtype,outsltype);



                [~,this.reg_output]=hdlnewsignal([outname_root,'_pre_outputmux'],'block',-1,cplx,this.num_copies,...
                outvtype,outsltype);
            else
                hTOut=this.outputs.Type;
                this.load_val_idx=hN.addSignal2('Type',hTOut,'Name',[(outname_root),'_load_val'],...
                'SimulinkRate',slrate);
                this.reg_output=hN.addSignal2('Type',hTOut,'Name',[outname_root,'_pre_outputmux'],...
                'SimulinkRate',slrate);
            end
        end
    end

    if emitmode

        hdlregsignal(this.reg_output);



        if this.willread_reg_input
            this.use_default_emit=true;
        end

        if~(strcmpi(this.adder_mode{1},'floor')&&~this.adder_mode{2})
            this.use_default_emit=true;
        end
        if~isempty(this.feedback_gain)&&(this.feedback_gain~=1)
            this.use_default_emit=true;
        end
        if~(all(outsizes==this.sum_type)&&(outWL~=1)&&outSIGNED)
            this.use_default_emit=true;
            this.dtc_adder_output=true;
        else
            this.dtc_adder_output=false;
        end

    else
        this.dtc_adder_output=true;
    end


    if this.use_default_emit||~emitmode

        if~isempty(this.feedback_gain)
            if emitmode
                [fbkoutvtype,fbkoutsltype]=hdlgettypesfromsizes(this.feedback_gain_type(1),...
                this.feedback_gain_type(2),this.feedback_gain_type(3));

                [~,this.gainoutidx]=hdlnewsignal([outname_root,'_scaled'],...
                'block',-1,cplx,this.num_copies,fbkoutvtype,fbkoutsltype);
            else
                if cplx
                    hTGainCplx=hdlcoder.tp_complex(this.feedback_gain_type);
                else
                    hTGainCplx=this.feedback_gain_type;
                end
                hTGainCplxVector=pirelab.createPirArrayType(hTGainCplx,this.num_copies);
                this.gainoutidx=hN.addSignal2('Type',hTGainCplxVector,'Name',[outname_root,'_scaled'],...
                'SimulinkRate',slrate);
            end
        else
            this.gainoutidx=this.outputs;
        end

        if emitmode

            [~,this.adder_output]=hdlnewsignal([outname_root,'_adder_output'],...
            'block',-1,cplx,this.num_copies,sumvtype,sumsltype);


            if this.dtc_adder_output
                [~,this.adder_output_recast]=hdlnewsignal([rootname(this.adder_output),'_cast'],'block',-1,cplx,this.num_copies,...
                outvtype,outsltype);
            else
                this.adder_output_recast=this.adder_output;
            end


            if strcmpi(this.accumulator_style,'load_and_acc_enable')
                [~,this.reg_input]=hdlnewsignal([outname_root,'_prereg'],'block',-1,cplx,this.num_copies,...
                outvtype,outsltype);
            else
                this.reg_input=this.adder_output_recast;
            end
        else



            if cplx
                hTSumCplx=hdlcoder.tp_complex(this.sum_type);
            else
                hTSumCplx=this.feedback_gain_type;
            end
            hTSumCplxVector=pirelab.createPirArrayType(hTSumCplx,this.num_copies);
            this.adder_output=hN.addSignal2('Type',hTSumCplxVector,'Name',[outname_root,'_adder_output'],...
            'SimulinkRate',slrate);


            if this.dtc_adder_output


                this.adder_output_recast=hN.addSignal2('Type',this.outputs.Type,'Name',[outname_root,'_adder_output_cast'],...
                'SimulinkRate',slrate);
            else
                this.adder_output_recast=this.adder_output;
            end


            if strcmpi(this.accumulator_style,'load_and_acc_enable')
                this.reg_input=hN.addSignal2('Type',this.outputs.Type,'Name',[outname_root,'_prereg'],...
                'SimulinkRate',slrate);
            else
                this.reg_input=this.adder_output_recast;
            end
        end
    end


    this.addend1=this.gainoutidx;
    this.addend2=this.inputs;
end




function str=rootname(sig)
    repostfix=hdlgetparameter('complex_real_postfix');
    str=sig.Name;
    if hdlsignaliscomplex(sig)
        pfixidx=strfind(str,repostfix);
        if~isempty(pfixidx)
            str(pfixidx(end):end)=[];
        end
    end
end


