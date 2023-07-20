function hFWFTNet=getFIFOFWFTNetwork(topNet,topNetIn,info,RAMDirective)



















    if nargin<4

        RAMDirective='';
    end



    InportNames={'In','Push','Pop'};
    in_types=arrayfun(@(x)topNetIn(x).Type,1:length(topNetIn),'uniformoutput',false);
    in_rates=arrayfun(@(x)topNetIn(x).SimulinkRate,1:length(topNetIn));


    [OutportNames,OutportTypes]=deal(cell(1,5));


    info.input_type=topNetIn(1).Type;
    info.boolean_type=pir_ufixpt_t(1,0);
    info.ufix_address_type=pir_ufixpt_t(info.address_size,0);
    info.ufix_address_type_p1=pir_ufixpt_t(ceil(log2(info.fifo_size+1)),0);
    info.ufix_address_type_p4=pir_ufixpt_t(ceil(log2(info.fifo_size+1+3)),0);

    if info.rst_on
        InportNames{4}='reset';
        in_types{4}=info.boolean_type;
    end

    OutportNames{1}='Out';
    OutportTypes{1}=info.input_type;

    if info.empty_on
        OutportNames{2}='Empty';
        OutportTypes{2}=info.boolean_type;
    end

    if info.full_on
        OutportNames{3}='Full';
        OutportTypes{3}=info.boolean_type;
    end

    if info.afull_on
        OutportNames{4}='AFull';
        OutportTypes{4}=info.boolean_type;
    end

    if info.num_on
        OutportNames{5}='Num';




        OutportTypes{5}=info.ufix_address_type_p4;
    end


    rmv=cellfun(@(c)isempty(c),OutportNames);
    OutportNames(rmv)=[];
    OutportTypes(rmv)=[];


    hFWFTNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',info.name,...
    'InportNames',InportNames,...
    'InportTypes',[in_types{:}],...
    'InportRates',in_rates,...
    'OutportNames',OutportNames,...
    'OutportTypes',[OutportTypes{:}]);
    for ii=1:numel(hFWFTNet.PirOutputSignals)
        hFWFTNet.PirOutputSignals(ii).SimulinkRate=in_rates(1);
    end


    optIdx=2;
    if info.empty_on
        fwft_empty=hFWFTNet.PirOutputSignals(optIdx);
        optIdx=optIdx+1;
    else
        fwft_empty=hFWFTNet.addSignal(info.boolean_type,'fwft_empty');
    end

    if info.full_on
        fifo_full=hFWFTNet.PirOutputSignals(optIdx);
        optIdx=optIdx+1;
    else
        fifo_full=hFWFTNet.addSignal(info.boolean_type,'fifo_full');
    end

    if info.afull_on
        fifo_afull=hFWFTNet.PirOutputSignals(optIdx);
        optIdx=optIdx+1;
    end

    if info.num_on
        fwft_num=hFWFTNet.PirOutputSignals(optIdx);
    else
        fwft_num=hFWFTNet.addSignal(info.ufix_address_type_p4,'fwft_num');
    end

    fifo_data_in=hFWFTNet.PirInputSignals(1);
    fifo_push_in=hFWFTNet.PirInputSignals(2);
    fwft_pop=hFWFTNet.PirInputSignals(3);
    if info.rst_on
        fwft_reset=hFWFTNet.PirInputSignals(4);
    else
        fwft_reset=[];
    end


    fifo_push=addSignal(hFWFTNet,info.boolean_type,fifo_push_in.SimulinkRate,'fifo_push');
    fifo_pop=addSignal(hFWFTNet,info.boolean_type,fwft_pop.SimulinkRate,'fifo_pop');
    fifo_data_out=hFWFTNet.addSignal(info.input_type,'fifo_data_out');
    fifo_empty=hFWFTNet.addSignal(info.boolean_type,'fifo_empty');
    fifo_num=hFWFTNet.addSignal(info.ufix_address_type_p1,'fifo_num');

    fwft_data=hFWFTNet.PirOutputSignals(1);

    classicFIFOInSignals=[fifo_data_in,fifo_push,fifo_pop];
    if info.rst_on
        classicFIFOInSignals(end+1)=fwft_reset;
    end
    classicFIFOOutSignals=[fifo_data_out,fifo_empty,fifo_full,fifo_num];


    classic_info=info;
    classic_info.name=[info.name,'_classic'];
    classic_info.empty_on=true;
    classic_info.full_on=true;
    classic_info.num_on=true;
    hFIFONet=pirelab.getFIFONetwork(hFWFTNet,classicFIFOInSignals,classicFIFOOutSignals,classic_info,info.ramCorePrefix,RAMDirective);


    hFIFOComp=pirelab.instantiateNetwork(hFWFTNet,hFIFONet,classicFIFOInSignals,classicFIFOOutSignals,...
    sprintf('%s_inst',classic_info.name));


    if info.afull_on
        afull_num=hFWFTNet.addSignal(info.ufix_address_type_p1,'afull_num');
        pirelab.getConstComp(hFWFTNet,afull_num,info.fifo_size-info.afull_threshold);
        pirelab.getRelOpComp(hFWFTNet,[fifo_num,afull_num],fifo_afull,'>=');
    end








    fifo_nfull=hFWFTNet.addSignal(info.boolean_type,'fifo_nfull');
    pirelab.getBitwiseOpComp(hFWFTNet,fifo_full,fifo_nfull,'NOT');
    pirelab.getBitwiseOpComp(hFWFTNet,[fifo_push_in,fifo_nfull],fifo_push,'AND');


    getFWFTLogic(hFWFTNet,info,fifo_data_out,fwft_pop,fifo_empty,fifo_num,fwft_data,fwft_empty,fifo_pop,fwft_num,fwft_reset);


    hFIFOComp.flatten(true);
    hFWFTNet.flattenHierarchy;
end

function getFWFTLogic(hN,info,data_in,pop_in,empty_in,num_in,data_out,empty_out,pop_out,num_out,fwft_reset)


    ufix2Type=pir_ufixpt_t(2,0);
    dout_rate=data_out.SimulinkRate;

    cache_data=addSignal(hN,info.input_type,dout_rate,'cache_data');
    data_out_next=addSignal(hN,info.input_type,dout_rate,'data_out_next');

    cache_valid=addSignal(hN,info.boolean_type,dout_rate,'cache_valid');
    fifo_valid=addSignal(hN,info.boolean_type,dout_rate,'fifo_valid');
    out_valid=addSignal(hN,info.boolean_type,dout_rate,'out_valid');
    all_valid=addSignal(hN,info.boolean_type,dout_rate,'all_valid');
    int_valid=addSignal(hN,info.boolean_type,dout_rate,'int_valid');

    cache_wr_en=addSignal(hN,info.boolean_type,dout_rate,'cache_wr_en');
    out_wr_en=addSignal(hN,info.boolean_type,dout_rate,'out_wr_en');
    fwft_wr_en=addSignal(hN,info.boolean_type,dout_rate,'fwft_wr_en');

    cache_update=addSignal(hN,info.boolean_type,dout_rate,'cache_update');

    num_internal=addSignal(hN,ufix2Type,dout_rate,'num_int');


    data_flow=addSignal(hN,info.boolean_type,dout_rate,'data_flow');
    fifo_and_out_valid=addSignal(hN,info.boolean_type,dout_rate,'fifo_and_out_valid');


    pirelab.getRelOpComp(hN,[cache_valid,out_wr_en],cache_update,'==');
    pirelab.getBitwiseOpComp(hN,[cache_update,fifo_valid],cache_wr_en,'AND');


    pirelab.getBitwiseOpComp(hN,[fifo_valid,cache_valid],int_valid,'OR');
    pirelab.getBitwiseOpComp(hN,[pop_in,empty_out],data_flow,'OR');
    pirelab.getBitwiseOpComp(hN,[data_flow,int_valid],out_wr_en,'AND');



    pirelab.getBitwiseOpComp(hN,[fifo_valid,out_valid],fifo_and_out_valid,'AND');
    pirelab.getBitwiseOpComp(hN,[cache_valid,fifo_and_out_valid],all_valid,'AND');
    pirelab.getBitwiseOpComp(hN,[empty_in,all_valid],pop_out,'NOR');


    pirelab.getBitwiseOpComp(hN,out_valid,empty_out,'NOT');




    pirelab.getUnitDelayEnabledComp(hN,data_in,cache_data,cache_wr_en,'cache_data_reg');



    pirelab.getSwitchComp(hN,[cache_data,data_in],data_out_next,cache_valid,'switch_data_out','==',1);

    pirelab.getUnitDelayEnabledComp(hN,data_out_next,data_out,out_wr_en,'out_data_reg');





    pirelab.getBitwiseOpComp(hN,[cache_wr_en,out_wr_en],fwft_wr_en,'OR');
    getSRLatchComp(hN,pop_out,fwft_wr_en,fifo_valid,info.rst_on,fwft_reset);





    getSRLatchComp(hN,cache_wr_en,out_wr_en,cache_valid,info.rst_on,fwft_reset);





    getSRLatchComp(hN,out_wr_en,pop_in,out_valid,info.rst_on,fwft_reset);


    pirelab.getAddComp(hN,[fifo_valid,cache_valid,out_valid],num_internal,'Floor','wrap','num_int_adder',ufix2Type,'+++');
    pirelab.getAddComp(hN,[num_internal,num_in],num_out,'Floor','wrap','num_int_adder',info.ufix_address_type_p4,'++');

end

function getSRLatchComp(hN,S,R,Q,rst,fwft_reset)


    boolean_type=pir_ufixpt_t(1,0);

    Q_next=hN.addSignal(boolean_type,'Q_next');
    Q_keep=hN.addSignal(boolean_type,'Q_keep');
    R_x=hN.addSignal(boolean_type,'R_x');

    pirelab.getBitwiseOpComp(hN,R,R_x,'NOT');
    pirelab.getBitwiseOpComp(hN,[R_x,Q],Q_keep,'AND');
    pirelab.getBitwiseOpComp(hN,[S,Q_keep],Q_next,'OR');

    if rst
        w_out_1=hN.addSignal(Q_next.Type,'w_out_1');
        w_out_1.SimulinkRate=Q_next.SimulinkRate;

        w_const_0=hN.addSignal(Q_next.Type,'w_const_0');
        w_const_0.SimulinkRate=Q_next.SimulinkRate;
        pirelab.getConstComp(hN,w_const_0,0,'constant_zero');

        pirelab.getSwitchComp(hN,[w_const_0,Q_next],w_out_1,fwft_reset,'mux2_0','~=');
        switchOut=w_out_1;

    else
        switchOut=Q_next;
    end
    pirelab.getUnitDelayComp(hN,switchOut,Q,'Q_reg');
end

function s=addSignal(hN,type,rate,name)
    s=hN.addSignal(type,name);
    s.SimulinkRate=rate;
end



