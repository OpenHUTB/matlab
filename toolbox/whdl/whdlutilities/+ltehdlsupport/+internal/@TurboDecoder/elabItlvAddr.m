function itlvNet=elabItlvAddr(~,topNet,blockInfo,dataRate)




    boolType=pir_boolean_t();
    addrType=blockInfo.dataRAMaddrType;
    uint8Type=pir_ufixpt_t(8,0);
    int16Type=pir_sfixpt_t(16,0);






    inportNames={'itlv_init_sel','bLen','bLen_ext'};
    inTypes=[boolType,addrType,addrType];
    indataRates=[dataRate,dataRate,dataRate];
    outportNames={'itlv_addr'};

    outTypes=addrType;

    itlvNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ItlvAddress',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );


    itlv_init_sel=itlvNet.PirInputSignals(1);
    bLen=itlvNet.PirInputSignals(2);
    bLen_ext=itlvNet.PirInputSignals(3);
    itlv_addr=itlvNet.PirOutputSignals(1);


    itlv_en=itlvNet.addSignal(boolType,'itlv_en');
    itlv_load=itlvNet.addSignal(boolType,'itlv_load');



    itlv_init_sel_reg=itlvNet.addSignal(boolType,'itlv_init_sel_reg');
    pirelab.getUnitDelayComp(itlvNet,itlv_init_sel,itlv_init_sel_reg);


    desc='Interleaver Controller';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+ltehdlsupport','+internal','@TurboDecoder','cgireml','ItlvController.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');

    fclose(fid);


    inports=[itlv_init_sel_reg,bLen,bLen_ext];

    outports=[itlv_en,itlv_load];

    icontroller=itlvNet.addComponent2(...
    'kind','cgireml',...
    'Name','itlvController',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','ItlvController',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.winSize-1},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    icontroller.runConcurrencyMaximizer(0);






    consts=[4,28,60,92];
    ops={'+-','++','++','++'};
    cmpvalue=[2048,1024,512];

    for i=1:4

        bLen_shift(i)=itlvNet.addSignal(addrType,['bLen_shift',num2str(i+2)]);
        shift_low8(i)=itlvNet.addSignal(uint8Type,['shift',num2str(i+2),'_low8']);
        const(i)=itlvNet.addSignal(uint8Type,['const',num2str(consts(i))]);
        brunch(i)=itlvNet.addSignal(uint8Type,['brunch',num2str(i)]);



        comp=pirelab.getBitShiftComp(itlvNet,bLen,bLen_shift(i),'sra',i+2);
        if i==1
            comp.addComment('Compute interleaver parameter table index');
        end

        pirelab.getBitSliceComp(itlvNet,bLen_shift(i),shift_low8(i),7,0);
        pirelab.getConstComp(itlvNet,const(i),consts(i));
        pirelab.getAddComp(itlvNet,[shift_low8(i),const(i)],brunch(i),...
        'Floor','Wrap','',uint8Type,ops{i});

        if i<4
            cmp(i)=itlvNet.addSignal(boolType,['cmp',num2str(cmpvalue(i))]);
            pirelab.getCompareToValueComp(itlvNet,bLen,cmp(i),'<=',cmpvalue(i),'',false);

        end
    end

    selected1=itlvNet.addSignal(uint8Type,'selected1');
    selected2=itlvNet.addSignal(uint8Type,'selected2');
    lut_addr=itlvNet.addSignal(uint8Type,'lut_addr');
    lut_out=itlvNet.addSignal(pir_ufixpt_t(19,0),'lut_out');
    lut_out_reg1=itlvNet.addSignal(pir_ufixpt_t(19,0),'lut_out_reg1');
    lut_out_reg2=itlvNet.addSignal(pir_ufixpt_t(19,0),'lut_out_reg2');


    pirelab.getSwitchComp(itlvNet,[brunch(3),brunch(4)],selected1,cmp(1),'','==',1);
    pirelab.getSwitchComp(itlvNet,[brunch(2),selected1],selected2,cmp(2),'','==',1);
    pirelab.getSwitchComp(itlvNet,[brunch(1),selected2],lut_addr,cmp(3),'','==',1);


    [table,idx,bpType,oType,fType]=computeLUT();


    comp=pirelab.getLookupNDComp(itlvNet,lut_addr,lut_out,...
    table,0,bpType,oType,fType,0,idx,'Lookup Table1',-1);
    comp.addComment(' LTE interleaver parameter table ');


    regcomp=pirelab.getUnitDelayComp(itlvNet,lut_out,lut_out_reg1,'LUT1outRegister',0,true);
    regcomp.addComment('Lookup table output register');


    regcomp=pirelab.getUnitDelayComp(itlvNet,lut_out_reg1,lut_out_reg2,'LUT1outRegister',0);
    regcomp.addComment('Lookup table output pipeline register');

    f1=itlvNet.addSignal(pir_ufixpt_t(9,0),'f1');
    f2=itlvNet.addSignal(pir_ufixpt_t(10,0),'f2');

    pirelab.getBitSliceComp(itlvNet,lut_out_reg2,f2,9,0);
    pirelab.getBitSliceComp(itlvNet,lut_out_reg2,f1,18,10);



    init1=itlvNet.addSignal(int16Type,'m2bLen_reg');
    bLensll=itlvNet.addSignal(int16Type,'m2bLen');
    init2=itlvNet.addSignal(int16Type,'bLen_int16_reg');
    bLenint16=itlvNet.addSignal(int16Type,'bLen_int16');
    init3=itlvNet.addSignal(int16Type,'m2f2-2bLen');
    init4=itlvNet.addSignal(int16Type,'m2f2/f1+f2');
    init5=itlvNet.addSignal(int16Type,'m2f2-bLen');
    f2int16=itlvNet.addSignal(int16Type,'f2int16');
    iniselected=itlvNet.addSignal(int16Type,'iniSelected');

    f2sll=itlvNet.addSignal(int16Type,'m2f2');
    for i=1:3
        addout(i)=itlvNet.addSignal(int16Type,['addout',num2str(i)]);
    end

    pirelab.getDTCComp(itlvNet,bLen,bLenint16,'floor','Wrap');
    pirelab.getBitShiftComp(itlvNet,bLenint16,bLensll,'sll',1);
    pirelab.getUnitDelayComp(itlvNet,bLensll,init1);

    pirelab.getUnitDelayComp(itlvNet,bLenint16,init2);

    comp=pirelab.getDTCComp(itlvNet,f2,f2int16,'floor','Wrap');
    comp.addComment('Compute initial parameters');

    pirelab.getBitShiftComp(itlvNet,f2int16,f2sll,'sll',1);
    pirelab.getAddComp(itlvNet,[f2sll,bLensll],addout(1),...
    'Floor','Wrap','',int16Type,'+-');

    pirelab.getUnitDelayComp(itlvNet,addout(1),init3);

    pirelab.getAddComp(itlvNet,[f1,f2],addout(2),...
    'Floor','Wrap','',int16Type,'++');

    pirelab.getSwitchComp(itlvNet,[addout(2),f2sll],iniselected,itlv_init_sel_reg,'','==',1);
    comp=pirelab.getUnitDelayEnabledComp(itlvNet,iniselected,init4,itlv_en,'LTEInitparam_register',0,'','',1);
    comp.addComment('load LTE iterleaver initial parameters');


    pirelab.getAddComp(itlvNet,[f2sll,bLenint16],addout(3),...
    'Floor','Wrap','',int16Type,'+-');

    pirelab.getUnitDelayComp(itlvNet,addout(3),init5);






    modout=itlvNet.addSignal(int16Type,'modout');
    incVal=itlvNet.addSignal(int16Type,'incVal');
    incVal.simulinkRate=dataRate;
    indices=itlvNet.addSignal(int16Type,'indices');
    indices.simulinkRate=dataRate;
    indices_inc=itlvNet.addSignal(int16Type,'indices_inc');
    indices_next=itlvNet.addSignal(int16Type,'indices_next');
    indices_inc_adjust=itlvNet.addSignal(int16Type,'indices_inc_adjust');


    addrout=itlvNet.addSignal(addrType,'addrout');

    for i=1:3
        add32out(i)=itlvNet.addSignal(int16Type,['addout16',num2str(i)]);
        swSel(i)=itlvNet.addSignal(boolType,['swSel',num2str(i)]);
    end

    branch1=itlvNet.addSignal(int16Type,'branch1');
    branch2=itlvNet.addSignal(int16Type,'branch2');

    comp=pirelab.getAddComp(itlvNet,[incVal,init3],add32out(1),...
    'Floor','Wrap','',int16Type,'++');
    comp.addComment('Compute itlv address');

    pirelab.getAddComp(itlvNet,[incVal,init4],add32out(2),...
    'Floor','Wrap','',int16Type,'++');

    pirelab.getAddComp(itlvNet,[incVal,init5],add32out(3),...
    'Floor','Wrap','',int16Type,'++');


    pirelab.getRelOpComp(itlvNet,[add32out(2),init1],swSel(1),'>=');
    pirelab.getRelOpComp(itlvNet,[add32out(2),init2],swSel(2),'>=');





    itlv_init_sel_delay=itlvNet.addSignal(boolType,'intlv_init_sel_delay');
    pirelab.getUnitDelayComp(itlvNet,itlv_init_sel_reg,itlv_init_sel_delay);
    sel_f1_f2=itlvNet.addSignal(boolType,'sel_f1_f2');
    pirelab.getLogicComp(itlvNet,[itlv_init_sel_delay,swSel(1)],sel_f1_f2,'or');


    pirelab.getSwitchComp(itlvNet,[add32out(1),add32out(2)],branch1,swSel(1),'','==',1);
    pirelab.getSwitchComp(itlvNet,[add32out(3),add32out(2)],branch2,swSel(2),'','==',1);
    pirelab.getSwitchComp(itlvNet,[branch1,branch2],modout,sel_f1_f2,'','==',1);





    resetEnb=itlv_init_sel_reg;

    comp=pirelab.getUnitDelayResettableComp(itlvNet,modout,incVal,resetEnb,'incVal_Register',0,'',1);
    comp.addComment('Selected the correct address incremental value');


    pirelab.getAddComp(itlvNet,[incVal,indices],indices_inc,...
    'Floor','Wrap','',int16Type,'++');

    pirelab.getAddComp(itlvNet,[indices_inc,init2],indices_inc_adjust,...
    'Floor','Wrap','',int16Type,'+-');

    pirelab.getRelOpComp(itlvNet,[indices_inc,init2],swSel(3),'>');
    pirelab.getSwitchComp(itlvNet,[indices_inc_adjust,indices_inc],indices_next,swSel(3),'','==',1);
    comp=pirelab.getUnitDelayResettableComp(itlvNet,indices_next,indices,resetEnb,'indices_Register',1,'',1);
    comp.addComment('compute next address');
    pirelab.getDTCComp(itlvNet,indices,addrout);



    desc='Iterleaver address Last In First Out buffer';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+ltehdlsupport','+internal','@TurboDecoder','cgireml','itlvLIFO.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');

    fclose(fid);

    itlv_load_reg=itlvNet.addSignal(boolType,'itlv_load_reg');
    pirelab.getUnitDelayComp(itlvNet,itlv_load,itlv_load_reg);

    inports=[addrout,itlv_load_reg];

    itlvlifo=itlvNet.addComponent2(...
    'kind','cgireml',...
    'Name','itlvLIFO',...
    'InputSignals',inports,...
    'OutputSignals',itlv_addr,...
    'EMLFileName','itlvLIFO',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.winSize,13},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    itlvlifo.runConcurrencyMaximizer(0);
end



function[table,idx,bpType,oType,fType]=computeLUT()

    validK=[40:8:512,528:16:1024,1056:32:2048,2112:64:6144]';
    Index=[1:length(validK)]';
    f1=Index;
    f2=Index;


    for i=1:length(validK)
        [f1(i),f2(i)]=getltef1f2(validK(i));

    end

    oType=ufi(1,19,0);
    fType=oType;
    table=zeros(256,1);
    table(2:188+1)=f1*2^10+f2;
    table=cast(table,'like',oType);

    bpType=ufi(0,8,0);
    idx={fi((0:255),bpType.numerictype)};

end


