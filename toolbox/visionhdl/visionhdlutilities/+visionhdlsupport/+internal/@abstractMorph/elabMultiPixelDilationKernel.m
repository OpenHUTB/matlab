function cNet=elabMultiPixelDilationKernel(~,topNet,blockInfo,inRate)





    boolType=pir_boolean_t();
    pixelIType=pirelab.createPirArrayType(boolType,[blockInfo.kHeight,blockInfo.kWidth]);
    pixelOType=pirelab.getPirVectorType(boolType,blockInfo.NumberOfPixels);
    pixelVType=pirelab.getPirVectorType(boolType,blockInfo.kHeight);




    inportnames{1}='pixelInVec';
    inportnames{2}='enbIn';

    outportnames{1}='pixelOut';




    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MultiPixelDilationKernel',...
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
    Nhood=blockInfo.Nhood;

    dataSplit=data_in.split.Piroutputsignals(end:-1:1);


    for i=1:kW

        nhood(i)=cNet.addSignal(pixelVType,['nhood',num2str(i)]);

        comp=pirelab.getConstComp(cNet,nhood(i),Nhood(:,i));
        comp.addComment('Neighborhood');
    end

    for i=1:kW


        datareg(i)=cNet.addSignal(pixelVType,['datareg',num2str(i)]);
        regin=dataSplit(i);

        pirelab.getWireComp(cNet,regin,datareg(i));


        andout(i)=cNet.addSignal(pixelVType,['andout',num2str(i)]);
        if i==1
            andin=dataSplit(1);
        else
            andin=datareg(i);
        end

        comp=pirelab.getLogicComp(cNet,[nhood(i),andin],andout(i),'and');
        if i==1
            comp.addComment('Finding local maxima');
        end

        or_col(i)=cNet.addSignal(boolType,['or_col',num2str(i)]);
        pirelab.getLogicComp(cNet,andout(i),or_col(i),'or');
    end


    pirelab.getLogicComp(cNet,or_col,dataout,'or');







