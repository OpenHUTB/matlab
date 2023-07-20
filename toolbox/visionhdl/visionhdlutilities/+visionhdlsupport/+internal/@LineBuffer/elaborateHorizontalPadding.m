function horPadNet=elaborateHorizontalPadding(~,topNet,blockInfo,sigInfo,dataRate,M)%#ok<INUSD>






    inType=sigInfo.inType;%#ok<NASGU>
    booleanT=sigInfo.booleanT;
    lineStartT=sigInfo.lineStartT;%#ok<NASGU>
    countT=sigInfo.countT;
    dataVType=sigInfo.dataVType;



    inPortNames={'dataVectorIn','horPadCount','padShift'};
    inPortTypes=[dataVType,countT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate];
    outPortNames={'dataVector'};
    outPortTypes=dataVType;



    horPadNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Horizontal Padder',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=horPadNet.PirInputSignals;
    dataVectorIn=inSignals(1);
    horPadCount=inSignals(2);
    padShift=inSignals(3);


    outSignals=horPadNet.PirOutputSignals;
    dataVectorOut=outSignals(1);

    dataMuxIn=horPadNet.addSignal2('Type',dataVType,'Name','DataMuxIn');

    if~blockInfo.BiasUp&&mod(blockInfo.KernelWidth,2)==0
        BiasUpConst=1;
    else
        BiasUpConst=0;
    end

    if strcmpi(blockInfo.PaddingMethod,'Constant')
        if mod(blockInfo.KernelWidth,2)==0&&blockInfo.BiasUp
            pirelab.getIntDelayEnabledComp(horPadNet,dataVectorIn,dataMuxIn,padShift,floor(blockInfo.KernelWidth/2)-1);
        else
            pirelab.getIntDelayEnabledComp(horPadNet,dataVectorIn,dataMuxIn,padShift,floor(blockInfo.KernelWidth/2));
        end



        dataPadValue=horPadNet.addSignal2('Type',dataVType,'Name','DataPadValue');
        pirelab.getConstComp(horPadNet,dataPadValue,ones(blockInfo.KernelHeight,blockInfo.NumPixels).*blockInfo.PaddingValue);

        for ii=1:1:blockInfo.KernelWidth

            if ii==ceil(blockInfo.KernelWidth/2)+BiasUpConst
                padArray(ii)=dataMuxIn;%#ok<AGROW>
            else
                padArray(ii)=dataPadValue;%#ok<AGROW>
            end

        end

    elseif strcmpi(blockInfo.PaddingMethod,'Replicate')||(blockInfo.NumPixels>1&&(blockInfo.KernelTwo||blockInfo.KernelWidth<=4)&&strcmpi(blockInfo.PaddingMethod,'Symmetric'))

        if blockInfo.NumPixels==1
            padArray(1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(1)]);
            pirelab.getWireComp(horPadNet,dataVectorIn,padArray(1));
            for ii=1:1:blockInfo.KernelWidth+1
                padArray(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii)]);%#ok<AGROW>
                pirelab.getIntDelayEnabledComp(horPadNet,padArray(ii),padArray(ii+1),padShift,1);

            end

        else

            padDelayLine(1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(1)]);
            lowerPadMux=horPadNet.addSignal2('Type',dataVType,'Name','lowerPadMux');



            pirelab.getWireComp(horPadNet,dataVectorIn,padDelayLine(1));
            for ii=1:1:blockInfo.KernelWidth+1
                padDelayLine(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii)]);%#ok<AGROW>
                pirelab.getIntDelayEnabledComp(horPadNet,padDelayLine(ii),padDelayLine(ii+1),padShift,1);

            end

            pirelab.getSwitchComp(horPadNet,padDelayLine,lowerPadMux,horPadCount);

            columnType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,1]);

            lowerPadVec=horPadNet.addSignal2('Type',columnType,'Name',['LowerPadVec']);%#ok<NBRAK>
            upperPadVec=horPadNet.addSignal2('Type',columnType,'Name',['UpperPadVec']);%#ok<NBRAK>
            lowerPadMatrix=horPadNet.addSignal2('Type',dataVType,'Name','lowerPadMatrix');
            upperPadMatrix=horPadNet.addSignal2('Type',dataVType,'Name','upperPadMatrix');


            selIndicesLower={[1,3],double(1)};
            selIndicesUpper={[1,3],double(blockInfo.NumPixels)};

            pirelab.getSelectorComp(horPadNet,lowerPadMux,lowerPadVec,...
            'one-based',{'Select all','Index vector (dialog)'},selIndicesLower,{'1','1'}','2','Select',[5,4]);

            pirelab.getSelectorComp(horPadNet,lowerPadMux,upperPadVec,...
            'one-based',{'Select all','Index vector (dialog)'},selIndicesUpper,{'1','1'}','2','Select',[5,4]);

            for ii=1:1:blockInfo.NumPixels
                lowerPadArray(ii)=lowerPadVec;%#ok<AGROW>
                upperPadArray(ii)=upperPadVec;%#ok<AGROW>
            end


            pirelab.getConcatenateComp(horPadNet,lowerPadArray,lowerPadMatrix,'lowerPadMatrix','2');
            pirelab.getConcatenateComp(horPadNet,upperPadArray,upperPadMatrix,'upperPadMatrix','2');

            for ii=1:1:blockInfo.KernelWidth+1

                if ii<ceil(blockInfo.KernelWidth/2)
                    padArray(ii)=lowerPadMatrix;%#ok<AGROW>
                elseif ii==ceil(blockInfo.KernelWidth/2)
                    padArray(ii)=padDelayLine(ii);%#ok<AGROW>
                elseif ii>ceil(blockInfo.KernelWidth/2)
                    padArray(ii)=upperPadMatrix;%#ok<AGROW>
                end


            end


        end



    elseif strcmpi(blockInfo.PaddingMethod,'Symmetric')
        if blockInfo.NumPixels==1
            padArray(1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(1)]);
            pirelab.getUnitDelayEnabledComp(horPadNet,dataVectorIn,padArray(1),padShift);
            if mod(blockInfo.KernelWidth,2)==0
                for ii=1:1:blockInfo.KernelWidth+1
                    if ii<floor(blockInfo.KernelWidth/2)-1
                        padArray(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii)]);%#ok<AGROW>
                        pirelab.getIntDelayEnabledComp(horPadNet,padArray(ii),padArray(ii+1),padShift,2);
                    elseif ii<ceil(blockInfo.KernelWidth/2)+1
                        padArray(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii)]);%#ok<AGROW>
                        pirelab.getUnitDelayEnabledComp(horPadNet,padArray(ii),padArray(ii+1),padShift);
                    else
                        padArray(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii)]);%#ok<AGROW>
                        pirelab.getIntDelayEnabledComp(horPadNet,padArray(ii),padArray(ii+1),padShift,2);
                    end
                end
            else
                for ii=1:1:blockInfo.KernelWidth+1
                    if ii<floor(blockInfo.KernelWidth/2)
                        padArray(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii)]);%#ok<AGROW>
                        pirelab.getIntDelayEnabledComp(horPadNet,padArray(ii),padArray(ii+1),padShift,2);
                    elseif ii<ceil(blockInfo.KernelWidth/2)+1
                        padArray(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii)]);%#ok<AGROW>
                        pirelab.getUnitDelayEnabledComp(horPadNet,padArray(ii),padArray(ii+1),padShift);
                    else
                        padArray(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii)]);%#ok<AGROW>
                        pirelab.getIntDelayEnabledComp(horPadNet,padArray(ii),padArray(ii+1),padShift,2);
                    end
                end
            end
        else
            padDelayLine(1)=horPadNet.addSignal2('Type',dataVType,'Name',['PaddingRegister',num2str(1)]);
            lowerPadMux=horPadNet.addSignal2('Type',dataVType,'Name','lowerPadMux');


            pirelab.getWireComp(horPadNet,dataVectorIn,padDelayLine(1));
            for ii=1:1:blockInfo.KernelWidth+1
                padDelayLine(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['PaddingRegister',num2str(ii)]);%#ok<AGROW>
                pirelab.getIntDelayEnabledComp(horPadNet,padDelayLine(ii),padDelayLine(ii+1),padShift,1);

            end

            if mod(blockInfo.KernelWidth,2)==0&&blockInfo.BiasUp
                EvenBiasConstant=1;
            elseif mod(blockInfo.KernelWidth,2)==0&&~blockInfo.BiasUp
                EvenBiasConstant=1;
            else
                EvenBiasConstant=0;
            end

            paddingCycles=ceil((floor(blockInfo.KernelWidth/2))/blockInfo.NumPixels);

            lowerPaddingCycles=ceil((floor(blockInfo.KernelWidth/2)-EvenBiasConstant)/blockInfo.NumPixels);

            if paddingCycles==1
                lowerPaddingCycles=paddingCycles;
            end

            for ii=1:1:floor(blockInfo.KernelWidth/2)
                if ii<=paddingCycles
                    UpperPaddingLUT(ii)=floor(blockInfo.KernelWidth/2)+1+(2*(ii-1))-EvenBiasConstant;%#ok<AGROW>
                else
                    UpperPaddingLUT(ii)=floor(blockInfo.KernelWidth/2)+1-EvenBiasConstant;%#ok<AGROW>
                end
            end

            LowerPaddingLUT=ones(floor(blockInfo.KernelWidth/2)-1-EvenBiasConstant,1);

            for ii=1:1:floor(blockInfo.KernelWidth/2)-1-EvenBiasConstant
                if ii<=lowerPaddingCycles
                    LowerPaddingLUT(end-(ii-1))=floor(blockInfo.KernelWidth/2)-1-(2*(ii-1))-EvenBiasConstant;
                else
                    LowerPaddingLUT(end-(ii-1))=floor(blockInfo.KernelWidth/2)-1-EvenBiasConstant;
                end
            end


            twoPixelEdgeCase=double(blockInfo.NumPixels==2&&mod(floor((blockInfo.KernelWidth-1)/2),2)==1);

            padIndexes=[LowerPaddingLUT'+twoPixelEdgeCase,ceil(blockInfo.KernelWidth/2),UpperPaddingLUT+twoPixelEdgeCase];

            for ii=1:1:blockInfo.KernelWidth-1
                paddingValue(ii)=horPadNet.addSignal2('Type',dataVType,'Name',['paddingValue',num2str(ii)]);%#ok<AGROW>
                if ii<=floor(blockInfo.KernelWidth/2)-1-lowerPaddingCycles-EvenBiasConstant
                    pirelab.getConstComp(horPadNet,paddingValue(ii),0);
                else
                    pirelab.getWireComp(horPadNet,padDelayLine(padIndexes(ii)),paddingValue(ii));
                end
            end





            pirelab.getSwitchComp(horPadNet,paddingValue,lowerPadMux,horPadCount);

            columnType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,1]);

            lowerPadVec=horPadNet.addSignal2('Type',columnType,'Name',['LowerPadVec']);%#ok<NBRAK>
            upperPadVec=horPadNet.addSignal2('Type',columnType,'Name',['UpperPadVec']);%#ok<NBRAK,NASGU>
            lowerPadMatrix=horPadNet.addSignal2('Type',dataVType,'Name','lowerPadMatrix');
            lowerPadMatrixD=horPadNet.addSignal2('Type',dataVType,'Name','lowerPadMatrixD');
            upperPadMatrix=horPadNet.addSignal2('Type',dataVType,'Name','upperPadMatrix');%#ok<NASGU>





            for ii=1:1:blockInfo.NumPixels
                lowerPadVec(ii)=horPadNet.addSignal2('Type',columnType,'Name',['LowerPadVec',num2str(ii)]);

                pirelab.getSelectorComp(horPadNet,lowerPadMux,lowerPadVec(ii),...
                'one-based',{'Select all','Index vector (dialog)'},{[1,3],double(ii)},{'1','1'}','2','Select',[5,4]);



            end

            padIndex=1;
            for ii=blockInfo.NumPixels:-1:1
                lowerPadArray(padIndex)=lowerPadVec(ii);
                padIndex=padIndex+1;

            end


            pirelab.getConcatenateComp(horPadNet,lowerPadArray,lowerPadMatrix,'lowerPadMatrix','2');
            pirelab.getIntDelayEnabledComp(horPadNet,lowerPadMatrix,lowerPadMatrixD,padShift,1);


            for ii=1:1:blockInfo.KernelWidth+1
                if ii<ceil(blockInfo.KernelWidth/2)
                    if blockInfo.KernelWidth==5&&ii==1||(EvenBiasConstant==1&&ii==1)
                        constZero=horPadNet.addSignal2('Type',dataVType,'Name','lowerPadMatrixD');
                        pirelab.getConstComp(horPadNet,constZero,0);
                        padArray(ii)=constZero;%#ok<AGROW>
                    else
                        padArray(ii)=lowerPadMatrixD;%#ok<AGROW>
                    end
                elseif ii==ceil(blockInfo.KernelWidth/2)
                    padArray(ii)=padDelayLine(ii+twoPixelEdgeCase);%#ok<AGROW>
                elseif ii>ceil(blockInfo.KernelWidth/2)
                    padArray(ii)=lowerPadMatrixD;%#ok<AGROW>
                end
            end
        end

    elseif strcmpi(blockInfo.PaddingMethod,'Reflection')
        if blockInfo.NumPixels==1
            padArray(1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(1)]);
            pirelab.getUnitDelayEnabledComp(horPadNet,dataVectorIn,padArray(1),padShift);
            for ii=1:1:blockInfo.KernelWidth+1
                padArray(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['DataMuxIn',num2str(ii+1)]);%#ok<AGROW>
                pirelab.getIntDelayEnabledComp(horPadNet,padArray(ii),padArray(ii+1),padShift,2);
            end
        else
            padDelayLine(1)=horPadNet.addSignal2('Type',dataVType,'Name',['PaddingRegister',num2str(1)]);

            pirelab.getWireComp(horPadNet,dataVectorIn,padDelayLine(1));
            for ii=1:1:blockInfo.KernelWidth+1
                padDelayLine(ii+1)=horPadNet.addSignal2('Type',dataVType,'Name',['PaddingRegister',num2str(ii+1)]);%#ok<AGROW>
                pirelab.getIntDelayEnabledComp(horPadNet,padDelayLine(ii),padDelayLine(ii+1),padShift,1);
            end

            if mod(blockInfo.KernelWidth,2)==0&&blockInfo.BiasUp
                EvenBiasConstant=1;
            elseif mod(blockInfo.KernelWidth,2)==0&&~blockInfo.BiasUp
                EvenBiasConstant=1;
            else
                EvenBiasConstant=0;
            end


            twoPixelEdgeCase=double(blockInfo.NumPixels==2&&mod(floor((blockInfo.KernelWidth-1)/2),2)==1);

            paddingCycles=ceil((floor(blockInfo.KernelWidth/2))/blockInfo.NumPixels);%#ok<NASGU>
            lowerPaddingCycles=ceil((floor(blockInfo.KernelWidth/2)-EvenBiasConstant)/blockInfo.NumPixels);

            padMuxA=horPadNet.addSignal2('Type',dataVType,'Name','padMuxA');
            padMuxB=horPadNet.addSignal2('Type',dataVType,'Name','padMuxB');
            constZero=horPadNet.addSignal2('Type',dataVType,'Name','constZero');
            pirelab.getConstComp(horPadNet,constZero,0);

            if blockInfo.KernelWidth==3&&blockInfo.KernelWidthTwo
                for ii=1:1:3
                    UpperPaddingLUT(ii)=1+ii;%#ok<AGROW>
                end
                padIndexes=[1,UpperPaddingLUT];
                for ii=1:1:blockInfo.KernelWidth
                    paddingValue(ii)=horPadNet.addSignal2('Type',dataVType,'Name',['paddingValue',num2str(ii)]);%#ok<AGROW>
                    if ii<=floor(blockInfo.KernelWidth/2)-1-lowerPaddingCycles-EvenBiasConstant
                        pirelab.getConstComp(horPadNet,paddingValue(ii),0);
                    else
                        pirelab.getWireComp(horPadNet,padDelayLine(padIndexes(ii+1)),paddingValue(ii));
                    end
                end
                pirelab.getSwitchComp(horPadNet,paddingValue(1:end-1),padMuxA,horPadCount);
                pirelab.getSwitchComp(horPadNet,paddingValue(2:end),padMuxB,horPadCount);
            else
                if blockInfo.KernelWidth<=4
                    paddingLUTA=ones(1,ceil(blockInfo.KernelWidth/2)+2);
                    paddingLUTB=ones(1,ceil(blockInfo.KernelWidth/2)+2);
                else
                    paddingLUTA=(ceil(blockInfo.KernelWidth/2)-(2*lowerPaddingCycles))*ones(1,ceil(blockInfo.KernelWidth/2)+2+twoPixelEdgeCase);
                    paddingLUTB=(ceil(blockInfo.KernelWidth/2)-(2*lowerPaddingCycles)+1)*ones(1,ceil(blockInfo.KernelWidth/2)+2+twoPixelEdgeCase);
                end

                if lowerPaddingCycles>1
                    for ii=(ceil(blockInfo.KernelWidth/2)-lowerPaddingCycles):1:(ceil(blockInfo.KernelWidth/2)-1)
                        paddingLUTA(ii)=paddingLUTA(ii-1)+2;
                        paddingLUTB(ii)=paddingLUTB(ii-1)+2;
                    end
                end

                for ii=ceil(blockInfo.KernelWidth/2):1:length(paddingLUTA)
                    if ii==ceil(blockInfo.KernelWidth/2)
                        paddingLUTA(ii)=ceil(blockInfo.KernelWidth/2)+1;
                        paddingLUTB(ii)=ceil(blockInfo.KernelWidth/2)+2;
                    else
                        paddingLUTA(ii)=paddingLUTA(ii-1)+2;
                        paddingLUTB(ii)=paddingLUTB(ii-1)+2;
                    end
                end

                paddingLUTA(paddingLUTA>(blockInfo.KernelWidth+2))=blockInfo.KernelWidth+2;
                paddingLUTB(paddingLUTB>(blockInfo.KernelWidth+2))=blockInfo.KernelWidth+2;

                if blockInfo.KernelWidth<=4
                    pirelab.getSwitchComp(horPadNet,[constZero,padDelayLine(paddingLUTA(2:end))],padMuxA,horPadCount);
                    pirelab.getSwitchComp(horPadNet,padDelayLine(paddingLUTB),padMuxB,horPadCount);
                elseif twoPixelEdgeCase
                    idx=find(paddingLUTA==0,1,'last');
                    for ii=1:1:idx
                        constZeroLine(ii)=horPadNet.addSignal2('Type',dataVType,'Name',['constZero',num2str(ii)]);%#ok<AGROW> 
                        pirelab.getWireComp(horPadNet,constZero,constZeroLine(ii));
                    end
                    pirelab.getSwitchComp(horPadNet,[constZeroLine(:)',padDelayLine(paddingLUTA((idx+1):end))],padMuxA,horPadCount);
                    pirelab.getSwitchComp(horPadNet,padDelayLine(paddingLUTB),padMuxB,horPadCount);
                else
                    pirelab.getSwitchComp(horPadNet,padDelayLine(paddingLUTA),padMuxA,horPadCount);
                    pirelab.getSwitchComp(horPadNet,padDelayLine(paddingLUTB),padMuxB,horPadCount);
                end
            end

            columnType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,1]);


            for ii=1:1:blockInfo.NumPixels

                padVecA(ii)=horPadNet.addSignal2('Type',columnType,'Name',['padVecA',num2str(ii)]);%#ok<AGROW>
                pirelab.getSelectorComp(horPadNet,padMuxA,padVecA(ii),...
                'one-based',{'Select all','Index vector (dialog)'},{[1,3],double(ii)},{'1','1'}','2','Select',[5,4]);

                padVecB(ii)=horPadNet.addSignal2('Type',columnType,'Name',['padVecB',num2str(ii)]);%#ok<AGROW>
                pirelab.getSelectorComp(horPadNet,padMuxB,padVecB(ii),...
                'one-based',{'Select all','Index vector (dialog)'},{[1,3],double(ii)},{'1','1'}','2','Select',[5,4]);
            end


            for ii=1:1:blockInfo.NumPixels
                if ii<blockInfo.NumPixels
                    upperPadArray(ii)=padVecA(blockInfo.NumPixels-ii);%#ok<AGROW>
                else
                    upperPadArray(ii)=padVecB(blockInfo.NumPixels);%#ok<AGROW>
                end

                if ii==1
                    lowerPadArray(ii)=padVecA(1);%#ok<AGROW>
                else
                    lowerPadArray(ii)=padVecB(blockInfo.NumPixels+2-ii);%#ok<AGROW>
                end
            end

            lowerPadMatrix=horPadNet.addSignal2('Type',dataVType,'Name','lowerPadMatrix');
            upperPadMatrix=horPadNet.addSignal2('Type',dataVType,'Name','upperPadMatrix');
            padMatrix=horPadNet.addSignal2('Type',dataVType,'Name','padMatrix');
            padMatrixD=horPadNet.addSignal2('Type',dataVType,'Name','padMatrixD');

            pirelab.getConcatenateComp(horPadNet,lowerPadArray,lowerPadMatrix,'lowerPadMatrix','2');
            pirelab.getConcatenateComp(horPadNet,upperPadArray,upperPadMatrix,'upperPadMatrix','2');

            if blockInfo.KernelWidth==3&&blockInfo.KernelWidthTwo
                pirelab.getSwitchComp(horPadNet,[upperPadMatrix,lowerPadMatrix],padMatrix,horPadCount,'mux','>',0);
            else
                pirelab.getSwitchComp(horPadNet,[upperPadMatrix,lowerPadMatrix],padMatrix,horPadCount,'mux','>',floor(blockInfo.KernelWidth/2)-1-EvenBiasConstant);
            end

            pirelab.getIntDelayEnabledComp(horPadNet,padMatrix,padMatrixD,padShift,1);

            for ii=1:1:blockInfo.KernelWidth+1
                if ii<ceil(blockInfo.KernelWidth/2)
                    if blockInfo.KernelWidth==5&&ii==1||(EvenBiasConstant==1&&blockInfo.KernelWidth>4&&ii==1)
                        constZero=horPadNet.addSignal2('Type',dataVType,'Name','lowerPadMatrixD');
                        pirelab.getConstComp(horPadNet,constZero,0);
                        padArray(ii)=constZero;%#ok<AGROW>
                    else
                        padArray(ii)=padMatrixD;%#ok<AGROW>
                    end
                elseif ii==ceil(blockInfo.KernelWidth/2)
                    padArray(ii)=padDelayLine(ii+1);%#ok<AGROW>
                elseif ii>ceil(blockInfo.KernelWidth/2)
                    padArray(ii)=padMatrixD;%#ok<AGROW>
                end
            end
        end
    end

    pirelab.getSwitchComp(horPadNet,padArray,dataVectorOut,horPadCount);


    function[tabledata,tableidx,bpType,oType,fType]=ComputeLUT(LUT,Wl,Fl,Si,Addr_Wl)%#ok<DEFNU>

        oType=fi(0,Si,Wl,Fl);
        fType=fi(0,0,32,31);


        bpType=fi(0,0,Addr_Wl,0);
        tableidx={fi((0:2^Addr_Wl-1),bpType.numerictype)};

        Fsat=fimath('RoundMode','Nearest',...
        'OverflowMode','Saturate',...
        'SumMode','KeepLSB',...
        'SumWordLength',Wl,...
        'SumFractionLength',Fl,...
        'CastBeforeSum',true);

        tabledata=fi(LUT,oType.numerictype,Fsat);

