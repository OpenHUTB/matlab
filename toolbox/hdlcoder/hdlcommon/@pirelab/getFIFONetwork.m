function h_top_network=getFIFONetwork(topNet,topNetIn,topNetOut,info,ramCorePrefix,RAMDirective)




    if nargin<6

        RAMDirective='';
    end

    if nargin<5

        ramCorePrefix='';
    end



    InportNames={'In','Push','Pop'};
    in_types=arrayfun(@(x)topNetIn(x).Type,1:length(topNetIn),'uniformoutput',false);
    in_rates=arrayfun(@(x)topNetIn(x).SimulinkRate,1:length(topNetIn));

    info.boolean_type=pir_ufixpt_t(1,0);

    if info.rst_on
        InportNames{4}='rst';
        in_types{4}=info.boolean_type;
    end

    [OutportNames,OutportTypes]=deal(cell(1,4));


    info.input_type=topNetIn(1).Type;
    info.ufix_address_type=pir_ufixpt_t(info.address_size,0);
    info.ufix_address_type_p1=pir_ufixpt_t(ceil(log2(info.fifo_size+1)),0);

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

    if info.num_on
        OutportNames{4}='Num';



        OutportTypes{4}=info.ufix_address_type_p1;
    end


    rmv=cellfun(@(c)isempty(c),OutportNames);
    OutportNames(rmv)=[];
    OutportTypes(rmv)=[];


    h_top_network=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',info.name,...
    'InportNames',InportNames,...
    'InportTypes',[in_types{:}],...
    'InportRates',in_rates,...
    'OutportNames',OutportNames,...
    'OutportTypes',[OutportTypes{:}]);

    din=h_top_network.PirInputSignals(1);
    push=h_top_network.PirInputSignals(2);
    pop=h_top_network.PirInputSignals(3);
    if info.rst_on
        rst=h_top_network.PirInputSignals(4);
    else
        rst=[];
    end


    dout=h_top_network.PirOutputSignals(1);
    switch num2str([info.empty_on,info.full_on,info.num_on],'%d')
    case '000'
        w_empty=h_top_network.addSignal(info.boolean_type,'w_empty');
        w_full=h_top_network.addSignal(info.boolean_type,'w_full');
        o_num=h_top_network.addSignal(info.ufix_address_type_p1,'w_num');
    case '001'
        w_empty=h_top_network.addSignal(info.boolean_type,'w_empty');
        w_full=h_top_network.addSignal(info.boolean_type,'w_full');
        o_num=h_top_network.PirOutputSignals(2);
    case '010'
        w_empty=h_top_network.addSignal(info.boolean_type,'w_empty');
        w_full=h_top_network.PirOutputSignals(2);
        o_num=h_top_network.addSignal(info.ufix_address_type_p1,'w_num');
    case '011'
        w_empty=h_top_network.addSignal(info.boolean_type,'w_empty');
        w_full=h_top_network.PirOutputSignals(2);
        o_num=h_top_network.PirOutputSignals(3);
    case '100'
        w_empty=h_top_network.PirOutputSignals(2);
        w_full=h_top_network.addSignal(info.boolean_type,'w_full');
        o_num=h_top_network.addSignal(info.ufix_address_type_p1,'w_num');
    case '101'
        w_empty=h_top_network.PirOutputSignals(2);
        w_full=h_top_network.addSignal(info.boolean_type,'w_full');
        o_num=h_top_network.PirOutputSignals(3);
    case '110'
        w_empty=h_top_network.PirOutputSignals(2);
        w_full=h_top_network.PirOutputSignals(3);
        o_num=h_top_network.addSignal(info.ufix_address_type_p1,'w_num');
    case '111'
        w_empty=h_top_network.PirOutputSignals(2);
        w_full=h_top_network.PirOutputSignals(3);
        o_num=h_top_network.PirOutputSignals(4);
    end


    [w_us1,w_us2,w_us3]=upsample_blocks(h_top_network,din,push,pop,info);



    [w_waddr,w_we,w_raddr]=fifo_control_eml(h_top_network,w_us2,w_us3,rst,w_empty,w_full,o_num,info);


    w_sdpr=RAM_block(h_top_network,w_us1,w_waddr,w_we,w_raddr,info,ramCorePrefix,RAMDirective);


    w_bypass=bypass_network(h_top_network,w_sdpr,w_us3,o_num,rst,info);


    n_ds=pirelab.getDownSampleComp(h_top_network,w_bypass,dout,info.output_rate,0,0);%#ok




    if info.num_on


        numOutputType=topNetOut(end).Type;

        numOutSignal=h_top_network.PirOutputSignals(end);
        numOutPort=h_top_network.PirOutputPorts(end);

        if~numOutputType.isEqual(OutportTypes{end})
            outDtcSignal=h_top_network.addSignal(numOutputType,[numOutSignal.Name,'_dtc']);
            pirelab.getDTCComp(h_top_network,numOutSignal,outDtcSignal);
            numOutSignal.disconnectReceiver(numOutPort);
            outDtcSignal.addReceiver(numOutPort);
        end
    end



    function[w_us1,w_us2,w_us3]=upsample_blocks(top,din,push,pop,info)

        w_us1=top.addSignal(din.Type,'w_us1');
        n_us1=pirelab.getUpSampleComp(top,din,w_us1,info.input_rate,0,0,'us1');%#ok

        w_us2=top.addSignal(info.boolean_type,'w_us2');
        n_us2=pirelab.getUpSampleComp(top,push,w_us2,info.input_rate,0,0,'us2');%#ok

        w_us3=top.addSignal(info.boolean_type,'w_us3');
        n_us3=pirelab.getUpSampleComp(top,pop,w_us3,info.output_rate,0,0,'us3');%#ok

        function[w_waddr,w_we,w_raddr]=control_subsignals(top,info)
            w_waddr=top.addSignal(info.ufix_address_type,'w_waddr');
            w_we=top.addSignal(info.boolean_type,'w_we');
            w_raddr=top.addSignal(info.ufix_address_type,'w_raddr');

            function[w_waddr,w_we,w_raddr]=fifo_control_eml(top,push,pop,rst,w_empty,w_full,w_num,info)


                [w_waddr,w_we,w_raddr]=control_subsignals(top,info);

                if info.rst_on
                    inputSignals=[push,pop,rst];
                else
                    inputSignals=[push,pop];
                end


                top.addComponent2(...
                'kind','cgireml',...
                'Name','fifo',...
                'InputSignals',inputSignals,...
                'OutputSignals',[w_waddr,w_we,w_raddr,w_empty,w_full,w_num],...
                'EMLFileName','fifo_control_logic',...
                'EMLFlag_ParamsFollowInputs',false,...
                'EMLParams',{info.fifo_size,info.address_size,info.rst_on},...
                'BlockComment','FIFO logic controller');

                function w_sdpr=RAM_block(top,w_us1,w_waddr,w_we,w_raddr,info,ramCorePrefix,RAMDirective)



                    w_sdpr=top.addSignal(info.input_type,'w_waddr');
                    n_sdpr=pirelab.getSimpleDualPortRamComp(top,...
                    [w_us1,w_waddr,w_we,w_raddr],...
                    w_sdpr,sprintf('%s_ram',info.name),1,[],[],ramCorePrefix,'',RAMDirective);
                    if isfield(info,'for_comments')&&~isempty(info.for_comments)
                        n_sdpr.copyComment(info.for_comments);
                    end

                    function w_out=bypass_network(top,din,pop,num,rst,info)


                        w_const=top.addSignal(info.boolean_type,'w_const');
                        w_const.SimulinkRate=din.SimulinkRate;
                        n_const=pirelab.getConstComp(top,w_const,0,'ground_bypass');%#ok

                        w_cz=pirelab.getCompareToZero(top,num,'>','w_cz');

                        w_mux1=top.addSignal(info.boolean_type,'w_mux1');
                        n_mux1=pirelab.getSwitchComp(top,[pop,w_const],w_mux1,w_cz,'mux1','~=');%#ok

                        w_d1=top.addSignal(info.boolean_type,'w_d1');
                        n_d1=pirelab.getUnitDelayComp(top,w_mux1,w_d1,'f_d1');%#ok

                        w_d2=top.addSignal(din.Type,'w_d2');

                        n_d2=pirelab.getUnitDelayEnabledComp(top,din,w_d2,w_d1,'f_d2');%#ok

                        w_out=top.addSignal(din.Type,'w_out');

                        if info.rst_on
                            w_out_1=top.addSignal(din.Type,'w_out_1');
                            w_out_1.SimulinkRate=din.SimulinkRate;

                            w_const_0=top.addSignal(din.Type,'w_const_0');
                            w_const_0.SimulinkRate=din.SimulinkRate;
                            pirelab.getConstComp(top,w_const_0,0,'constant_zero');

                            pirelab.getSwitchComp(top,[w_const_0,din],w_out_1,rst,'mux2_0','~=');
                            switchOut=w_out_1;

                        else
                            switchOut=din;
                        end
                        n_mux2=pirelab.getSwitchComp(top,[switchOut,w_d2],w_out,w_d1,'mux2','~=');%#ok

