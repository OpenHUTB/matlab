function elaborateLMS(this,hN,hC)



    slrate=hC.PirInputSignals(1).SimulinkRate;
    pirNetworkForFilterComp('push',hN);

    bfp=hC.SimulinkHandle;
    rto=get_param(bfp,'RuntimeObject');







    inputs=hN.PIRInputSignals;
    data_sig=inputs(1);
    desired_sig=inputs(2);

    outputs=hN.PIROutputSignals;
    filter_outsig=outputs(1);
    err_sig=outputs(2);

    cplx=hdlsignaliscomplex(data_sig);







    block_name=hdllegalname(get_param(bfp,'Name'));


    getInfo=0;
    leakage_rtoidx=[];mu_rtoidx=[];wgtic_rtoidx=[];
    for ii=1:rto.NumRuntimePrms
        rto_names=rto.RuntimePrm(ii).Name;


        if(strcmpi('LEAKAGE_RTP',rto_names))
            leakage_rtoidx=ii;
            getInfo=getInfo+1;
        elseif(strcmpi('MU_RTP',rto_names))
            mu_rtoidx=ii;
            getInfo=getInfo+1;
        elseif(strcmpi('WGT_IC_RTP',rto_names))
            wgtic_rtoidx=ii;
            getInfo=getInfo+1;
        end
        if(getInfo==3)
            break;
        end
    end




    if isempty(mu_rtoidx)
        muWL=this.hdlslResolve('firstCoeffWordLength',bfp);
        muFL=this.hdlslResolve('firstCoeffFracLength',bfp);
    else
        mufi=fi(rto.RuntimePrm(mu_rtoidx).Data);
        muWL=mufi.WordLength;
        muFL=mufi.FractionLength;
    end

    leakage=rto.RuntimePrm(leakage_rtoidx).Data;
    lkgfi=fi(leakage);
    leakageWL=lkgfi.WordLength;
    leakageFL=lkgfi.FractionLength;

    weightIC=(fi(rto.RuntimePrm(wgtic_rtoidx).Data));
    weightIC_WL=weightIC.WordLength;
    weightIC_FL=weightIC.FractionLength;



    accum_mode=get_param(bfp,'accumMode');
    if strcmpi(accum_mode,'Same as first input')
        [accWL,accFL,dummy]=hdlwordsize(hdlsignalsltype(data_sig));
        weightTdata_accFL=accFL;
    else
        accWL=this.hdlslResolve('accumWordLength',bfp);
        accFL=this.hdlslResolve('accumFracLength',bfp);
        weightTdata_accFL=this.hdlslResolve('accum2FracLength',bfp);
    end

    prod_mode=get_param(bfp,'prodOutputMode');
    if strcmpi(prod_mode,'Same as first input')

        [prodWL,prodFL,dummy]=hdlwordsize(hdlsignalsltype(data_sig));
        weightTdata_prodFL=prodFL;
        muErr_prodFL=prodFL;
        QuU_prodFL=prodFL;


    else

        prodWL=this.hdlslResolve('prodOutputWordLength',bfp);
        prodFL=this.hdlslResolve('prodOutputFracLength',bfp);
        weightTdata_prodFL=this.hdlslResolve('prodOutput2FracLength',bfp);
        muErr_prodFL=this.hdlslResolve('prodOutput3FracLength',bfp);
        QuU_prodFL=this.hdlslResolve('prodOutput4FracLength',bfp);
        quotient_prodFL=this.hdlslResolve('quotientFracLength',bfp);

    end

    roundmode=get_param(bfp,'roundingMode');

    roundmode=strrep(roundmode,'Ceiling','Ceil');
    roundmode=strrep(roundmode,'Zero','Fix');

    satmode=strcmpi(get_param(bfp,'overflowMode'),'on');



    filter_length=this.hdlslResolve('L',bfp);
    algorithm=get_param(bfp,'Algo');

    wgt_port=strcmpi(get_param(bfp,'weights'),'on');

    adapt=strcmpi(get_param(bfp,'Adapt'),'on');
    if strcmpi(get_param(bfp,'stepflag'),'Dialog')
        muport=false;

        mu=rto.RuntimePrm(mu_rtoidx).Data;
    else
        muport=true;
        mu=[];
    end

    if isscalar(weightIC)
        weightIC=repmat(weightIC,1,filter_length);
    end

    resetflag=get_param(bfp,'resetflag');
    switch(resetflag)
    case{'Rising edge'}
        resetport=true;
        resettype='rising';
    case{'Falling edge'}
        resetport=true;
        resettype='falling';
    case{'Either edge'}
        resetport=true;
        resettype='both';
    case{'Non-zero sample'}
        resetport=true;
        resettype='nonzero';
    case{'None'}
        resetport=false;
    end



    hTWeight=hN.getType('FixedPoint','Signed',true,...
    'WordLength',weightIC_WL,'FractionLength',-1*weightIC_FL);

    hTFiltersum=hN.getType('FixedPoint','Signed',true,...
    'WordLength',accWL,'FractionLength',-1*weightTdata_accFL);


    hTDatapipe=data_sig.Type;



    hTMu=hN.getType('FixedPoint','Signed',true,...
    'WordLength',muWL,'FractionLength',-1*muFL);

    hTLeakage=hN.getType('FixedPoint','Signed',true,...
    'WordLength',leakageWL,'FractionLength',-1*leakageFL);

    hTMuerr=hN.getType('FixedPoint','Signed',true,...
    'WordLength',prodWL,'FractionLength',-1*muErr_prodFL);
    hTMuerrUminus=hN.getType('FixedPoint','Signed',true,...
    'WordLength',prodWL+1,'FractionLength',-1*muErr_prodFL);

    hTWuacc=hN.getType('FixedPoint','Signed',true,...
    'WordLength',prodWL,'FractionLength',-1*QuU_prodFL);

    hTWuprod=hN.getType('FixedPoint','Signed',true,...
    'WordLength',prodWL,'FractionLength',-1*QuU_prodFL);









    Fm=fimath;
    Fm.RoundMode=roundmode;
    if satmode
        Fm.OverflowMode='Saturate';
    else
        Fm.OverflowMode='Wrap';
    end
    satmode=Fm.OverflowMode;













    if leakage~=1
        leakagevalidx=hN.addSignal2('Type',hTLeakage,'Name',['C_',upper(block_name),'_LEAKAGE'],...
        'SimulinkRate',slrate);
        pirelab.getConstComp(hN,leakagevalidx,leakage);



    else
        leakagevalidx=[];
    end


    iport_cnt=3;
    if~muport
        muidx=hN.addSignal2('Type',hTMu,'Name',['C_',upper(block_name),'_STEP_SIZE'],...
        'SimulinkRate',slrate);
        pirelab.getConstComp(hN,muidx,mu);



    else
        muidx=inputs(iport_cnt);
        iport_cnt=iport_cnt+1;
    end

    if adapt
        adaptinputidx=inputs(iport_cnt);
        iport_cnt=iport_cnt+1;
    else
        adaptinputidx=[];
    end

    resetportisboolean=false;
    if resetport
        rstinputidx=inputs(iport_cnt);
        iport_cnt=iport_cnt+1;%#ok<NASGU>

        resetportisboolean=hdlsignalisboolean(rstinputidx);

        if~(resetportisboolean&&strcmpi(resettype,'nonzero'))
            loadweightsidx=hN.addSignal2('Type',pir_boolean_t,'Name','load_weights',...
            'SimulinkRate',slrate);

        else
            loadweightsidx=[];
        end
    else
        rstinputidx=[];
        loadweightsidx=[];
    end





    if cplx
        hTWeightCplx=hdlcoder.tp_complex(hTWeight);
    else
        hTWeightCplx=hTWeight;
    end
    hTWeightCplxVector=pirelab.createPirArrayType(hTWeightCplx,filter_length);
    weightidx=hN.addSignal2('Type',hTWeightCplxVector,'Name','weight',...
    'SimulinkRate',slrate);


    if cplx
        hTFiltersumCplx=hdlcoder.tp_complex(hTFiltersum);
    else
        hTFiltersumCplx=hTFiltersum;
    end
    filtersumidx=hN.addSignal2('Type',hTFiltersumCplx,'Name','filter_sum',...
    'SimulinkRate',slrate);



    if cplx

        hTDatapipeCplxVector=pirelab.createPirArrayType(hTDatapipe,filter_length);
        datapipeconjidx=hN.addSignal2('Type',hTDatapipeCplxVector,'Name','data_pipe_conjugate',...
        'SimulinkRate',slrate);


    else
        datapipeconjidx=[];
    end
























    fir_obj=hdl.FIR(...
    'datain',data_sig,...
    'filterout',filtersumidx,...
    'taps',weightidx,...
    'length',filter_length,...
    'product_type',[prodWL,weightTdata_prodFL,1],...
    'product_mode',{roundmode,satmode},...
    'adder_mode',{roundmode,satmode},...
    'adder_implementation','try_tree',...
...
    'hN',hN,...
    'slrate',slrate...
    );
    fir_obj.elaborate;





    datapipeidx=get(fir_obj,'data_pipe');





    pirelab.getDTCComp(hN,filtersumidx,filter_outsig,roundmode,satmode);





    subType=err_sig.Type;
    desired_sig_cbs=hN.addSignal2('Type',subType,'Name',[desired_sig.Name,'_cbs'],...
    'SimulinkRate',slrate);
    filtersumidx_cbs=hN.addSignal2('Type',subType,'Name',[filtersumidx.Name,'_cbs'],...
    'SimulinkRate',slrate);
    pirelab.getDTCComp(hN,desired_sig,desired_sig_cbs,roundmode,satmode);
    pirelab.getDTCComp(hN,filtersumidx,filtersumidx_cbs,roundmode,satmode);
    subComp=pirelab.getSubComp(hN,[desired_sig_cbs,filtersumidx_cbs],err_sig,...
    roundmode,satmode,'filter_error_sub',subType);
    subComp.addComment('Calculate Filter Error');







    switch(algorithm)

    case{'Sign-Error LMS'}



        wgt_acc_input=do_sign_err_lms(hN,hC,datapipeidx,err_sig,muidx,filter_length,...
        mu,roundmode,satmode,hTWuprod);

    case{'Sign-Sign LMS'}



        wgt_acc_input=do_sign_sign_lms(hN,hC,datapipeidx,err_sig,muidx,filter_length,...
        mu,roundmode,satmode,hTWuprod);

    case{'Sign-Data LMS'}



        wgt_acc_input=do_sign_data_lms(hN,hC,datapipeidx,err_sig,muidx,filter_length,...
        roundmode,satmode,hTMuerr,hTMuerrUminus,hTWuprod,bfp);



    case{'LMS'}




        sp_muerr_mult=hdl.spblkmultiply(...
        'in1',muidx,...
        'in2',err_sig,...
        'outname','mu_err',...
        'product_sltype',hTMuerr,...
        'accumulator_sltype',hTMuerr,...
        'rounding',roundmode,...
        'saturation',satmode,...
        'hN',hN,...
        'slrate',slrate...
        );

        sp_muerr_mult.elaborate;

        muerridx=get(sp_muerr_mult,'out');


        if isempty(datapipeconjidx)
            datapipeconjidx=datapipeidx;
        else
            complex_conj_obj=hdl.complex_conjugate;

            complex_conj_obj.elaborate(hN,slrate,datapipeidx,datapipeconjidx,roundmode,satmode);
        end


        sp_muED_mult=hdl.spblkmultiply(...
        'in1',datapipeconjidx,...
        'in2',muerridx,...
        'outname','mu_err_data_prod',...
        'product_sltype',hTWuprod,...
        'accumulator_sltype',hTWuacc,...
        'rounding',roundmode,...
        'saturation',satmode,...
        'hN',hN,...
        'slrate',slrate...
        );

        sp_muED_mult.elaborate;

        muerrdataprodidx=get(sp_muED_mult,'out');


        wgt_acc_input=muerrdataprodidx;

    end



    if resetport


        if strcmpi(resettype,'nonzero')

            if resetportisboolean
                loadweightsidx=rstinputidx;
            else

                pirelab.getCompareToValueComp(hN,rstinputidx,loadweightsidx,'~=',0);
            end
        else
            ed=hdl.edge_detect(...
...
...
...
            'input',rstinputidx,...
            'output',loadweightsidx,...
            'edge_type',resettype,...
            'processName',[block_name,'_ed_',hdluniqueprocessname],...
            'hN',hN,...
            'slrate',slrate...
            );

            ed.elaborate;


        end
    end





    weight_update_obj=hdl.accumulator(...
...
...
...
    'inputs',wgt_acc_input,...
    'outputs',weightidx,...
    'resetvalues',weightIC,...
    'adder_mode',{roundmode,satmode},...
    'load_val',weightIC,...
    'load',loadweightsidx,...
    'reg_enable_accumulation',adaptinputidx,...
    'willread_reg_input',wgt_port,...
    'feedback_gain',leakagevalidx,...
    'feedback_gain_type',hTWuprod,...
    'sum_type',hTWuacc,...
...
    'feedback_gain_mode',{roundmode,satmode},...
    'processName',[block_name,'_acc_',hdluniqueprocessname],...
    'hN',hN,...
    'slrate',slrate...
    );


    weight_update_obj.elaborate;


    if wgt_port

        wop_comment=[block_name,' Weight Output Port'];

        wgt_regin=get(weight_update_obj,'reg_input');
        outSplitSignals=hdlexpandconnectiontovectorsignal(hN,outputs(3));
        if adapt


            weightunorderedidx=hN.addSignal2('Type',hTWeightCplxVector,'Name','weight_backwards',...
            'SimulinkRate',slrate);


            pirelab.getSwitchComp(hN,[wgt_regin,weightidx],weightunorderedidx,adaptinputidx,[],'==',1);


            weightSplitSignals=weightunorderedidx.split.PIROutputSignals;
            for ii=1:filter_length
                wComp=pirelab.getWireComp(hN,weightSplitSignals(ii),outSplitSignals(filter_length+1-ii));
            end

        else

            weightRegSplitSignals=wgt_regin.split.PIROutputSignals;
            for ii=1:filter_length
                wComp=pirelab.getWireComp(hN,weightRegSplitSignals(ii),outSplitSignals(filter_length+1-ii));
            end
        end
        wComp.addComment(wop_comment);
    end

















    pirNetworkForFilterComp('pop');



end




function wgt_acc_input=do_sign_err_lms(hN,hC,datapipeidx,err_sig,muidx,filter_length,...
    mu,roundmode,satmode,hTWuprod)




    Fm=fimath;
    Fm.RoundMode=roundmode;

    Fm.OverflowMode=satmode;
    slrate=hC.PirInputSignals(1).SimulinkRate;



    booleanhdl=pir_boolean_t;
    datapipe_exp=hdlexpandvectorsignal(datapipeidx);








    hTWuVector=pirelab.createPirArrayType(hTWuprod,filter_length);
    mudataprodnegidx=hN.addSignal2('Type',hTWuVector,'Name','mu_data_prod_neg',...
    'SimulinkRate',slrate);

    errsignidx=hN.addSignal2('Type',booleanhdl,'Name','error_sign',...
    'SimulinkRate',slrate);

    mudataprodidx=hN.addSignal2('Type',hTWuVector,'Name','mu_data_prod',...
    'SimulinkRate',slrate);

    muESDprodtmpidx=hN.addSignal2('Type',hTWuVector,'Name','mu_ES_data_prod_tmp',...
    'SimulinkRate',slrate);

    muESDprodidx=hN.addSignal2('Type',hTWuVector,'Name','mu_ES_data_prod',...
    'SimulinkRate',slrate);



    wuprodzeroidx=hN.addSignal2('Type',hTWuprod,'Name','C_WU_ZERO',...
    'SimulinkRate',slrate);
    pirelab.getConstComp(hN,wuprodzeroidx,0);

    errEQidx=hN.addSignal2('Type',booleanhdl,'Name','err_equals_zero',...
    'SimulinkRate',slrate);

    negmuidx=hN.addSignal2('Type',muidx.Type,'Name','negative_step_size',...
    'SimulinkRate',slrate);



    if~isempty(mu)
        hTmu=muidx.Type.BaseType;
        muWL=hTmu.WordLength;
        muFL=-1*hTmu.FractionLength;
        muneg_fi=fi(-mu,1,muWL,muFL,Fm);


        pirelab.getConstComp(hN,negmuidx,muneg_fi);
    else

        pirelab.getUnaryMinusComp(hN,muidx,negmuidx,satmode);
    end

    mudataprod_exp=hdlexpandconnectiontovectorsignal(hN,mudataprodidx);
    mudataprodneg_exp=hdlexpandconnectiontovectorsignal(hN,mudataprodnegidx);
    muESDprodtmp_exp=hdlexpandconnectiontovectorsignal(hN,muESDprodtmpidx);
    muESDprod_exp=hdlexpandconnectiontovectorsignal(hN,muESDprodidx);






    errWL=err_sig.Type.BaseType.WordLength;
    pirelab.getBitSliceComp(hN,err_sig,errsignidx,errWL-1,errWL-1);

    pirelab.getCompareToValueComp(hN,err_sig,errEQidx,'==',0);

    for ii=1:filter_length

        tap_comment=['update for tap ',num2str(ii-1)];

        mcomp=pirelab.getMulComp(hN,[datapipe_exp(ii),muidx],mudataprod_exp(ii),...
        roundmode,satmode);
        mcomp.addComment(tap_comment);

        pirelab.getMulComp(hN,[datapipe_exp(ii),negmuidx],mudataprodneg_exp(ii),...
        roundmode,satmode);



        pirelab.getSwitchComp(hN,[mudataprod_exp(ii),mudataprodneg_exp(ii)],...
        muESDprodtmp_exp(ii),errsignidx,'choosePosNeg','==',0);



        pirelab.getSwitchComp(hN,[wuprodzeroidx,muESDprodtmp_exp(ii)],...
        muESDprod_exp(ii),errEQidx,'chooseZeroNonzero','==',1);
    end

    wgt_acc_input=muESDprodidx;
end





function wgt_acc_input=do_sign_data_lms(hN,hC,datapipeidx,err_sig,muidx,filter_length,...
    roundmode,satmode,hTMuerr,hTMuerrUminus,hTWuprod,~)




    Fm=fimath;
    Fm.RoundMode=roundmode;

    Fm.OverflowMode=satmode;
    slrate=hC.PirInputSignals(1).SimulinkRate;



    booleanhdl=pir_boolean_t;
    datapipe_exp=hdlexpandvectorsignal(datapipeidx);








    hTWuVector=pirelab.createPirArrayType(hTWuprod,filter_length);

    booleanVector=pirelab.createPirArrayType(booleanhdl,filter_length);
    datasignidx=hN.addSignal2('Type',booleanVector,'Name','data_sign',...
    'SimulinkRate',slrate);


    wuprodzeroidx=hN.addSignal2('Type',hTWuprod,'Name','C_WU_ZERO',...
    'SimulinkRate',slrate);
    pirelab.getConstComp(hN,wuprodzeroidx,0);

    dataEQidx=hN.addSignal2('Type',booleanVector,'Name','data_equals_zero',...
    'SimulinkRate',slrate);

    muDSEprodidx=hN.addSignal2('Type',hTWuVector,'Name','mu_DS_err_prod',...
    'SimulinkRate',slrate);

    muerridx=hN.addSignal2('Type',hTMuerr,'Name','mu_err',...
    'SimulinkRate',slrate);

    muerrposnegidx=hN.addSignal2('Type',hTWuVector,'Name','mu_err_posneg',...
    'SimulinkRate',slrate);

    muerruminusidx=hN.addSignal2('Type',hTMuerrUminus,'Name','mu_err_uminus',...
    'SimulinkRate',slrate);
    muerrnegtmpidx=hN.addSignal2('Type',hTWuprod,'Name','mu_err_neg_tmp',...
    'SimulinkRate',slrate);


    muerrpostmpidx=hN.addSignal2('Type',hTWuprod,'Name','mu_err_pos_tmp',...
    'SimulinkRate',slrate);



    datasign_exp=hdlexpandconnectiontovectorsignal(hN,datasignidx);
    dataEQ_exp=hdlexpandconnectiontovectorsignal(hN,dataEQidx);
    muDSEprod_exp=hdlexpandconnectiontovectorsignal(hN,muDSEprodidx);
    muerrposneg_exp=hdlexpandconnectiontovectorsignal(hN,muerrposnegidx);





    pirelab.getMulComp(hN,[muidx,err_sig],muerridx,...
    roundmode,satmode);











    pirelab.getDTCComp(hN,muerridx,muerrpostmpidx,roundmode,satmode);





    pirelab.getUnaryMinusComp(hN,muerridx,muerruminusidx);
    pirelab.getDTCComp(hN,muerruminusidx,muerrnegtmpidx,roundmode,satmode);


    for ii=1:filter_length

        tap_comment=['update for tap ',num2str(ii-1)];


        dataWL=datapipeidx.Type.BaseType.Wordlength;
        beComp=pirelab.getBitSliceComp(hN,datapipe_exp(ii),datasign_exp(ii),dataWL-1,dataWL-1);
        beComp.addComment(tap_comment);

        pirelab.getCompareToValueComp(hN,datapipe_exp(ii),dataEQ_exp(ii),'==',0);


        pirelab.getSwitchComp(hN,[muerrpostmpidx,muerrnegtmpidx],muerrposneg_exp(ii),...
        datasign_exp(ii),'choosePosNeg','==',0);



        pirelab.getSwitchComp(hN,[muerrposneg_exp(ii),wuprodzeroidx],muDSEprod_exp(ii),...
        dataEQ_exp(ii),'chooseZeroNonzero','==',0);

    end

    wgt_acc_input=muDSEprodidx;

end




function wgt_acc_input=do_sign_sign_lms(hN,hC,datapipeidx,err_sig,muidx,filter_length,...
    mu,roundmode,satmode,hTWuprod)




    Fm=fimath;
    Fm.RoundMode=roundmode;

    Fm.OverflowMode=satmode;
    slrate=hC.PirInputSignals(1).SimulinkRate;



    booleanhdl=pir_boolean_t;
    datapipe_exp=hdlexpandvectorsignal(datapipeidx);








    errsignidx=hN.addSignal2('Type',booleanhdl,'Name','error_sign',...
    'SimulinkRate',slrate);

    errEQidx=hN.addSignal2('Type',booleanhdl,'Name','err_equals_zero',...
    'SimulinkRate',slrate);

    hTBooleanVector=pirelab.createPirArrayType(booleanhdl,filter_length);
    datasignidx=hN.addSignal2('Type',hTBooleanVector,'Name','data_sign',...
    'SimulinkRate',slrate);

    dataEQidx=hN.addSignal2('Type',hTBooleanVector,'Name','data_equals_zero',...
    'SimulinkRate',slrate);



    wuprodzeroidx=hN.addSignal2('Type',hTWuprod,'Name','C_WU_ZERO',...
    'SimulinkRate',slrate);
    pirelab.getConstComp(hN,wuprodzeroidx,0);


    hTMuType=muidx.Type;
    hTMuVector=pirelab.createPirArrayType(hTMuType,filter_length);
    muposnegidx=hN.addSignal2('Type',hTMuVector,'Name','step_size_pos_neg',...
    'SimulinkRate',slrate);

    hTWuVector=pirelab.createPirArrayType(hTWuprod,filter_length);
    muSSprodidx=hN.addSignal2('Type',hTWuVector,'Name','mu_SS_prod',...
    'SimulinkRate',slrate);

    negmuidx=hN.addSignal2('Type',hTMuType,'Name','negative_step_size',...
    'SimulinkRate',slrate);

    muselidx=hN.addSignal2('Type',hTBooleanVector,'Name','mu_posneg_sel',...
    'SimulinkRate',slrate);

    muzeroselidx=hN.addSignal2('Type',hTBooleanVector,'Name','mu_zero_sel',...
    'SimulinkRate',slrate);








    mucastidx=hN.addSignal2('Type',hTWuVector,'Name','step_size_posneg_cast',...
    'SimulinkRate',slrate);





    datasign_in_exp=hdlexpandconnectiontovectorsignal(hN,datasignidx);
    dataEQ_in_exp=hdlexpandconnectiontovectorsignal(hN,dataEQidx);
    musel_in_exp=hdlexpandconnectiontovectorsignal(hN,muselidx);
    muzerosel_in_exp=hdlexpandconnectiontovectorsignal(hN,muzeroselidx);
    mucast_in_exp=hdlexpandconnectiontovectorsignal(hN,mucastidx);
    muposneg_in_exp=hdlexpandconnectiontovectorsignal(hN,muposnegidx);
    muSSprod_in_exp=hdlexpandconnectiontovectorsignal(hN,muSSprodidx);

    musel_exp=hdlexpandvectorsignal(muselidx);
    muzerosel_exp=hdlexpandvectorsignal(muzeroselidx);
    muposneg_exp=hdlexpandvectorsignal(muposnegidx);


    if~isempty(mu)
        hTmu=muidx.Type.BaseType;
        muWL=hTmu.WordLength;
        muFL=-1*hTmu.FractionLength;
        muneg_fi=fi(-mu,1,muWL,muFL,Fm);


        pirelab.getConstComp(hN,negmuidx,muneg_fi);
    else

        pirelab.getUnaryMinusComp(hN,muidx,negmuidx,satmode);
    end




    errWL=err_sig.Type.BaseType.WordLength;
    pirelab.getBitSliceComp(hN,err_sig,errsignidx,errWL-1,errWL-1);

    pirelab.getCompareToValueComp(hN,err_sig,errEQidx,'==',0);

    for ii=1:filter_length


        tap_comment=['update for tap ',num2str(ii-1)];

        dataWL=datapipeidx.Type.BaseType.WordLength;
        beComp=pirelab.getBitSliceComp(hN,datapipe_exp(ii),datasign_in_exp(ii),dataWL-1,dataWL-1);
        beComp.addComment(tap_comment);

        pirelab.getCompareToValueComp(hN,datapipe_exp(ii),dataEQ_in_exp(ii),'==',0);



        pirelab.getBitwiseOpComp(hN,[errsignidx,datasign_in_exp(ii)],musel_in_exp(ii),'XOR');

        pirelab.getBitwiseOpComp(hN,[errEQidx,dataEQ_in_exp(ii)],muzerosel_in_exp(ii),'OR');



        pirelab.getSwitchComp(hN,[muidx,negmuidx],muposneg_in_exp(ii),musel_exp(ii),[],'==',0);


        pirelab.getDTCComp(hN,muposneg_exp(ii),mucast_in_exp(ii),roundmode,satmode);



        pirelab.getSwitchComp(hN,[mucast_in_exp(ii),wuprodzeroidx],muSSprod_in_exp(ii),muzerosel_exp(ii),[],'==',0);
    end

    wgt_acc_input=muSSprodidx;

end




