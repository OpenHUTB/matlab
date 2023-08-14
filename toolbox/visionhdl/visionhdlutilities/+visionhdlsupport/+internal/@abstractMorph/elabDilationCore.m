function cNet=elabDilationCore(~,topNet,blockInfo,inRate)





    boolType=pir_boolean_t();
    pixelVType=pirelab.getPirVectorType(boolType,blockInfo.kHeight);

    inportnames{1}='pixelInVec';
    inportnames{2}='hStartIn';
    inportnames{3}='hEndIn';
    inportnames{4}='vStartIn';
    inportnames{5}='vEndIn';
    inportnames{6}='validIn';
    inportnames{7}='processData';


    outportnames{1}='pixelOut';
    outportnames{2}='hStartOut';
    outportnames{3}='hEndOut';
    outportnames{4}='vStartOut';
    outportnames{5}='vEndOut';
    outportnames{6}='validOut';




    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DilationCore',...
    'InportNames',inportnames,...
    'InportTypes',[pixelVType,boolType,boolType,boolType,boolType,boolType,boolType],...
    'InportRates',[inRate,inRate,inRate,inRate,inRate,inRate,inRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[boolType,boolType,boolType,boolType,boolType,boolType]...
    );
    cNet.addComment('Find local maxima in binary image');



    data_in=cNet.PirInputSignals(1);
    hstartIn=cNet.PirInputSignals(2);
    hendIn=cNet.PirInputSignals(3);
    vstartIn=cNet.PirInputSignals(4);
    vendIn=cNet.PirInputSignals(5);
    validIn=cNet.PirInputSignals(6);
    enbIn=cNet.PirInputSignals(7);

    dataout=cNet.PirOutputSignals(1);
    hstartOut=cNet.PirOutputSignals(2);
    hendOut=cNet.PirOutputSignals(3);
    vstartOut=cNet.PirOutputSignals(4);
    vendOut=cNet.PirOutputSignals(5);
    validOut=cNet.PirOutputSignals(6);













    kW=blockInfo.kWidth;
    Nhood=blockInfo.Nhood;

    for i=1:kW

        nhood(i)=cNet.addSignal(pixelVType,['nhood',num2str(i)]);

        comp=pirelab.getConstComp(cNet,nhood(i),Nhood(:,i));
        comp.addComment('Neighborhood');
    end

    for i=1:kW

        if i~=kW
            datareg(i)=cNet.addSignal(pixelVType,['datareg',num2str(i)]);
            if i==1
                regin=data_in;
            else
                regin=datareg(i-1);
            end
            pirelab.getUnitDelayEnabledComp(cNet,regin,datareg(i),enbIn);
        end

        andout(i)=cNet.addSignal(pixelVType,['andout',num2str(i)]);
        if i==1
            andin=data_in;
        else
            andin=datareg(i-1);
        end

        comp=pirelab.getLogicComp(cNet,[nhood(i),andin],andout(i),'and');
        if i==1
            comp.addComment('Finding local maxima');
        end

        or_col(i)=cNet.addSignal(boolType,['or_col',num2str(i)]);
        pirelab.getLogicComp(cNet,andout(i),or_col(i),'or');
    end


    finalor=cNet.addSignal(boolType,'finalor');
    pirelab.getLogicComp(cNet,or_col,finalor,'or');


    linebufferDelay=floor((kW-1)/2);

    if blockInfo.kWidth==1&&blockInfo.kHeight>=2
        hdlDelay=0;
    else
        hdlDelay=1;
    end



    if strcmpi(blockInfo.PaddingMethod,'None')


        hstartKernelOut=cNet.addSignal(boolType,'hStartKernelOut');
        hendKernelOut=cNet.addSignal(boolType,'hEndKernelOut');
        vstartKernelOut=cNet.addSignal(boolType,'vStartKernelOut');
        vendKernelOut=cNet.addSignal(boolType,'vEndKernelOut');
        pirelab.getIntDelayEnabledComp(cNet,hstartIn,hstartKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayComp(cNet,hendIn,hendKernelOut,linebufferDelay);
        pirelab.getIntDelayEnabledComp(cNet,vstartIn,vstartKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayComp(cNet,vendIn,vendKernelOut,linebufferDelay);



        hstartKernelValidOut=cNet.addSignal(boolType,'hStartKernelValidOut');
        hendKernelValidOut=cNet.addSignal(boolType,'hEndKernelValidOut');
        vstartKernelValidOut=cNet.addSignal(boolType,'vStartKernelValidOut');
        vendKernelValidOut=cNet.addSignal(boolType,'vEndKernelValidOut');
        pirelab.getLogicComp(cNet,[hstartKernelOut,enbIn],hstartKernelValidOut,'and');
        pirelab.getWireComp(cNet,hendKernelOut,hendKernelValidOut);
        pirelab.getLogicComp(cNet,[vstartKernelOut,enbIn],vstartKernelValidOut,'and');
        pirelab.getWireComp(cNet,vendKernelOut,vendKernelValidOut);



        pirelab.getIntDelayComp(cNet,hstartKernelValidOut,hstartOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,hendKernelValidOut,hendOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,vstartKernelValidOut,vstartOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,vendKernelValidOut,vendOut,hdlDelay);



        validREG=cNet.addSignal(boolType,'validREG');
        pirelab.getUnitDelayEnabledResettableComp(cNet,hendIn,validREG,hendIn,hendKernelOut,'validREG',0,'',true,'',-1,true);


        pixelSel=cNet.addSignal(boolType,'pixelsel');
        pixelSelEnb=cNet.addSignal(boolType,'pixelsel');
        pirelab.getIntDelayEnabledResettableComp(cNet,validIn,pixelSel,enbIn,hendIn,linebufferDelay);
        pixelSelValidOut=cNet.addSignal(boolType,'validKernelValidOut');
        pirelab.getLogicComp(cNet,[pixelSel,enbIn],pixelSelEnb,'and');
        pirelab.getLogicComp(cNet,[pixelSelEnb,validREG],pixelSelValidOut,'or');
        pirelab.getIntDelayComp(cNet,pixelSelValidOut,validOut,hdlDelay);

        falseout=cNet.addSignal(boolType,'falseout');
        comp=pirelab.getConstComp(cNet,falseout,false);
        comp.addComment('Constant zero');


        validpixel=cNet.addSignal(boolType,'validpixel');
        pirelab.getSwitchComp(cNet,[finalor,falseout],validpixel,pixelSelValidOut,'','==',1);
        pirelab.getIntDelayComp(cNet,validpixel,dataout,hdlDelay);


    else

        hstartKernelOut=cNet.addSignal(boolType,'hStartKernelOut');
        hendKernelOut=cNet.addSignal(boolType,'hEndKernelOut');
        vstartKernelOut=cNet.addSignal(boolType,'vStartKernelOut');
        vendKernelOut=cNet.addSignal(boolType,'vEndKernelOut');
        pirelab.getIntDelayEnabledComp(cNet,hstartIn,hstartKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayEnabledComp(cNet,hendIn,hendKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayEnabledComp(cNet,vstartIn,vstartKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayEnabledComp(cNet,vendIn,vendKernelOut,enbIn,linebufferDelay);



        hstartKernelValidOut=cNet.addSignal(boolType,'hStartKernelValidOut');
        hendKernelValidOut=cNet.addSignal(boolType,'hEndKernelValidOut');
        vstartKernelValidOut=cNet.addSignal(boolType,'vStartKernelValidOut');
        vendKernelValidOut=cNet.addSignal(boolType,'vEndKernelValidOut');
        pirelab.getLogicComp(cNet,[hstartKernelOut,enbIn],hstartKernelValidOut,'and');
        pirelab.getLogicComp(cNet,[hendKernelOut,enbIn],hendKernelValidOut,'and');
        pirelab.getLogicComp(cNet,[vstartKernelOut,enbIn],vstartKernelValidOut,'and');
        pirelab.getLogicComp(cNet,[vendKernelOut,enbIn],vendKernelValidOut,'and');


        pirelab.getIntDelayComp(cNet,hstartKernelValidOut,hstartOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,hendKernelValidOut,hendOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,vstartKernelValidOut,vstartOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,vendKernelValidOut,vendOut,hdlDelay);

        pixelSel=cNet.addSignal(boolType,'pixelsel');
        pirelab.getIntDelayEnabledComp(cNet,validIn,pixelSel,enbIn,linebufferDelay);
        pixelSelValidOut=cNet.addSignal(boolType,'validKernelValidOut');
        pirelab.getLogicComp(cNet,[pixelSel,enbIn],pixelSelValidOut,'and');
        pirelab.getIntDelayComp(cNet,pixelSelValidOut,validOut,hdlDelay);

        falseout=cNet.addSignal(boolType,'falseout');
        comp=pirelab.getConstComp(cNet,falseout,false);
        comp.addComment('Constant zero');


        validpixel=cNet.addSignal(boolType,'validpixel');
        pirelab.getSwitchComp(cNet,[finalor,falseout],validpixel,pixelSelValidOut,'','==',1);
        pirelab.getIntDelayComp(cNet,validpixel,dataout,hdlDelay);


    end

