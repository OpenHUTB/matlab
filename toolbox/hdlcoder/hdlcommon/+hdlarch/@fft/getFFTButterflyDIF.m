function hBFNet=getFFTButterflyDIF(hN,FFTInfo,inputRate,isSimpleArch)


















    if nargin<4
        isSimpleArch=false;
    end


    dataType=FFTInfo.outputType;
    accumType=FFTInfo.accumType;
    prodType=FFTInfo.prodType;
    twiddleType=FFTInfo.sineType;

    dataBaseType=dataType.getLeafType;
    accumBaseType=accumType.getLeafType;
    prodBaseType=prodType.getLeafType;
    twiddleBaseType=twiddleType.getLeafType;

    ufix1Type=pir_ufixpt_t(1,0);




    if~isSimpleArch



        hBFNet=pirelab.createNewNetwork(...
        'Network',hN,...
        'Name',sprintf('%s_Butterfly_DIF_Unit',FFTInfo.refName),...
        'InportNames',{'u','v','twiddle','twiddleone'},...
        'InportTypes',[dataType,dataType,twiddleType,ufix1Type],...
        'InportRates',[inputRate,inputRate,inputRate,inputRate],...
        'OutportNames',{'x_out','y_out'},...
        'OutportTypes',[dataType,dataType]);


        u=hBFNet.PirInputSignals(1);
        v=hBFNet.PirInputSignals(2);
        twiddle=hBFNet.PirInputSignals(3);
        twiddleone=hBFNet.PirInputSignals(4);
        x_out=hBFNet.PirOutputSignals(1);
        y_out=hBFNet.PirOutputSignals(2);


        hdlgetclockbundle(hBFNet,[],u,1,1,0);





        u_p=hBFNet.addSignal(dataType,'u_p');
        v_p=hBFNet.addSignal(dataType,'v_p');
        tw_p=hBFNet.addSignal(twiddleType,'tw_p');
        pComp=pirelab.getUnitDelayComp(hBFNet,u,u_p,'u_pc');
        pComp.addComment('Input pipeline register on u');
        pComp=pirelab.getUnitDelayComp(hBFNet,v,v_p,'v_pc');
        pComp.addComment('Input pipeline register on v');
        pComp=pirelab.getIntDelayComp(hBFNet,twiddle,tw_p,FFTInfo.pipeAddMinusDelay,'twd');
        pComp.addComment('Input pipeline register on twiddle');


        u_accum=hBFNet.addSignal(accumType,'u_accum');
        v_accum=hBFNet.addSignal(accumType,'v_accum');
        dtcComp=pirelab.getDTCComp(hBFNet,u_p,u_accum,FFTInfo.rndMode,FFTInfo.satMode,'RWV','u_accum_dtc');
        dtcComp.addComment('Data type conversion to accumulator data type');
        dtcComp=pirelab.getDTCComp(hBFNet,v_p,v_accum,FFTInfo.rndMode,FFTInfo.satMode,'RWV','v_accum_dtc');
        dtcComp.addComment('Data type conversion to accumulator data type');


        bf1=hBFNet.addSignal(dataType,'bf1');
        bf2=hBFNet.addSignal(dataType,'bf2');
        addComp=pirelab.getAddComp(hBFNet,[u_accum,v_accum],bf1,FFTInfo.rndMode,FFTInfo.satMode,'xadd',accumType);
        addComp.addComment('Butterfly adder');
        subComp=pirelab.getSubComp(hBFNet,[u_accum,v_accum],bf2,FFTInfo.rndMode,FFTInfo.satMode,'ysub',accumType);
        subComp.addComment('Butterfly subtractor');


        pComp=pirelab.getUnitDelayComp(hBFNet,bf1,x_out,'x_pc');
        pComp.addComment('Output pipeline register on x');

        bf2_p=hBFNet.addSignal(dataType,'bf2_p');
        pComp=pirelab.getIntDelayComp(hBFNet,bf2,bf2_p,FFTInfo.pipeAddMinusDelay,'bf2d');
        pComp.addComment('Pipeline register on bf2');





        t_re=hBFNet.addSignal(dataBaseType,'t_re');
        t_im=hBFNet.addSignal(dataBaseType,'t_im');
        pirelab.getComplex2RealImag(hBFNet,bf2_p,[t_re,t_im],'Real and Imag','t_c2ri');
        tw_re=hBFNet.addSignal(twiddleBaseType,'tw_re');
        tw_im=hBFNet.addSignal(twiddleBaseType,'tw_im');
        pirelab.getComplex2RealImag(hBFNet,tw_p,[tw_re,tw_im],'Real and Imag','tw_c2ri');


        mul1=hBFNet.addSignal(prodBaseType,'mul1');
        mul2=hBFNet.addSignal(prodBaseType,'mul2');
        mul3=hBFNet.addSignal(prodBaseType,'mul3');
        mul4=hBFNet.addSignal(prodBaseType,'mul4');
        mulComp=pirelab.getMulComp(hBFNet,[t_re,tw_re],mul1,FFTInfo.rndMode,FFTInfo.satMode,'mul1c');
        mulComp.addComment('Multiplier for complex multiply');
        mulComp=pirelab.getMulComp(hBFNet,[t_im,tw_im],mul2,FFTInfo.rndMode,FFTInfo.satMode,'mul2c');
        mulComp.addComment('Multiplier for complex multiply');
        mulComp=pirelab.getMulComp(hBFNet,[t_re,tw_im],mul3,FFTInfo.rndMode,FFTInfo.satMode,'mul3c');
        mulComp.addComment('Multiplier for complex multiply');
        mulComp=pirelab.getMulComp(hBFNet,[t_im,tw_re],mul4,FFTInfo.rndMode,FFTInfo.satMode,'mul4c');
        mulComp.addComment('Multiplier for complex multiply');


        mul1_p=hBFNet.addSignal(prodBaseType,'mul1_p');
        mul2_p=hBFNet.addSignal(prodBaseType,'mul2_p');
        mul3_p=hBFNet.addSignal(prodBaseType,'mul3_p');
        mul4_p=hBFNet.addSignal(prodBaseType,'mul4_p');
        pComp=pirelab.getUnitDelayComp(hBFNet,mul1,mul1_p,'mul1_pc');
        pComp.addComment('Pipelining registers after multiplier mul1');
        pComp=pirelab.getUnitDelayComp(hBFNet,mul2,mul2_p,'mul2_pc');
        pComp.addComment('Pipelining registers after multiplier mul2');
        pComp=pirelab.getUnitDelayComp(hBFNet,mul3,mul3_p,'mul3_pc');
        pComp.addComment('Pipelining registers after multiplier mul3');
        pComp=pirelab.getUnitDelayComp(hBFNet,mul4,mul4_p,'mul4_pc');
        pComp.addComment('Pipelining registers after multiplier mul4');


        mul1_accum=hBFNet.addSignal(accumBaseType,'mul1_accum');
        mul2_accum=hBFNet.addSignal(accumBaseType,'mul2_accum');
        mul3_accum=hBFNet.addSignal(accumBaseType,'mul3_accum');
        mul4_accum=hBFNet.addSignal(accumBaseType,'mul4_accum');
        dtcComp=pirelab.getDTCComp(hBFNet,mul1_p,mul1_accum,FFTInfo.rndMode,FFTInfo.satMode,'RWV','mul1_accum_dtc');
        dtcComp.addComment('Data type conversion to Accumulator data type');
        dtcComp=pirelab.getDTCComp(hBFNet,mul2_p,mul2_accum,FFTInfo.rndMode,FFTInfo.satMode,'RWV','mul2_accum_dtc');
        dtcComp.addComment('Data type conversion to Accumulator data type');
        dtcComp=pirelab.getDTCComp(hBFNet,mul3_p,mul3_accum,FFTInfo.rndMode,FFTInfo.satMode,'RWV','mul3_accum_dtc');
        dtcComp.addComment('Data type conversion to Accumulator data type');
        dtcComp=pirelab.getDTCComp(hBFNet,mul4_p,mul4_accum,FFTInfo.rndMode,FFTInfo.satMode,'RWV','mul4_accum_dtc');
        dtcComp.addComment('Data type conversion to Accumulator data type');


        sub_mul=hBFNet.addSignal(dataBaseType,'sub_mul');
        add_mul=hBFNet.addSignal(dataBaseType,'add_mul');
        subComp=pirelab.getSubComp(hBFNet,[mul1_accum,mul2_accum],sub_mul,FFTInfo.rndMode,FFTInfo.satMode,'sub_mulc',accumBaseType);
        subComp.addComment('Subtractor for complex multiply');
        addComp=pirelab.getAddComp(hBFNet,[mul3_accum,mul4_accum],add_mul,FFTInfo.rndMode,FFTInfo.satMode,'add_mulc',accumBaseType);
        addComp.addComment('Adder for complex multiply');


        sub_mul_p=hBFNet.addSignal(dataBaseType,'sub_mul_p');
        add_mul_p=hBFNet.addSignal(dataBaseType,'add_mul_p');
        pComp=pirelab.getUnitDelayComp(hBFNet,sub_mul,sub_mul_p,'sub_mul_pc');
        pComp.addComment('Pipelining registers after subtractor sub_mul');
        pComp=pirelab.getUnitDelayComp(hBFNet,add_mul,add_mul_p,'add_mul_pc');
        pComp.addComment('Pipelining registers after adder add_mul');


        cmul_out=hBFNet.addSignal(dataType,'cmul_out');
        pirelab.getRealImag2Complex(hBFNet,[sub_mul_p,add_mul_p],cmul_out);



        bf2_twone=hBFNet.addSignal(dataType,'bf2_twone');
        pComp=pirelab.getIntDelayComp(hBFNet,bf2_p,bf2_twone,FFTInfo.pipeComplexMulDelay,'bf2twd');
        pComp.addComment('Matching pipelining delays on y');


        twone_p=hBFNet.addSignal(ufix1Type,'twone_p');
        pComp=pirelab.getIntDelayComp(hBFNet,twiddleone,twone_p,FFTInfo.pipeBFDelay,'twoned');
        pComp.addComment('Matching pipelining delays on twiddle equal to one signal');

        tsComp=pirelab.getSwitchComp(hBFNet,[bf2_twone,cmul_out],y_out,twone_p,'twone_switch','==',1);
        tsComp.addComment('Swtich for twiddle equal to one optimization -- matching Simulink behavior');

    else



        hBFNet=pirelab.createNewNetwork(...
        'Network',hN,...
        'Name',sprintf('%s_Butterfly_DIF_Unit_Simple',FFTInfo.refName),...
        'InportNames',{'u','v'},...
        'InportTypes',[dataType,dataType],...
        'InportRates',[inputRate,inputRate],...
        'OutportNames',{'x_out','y_out'},...
        'OutportTypes',[dataType,dataType]);


        u=hBFNet.PirInputSignals(1);
        v=hBFNet.PirInputSignals(2);
        x_out=hBFNet.PirOutputSignals(1);
        y_out=hBFNet.PirOutputSignals(2);


        hdlgetclockbundle(hBFNet,[],u,1,1,0);





        u_p=hBFNet.addSignal(dataType,'u_p');
        v_p=hBFNet.addSignal(dataType,'v_p');
        pComp=pirelab.getUnitDelayComp(hBFNet,u,u_p,'u_pc');
        pComp.addComment('Input pipeline register on u');
        pComp=pirelab.getUnitDelayComp(hBFNet,v,v_p,'v_pc');
        pComp.addComment('Input pipeline register on v');


        u_accum=hBFNet.addSignal(accumType,'u_accum');
        v_accum=hBFNet.addSignal(accumType,'v_accum');
        dtcComp=pirelab.getDTCComp(hBFNet,u_p,u_accum,FFTInfo.rndMode,FFTInfo.satMode,'RWV','u_accum_dtc');
        dtcComp.addComment('Data type conversion to accumulator data type');
        dtcComp=pirelab.getDTCComp(hBFNet,v_p,v_accum,FFTInfo.rndMode,FFTInfo.satMode,'RWV','v_accum_dtc');
        dtcComp.addComment('Data type conversion to accumulator data type');


        x=hBFNet.addSignal(dataType,'x');
        y=hBFNet.addSignal(dataType,'y');
        addComp=pirelab.getAddComp(hBFNet,[u_accum,v_accum],x,FFTInfo.rndMode,FFTInfo.satMode,'xaddc',accumType);
        addComp.addComment('Butterfly adder');
        subComp=pirelab.getSubComp(hBFNet,[u_accum,v_accum],y,FFTInfo.rndMode,FFTInfo.satMode,'ysubc',accumType);
        subComp.addComment('Butterfly subtractor');


        pComp=pirelab.getUnitDelayComp(hBFNet,x,x_out,'x_pc');
        pComp.addComment('Output pipeline register on x');
        pComp=pirelab.getUnitDelayComp(hBFNet,y,y_out,'y_pc');
        pComp.addComment('Output pipeline register on y');

    end


