classdef EstimatorTimeAdder<dnnfpga.estimate.EstimatorTransfer




    properties


        BurstToBurstDelay=2;
        CompLatency=[];
    end

    methods
        function obj=EstimatorTimeAdder(complatency)
            obj.CompLatency=complatency;
        end
    end

    methods
        function AdderLayerTime=GetLayerTime(this,hPC,adderProcessor,processorParams,dataTransNum,calData)














            cc=adderProcessor.getCC;
            adderSize=processorParams.adderSize;
            adderSizeAXI=ceil(adderSize/dataTransNum);

            inputBurstLength=cc.inputBurstLength;
            outputBurstLength=cc.inputBurstLength;
            inputBurstNum=processorParams.inputBurstNum;
            outputBurstNum=processorParams.outputBurstNum;

            totalInputBurstTime=this.getLayerBusrtCycles(hPC,adderSizeAXI,inputBurstLength,inputBurstNum,'IP');
            totalOutputBurstTime=this.getLayerBusrtCycles(hPC,adderSizeAXI,outputBurstLength,outputBurstNum,'OP');




            layerTime.LayerComputationCycle=this.CompLatency;
            layerTime.LayerInputBusrtCycle=totalInputBurstTime*2;
            layerTime.LayerOutputBusrtCycle=totalOutputBurstTime;

            if inputBurstNum==1||outputBurstNum==1

                layerTime.LayerProcessCycle=layerTime.LayerComputationCycle+layerTime.LayerInputBusrtCycle+layerTime.LayerOutputBusrtCycle;
            else

                layerTime.LayerProcessCycle=layerTime.LayerComputationCycle+max(layerTime.LayerInputBusrtCycle,layerTime.LayerOutputBusrtCycle);
            end

            AdderLayerTime.layer=layerTime;
        end

        function layerBusrtCycles=getLayerBusrtCycles(this,hPC,adderSizeAXI,burstLength,burstNum,moduleType)





            ClockValue=hPC.TargetFrequency;
            boardType=hPC.TargetPlatform;








            shortBurstSize=mod(adderSizeAXI,burstLength);
            if shortBurstSize
                shortBurstCycles=this.getBurstCycles(moduleType,boardType,ClockValue,shortBurstSize);


                burstNum=burstNum-1;
            else

                shortBurstCycles=0;
            end





            longBurstCycles=this.getBurstCycles(moduleType,boardType,ClockValue,burstLength)*burstNum;
            layerBusrtCycles=shortBurstCycles+longBurstCycles;

        end
        function burstCycles=getBurstCycles(this,moduleType,boardType,ClockValue,burstLength)








            if strcmpi(moduleType,'IP')
                this.getProcessorIPOverhead(boardType,ClockValue,burstLength);
                burstCycles=burstLength+this.BurstToBurstDelay+this.IPOffset;
            else
                this.getProcessorOPOverhead(boardType,ClockValue,burstLength);
                burstCycles=burstLength+this.BurstToBurstDelay+this.OPOffset;
            end
        end
    end
end


