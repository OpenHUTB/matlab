function twdlmult_sdnf1=elabTWDLMULT_SDNF1(this,topNet,blockInfo,R2StageNum,dataRate,requireMultiplication,bitReversedInput,multByOne1,multByOne2,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,...
    din1_re,din1_im,din2_re,din2_im,din_vld,...
    twdl1_re,twdl1_im,twdl2_re,twdl2_im,twdl_vld,softReset,...
    twdlXdin1_re,twdlXdin1_im,twdlXdin2_re,twdlXdin2_im,twdlXdin_vld)






    InportNames={din1_re.Name,din1_im.Name,din2_re.Name,din2_im.Name,din_vld.Name,twdl1_re.Name,twdl1_im.Name,twdl2_re.Name,twdl2_im.Name,twdl_vld.Name,softReset.Name};
    InportTypes=[din1_re.Type;din1_im.Type;din2_re.Type;din2_im.Type;din_vld.Type;twdl1_re.Type;twdl1_im.Type;twdl2_re.Type;twdl2_im.Type;twdl_vld.Type;softReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={twdlXdin1_re.Name,twdlXdin1_im.Name,twdlXdin2_re.Name,twdlXdin2_im.Name,twdlXdin_vld.Name};
    OutportTypes=[twdlXdin1_re.Type;twdlXdin1_im.Type;twdlXdin2_re.Type;twdlXdin2_im.Type;twdlXdin_vld.Type];

    twdlmult_sdnf1=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['TWDLMULT_SDNF1_',int2str(R2StageNum)],...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=twdlmult_sdnf1.PirInputSignals;
    outputPort=twdlmult_sdnf1.PirOutputSignals;

    if inputPort(1).Type.WordLength==outputPort(1).Type.WordLength
        din1_re=inputPort(1);
        din1_im=inputPort(2);
        din2_re=inputPort(3);
        din2_im=inputPort(4);
    else
        din1_re=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_re.Type,'Name','din_re');
        din1_re.SimulinkRate=dataRate;
        din1_im=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_im.Type,'Name','din_im');
        din1_im.SimulinkRate=dataRate;
        din2_re=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_re.Type,'Name','din_re');
        din2_re.SimulinkRate=dataRate;
        din2_im=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_im.Type,'Name','din_im');
        din2_im.SimulinkRate=dataRate;

        pirelab.getDTCComp(twdlmult_sdnf1,inputPort(1),din1_re);
        pirelab.getDTCComp(twdlmult_sdnf1,inputPort(2),din1_im);
        pirelab.getDTCComp(twdlmult_sdnf1,inputPort(3),din2_re);
        pirelab.getDTCComp(twdlmult_sdnf1,inputPort(4),din2_im);
    end
    din_vld=inputPort(5);
    twdl1_re=inputPort(6);
    twdl1_im=inputPort(7);
    twdl2_re=inputPort(8);
    twdl2_im=inputPort(9);
    twdl_vld=inputPort(10);
    softReset=inputPort(11);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        syncReset=softReset;
    else
        syncReset='';
    end

    twdlXdin1_re=outputPort(1);
    twdlXdin1_im=outputPort(2);
    twdlXdin2_re=outputPort(3);
    twdlXdin2_im=outputPort(4);
    twdlXdin_vld=outputPort(5);



    twdlXdin1_vld=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name','twdlXdin1_vld');
    twdlXdin1_vld.SimulinkRate=dataRate;
    twdlXdin2_vld=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name','twdlXdin2_vld');
    twdlXdin2_vld.SimulinkRate=dataRate;

    if~bitReversedInput
        if R2StageNum==1||isLastStageOfNonPowerOf4(blockInfo,R2StageNum)||~requireMultiplication
            din1_vld=din_vld;
            for loop=1:9
                din1_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_re.Type,'Name',['din1_re_dly',int2str(loop)]);
                din1_re_dly.SimulinkRate=dataRate;
                din1_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_im.Type,'Name',['din1_im_dly',int2str(loop)]);
                din1_im_dly.SimulinkRate=dataRate;
                din_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['din_vld_dly',int2str(loop)]);
                din_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_re,din1_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_im,din1_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_vld,din_vld_dly,'',syncReset,1);
                din1_re=din1_re_dly;
                din1_im=din1_im_dly;
                din1_vld=din_vld_dly;
            end
            pirelab.getWireComp(twdlmult_sdnf1,din1_re_dly,twdlXdin1_re);
            pirelab.getWireComp(twdlmult_sdnf1,din1_im_dly,twdlXdin1_im);
            pirelab.getWireComp(twdlmult_sdnf1,din_vld_dly,twdlXdin1_vld);
        elseif strcmpi(blockInfo.ComplexMultiplication,'Use 3 multipliers and 5 adders')
            din1_vld=din_vld;
            for loop=1:3
                din1_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_re.Type,'Name',['din1_re_dly',int2str(loop)]);
                din1_re_dly.SimulinkRate=dataRate;
                din1_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_im.Type,'Name',['din1_im_dly',int2str(loop)]);
                din1_im_dly.SimulinkRate=dataRate;
                din1_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['din1_vld_dly',int2str(loop)]);
                din1_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_re,din1_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_im,din1_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_vld,din1_vld_dly,'',syncReset,1);
                din1_re=din1_re_dly;
                din1_im=din1_im_dly;
                din1_vld=din1_vld_dly;
            end
            MUL3=this.elabComplex3Multiply(twdlmult_sdnf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din1_re,din1_im,din1_vld,twdl1_re,twdl1_im,softReset,twdlXdin1_re,twdlXdin1_im,twdlXdin1_vld);
            pirelab.instantiateNetwork(twdlmult_sdnf1,MUL3,[din1_re,din1_im,din1_vld,twdl1_re,twdl1_im,softReset],[twdlXdin1_re,twdlXdin1_im,twdlXdin1_vld],...
            'MUL3_1');
        else
            din1_vld=din_vld;
            for loop=1:3
                din1_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_re.Type,'Name',['din1_re_dly',int2str(loop)]);
                din1_re_dly.SimulinkRate=dataRate;
                din1_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_im.Type,'Name',['din1_im_dly',int2str(loop)]);
                din1_im_dly.SimulinkRate=dataRate;
                din1_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['din1_vld_dly',int2str(loop)]);
                din1_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_re,din1_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_im,din1_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_vld,din1_vld_dly,'',syncReset,1);
                din1_re=din1_re_dly;
                din1_im=din1_im_dly;
                din1_vld=din1_vld_dly;
            end
            MUL4=this.elabComplex4Multiply(twdlmult_sdnf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din1_re,din1_im,din1_vld,twdl1_re,twdl1_im,softReset,twdlXdin1_re,twdlXdin1_im,twdlXdin1_vld);
            pirelab.instantiateNetwork(twdlmult_sdnf1,MUL4,[din1_re,din1_im,din1_vld,twdl1_re,twdl1_im,softReset],[twdlXdin1_re,twdlXdin1_im,twdlXdin1_vld],...
            'MUL4_1');
        end

        if R2StageNum==1
            pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_re,twdlXdin2_re,'',syncReset,1);
            pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_im,twdlXdin2_im,'',syncReset,1);
            pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din_vld,twdlXdin_vld,'',syncReset,1);
        elseif strcmpi(blockInfo.ComplexMultiplication,'Use 3 multipliers and 5 adders')
            din2_vld=din_vld;
            for loop=1:3
                din2_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['di2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            MUL3=this.elabComplex3Multiply(twdlmult_sdnf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset,twdlXdin2_re,twdlXdin2_im,twdlXdin2_vld);
            pirelab.instantiateNetwork(twdlmult_sdnf1,MUL3,[din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset],[twdlXdin2_re,twdlXdin2_im,twdlXdin_vld],...
            'MUL3_2');
        else
            din2_vld=din_vld;
            for loop=1:3
                din2_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['di2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            MUL4=this.elabComplex4Multiply(twdlmult_sdnf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset,twdlXdin2_re,twdlXdin2_im,twdlXdin2_vld);
            pirelab.instantiateNetwork(twdlmult_sdnf1,MUL4,[din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset],[twdlXdin2_re,twdlXdin2_im,twdlXdin_vld],...
            'MUL4_2');
        end

    else
        if multByOne1
            noOfDelays=9;
            din1_vld=din_vld;
            for loop=1:noOfDelays
                din1_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_re.Type,'Name',['din1_re_dly',int2str(loop)]);
                din1_re_dly.SimulinkRate=dataRate;
                din1_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_im.Type,'Name',['din1_im_dly',int2str(loop)]);
                din1_im_dly.SimulinkRate=dataRate;
                din_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['din_vld_dly',int2str(loop)]);
                din_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_re,din1_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_im,din1_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_vld,din_vld_dly,'',syncReset,1);
                din1_re=din1_re_dly;
                din1_im=din1_im_dly;
                din1_vld=din_vld_dly;
            end
            pirelab.getWireComp(twdlmult_sdnf1,din1_re_dly,twdlXdin1_re);
            pirelab.getWireComp(twdlmult_sdnf1,din1_im_dly,twdlXdin1_im);
            pirelab.getWireComp(twdlmult_sdnf1,din_vld_dly,twdlXdin1_vld);
        elseif strcmpi(blockInfo.ComplexMultiplication,'Use 3 multipliers and 5 adders')
            din1_vld=din_vld;
            for loop=1:3
                din1_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_re.Type,'Name',['din1_re_dly',int2str(loop)]);
                din1_re_dly.SimulinkRate=dataRate;
                din1_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_im.Type,'Name',['din1_im_dly',int2str(loop)]);
                din1_im_dly.SimulinkRate=dataRate;
                din1_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['din1_vld_dly',int2str(loop)]);
                din1_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_re,din1_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_im,din1_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_vld,din1_vld_dly,'',syncReset,1);
                din1_re=din1_re_dly;
                din1_im=din1_im_dly;
                din1_vld=din1_vld_dly;
            end
            MUL3=this.elabComplex3Multiply(twdlmult_sdnf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din1_re,din1_im,din1_vld,twdl1_re,twdl1_im,softReset,twdlXdin1_re,twdlXdin1_im,twdlXdin1_vld);
            pirelab.instantiateNetwork(twdlmult_sdnf1,MUL3,[din1_re,din1_im,din1_vld,twdl1_re,twdl1_im,softReset],[twdlXdin1_re,twdlXdin1_im,twdlXdin1_vld],...
            'MUL3_1');
        else
            din1_vld=din_vld;
            for loop=1:3
                din1_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_re.Type,'Name',['din1_re_dly',int2str(loop)]);
                din1_re_dly.SimulinkRate=dataRate;
                din1_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_im.Type,'Name',['din1_im_dly',int2str(loop)]);
                din1_im_dly.SimulinkRate=dataRate;
                din1_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['din1_vld_dly',int2str(loop)]);
                din1_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_re,din1_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_im,din1_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din1_vld,din1_vld_dly,'',syncReset,1);
                din1_re=din1_re_dly;
                din1_im=din1_im_dly;
                din1_vld=din1_vld_dly;
            end
            MUL4=this.elabComplex4Multiply(twdlmult_sdnf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din1_re,din1_im,din1_vld,twdl1_re,twdl1_im,softReset,twdlXdin1_re,twdlXdin1_im,twdlXdin1_vld);
            pirelab.instantiateNetwork(twdlmult_sdnf1,MUL4,[din1_re,din1_im,din1_vld,twdl1_re,twdl1_im,softReset],[twdlXdin1_re,twdlXdin1_im,twdlXdin1_vld],...
            'MUL4_1');
        end

        if multByOne2
            noOfDelays=9;
            din2_vld=din_vld;
            for loop=1:noOfDelays
                din2_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin1_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['din_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            pirelab.getWireComp(twdlmult_sdnf1,din2_re_dly,twdlXdin2_re);
            pirelab.getWireComp(twdlmult_sdnf1,din2_im_dly,twdlXdin2_im);
            pirelab.getWireComp(twdlmult_sdnf1,din2_vld_dly,twdlXdin_vld);

        elseif strcmpi(blockInfo.ComplexMultiplication,'Use 3 multipliers and 5 adders')
            din2_vld=din_vld;
            for loop=1:3
                din2_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['di2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            MUL3=this.elabComplex3Multiply(twdlmult_sdnf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset,twdlXdin2_re,twdlXdin2_im,twdlXdin2_vld);
            pirelab.instantiateNetwork(twdlmult_sdnf1,MUL3,[din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset],[twdlXdin2_re,twdlXdin2_im,twdlXdin_vld],...
            'MUL3_2');
        else
            din2_vld=din_vld;
            for loop=1:3
                din2_re_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=twdlmult_sdnf1.addSignal2('Type',twdlXdin2_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=twdlmult_sdnf1.addSignal2('Type',pir_boolean_t,'Name',['di2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(twdlmult_sdnf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            MUL4=this.elabComplex4Multiply(twdlmult_sdnf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset,twdlXdin2_re,twdlXdin2_im,twdlXdin2_vld);
            pirelab.instantiateNetwork(twdlmult_sdnf1,MUL4,[din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset],[twdlXdin2_re,twdlXdin2_im,twdlXdin_vld],...
            'MUL4_2');
        end

    end

end

function status=isLastStageOfNonPowerOf4(blockInfo,stageNum)

    totalStages=log2(blockInfo.FFTLength);
    status=false;
    if stageNum==totalStages&&mod(stageNum,2)
        status=true;
    end

end
