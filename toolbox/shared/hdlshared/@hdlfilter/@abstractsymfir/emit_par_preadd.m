function[hdl_arch,preaddlist]=emit_par_preadd(this,delaylist)





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        vector_dims=1;
    else
        vector_dims=pirelab.getVectorTypeInfo(delaylist(1),1);
    end


    num_channel=hdlgetparameter('filter_generate_multichannel');
    delaylist=delaylist(1:num_channel:end);

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');

    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    coeffs=this.Coefficients;
    firlen=length(coeffs);
    halflen=floor(firlen/2);
    oddtaps=mod(firlen,2);
    if strcmpi(this.implementation,'parallel')
        cplxity=this.isInputPortComplex;
    else
        cplxity=0;
    end


    if emitMode
        SimulinkRate=0;
    else
        SimulinkRate=delaylist(1).SimulinkRate;
    end

    if strcmpi(this.implementation,'distributedarithmetic')
        [tapsumvtype,tapsumsltype]=hdlgettypesfromsizes(inputall.size+1,inputall.bp,true);
    else
        tapsumall=hdlgetallfromsltype(this.tapsumSLtype);
        tapsumvtype=tapsumall.vtype;
        tapsumsltype=tapsumall.sltype;
        multiplicandvtype=tapsumvtype;
        multiplicandsltype=tapsumsltype;
    end
    rmode=this.Roundmode;
    [~,~,~,~,multiplicandrounding]=deal(rmode);

    omode=this.Overflowmode;
    [~,~,~,~,multiplicandsaturation]=deal(omode);

    preaddlist=[];
    for tap=1:halflen
        coeffn=coeffs(tap);
        if coeffn~=0
            [~,sumout]=hdlnewsignal(['tapsum',num2str(tap)],'filter',-1,...
            cplxity,vector_dims,tapsumvtype,tapsumsltype,SimulinkRate);

            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumout)];





            input1=delaylist(tap);
            input2=delaylist(firlen-(tap-1));
            output=sumout;
            [tempbody,tempsignals]=gettapsumout(this,input1,input2,output);

            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
            if~strcmpi(this.implementation,'distributedarithmetic')
                [~,castsumout]=hdlnewsignal('tapsum_mcand','filter',-1,cplxity,...
                vector_dims,multiplicandvtype,multiplicandsltype,SimulinkRate);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(castsumout)];
                tempbody=hdldatatypeassignment(sumout,castsumout,...
                multiplicandrounding,multiplicandsaturation);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            else
                castsumout=sumout;
            end
        else

            if emitMode
                castsumout=0;
            else

                [~,dummy]=hdlnewsignal(['tapsum',num2str(tap)],'filter',-1,...
                cplxity,vector_dims,tapsumvtype,tapsumsltype,SimulinkRate);
                castsumout=dummy;



                hN.removeSignal(dummy);

            end
        end
        preaddlist=[preaddlist,castsumout];
    end

    if oddtaps==1
        if strcmpi(this.implementation,'distributedarithmetic')


            if emitMode
                [~,tapsumcastsig]=hdlnewsignal(['tapsum',num2str(tap+1)],'filter',...
                -1,0,vector_dims,tapsumvtype,tapsumsltype);
            else
                [~,tapsumcastsig]=hdlnewsignal(['tapsum',num2str(tap+1)],'filter',...
                -1,0,vector_dims,tapsumvtype,tapsumsltype,SimulinkRate);
            end


            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(tapsumcastsig)];
            tempbody=hdldatatypeassignment(delaylist(halflen+1),tapsumcastsig,...
            'floor',0);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            preaddlist=[preaddlist,tapsumcastsig];
        else


            if strcmpi(this.class,'hdlfilter.dfsymfir')||...
                (strcmpi(this.class,'hdlfilter.dfasymfir')&&firlen==1)


                if emitMode
                    preaddlist=[preaddlist,delaylist(halflen+1)];
                else
                    [~,tapsumcastsig]=hdlnewsignal(['tapsum',num2str(tap+1)],'filter',...
                    -1,cplxity,vector_dims,tapsumvtype,tapsumsltype,SimulinkRate);
                    hdldatatypeassignment(delaylist(halflen+1),tapsumcastsig,'floor',0);
                    preaddlist=[preaddlist,tapsumcastsig];
                end
            end

            if~emitMode&&strcmpi(this.class,'hdlfilter.dfasymfir')
                pirelab.getNilComp(hN,delaylist(halflen+1));
            end
        end
    end