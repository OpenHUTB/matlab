function blockInfo=getBlockInfo(this,hC)




    bfp=hC.SimulinkHandle;

    blockInfo.ModulationSource=get_param(bfp,'ModulationSource');
    blockInfo.NoiseVariance=strcmp(get_param(bfp,'NoiseVariance'),'on');
    blockInfo.NormMethod=get_param(bfp,'NormMethod');
    if strcmp(blockInfo.ModulationSource,'Property')
        blockInfo.ModulationScheme=get_param(bfp,'ModulationScheme');
        if(strcmp(blockInfo.ModulationScheme,'16-QAM')||strcmp(blockInfo.ModulationScheme,'64-QAM')||strcmp(blockInfo.ModulationScheme,'256-QAM'))
            blockInfo.ConstOrder=get_param(bfp,'ConstOrder');
            blockInfo.NormMethod=get_param(bfp,'NormMethod');
            if(strcmp(blockInfo.ConstOrder,'User-defined'))
                blockInfo.ConstMap=get_param(bfp,'ConstMap');
                if strcmp(blockInfo.ModulationScheme,'256-QAM')
                    defConstOrder=1:8;
                    mappedBits=str2num(blockInfo.ConstMap);
                    binaryMapped=de2bi(mappedBits(1:16),8,'left-msb');
                    sumColumns=sum(binaryMapped);
                    [~,indMax]=find(sumColumns==16);
                    [~,indMin]=find(sumColumns==0);
                    indFinal=union(indMin,indMax);
                    indOthers=~ismember(defConstOrder,indFinal);
                    inpBitOrder=[indFinal,defConstOrder(indOthers)];
                    for ind=1:8
                        blockInfo.shuffleOrder(ind)=uint8(defConstOrder(inpBitOrder==ind));
                    end
                    signCalcBits=~de2bi(mappedBits(136),8,'left-msb');
                    blockInfo.coeffSign=fi((1-2*signCalcBits),1,3,0,hdlfimath);
                elseif strcmp(blockInfo.ModulationScheme,'64-QAM')
                    defConstOrder=1:6;
                    mappedBits=str2num(blockInfo.ConstMap);
                    binaryMapped=de2bi(mappedBits(1:8),6,'left-msb');
                    sumColumns=sum(binaryMapped);
                    [~,indMax]=find(sumColumns==8);
                    [~,indMin]=find(sumColumns==0);
                    indFinal=union(indMin,indMax);
                    indOthers=~ismember(defConstOrder,indFinal);
                    inpBitOrder=[indFinal,defConstOrder(indOthers)];

                    for ind=1:8
                        if ind<7
                            blockInfo.shuffleOrder(ind)=uint8(defConstOrder(inpBitOrder==ind));
                        else
                            blockInfo.shuffleOrder(ind)=uint8(1);
                        end
                    end
                    signCalcBits=~de2bi(mappedBits(36),6,'left-msb');
                    blockInfo.coeffSign=fi([1-2*signCalcBits],1,3,0,hdlfimath);
                else
                    defConstOrder=1:4;
                    mappedBits=str2num(blockInfo.ConstMap);
                    binaryMapped=de2bi(mappedBits(1:4),4,'left-msb');
                    sumColumns=sum(binaryMapped);
                    [~,indMax]=find(sumColumns==4);
                    [~,indMin]=find(sumColumns==0);
                    indFinal=union(indMin,indMax);
                    indOthers=~ismember(defConstOrder,indFinal);
                    inpBitOrder=[indFinal,defConstOrder(indOthers)];

                    for ind=1:8
                        if ind<5
                            blockInfo.shuffleOrder(ind)=uint8(defConstOrder(inpBitOrder==ind));
                        else
                            blockInfo.shuffleOrder(ind)=uint8(1);
                        end
                    end
                    signCalcBits=~de2bi(mappedBits(10),4,'left-msb');
                    blockInfo.coeffSign=fi([1-2*signCalcBits],1,3,0,hdlfimath);
                end
            else
                blockInfo.shuffleOrder=uint8(1:8);
                if strcmp(blockInfo.ModulationScheme,'256-QAM')
                    signCalcBits=[0,0,1,1,0,0,1,1];
                elseif strcmp(blockInfo.ModulationScheme,'64-QAM')
                    signCalcBits=[0,0,1,0,0,1];
                else
                    signCalcBits=[0,0,0,0];
                end
                blockInfo.coeffSign=fi([1-2*signCalcBits],1,3,0,hdlfimath);
            end


            if(strcmp(blockInfo.NormMethod,'Custom'))
                blockInfo.MinSymDistance=get_param(bfp,'MinSymDistance');
            else
                if(strcmp(blockInfo.ModulationScheme,'16-QAM'))
                    blockInfo.MinSymDistance='2/sqrt(10)';
                elseif(strcmp(blockInfo.ModulationScheme,'64-QAM'))
                    blockInfo.MinSymDistance='2/sqrt(42)';
                else
                    blockInfo.MinSymDistance='2/sqrt(170)';
                end
            end
            blockInfo.MinSymDistanceBy2=fi(str2num(blockInfo.MinSymDistance)/2,1,16,11,hdlfimath);


        end
    else
        blockInfo.MaxModulation=get_param(bfp,'MaxModulation');
        if(strcmp(blockInfo.MaxModulation,'16-QAM')||strcmp(blockInfo.MaxModulation,'64-QAM')||strcmp(blockInfo.MaxModulation,'256-QAM'))||strcmp(blockInfo.MaxModulation,'32-PSK')
            blockInfo.ConstOrder=get_param(bfp,'ConstOrder');
            blockInfo.NormMethod=get_param(bfp,'NormMethod');

            if(strcmpi(blockInfo.ConstOrder,'User-defined'))
                blockInfo.ConstMap=get_param(bfp,'ConstMap');
                if(strcmpi(blockInfo.MaxModulation,'16-QAM'))||strcmp(blockInfo.MaxModulation,'32-PSK')
                    defConstOrder=1:4;
                    mappedBits=str2num(blockInfo.ConstMap);
                    binaryMapped=de2bi(mappedBits(1:4),4,'left-msb');
                    sumColumns=sum(binaryMapped);
                    [~,indMax]=find(sumColumns==4);
                    [~,indMin]=find(sumColumns==0);
                    indFinal=union(indMin,indMax);
                    indOthers=~ismember(defConstOrder,indFinal);
                    inpBitOrder=[indFinal,defConstOrder(indOthers)];
                    for ind=1:8
                        if ind<5
                            blockInfo.shuffleOrder(ind)=uint8(defConstOrder(inpBitOrder==ind));
                        else
                            blockInfo.shuffleOrder(ind)=uint8(1);
                        end
                    end
                    blockInfo.shuffleOrder16=blockInfo.shuffleOrder;
                    signCalcBits16=~de2bi(mappedBits(10),4,'left-msb');
                    blockInfo.coeffSign16=fi([1-2*signCalcBits16],1,3,0,hdlfimath);
                elseif(strcmpi(blockInfo.MaxModulation,'64-QAM'))
                    defConstOrder=1:6;
                    mappedBits=str2num(blockInfo.ConstMap);
                    binaryMapped=de2bi(mappedBits(1:8),6,'left-msb');
                    sumColumns=sum(binaryMapped);
                    [~,indMax]=find(sumColumns==8);
                    [~,indMin]=find(sumColumns==0);
                    indFinal=union(indMin,indMax);
                    indOthers=~ismember(defConstOrder,indFinal);
                    indFinalLast=defConstOrder(indOthers);
                    inpBitOrder=[indFinal,indFinalLast];
                    for ind=1:8
                        if ind<7
                            blockInfo.shuffleOrder(ind)=uint8(defConstOrder(inpBitOrder==ind));
                        else
                            blockInfo.shuffleOrder(ind)=uint8(1);
                        end
                    end

                    inpBitOrder16=inpBitOrder(inpBitOrder<=4);
                    blockInfo.shuffleOrder16=uint8([defConstOrder(inpBitOrder16==1),defConstOrder(inpBitOrder16==2),defConstOrder(inpBitOrder16==3),defConstOrder(inpBitOrder16==4),1,1,1,1]);
                    blockInfo.shuffleOrder64=blockInfo.shuffleOrder;
                    signCalcBits=~de2bi(mappedBits(36),6,'left-msb');
                    blockInfo.coeffSign64=fi([1-2*signCalcBits],1,3,0,hdlfimath);
                    signCalcBits16=[signCalcBits(indFinal(1:2)),signCalcBits(indFinalLast(1:2))];
                    blockInfo.coeffSign16=fi([1-2*signCalcBits16],1,3,0,hdlfimath);
                else
                    defConstOrder=1:8;
                    mappedBits=str2num(blockInfo.ConstMap);
                    binaryMapped=de2bi(mappedBits(1:16),8,'left-msb');
                    sumColumns=sum(binaryMapped);
                    [~,indMax]=find(sumColumns==16);
                    [~,indMin]=find(sumColumns==0);
                    indFinal=union(indMin,indMax);
                    indOthers=~ismember(defConstOrder,indFinal);
                    indFinalLast=defConstOrder(indOthers);
                    inpBitOrder=[indFinal,indFinalLast];
                    for ind=1:8
                        blockInfo.shuffleOrder(ind)=uint8(defConstOrder(inpBitOrder==ind));
                    end

                    inpBitOrder64=inpBitOrder(inpBitOrder<=6);
                    blockInfo.shuffleOrder64=uint8([defConstOrder(inpBitOrder64==1),defConstOrder(inpBitOrder64==2),defConstOrder(inpBitOrder64==3),defConstOrder(inpBitOrder64==4),...
                    defConstOrder(inpBitOrder64==5),defConstOrder(inpBitOrder64==6),1,1]);

                    inpBitOrder16=inpBitOrder(inpBitOrder<=4);
                    blockInfo.shuffleOrder16=uint8([defConstOrder(inpBitOrder16==1),defConstOrder(inpBitOrder16==2),defConstOrder(inpBitOrder16==3),defConstOrder(inpBitOrder16==4),1,1,1,1]);
                    blockInfo.shuffleOrder256=uint8(blockInfo.shuffleOrder);
                    signCalcBits=~de2bi(mappedBits(136),8,'left-msb');
                    blockInfo.coeffSign256=fi([1-2*signCalcBits],1,3,0,hdlfimath);

                    signCalcBits64=[signCalcBits(indFinal(1:3)),signCalcBits(indFinalLast(1:3))];
                    blockInfo.coeffSign64=fi([1-2*signCalcBits64],1,3,0,hdlfimath);

                    signCalcBits16=[signCalcBits(indFinal(1:2)),signCalcBits(indFinalLast(1:2))];
                    blockInfo.coeffSign16=fi([1-2*signCalcBits16],1,3,0,hdlfimath);
                end
            else
                blockInfo.shuffleOrder=uint8(1:8);
                blockInfo.shuffleOrder16=uint8(1:8);
                blockInfo.shuffleOrder64=uint8(1:8);
                blockInfo.shuffleOrder256=uint8(1:8);

                blockInfo.coeffSign16=fi([1,1,1,1],1,3,0,hdlfimath);
                blockInfo.coeffSign64=fi([1,1,-1,1,1,-1],1,3,0,hdlfimath);
                blockInfo.coeffSign256=fi([1,1,-1,-1,1,1,-1,-1],1,3,0,hdlfimath);
            end

            if(strcmp(blockInfo.ConstOrder,'User-defined'))
                blockInfo.ConstMap=get_param(bfp,'ConstMap');
            end
            if(strcmp(blockInfo.NormMethod,'Custom'))
                blockInfo.MinSymDistance=get_param(bfp,'MinSymDistance');
            else
                if(strcmp(blockInfo.MaxModulation,'16-QAM'))
                    blockInfo.MinSymDistance='2/sqrt(10)';
                elseif(strcmp(blockInfo.MaxModulation,'64-QAM'))
                    blockInfo.MinSymDistance='2/sqrt(42)';
                else
                    blockInfo.MinSymDistance='2/sqrt(170)';
                end
            end
            blockInfo.MinSymDistanceBy2=fi(str2num(blockInfo.MinSymDistance)/2,1,16,11,hdlfimath);
        end
    end

    blockInfo.PhaseOffset=get_param(bfp,'PhaseOffset');
    if(strcmp(blockInfo.NormMethod,'Custom'))
        if strcmp(blockInfo.ModulationSource,'Property')
            if(strcmp(blockInfo.ModulationScheme,'16-QAM')||strcmp(blockInfo.ModulationScheme,'64-QAM')||strcmp(blockInfo.ModulationScheme,'256-QAM'))
                blockInfo.MinSymDistance16QAM=blockInfo.MinSymDistanceBy2;
                blockInfo.MinSymDistance64QAM=blockInfo.MinSymDistanceBy2;
                blockInfo.MinSymDistance256QAM=blockInfo.MinSymDistanceBy2;
            else
                blockInfo.MinSymDistance16QAM=fi(1/sqrt(10),1,16,11,hdlfimath);
                blockInfo.MinSymDistance64QAM=fi(1/sqrt(42),1,16,11,hdlfimath);
                blockInfo.MinSymDistance256QAM=fi(1/sqrt(170),1,16,11,hdlfimath);
            end
        else
            if(strcmp(blockInfo.MaxModulation,'16-QAM')||strcmp(blockInfo.MaxModulation,'64-QAM')||strcmp(blockInfo.MaxModulation,'256-QAM'))||strcmp(blockInfo.MaxModulation,'32-PSK')
                blockInfo.MinSymDistance16QAM=blockInfo.MinSymDistanceBy2;
                blockInfo.MinSymDistance64QAM=blockInfo.MinSymDistanceBy2;
                blockInfo.MinSymDistance256QAM=blockInfo.MinSymDistanceBy2;
            else
                blockInfo.MinSymDistance16QAM=fi(1/sqrt(10),1,16,11,hdlfimath);
                blockInfo.MinSymDistance64QAM=fi(1/sqrt(42),1,16,11,hdlfimath);
                blockInfo.MinSymDistance256QAM=fi(1/sqrt(170),1,16,11,hdlfimath);
            end
        end
    else
        blockInfo.MinSymDistance16QAM=fi(1/sqrt(10),1,16,11,hdlfimath);
        blockInfo.MinSymDistance64QAM=fi(1/sqrt(42),1,16,11,hdlfimath);
        blockInfo.MinSymDistance256QAM=fi(1/sqrt(170),1,16,11,hdlfimath);
    end


    blockInfo.DecisionType=get_param(bfp,'DecisionType');
    blockInfo.OutputType=get_param(bfp,'OutputType');


    blockInfo.LValues08=fi(8./(2.^[0,1,2,3,4,5]),1,16,11,hdlfimath);
    blockInfo.LValues04=fi(4./(2.^[0,1,2,3]),1,16,11,hdlfimath);
    blockInfo.LUT=fi([8,4,2],1,16,11,hdlfimath);



    phaseOffsetValues={'pi/2','pi/4','pi/8','pi/16','pi/32','0','-pi/32','-pi/16','-pi/8','-pi/4','-pi/2'};
    if strcmp(blockInfo.ModulationSource,'Property')
        if(strcmp(blockInfo.ModulationScheme,'16-QAM')||strcmp(blockInfo.ModulationScheme,'64-QAM')||strcmp(blockInfo.ModulationScheme,'256-QAM'))
            LUTindex=1;
        else
            LUTindex=find(strcmp(phaseOffsetValues,blockInfo.PhaseOffset));
        end
    else
        LUTindex=find(strcmp(phaseOffsetValues,blockInfo.PhaseOffset));
    end

    lookUpCos02=fi(cos([0,pi/4,(3*pi)/8,(7*pi)/16,(15*pi)/32,pi/2,(17*pi)/32,(9*pi)/16,(5*pi)/8,(3*pi)/4,pi]),1,16,14,hdlfimath);
    lookUpSine02=fi(sin([0,pi/4,(3*pi)/8,(7*pi)/16,(15*pi)/32,pi/2,(17*pi)/32,(9*pi)/16,(5*pi)/8,(3*pi)/4,pi]),1,16,14,hdlfimath);
    lookUpSine04=fi(sin([-pi/4,0,pi/8,(3*pi)/16,(7*pi)/32,pi/4,(9*pi)/32,(5*pi)/16,(3*pi)/8,pi/2,(3*pi)/4]),1,16,14,hdlfimath);
    lookUpCos04=fi(cos([-pi/4,0,pi/8,(3*pi)/16,(7*pi)/32,pi/4,(9*pi)/32,(5*pi)/16,(3*pi)/8,pi/2,(3*pi)/4]),1,16,14,hdlfimath);
    lookUpSine08=fi(sin([-(3*pi)/8,-pi/8,0,pi/16,(3*pi)/32,pi/8,(5*pi)/32,(3*pi)/16,pi/4,(3*pi)/8,(5*pi)/8]),1,16,14,hdlfimath);
    lookUpCos08=fi(cos([-(3*pi)/8,-pi/8,0,pi/16,(3*pi)/32,pi/8,(5*pi)/32,(3*pi)/16,pi/4,(3*pi)/8,(5*pi)/8]),1,16,14,hdlfimath);
    lookUpSine16=fi(sin([-(7*pi)/16,-(3*pi)/16,-pi/16,0,pi/32,pi/16,(3*pi)/32,pi/8,(3*pi)/16,(5*pi)/16,(9*pi)/16]),1,16,14,hdlfimath);
    lookUpCos16=fi(cos([-(7*pi)/16,-(3*pi)/16,-pi/16,0,pi/32,pi/16,(3*pi)/32,pi/8,(3*pi)/16,(5*pi)/16,(9*pi)/16]),1,16,14,hdlfimath);
    lookUpSine32=fi(sin([-(15*pi)/32,-(7*pi)/32,-(3*pi)/32,-pi/32,0,pi/32,pi/16,(3*pi)/32,(5*pi)/32,(9*pi)/32,(17*pi)/32]),1,16,14,hdlfimath);
    lookUpCos32=fi(cos([-(15*pi)/32,-(7*pi)/32,-(3*pi)/32,-pi/32,0,pi/32,pi/16,(3*pi)/32,(5*pi)/32,(9*pi)/32,(17*pi)/32]),1,16,14,hdlfimath);

    if(strcmp(blockInfo.ModulationSource,'Property'))
        if(strcmp(blockInfo.ModulationScheme,'BPSK'))
            LUTvalueReal=lookUpCos02(LUTindex);
            LUTvalueImag=lookUpSine02(LUTindex);
        elseif(strcmp(blockInfo.ModulationScheme,'QPSK'))
            LUTvalueReal=lookUpCos04(LUTindex);
            LUTvalueImag=lookUpSine04(LUTindex);
        elseif(strcmp(blockInfo.ModulationScheme,'8-PSK'))
            LUTvalueReal=lookUpCos08(LUTindex);
            LUTvalueImag=lookUpSine08(LUTindex);
        elseif(strcmp(blockInfo.ModulationScheme,'16-PSK'))
            LUTvalueReal=lookUpCos16(LUTindex);
            LUTvalueImag=lookUpSine16(LUTindex);
        elseif(strcmp(blockInfo.ModulationScheme,'32-PSK'))
            LUTvalueReal=lookUpCos32(LUTindex);
            LUTvalueImag=lookUpSine32(LUTindex);
        else
            LUTvalueReal=lookUpCos02(LUTindex);
            LUTvalueImag=lookUpSine02(LUTindex);
        end
    else
        LUTvalueReal=lookUpCos02(LUTindex);
        LUTvalueImag=lookUpSine02(LUTindex);
    end

    blockInfo.LUTvalueReal=LUTvalueReal;
    blockInfo.LUTvalueImag=LUTvalueImag;

    blockInfo.LUTvalueReal2=lookUpCos02(LUTindex);
    blockInfo.LUTvalueImag2=lookUpSine02(LUTindex);
    blockInfo.LUTvalueReal4=lookUpCos04(LUTindex);
    blockInfo.LUTvalueImag4=lookUpSine04(LUTindex);
    blockInfo.LUTvalueReal8=lookUpCos08(LUTindex);
    blockInfo.LUTvalueImag8=lookUpSine08(LUTindex);
    blockInfo.LUTvalueReal16=lookUpCos16(LUTindex);
    blockInfo.LUTvalueImag16=lookUpSine16(LUTindex);
    blockInfo.LUTvalueReal32=lookUpCos32(LUTindex);
    blockInfo.LUTvalueImag32=lookUpSine32(LUTindex);

    blockInfo.LUTAdd02=fi([exp(1i*(pi/2)),exp(1i*((3*pi)/2))],1,16,14,hdlfimath);
    blockInfo.LUTAdd04=fi([exp(1i*(pi/4)),exp(1i*((3*pi)/4)),exp(1i*((7*pi)/4))],1,16,14,hdlfimath);
    blockInfo.LUTAdd08=fi([exp(1i*(pi/8)),exp(1i*((5*pi)/8)),exp(1i*((15*pi)/8)),exp(1i*((3*pi)/8))],1,16,14,hdlfimath);
    blockInfo.LUTAdd16=fi([exp(1i*(pi/16)),exp(1i*((9*pi)/16)),exp(1i*((31*pi)/16)),exp(1i*((5*pi)/16)),exp(1i*((3*pi)/16))],1,16,14,hdlfimath);
    blockInfo.LUTAdd32=fi([exp(1i*(pi/32)),exp(1i*((17*pi)/32)),exp(1i*((63*pi)/32)),exp(1i*((9*pi)/32)),exp(1i*((5*pi)/32)),exp(1i*((3*pi)/32))],1,16,14,hdlfimath);

end
