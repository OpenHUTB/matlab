function verticalMuxNet=elaborateVerMux(this,topNet,blockInfo,sigInfo,dataRate)




    inType=sigInfo.inType;
    SELT=sigInfo.VERSELT;
    booleanT=sigInfo.booleanT;

    for ii=1:1:blockInfo.effectiveKernelHeight
        inPortNames{ii}=['dataIn',num2str(ii)];
        inPortTypes(ii)=inType;
        inPortRates(ii)=dataRate;
    end

    for ii=1:1:blockInfo.KernelHeight
        outPortNames{ii}=['dataOut',num2str(ii)];
        outPortTypes(ii)=inType;
    end



    inPortNames=[inPortNames,'verMuxSEL'];
    inPortTypes=[inPortTypes,SELT];
    inPortRates=[inPortRates,dataRate];

    verticalMuxNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','verticalMux',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=verticalMuxNet.PirInputSignals;

    for ii=1:1:blockInfo.effectiveKernelHeight
        inSignalsD(ii)=verticalMuxNet.addSignal2('Type',inType,'Name',['inSignalD',num2str(ii)]);
        pirelab.getUnitDelayComp(verticalMuxNet,inSignals(ii),inSignalsD(ii));
    end

    SEL=verticalMuxNet.addSignal2('Type',SELT,'Name','SEL');
    pirelab.getUnitDelayComp(verticalMuxNet,inSignals(end),SEL);
    outSignals=verticalMuxNet.PirOutputSignals;
    halfHeight=ceil(blockInfo.effectiveKernelHeight/2);


    if strcmpi(blockInfo.PaddingMethod,'Constant')

        paddingConstant=fi((blockInfo.PaddingValue),0,inType.WordLength,inType.FractionLength);
        padConst=verticalMuxNet.addSignal2('Type',inType,...
        'Name','paddingConstant');
        padValue=pirelab.getConstComp(verticalMuxNet,padConst,paddingConstant);

        upperCount=ceil(blockInfo.effectiveKernelHeight/2);
        lowerCount=1;

        for ii=1:1:blockInfo.effectiveKernelHeight
            for jj=1:1:blockInfo.effectiveKernelHeight
                if ii<halfHeight
                    if jj<=halfHeight
                        verMux(ii,jj)=inSignalsD(ii);
                    elseif(jj>halfHeight)&&(jj<=upperCount)
                        verMux(ii,jj)=inSignalsD(ii);
                    else
                        verMux(ii,jj)=padConst;
                    end
                elseif ii>halfHeight
                    if jj>=halfHeight
                        verMux(ii,jj)=inSignalsD(ii);
                    elseif(jj<halfHeight)&&(jj>=lowerCount)
                        verMux(ii,jj)=inSignalsD(ii);
                    else

                        verMux(ii,jj)=padConst;
                    end
                end
            end
            if ii<halfHeight
                upperCount=upperCount+1;
            else
                lowerCount=lowerCount+1;
            end
        end









    elseif strcmpi(blockInfo.PaddingMethod,'Symmetric')

        PaddingLineNum=floor(blockInfo.effectiveKernelHeight/2);
        halfHeight=ceil(blockInfo.effectiveKernelHeight/2);

        ind=1;


        for ii=1:1:blockInfo.effectiveKernelHeight
            verMux(ii,1:blockInfo.effectiveKernelHeight)=inSignalsD(ii);
        end


        offsetI=0;
        offsetJ=0;
        num=1;
        for ii=1:1:PaddingLineNum
            offsetI=offsetI+1;
            offsetJ=0;
            for jj=(blockInfo.effectiveKernelHeight):-1:(halfHeight+1)
                if(blockInfo.effectiveKernelHeight-offsetI-offsetJ)>ii
                    verMux(ii,jj)=inSignalsD(blockInfo.effectiveKernelHeight-offsetI-offsetJ);
                    offsetJ=offsetJ+2;
                else
                    verMux(ii,jj)=inSignalsD(ii);
                end
            end
            num=num+1;
        end







        offsetI=0;
        offsetJ=0;
        num=halfHeight-1;
        for ii=blockInfo.effectiveKernelHeight:-1:halfHeight+1
            offsetI=offsetI+1;
            offsetJ=0;
            for jj=halfHeight-1:-1:1
                if jj<=num
                    verMux(ii,jj)=inSignalsD(blockInfo.effectiveKernelHeight-offsetI-offsetJ);
                    offsetJ=offsetJ+2;
                else
                    verMux(ii,jj)=inSignalsD(ii);
                end
            end
            num=num-1;
        end





    elseif strcmpi(blockInfo.PaddingMethod,'Replicate')

        PaddingLineNum=floor(blockInfo.effectiveKernelHeight/2);
        halfHeight=ceil(blockInfo.effectiveKernelHeight/2);

        ind=1;


        for ii=1:1:blockInfo.effectiveKernelHeight
            verMux(ii,1:blockInfo.effectiveKernelHeight)=inSignalsD(ii);
        end



        upperCount=ceil(blockInfo.effectiveKernelHeight/2);
        lowerCount=1;
        for ii=1:1:blockInfo.effectiveKernelHeight
            verUC=1;
            verLC=ceil(blockInfo.effectiveKernelHeight/2);
            for jj=1:1:blockInfo.effectiveKernelHeight
                if ii<halfHeight
                    if jj<=halfHeight
                        verMux(ii,jj)=inSignalsD(ii);
                    elseif(jj>halfHeight)&&(jj<=upperCount)
                        verMux(ii,jj)=inSignalsD(ii);
                    else
                        verMux(ii,jj)=inSignalsD(ii+verUC);
                        verUC=verUC+1;
                    end
                elseif ii>halfHeight
                    if jj>=halfHeight
                        verMux(ii,jj)=inSignalsD(ii);
                    elseif(jj<halfHeight)&&(jj>=lowerCount)
                        verMux(ii,jj)=inSignalsD(ii);
                    else
                        verMux(ii,jj)=inSignalsD(verLC);
                        verLC=verLC+1;
                    end
                end
            end
            if ii<halfHeight
                upperCount=upperCount+1;
            else
                lowerCount=lowerCount+1;
            end
        end





    else
        if mod(blockInfo.KernelHeight,2)~=0
            for ii=1:1:blockInfo.KernelHeight
                pirelab.getWireComp(verticalMuxNet,inSignalsD(ii),outSignals(ii));
            end
        else
            if blockInfo.BiasUp
                for ii=1:1:blockInfo.effectiveKernelHeight-1
                    pirelab.getWireComp(verticalMuxNet,inSignalsD(ii),outSignals(ii));
                end
            else

                for ii=2:1:blockInfo.effectiveKernelHeight
                    pirelab.getWireComp(verticalMuxNet,inSignalsD(ii),outSignals(ii-1));
                end

            end
        end


    end


    if(strcmpi(blockInfo.PaddingMethod,'Replicate'))||(strcmpi(blockInfo.PaddingMethod,'Constant'))||...
        (strcmpi(blockInfo.PaddingMethod,'Symmetric'))


        if mod(blockInfo.KernelHeight,2)~=0
            for ii=1:1:blockInfo.KernelHeight
                if ii~=halfHeight
                    pirelab.getSwitchComp(verticalMuxNet,verMux(ii,1:end),...
                    outSignals(ii),SEL);
                end
            end


            passThrough=pirelab.getDTCComp(verticalMuxNet,inSignalsD(halfHeight),outSignals(halfHeight));
            passThrough.addComment('PASS THROUGH');
        else


            if blockInfo.BiasUp
                for ii=1:1:blockInfo.effectiveKernelHeight-1
                    if ii~=halfHeight
                        pirelab.getSwitchComp(verticalMuxNet,verMux(ii,1:end),...
                        outSignals(ii),SEL);
                    end
                end



                passThrough=pirelab.getDTCComp(verticalMuxNet,inSignalsD(halfHeight),outSignals(halfHeight));
                passThrough.addComment('PASS THROUGH');

            else
                for ii=2:1:blockInfo.effectiveKernelHeight
                    if(ii)~=halfHeight
                        pirelab.getSwitchComp(verticalMuxNet,verMux(ii,1:end),...
                        outSignals(ii-1),SEL);
                    end
                end



                passThrough=pirelab.getDTCComp(verticalMuxNet,inSignalsD(halfHeight),outSignals(halfHeight-1));
                passThrough.addComment('PASS THROUGH');


            end
        end
    end














