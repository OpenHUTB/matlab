function rgb2ycbcrNet=elabRGB2YCBCR(~,topNet,blockInfo,dataRate)






    if strcmp(blockInfo.Conversion,'RGB to YCbCr')
        inportnames={'R','G','B','hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
        outportnames={'Y','Cb','Cr','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
        blockname='RGB2YCbCrCore';
    else
        inportnames={'Y','Cb','Cr','hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
        outportnames={'R','G','B','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
        blockname='YCbCr2RGBCore';
    end

    insignals=topNet.PirInputSignals;
    pixelIn=insignals(1);
    dataType=pixelIn.type.basetype;
    ctrlType=pir_boolean_t();

    rgb2ycbcrNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',blockname,...
    'InportNames',inportnames,...
    'InportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType]);


    compoIn=rgb2ycbcrNet.PirInputSignals(1:3);
    hStartIn=rgb2ycbcrNet.PirInputSignals(4);
    hEndIn=rgb2ycbcrNet.PirInputSignals(5);
    vStartIn=rgb2ycbcrNet.PirInputSignals(6);
    vEndIn=rgb2ycbcrNet.PirInputSignals(7);
    validIn=rgb2ycbcrNet.PirInputSignals(8);

    compoOut=rgb2ycbcrNet.PirOutputSignals(1:3);
    hStartOut=rgb2ycbcrNet.PirOutputSignals(4);
    hEndOut=rgb2ycbcrNet.PirOutputSignals(5);
    vStartOut=rgb2ycbcrNet.PirOutputSignals(6);
    vEndOut=rgb2ycbcrNet.PirOutputSignals(7);
    validOut=rgb2ycbcrNet.PirOutputSignals(8);


    multi1Type=compoIn(1).Type;
    multi2Type=blockInfo.A(1);
    multWL=multi1Type.BaseType.WordLength+multi2Type.WordLength;
    multFL=multi2Type.FractionLength;
    multiType=rgb2ycbcrNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',multWL,...
    'FractionLength',-multFL);

    add1Type=rgb2ycbcrNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',multWL+1,...
    'FractionLength',-multFL);

    add3Type=rgb2ycbcrNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',multWL+2,...
    'FractionLength',-multFL);

    blockInfo.b=fi(blockInfo.b,true,multWL,multFL);

    for ii=1:3
        for jj=1:3
            if(strcmp(blockInfo.Conversion,'YCbCr to RGB')&&...
                ((ii==2)||(ii==3))&&(jj==1))
                assert(blockInfo.A(ii,jj)==blockInfo.A(1,1));
                multiOutDlySig(ii,jj)=rgb2ycbcrNet.addSignal(multiType,['castout',num2str(ii),num2str(jj)]);%#ok
                pirelab.getWireComp(rgb2ycbcrNet,multiOutDlySig(1,1),multiOutDlySig(ii,jj));
                continue;
            end

            current_gain=blockInfo.A(ii,jj);

            if current_gain==0
                multiOutDlySig(ii,jj)=rgb2ycbcrNet.addSignal(multiType,['castout',num2str(ii),num2str(jj)]);%#ok
                pirelab.getConstComp(rgb2ycbcrNet,multiOutDlySig(ii,jj),0);
            else

                inDlySig=rgb2ycbcrNet.addSignal(dataType,['multiInReg',num2str(ii),num2str(jj)]);
                pirelab.getIntDelayComp(rgb2ycbcrNet,compoIn(jj),inDlySig,2,['multiInDelay',num2str(ii),num2str(jj)]);


                multOutSig=rgb2ycbcrNet.addSignal(multiType,['multiOut',num2str(ii),num2str(jj)]);
                pirelab.getGainComp(rgb2ycbcrNet,inDlySig,multOutSig,current_gain,3,blockInfo.OptimM);



                multiOutDlySig(ii,jj)=rgb2ycbcrNet.addSignal(multiType,['multiOutReg',num2str(ii),num2str(jj)]);%#ok
                pirelab.getIntDelayComp(rgb2ycbcrNet,multOutSig,multiOutDlySig(ii,jj),2,['multiOutDelay',num2str(ii),num2str(jj)]);
            end
        end



        add1=rgb2ycbcrNet.addSignal(add1Type,['S1_up',num2str(ii)]);
        pirelab.getAddComp(rgb2ycbcrNet,[multiOutDlySig(ii,1),multiOutDlySig(ii,2)],add1);

        add11=rgb2ycbcrNet.addSignal(add1Type,['S1_up_delay',num2str(ii)]);
        pirelab.getIntDelayComp(rgb2ycbcrNet,add1,add11,1);


        add2=rgb2ycbcrNet.addSignal(add1Type,['S1_down',num2str(ii)]);
        add2_cons=rgb2ycbcrNet.addSignal(multiType,['offset',num2str(ii)]);
        pirelab.getConstComp(rgb2ycbcrNet,add2_cons,blockInfo.b(ii));
        pirelab.getAddComp(rgb2ycbcrNet,[multiOutDlySig(ii,3),add2_cons],add2);

        add22=rgb2ycbcrNet.addSignal(add1Type,['S1_down_delay',num2str(ii)]);
        pirelab.getIntDelayComp(rgb2ycbcrNet,add2,add22,1);



        add3=rgb2ycbcrNet.addSignal(add3Type,['S2',num2str(ii)]);
        pirelab.getAddComp(rgb2ycbcrNet,[add11,add22],add3);

        add33=rgb2ycbcrNet.addSignal(add3Type,['S2_delay',num2str(ii)]);
        pirelab.getIntDelayComp(rgb2ycbcrNet,add3,add33,1);


        castOut=rgb2ycbcrNet.addSignal(dataType,['castout',num2str(ii)]);
        regcomp=pirelab.getDTCComp(rgb2ycbcrNet,add33,castOut,'Nearest','Saturate');

        regcomp.addComment('convert to dataOut data type');


        castdelay(ii)=rgb2ycbcrNet.addSignal(dataType,['cast_delay',num2str(ii)]);%#ok
        pirelab.getIntDelayComp(rgb2ycbcrNet,castOut,castdelay(ii),1);
    end

    regcomp=pirelab.getIntDelayComp(rgb2ycbcrNet,hStartIn,hStartOut,8,'hStart');
    regcomp.addComment('delay hStart');
    regcomp=pirelab.getIntDelayComp(rgb2ycbcrNet,hEndIn,hEndOut,8,'hEnd');
    regcomp.addComment('delay hEnd');
    regcomp=pirelab.getIntDelayComp(rgb2ycbcrNet,vStartIn,vStartOut,8,'vStart');
    regcomp.addComment('delay vStart');
    regcomp=pirelab.getIntDelayComp(rgb2ycbcrNet,vEndIn,vEndOut,8,'vEnd');
    regcomp.addComment('delay vEnd');

    muxsel=rgb2ycbcrNet.addSignal(ctrlType,'Mux_Sel');
    pirelab.getIntDelayComp(rgb2ycbcrNet,validIn,muxsel,7);
    pirelab.getIntDelayComp(rgb2ycbcrNet,muxsel,validOut,1);

    zeroconst=rgb2ycbcrNet.addSignal(dataType,'const_zero');
    pirelab.getConstComp(rgb2ycbcrNet,zeroconst,0);

    for ii=1:3
        switchout=rgb2ycbcrNet.addSignal(dataType,['SwitchOut',num2str(ii)]);
        pirelab.getSwitchComp(rgb2ycbcrNet,[zeroconst,castdelay(ii)],switchout,muxsel);
        pirelab.getIntDelayComp(rgb2ycbcrNet,switchout,compoOut(ii),1);
    end


