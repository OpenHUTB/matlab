function verPadNet=elaborateVerticalPadding(~,topNet,blockInfo,sigInfo,dataRate,M)%#ok<INUSD>






    inType=sigInfo.inType;

    if blockInfo.NumPixels>1
        colType=pirelab.createPirArrayType(inType.BaseType,[1,inType.Dimensions]);
    end

    booleanT=sigInfo.booleanT;
    lineStartT=sigInfo.lineStartT;%#ok<NASGU>
    countT=sigInfo.countT;
    dataVType=sigInfo.dataVType;



    inPortNames={'dataVectorIn','verPadCount'};
    inPortTypes=[dataVType,countT];
    inPortRates=[dataRate,dataRate];
    outPortNames={'dataVectorOut'};
    outPortTypes=dataVType;



    verPadNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Vertical Padder',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=verPadNet.PirInputSignals;
    dataVectorIn=inSignals(1);
    verPadCount=inSignals(2);


    outSignals=verPadNet.PirOutputSignals;
    dataVectorOut=outSignals(1);

    if blockInfo.NumPixels==1


        for ii=1:1:blockInfo.KernelHeight
            dataLineIn(ii)=verPadNet.addSignal2('Type',inType,'Name',['DataLineIn',num2str(ii)]);%#ok<AGROW>
            dataLineOut(ii)=verPadNet.addSignal2('Type',inType,'Name',['DataLineOut',num2str(ii)]);%#ok<AGROW>
        end

        pirelab.getDemuxComp(verPadNet,dataVectorIn,dataLineIn);


        if mod(blockInfo.KernelHeight,2)==0
            EvenKernelConstant=1;
        else
            EvenKernelConstant=0;
        end


        if blockInfo.BiasUp
            BiasConstant=0;
        else
            BiasConstant=1;
        end

        if strcmpi(blockInfo.PaddingMethod,'Constant')

            dataPadValue=verPadNet.addSignal2('Type',inType,'Name','DataPadValue');
            pirelab.getConstComp(verPadNet,dataPadValue,blockInfo.PaddingValue);

            if mod(blockInfo.KernelHeight,2)==0
                for ii=1:1:blockInfo.KernelHeight


                    if ii<ceil(blockInfo.KernelHeight/2)+1
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'>',(floor(blockInfo.KernelHeight/2)+(ii-2))+BiasConstant);
                        pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    elseif ii>ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2)-1+BiasConstant);
                        pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    end
                end
            else
                for ii=1:1:blockInfo.KernelHeight

                    if ii==ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getWireComp(verPadNet,dataLineIn(ii),dataLineOut(ii));

                    elseif ii<ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'>',(floor(blockInfo.KernelHeight/2)+(ii-1)));
                        pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    elseif ii>ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2));
                        pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    end
                end


            end


        elseif strcmpi(blockInfo.PaddingMethod,'Replicate')


            for ii=1:1:blockInfo.KernelHeight
                verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                if ii<(ceil(blockInfo.KernelHeight/2))+EvenKernelConstant
                    pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'>',floor(blockInfo.KernelHeight/2)+(ii-1)-EvenKernelConstant);
                    pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataLineOut(ii+1)],dataLineOut(ii),verSEL(ii));
                elseif ii==(ceil(blockInfo.KernelHeight/2))
                    pirelab.getWireComp(verPadNet,dataLineIn(ii),dataLineOut(ii));
                elseif ii>ceil(blockInfo.KernelHeight/2)
                    pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2)-EvenKernelConstant);
                    pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataLineOut(ii-1)],dataLineOut(ii),verSEL(ii));
                end

            end

        elseif strcmpi(blockInfo.PaddingMethod,'Symmetric')

            padLocArray(1)=1;

            for ii=1:1:ceil(blockInfo.KernelHeight/2)
                padLocArray(ii)=(ii*2)-1;%#ok<AGROW>
            end


            for ii=1:1:blockInfo.KernelHeight


                if ii==ceil(blockInfo.KernelHeight/2)+EvenKernelConstant
                    pirelab.getWireComp(verPadNet,dataLineIn(ii),dataLineOut(ii));
                elseif ii<ceil(blockInfo.KernelHeight/2)+EvenKernelConstant
                    for jj=1:1:blockInfo.KernelHeight

                        if jj<ceil(blockInfo.KernelHeight/2)+EvenKernelConstant
                            dataLineMuxArrayLower(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                        else
...
                            padIndex=jj+EvenKernelConstant-floor(blockInfo.KernelHeight/2)-ii;

                            if padIndex>0
                                dataLineMuxArrayLower(jj,ii)=dataLineIn(padLocArray(padIndex)+ii);%#ok<AGROW>
                            else
                                dataLineMuxArrayLower(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                            end

                        end

                    end
                    pirelab.getSwitchComp(verPadNet,dataLineMuxArrayLower(:,ii)',dataLineOut(ii),verPadCount);

                elseif ii>ceil(blockInfo.KernelHeight/2)+EvenKernelConstant

                    for jj=1:1:blockInfo.KernelHeight
                        if jj>ceil(blockInfo.KernelHeight/2)+EvenKernelConstant
                            dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                        else
...
                            padIndex=ii-(ceil(blockInfo.KernelHeight/2)+(jj-1))-EvenKernelConstant;
                            if padIndex>0
                                dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii-padLocArray(padIndex));%#ok<AGROW>
                            else
                                dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                            end
                        end

                    end

                    pirelab.getSwitchComp(verPadNet,dataLineMuxArrayUpper(:,ii)',dataLineOut(ii),verPadCount);

                end


            end

        elseif strcmpi(blockInfo.PaddingMethod,'Reflection')

            padLocArray(1)=1;
            for ii=1:1:ceil(blockInfo.KernelHeight/2)
                padLocArray(ii)=(ii*2);%#ok<AGROW>
            end

            if blockInfo.KernelTwo
                EvenKernelConstant=1;
            else
                EvenKernelConstant=0;
            end
            for ii=1:1:blockInfo.KernelHeight

                if ii==ceil(blockInfo.KernelHeight/2)
                    pirelab.getWireComp(verPadNet,dataLineIn(ii),dataLineOut(ii));

                elseif ii<ceil(blockInfo.KernelHeight/2)
                    for jj=1:1:blockInfo.KernelHeight-EvenKernelConstant
                        if jj<ceil(blockInfo.KernelHeight/2)
                            dataLineMuxArrayLower(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                        else
                            padIndex=jj-floor(blockInfo.KernelHeight/2)-ii+EvenKernelConstant;
                            if padIndex>0
                                dataLineMuxArrayLower(jj,ii)=dataLineIn(padLocArray(padIndex)+ii);%#ok<AGROW>
                            else
                                dataLineMuxArrayLower(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                            end
                        end
                    end
                    pirelab.getSwitchComp(verPadNet,dataLineMuxArrayLower(:,ii)',dataLineOut(ii),verPadCount);

                elseif ii>ceil(blockInfo.KernelHeight/2)
                    for jj=1:1:blockInfo.KernelHeight-EvenKernelConstant
                        if jj>ceil(blockInfo.KernelHeight/2)
                            dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                        else
                            padIndex=ii-(ceil(blockInfo.KernelHeight/2)+(jj-1));
                            if padIndex>0
                                dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii-padLocArray(padIndex));%#ok<AGROW>
                            else
                                dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                            end
                        end
                    end
                    pirelab.getSwitchComp(verPadNet,dataLineMuxArrayUpper(:,ii)',dataLineOut(ii),verPadCount);
                end
            end
        end

        pirelab.getMuxComp(verPadNet,dataLineOut,dataVectorOut);

    else

        for ii=1:1:blockInfo.KernelHeight*blockInfo.NumPixels
            dataLineInPre(ii)=verPadNet.addSignal2('Type',colType.BaseType,'Name',['DataLineIn',num2str(ii)]);%#ok<NASGU,AGROW>
        end

        for ii=1:1:blockInfo.KernelHeight
            dataLineIn(ii)=verPadNet.addSignal2('Type',colType,'Name',['DataLineIn',num2str(ii)]);%#ok<AGROW>
            dataLineOut(ii)=verPadNet.addSignal2('Type',colType,'Name',['DataLineOut',num2str(ii)]);%#ok<AGROW>     
        end

        dataTType=pirelab.createPirArrayType(colType.BaseType,[colType.Dimensions,blockInfo.KernelHeight]);
        dataVectorTranpose=verPadNet.addSignal2('Type',dataTType,'Name','DataVectorTranspose');
        pirelab.getTransposeComp(verPadNet,dataVectorIn,dataVectorTranpose);



        dataVectorSplit=dataVectorTranpose.split;

        for kk=1:1:blockInfo.KernelHeight
            pirelab.getWireComp(verPadNet,dataVectorSplit.PirOutputSignals(kk),dataLineIn(kk));
        end



        if mod(blockInfo.KernelHeight,2)==0
            EvenKernelConstant=1;
        else
            EvenKernelConstant=0;
        end

        if blockInfo.BiasUp
            BiasConstant=0;
        else
            BiasConstant=1;
        end

        if strcmpi(blockInfo.PaddingMethod,'Constant')

            dataPadValue=verPadNet.addSignal2('Type',colType,'Name','DataPadValue');
            pirelab.getConstComp(verPadNet,dataPadValue,blockInfo.PaddingValue);

            if mod(blockInfo.KernelHeight,2)==0
                for ii=1:1:blockInfo.KernelHeight


                    if ii<ceil(blockInfo.KernelHeight/2)+1
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'>',(floor(blockInfo.KernelHeight/2)+(ii-2))+BiasConstant);
                        pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    elseif ii>ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2)-1+BiasConstant);
                        pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    end
                end
            else
                for ii=1:1:blockInfo.KernelHeight

                    if ii==ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getWireComp(verPadNet,dataLineIn(ii),dataLineOut(ii));

                    elseif ii<ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'>',(floor(blockInfo.KernelHeight/2)+(ii-1)));
                        pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    elseif ii>ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2));
                        pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    end
                end


            end


        elseif strcmpi(blockInfo.PaddingMethod,'Replicate')||(blockInfo.NumPixels>1&&(blockInfo.KernelTwo||blockInfo.KernelHeight==4)&&strcmpi(blockInfo.PaddingMethod,'Symmetric'))
            for ii=1:1:blockInfo.KernelHeight
                verSEL(ii)=verPadNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                if ii<(ceil(blockInfo.KernelHeight/2))+EvenKernelConstant
                    pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'>',floor(blockInfo.KernelHeight/2)+(ii-1)-EvenKernelConstant);
                    pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataLineOut(ii+1)],dataLineOut(ii),verSEL(ii));
                elseif ii==(ceil(blockInfo.KernelHeight/2))
                    pirelab.getWireComp(verPadNet,dataLineIn(ii),dataLineOut(ii));
                elseif ii>ceil(blockInfo.KernelHeight/2)
                    pirelab.getCompareToValueComp(verPadNet,verPadCount,verSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2)-EvenKernelConstant);
                    pirelab.getSwitchComp(verPadNet,[dataLineIn(ii),dataLineOut(ii-1)],dataLineOut(ii),verSEL(ii));
                end

            end

        elseif strcmpi(blockInfo.PaddingMethod,'Symmetric')

            padLocArray(1)=1;

            for ii=1:1:ceil(blockInfo.KernelHeight/2)
                padLocArray(ii)=(ii*2)-1;%#ok<AGROW>
            end

            for ii=1:1:blockInfo.KernelHeight


                if ii==ceil(blockInfo.KernelHeight/2)+EvenKernelConstant
                    pirelab.getWireComp(verPadNet,dataLineIn(ii),dataLineOut(ii));
                elseif ii<ceil(blockInfo.KernelHeight/2)+EvenKernelConstant
                    for jj=1:1:blockInfo.KernelHeight

                        if jj<ceil(blockInfo.KernelHeight/2)+EvenKernelConstant
                            dataLineMuxArrayLower(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                        else
...
                            padIndex=jj+EvenKernelConstant-floor(blockInfo.KernelHeight/2)-ii;

                            if padIndex>0
                                dataLineMuxArrayLower(jj,ii)=dataLineIn(padLocArray(padIndex)+ii);%#ok<AGROW>
                            else
                                dataLineMuxArrayLower(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                            end

                        end

                    end
                    pirelab.getSwitchComp(verPadNet,dataLineMuxArrayLower(:,ii)',dataLineOut(ii),verPadCount);

                elseif ii>ceil(blockInfo.KernelHeight/2)+EvenKernelConstant

                    for jj=1:1:blockInfo.KernelHeight
                        if jj>ceil(blockInfo.KernelHeight/2)+EvenKernelConstant
                            dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                        else
...
                            padIndex=ii-(ceil(blockInfo.KernelHeight/2)+(jj-1))-EvenKernelConstant;
                            if padIndex>0
                                dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii-padLocArray(padIndex));%#ok<AGROW>
                            else
                                dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                            end
                        end

                    end

                    pirelab.getSwitchComp(verPadNet,dataLineMuxArrayUpper(:,ii)',dataLineOut(ii),verPadCount);

                end


            end

        elseif strcmpi(blockInfo.PaddingMethod,'Reflection')

            padLocArray(1)=1;
            for ii=1:1:ceil(blockInfo.KernelHeight/2)
                padLocArray(ii)=(ii*2);%#ok<AGROW>
            end
            if blockInfo.KernelTwo
                EvenKernelConstant=1;

                constZero=verPadNet.addSignal2('Type',colType,'Name','constZero');
                pirelab.getConstComp(verPadNet,constZero,0);
                pirelab.getWireComp(verPadNet,constZero,dataLineOut(blockInfo.KernelHeight));
            else
                EvenKernelConstant=0;
            end

            for ii=1:1:blockInfo.KernelHeight-EvenKernelConstant

                if ii==ceil(blockInfo.KernelHeight/2)
                    pirelab.getWireComp(verPadNet,dataLineIn(ii),dataLineOut(ii));

                elseif ii<ceil(blockInfo.KernelHeight/2)
                    for jj=1:1:blockInfo.KernelHeight-EvenKernelConstant
                        if jj<ceil(blockInfo.KernelHeight/2)
                            dataLineMuxArrayLower(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                        else
                            padIndex=jj-floor(blockInfo.KernelHeight/2)-ii+EvenKernelConstant;
                            if padIndex>0
                                dataLineMuxArrayLower(jj,ii)=dataLineIn(padLocArray(padIndex)+ii);%#ok<AGROW>
                            else
                                dataLineMuxArrayLower(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                            end
                        end
                    end
                    pirelab.getSwitchComp(verPadNet,dataLineMuxArrayLower(:,ii)',dataLineOut(ii),verPadCount);

                elseif ii>ceil(blockInfo.KernelHeight/2)
                    for jj=1:1:blockInfo.KernelHeight-EvenKernelConstant
                        if jj>ceil(blockInfo.KernelHeight/2)
                            dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                        else
                            padIndex=ii-(ceil(blockInfo.KernelHeight/2)+(jj-1));
                            if padIndex>0
                                dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii-padLocArray(padIndex));%#ok<AGROW>
                            else
                                dataLineMuxArrayUpper(jj,ii)=dataLineIn(ii);%#ok<AGROW>
                            end
                        end
                    end
                    pirelab.getSwitchComp(verPadNet,dataLineMuxArrayUpper(:,ii)',dataLineOut(ii),verPadCount);
                end
            end
        end






        dataVecInt=verPadNet.addSignal2('Type',dataVType,'Name','dataVecInt');

        pirelab.getConcatenateComp(verPadNet,dataLineOut,dataVecInt,'VecConcatOut','1');
        pirelab.getWireComp(verPadNet,dataVecInt,dataVectorOut);








    end

