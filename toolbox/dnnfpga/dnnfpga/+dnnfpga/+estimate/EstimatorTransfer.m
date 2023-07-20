classdef EstimatorTransfer<dnnfpga.estimate.EstimatorTimeBase








    properties

        IPBursttoBurstDelay=15


        IPAXIMasterIO=7
        IPAddressComp=4
        IPExtraDelay=15

IPOffset


        OPBursttoBurstDelay=15


        OPAXIMasterIO=0
        OPAddressComp=0
        OPExtraDelay=0

OPOffset


AXIMasterWriteOverhead
    end

    methods(Abstract)
        LayerTime=GetLayerTime(this)
    end

    methods
        function TileInBurst=getTileInBurst(this,TileInfo,HWparams,InternalArchParam,varargin)
            if~isempty(varargin)
                calData=varargin{1};
            end



            InLongBurstNum=TileInfo.IndeltaX*floor(TileInfo.inputN/HWparams.ConvThreadNumber);
            if(mod(TileInfo.inputN,HWparams.ConvThreadNumber)==0)
                InShortBurstNum=0;
            else
                InShortBurstNum=TileInfo.IndeltaX;
            end

            BurstInternalDelay=this.IPAXIMasterIO+this.IPAddressComp+this.IPExtraDelay;


            burstLengthLong=ceil(TileInfo.IndeltaY*HWparams.ConvThreadNumber/InternalArchParam.Speedup);

            this.getProcessorIPOverhead(HWparams.TargetPlatform,HWparams.TargetFrequency,burstLengthLong);

            InLongBurstCycle=burstLengthLong+BurstInternalDelay+this.IPOffset;



            burstLengthShort=ceil(TileInfo.IndeltaY*(mod(TileInfo.inputN,HWparams.ConvThreadNumber))/InternalArchParam.Speedup);

            this.getProcessorIPOverhead(HWparams.TargetPlatform,HWparams.TargetFrequency,burstLengthShort);
            InShortBurstCycle=burstLengthShort+BurstInternalDelay+this.IPOffset;

            InterBurstDelay=this.IPBursttoBurstDelay;
            TileInBurst=InLongBurstNum*InLongBurstCycle+InShortBurstNum*InShortBurstCycle+InterBurstDelay;
        end

        function TileOutBurst=getTileOutBurst(this,TileInfo,HWparams,InternalArchParam,varargin)
            if~isempty(varargin)
                calData=varargin{1};
            end



            OutLongBurstNum=TileInfo.OutdeltaX*floor(TileInfo.outputM/HWparams.ConvThreadNumber);
            if(mod(TileInfo.outputM,HWparams.ConvThreadNumber)==0)
                OutShortBurstNum=0;
            else
                OutShortBurstNum=TileInfo.OutdeltaX;
            end

            BurstInternalDelay=this.OPAXIMasterIO+this.OPAddressComp+this.OPExtraDelay;


            burstLengthLong=ceil(TileInfo.OutdeltaY*HWparams.ConvThreadNumber/InternalArchParam.Speedup);

            this.getProcessorOPOverhead(HWparams.TargetPlatform,HWparams.TargetFrequency,burstLengthLong);
            OutLongBurstCycle=burstLengthLong+BurstInternalDelay+this.AXIMasterWriteOverhead+this.OPOffset;


            burstLengthShort=ceil(TileInfo.OutdeltaY*(mod(TileInfo.outputM,HWparams.ConvThreadNumber))/InternalArchParam.Speedup);

            this.getProcessorOPOverhead(HWparams.TargetPlatform,HWparams.TargetFrequency,burstLengthShort);
            OutShortBurstCycle=burstLengthShort+BurstInternalDelay+this.AXIMasterWriteOverhead+this.OPOffset;

            InterBurstDelay=this.OPBursttoBurstDelay;
            TileOutBurst=OutLongBurstNum*OutLongBurstCycle+OutShortBurstNum*OutShortBurstCycle+InterBurstDelay;
        end
    end


    methods
        function LayerInBurst=getLayerInBurst(this,LayerInfo)
            LayerInBurst=LayerInfo.input/4;
        end

        function LayerOutBurst=getLayerOutBurst(this,LayerInfo)
            LayerOutBurst=LayerInfo.output/4;
        end
    end


    methods
        function getProcessorIPOverhead(this,boardName,frequency,burst)

            if burst~=0

                if contains(boardName,'Zynq')
                    zcu102ioMacropath=fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+estimate','zcu102IOoffset.mat');
                    zcu102ioMacro=load(zcu102ioMacropath);

                    zcu102ipMacro=zcu102ioMacro.IO.IP;
                    if isKey(zcu102ipMacro,num2str(burst))
                        this.IPOffset=zcu102ipMacro(num2str(burst));
                    else
                        key=this.findNearKey(zcu102ipMacro,burst);
                        this.IPOffset=zcu102ipMacro(key);
                    end
                else
                    arria10socioMacropath=fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+estimate','arria10socIOoffset.mat');
                    arria10socioMacro=load(arria10socioMacropath);

                    arria10socipMacro=arria10socioMacro.IO.IP;
                    if isKey(arria10socipMacro,num2str(burst))
                        this.IPOffset=arria10socipMacro(num2str(burst));
                    else
                        key=this.findNearKey(arria10socipMacro,burst);
                        this.IPOffset=arria10socipMacro(key);
                    end
                end
            else
                this.IPOffset=0;
            end
        end

        function getProcessorOPOverhead(this,boardName,frequency,burst)
            if burst~=0
                if contains(boardName,'Zynq')
                    this.AXIMasterWriteOverhead=21;
                    zcu102ioMacropath=fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+estimate','zcu102IOoffset.mat');
                    zcu102ioMacro=load(zcu102ioMacropath);

                    zcu102opMacro=zcu102ioMacro.IO.OP;
                    if isKey(zcu102opMacro,num2str(burst))
                        this.OPOffset=zcu102opMacro(num2str(burst));
                    else
                        key=this.findNearKey(zcu102opMacro,burst);
                        this.OPOffset=zcu102opMacro(key);
                    end
                else
                    this.AXIMasterWriteOverhead=21;
                    arria10socioMacropath=fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+estimate','arria10socIOoffset.mat');
                    arria10socioMacro=load(arria10socioMacropath);

                    arria10socopMacro=arria10socioMacro.IO.OP;
                    if isKey(arria10socopMacro,num2str(burst))
                        this.OPOffset=arria10socopMacro(num2str(burst));
                    else
                        key=this.findNearKey(arria10socopMacro,burst);
                        this.OPOffset=arria10socopMacro(key);
                    end
                end
            else
                this.AXIMasterWriteOverhead=21;
                this.OPOffset=0;
            end
        end

        function key=findNearKey(this,map,burst)
            gapmax=1000000000;
            key='';
            allkeys=keys(map);
            for i=1:length(allkeys)
                thekey=str2num(allkeys{i});
                if abs(burst-thekey)<gapmax
                    gapmax=abs(burst-thekey);
                    key=allkeys{i};
                else
                    continue
                end
            end
        end
    end

    methods(Static)
        function weightloadingoffset=getWeightLoadingOverhead(boardName,targetFrequency,burstLength,calData)
            if isempty(calData)

                switch boardName
                case 'Zynq UltraScale+'
                    weightloadingoffset=dnnfpga.estimate.EstimatorTransfer.getZCU102Offset(targetFrequency,burstLength);
                case 'Arria 10'
                    weightloadingoffset=dnnfpga.estimate.EstimatorTransfer.getArria10Offset(targetFrequency,burstLength);
                case 'Zynq'
                    weightloadingoffset=dnnfpga.estimate.EstimatorTransfer.getZC706Offset(targetFrequency,burstLength);
                otherwise

                    if contains(boardName,'Zynq')
                        weightloadingoffset=dnnfpga.estimate.EstimatorTransfer.getZCU102Offset(targetFrequency,burstLength);
                    else
                        weightloadingoffset=dnnfpga.estimate.EstimatorTransfer.getArria10Offset(targetFrequency,burstLength);
                    end
                end
            else

                weightloadingoffset=dnnfpga.estimate.EstimatorTransfer.getOverheadfromMap(burstLength,calData);
            end
        end

        function RespTime=getZCU102Offset(ClockValue,BurstSize)



            InitialOverhead=[1,3,39,50,71];

            InFrequency=[150,200,220,250,300];

            checkFreq=find(ClockValue==InFrequency);

            if~isempty(checkFreq)
                RespTime=BurstSize+InitialOverhead(checkFreq);
            elseif ClockValue<InFrequency(1)

                RespTime=BurstSize;
            elseif ClockValue>InFrequency(end)

                RespTime=ceil(BurstSize+InitialOverhead(end)*(ClockValue-InFrequency(end))/Infrequency(end));
            else


                FreqMinBound=find(ClockValue>InFrequency);
                FreqMinBound=FreqMinBound(end);

                FreqMaxBound=find(ClockValue<InFrequency);
                FreqMaxBound=FreqMaxBound(1);

                RespTime=ceil(BurstSize+InitialOverhead(FreqMinBound)+...
                (InitialOverhead(FreqMaxBound)-InitialOverhead(FreqMinBound))*(ClockValue-InFrequency(FreqMinBound))/(InFrequency(FreqMaxBound)-InFrequency(FreqMinBound)));
            end
        end

        function RespTime=getArria10Offset(ClockValue,BurstSize)
            ReadTimerOffset=[0,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191];
            BurstLength=[8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536];
            InFrequency=[50,100,150,200,250,300];
            ReadTimerOffsetConst=[22,29,36,44,52,60];


            if(isempty(find(ClockValue==InFrequency))&&(ClockValue<InFrequency(end)))
                FreqMinBound=find(ClockValue>InFrequency);
                FreqMinBound=FreqMinBound(end);
                FreqMaxBound=find(ClockValue<InFrequency);
                FreqMaxBound=FreqMaxBound(1);
            elseif(isempty(find(ClockValue==InFrequency)))
                FreqMinBound=ReadTimerOffsetConst(end-1);
                FreqMaxBound=ReadTimerOffsetConst(end);
            end



            burstIndex=find(BurstSize==BurstLength);
            if~isempty(burstIndex)
                variantOffset=ReadTimerOffset(burstIndex);
            elseif BurstSize>BurstLength(end)
                variantOffset=ReadTimerOffset(end);
            elseif BurstSize<BurstLength(1)
                variantOffset=ReadTimerOffset(1);
            else
                BurstMinBound=find(BurstSize>BurstLength);
                BurstMinBound=BurstMinBound(end);
                BurstMaxBound=find(BurstSize<BurstLength);
                BurstMaxBound=BurstMaxBound(1);

                variantOffset=ceil(ReadTimerOffset(BurstMinBound)+...
                (ReadTimerOffset(BurstMaxBound)-...
                ReadTimerOffset(BurstMinBound))*(BurstSize-BurstLength(BurstMinBound))/(BurstLength(BurstMaxBound)-BurstLength(BurstMinBound)));
            end

            if(ClockValue==50)
                RespTime=BurstSize+ReadTimerOffsetConst(1);
            elseif(ClockValue==100)
                RespTime=BurstSize+ReadTimerOffsetConst(2);
            elseif(ClockValue==150)
                RespTime=BurstSize+ReadTimerOffsetConst(3)+variantOffset;
            elseif((ClockValue==200)||(ClockValue==300))
                RespTime=BurstSize+ReadTimerOffsetConst(find(ClockValue==InFrequency))+variantOffset;
            else
                RespTime=BurstSize+ReadTimerOffsetConst(1)+...
                ((ClockValue-50)/50)*(ReadTimerOffsetConst(FreqMaxBound)-ReadTimerOffsetConst(FreqMinBound)-1)+variantOffset;

            end
            if(BurstSize==256)
                RespTime=RespTime-1;
            end
        end

        function RespTime=getZC706Offset(ClockValue,BurstSize)
            InitialOverhead=[40,62,87,103];
            if(ClockValue==50)
                RespTime=ceil(BurstSize+InitialOverhead(1)+2);
            elseif(ClockValue==100)
                RespTime=ceil(BurstSize+InitialOverhead(2)+6);
            else
                RespTime=ceil(BurstSize+InitialOverhead(1)+(InitialOverhead(2)-InitialOverhead(1))*((ClockValue-50)/50));
            end
        end

        function weightloadingoffset=getOverheadfromMap(burstLength,calData)

            burstLengthList=calData.BurstLengths;
            writeLatencies=calData.WriteLatencies;

            burstMinBound=find(burstLength>=burstLengthList);
            if isempty(burstMinBound)

                burstMinBound=0;
            else
                burstMinBound=burstLengthList(burstMinBound(end));
            end

            burstMaxBound=find(burstLength<burstLengthList);
            burstMaxBound=burstLengthList(burstMaxBound(1));


            if burstMinBound==0

                latencyLowerBound=0;
            else
                latencyLowerBound=writeLatencies(burstLengthList==burstMinBound);
            end
            latencyUpperBound=writeLatencies(burstLengthList==burstMaxBound);



            weightloadingoffset=latencyLowerBound+...
            ((burstLength-burstMinBound)/(burstMaxBound-burstMinBound))*(latencyUpperBound-latencyLowerBound);
        end
    end
end
