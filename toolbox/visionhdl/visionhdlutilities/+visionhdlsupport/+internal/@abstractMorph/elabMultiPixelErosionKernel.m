function cNet=elabMultiPixelErosionKernel(~,topNet,blockInfo,inRate)





    boolType=pir_boolean_t();
    pixelIType=pirelab.createPirArrayType(boolType,[blockInfo.kHeight,blockInfo.kWidth]);
    pixelOType=pirelab.getPirVectorType(boolType,blockInfo.NumberOfPixels);
    pixelVType=pirelab.getPirVectorType(boolType,blockInfo.kHeight);




    inportnames{1}='pixelInVec';
    inportnames{2}='enbIn';

    outportnames{1}='pixelOut';




    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MultiPixelErosionKernel',...
    'InportNames',inportnames,...
    'InportTypes',[pixelIType,boolType],...
    'InportRates',[inRate,inRate],...
    'OutportNames',outportnames,...
    'OutportTypes',boolType...
    );
    cNet.addComment('Find local maxima in binary image');



    data_in=cNet.PirInputSignals(1);
    enbIn=cNet.PirInputSignals(2);


    dataout=cNet.PirOutputSignals(1);













    kW=blockInfo.kWidth;
    kH=blockInfo.kHeight;
    Nhood=blockInfo.Nhood;
    notNhood=not(Nhood(kH:-1:1,kW:-1:1));

    dataSplit=data_in.split.Piroutputsignals(end:-1:1);


    for i=1:kW

        nhood(i)=cNet.addSignal(pixelVType,['nhood',num2str(i)]);

        comp=pirelab.getConstComp(cNet,nhood(i),notNhood(:,i));
        comp.addComment('Neighborhood');
    end

    for i=1:kW


        datareg(i)=cNet.addSignal(pixelVType,['datareg',num2str(i)]);
        regin=dataSplit(i);

        pirelab.getWireComp(cNet,regin,datareg(i));


        orout(i)=cNet.addSignal(pixelVType,['orout',num2str(i)]);
        if i==1
            orin=dataSplit(1);
        else
            orin=datareg(i);
        end

        comp=pirelab.getLogicComp(cNet,[nhood(i),orin],orout(i),'or');
        if i==1
            comp.addComment('Finding local maxima');
        end

        and_col(i)=cNet.addSignal(boolType,['and_col',num2str(i)]);
        pirelab.getLogicComp(cNet,orout(i),and_col(i),'and');
    end


    pirelab.getLogicComp(cNet,and_col,dataout,'and');







