function elaborateSystolicFIR(~,net,inSignals,outSignals,params,pirTypes)








    dataIn=inSignals(1);
    validIn=inSignals(2);
    dataOut=outSignals(1);
    validOut=outSignals(2);
    ready=outSignals(3);





    L=length(params.Coefficients);





    validPipeIn=validIn;
    validPipeOut=validIn;
    dataPipeIn=dataIn;

    for k=1:L-1
        idxStr=int2str(k-1);

        validPipeOut=net.addSignal(pir_boolean_t,['validPipe',idxStr]);
        dataPipe(k)=net.addSignal(pirTypes.inputType,['dataPipe',idxStr]);%#ok<AGROW>
        dataDelay=net.addSignal(pirTypes.inputType,['dataDelay',idxStr]);

        pirelab.getUnitDelayComp(net,validPipeIn,validPipeOut,validPipeOut.Name);
        pirelab.getUnitDelayComp(net,dataPipeIn,dataPipe(k),dataPipe(k).Name);
        pirelab.getUnitDelayEnabledComp(net,dataPipe(k),dataDelay,validPipeOut,dataDelay.Name);

        validPipeIn=validPipeOut;
        dataPipeIn=dataDelay;
    end


    k=L;
    idxStr=int2str(k-1);
    dataPipe(k)=net.addSignal(pirTypes.inputType,['dataPipe',idxStr]);
    pirelab.getUnitDelayComp(net,dataPipeIn,dataPipe(k),dataPipe(k).Name);







    sum=net.addSignal(pirTypes.accumulatorType,'sum0');
    coeff=net.addSignal(pirTypes.coefficientsType,'coeff0');

    pirelab.getConstComp(net,coeff,params.Coefficients(1),'constCoeff0');
    elaborateMultCell(net,params,dataPipe(1),coeff,sum,pirTypes.productType,0);

    sumIn=sum;


    for k=2:L
        idxStr=int2str(k-1);
        sum=net.addSignal(pirTypes.accumulatorType,['sum',idxStr]);
        coeff=net.addSignal(pirTypes.coefficientsType,['coeff',idxStr]);

        pirelab.getConstComp(net,coeff,params.Coefficients(k),['constCoeff',idxStr]);
        elaborateMultAddCell1(net,params,dataPipe(k),coeff,sumIn,sum,pirTypes.productType,k-1);

        sumIn=sum;
    end






    finalSumValid=net.addSignal(pir_boolean_t,'finalSumValid');
    pirelab.getIntDelayComp(net,validPipeOut,finalSumValid,4,'finalSumValidPipe');

    finalSumPipe=net.addSignal(pirTypes.accumulatorType,'finalSumPipe');
    pirelab.getUnitDelayComp(net,sum,finalSumPipe,'finalSumPipe');




    converterIn=net.addSignal(pirTypes.accumulatorType,'converterIn');
    pirelab.getUnitDelayComp(net,finalSumPipe,converterIn,'finalSumPipe');

    converterOut=net.addSignal(pirTypes.outputType,'converterOut');
    pirelab.getDTCComp(net,converterIn,converterOut,params.RoundingMethod,params.OverflowAction);


    pirelab.getUnitDelayComp(net,finalSumValid,validOut,'finalValidPipe');
    pirelab.getUnitDelayEnabledComp(net,converterOut,dataOut,finalSumValid,'finalDataPipe');


    pirelab.getConstComp(net,ready,true);

end





function elaborateMultAddCell1(net,params,tapIn,coeffIn,sumIn,sumOut,~,idx)

    idxStr=int2str(idx);

    if strcmpi(params.synthesisToolname,'Altera Quartus II')




        multIn=net.addSignal(tapIn.Type,['multInPipe',idxStr]);

        pirelab.getUnitDelayComp(net,tapIn,multIn,multIn.name);


        pipelineDepth=0;
        sumInPipe=net.addSignal(sumIn.Type,['sumInPipe',idxStr]);
        pirelab.getUnitDelayComp(net,sumIn,sumInPipe,['sumInPipe',idxStr]);
        macSumIn=sumInPipe;

    else





        multIn=tapIn;
        pipelineDepth=1;
        macSumIn=sumIn;

    end

    pirelab.getScalarMACComp(net,[multIn,coeffIn,macSumIn],sumOut,'Floor','Wrap','','',-1,pipelineDepth);

end





function elaborateMultCell(net,params,tapIn,coeffIn,dataOut,productType,idx)

    idxStr=int2str(idx);

    if strcmpi(params.synthesisToolname,'Altera Quartus II')

        multIn=net.addSignal(tapIn.Type,['multInPipe',idxStr]);
        pirelab.getUnitDelayComp(net,tapIn,multIn,multIn.name);
    else

        multIn=tapIn;
    end


    product=net.addSignal(productType,['product',idxStr]);
    pirelab.getMulComp(net,[multIn,coeffIn],product);

    if strcmpi(params.synthesisToolname,'Altera Quartus II')

        productOut=product;
    else

        productPipe=net.addSignal(productType,['productPipe',idxStr]);
        pirelab.getUnitDelayComp(net,product,productPipe,['multOutPipe',idxStr]);
        productOut=productPipe;
    end

    pirelab.getDTCComp(net,productOut,dataOut);

end

