classdef EstimatorTimeResize2DLayer<dnnfpga.estimate.EstimatorTimeAdder




    methods
        function Resize2DLayerTime=GetLayerTime(this,hPC,adderProcessor,processorParams,dataTransNum,calData)













            cc=adderProcessor.getCC;

            inputSize=processorParams.inputSize;
            inputSizeAXI=ceil(inputSize/dataTransNum);

            outputSize=processorParams.outputSize;
            outputSizeAXI=ceil(outputSize/dataTransNum);

            inputBurstLength=cc.inputBurstLength;
            outputBurstLength=cc.inputBurstLength;
            inputBurstNum=processorParams.inputBurstNum;
            outputBurstNum=processorParams.outputBurstNum;

            totalInputBurstTime=this.getLayerBusrtCycles(hPC,inputSizeAXI,inputBurstLength,inputBurstNum,'IP');
            totalOutputBurstTime=this.getLayerBusrtCycles(hPC,outputSizeAXI,outputBurstLength,outputBurstNum,'OP');




            layerTime.LayerInputBusrtCycle=totalInputBurstTime*2;
            layerTime.LayerOutputBusrtCycle=totalOutputBurstTime;






            term1=processorParams.LayerInput(2)+2;
            term2=processorParams.Scale(2)*processorParams.LayerInput(2);
            term3=processorParams.Scale(1);
            term4=processorParams.LayerInput(1);
            term5=ceil(processorParams.LayerInput(3)/dataTransNum);
            layerTime.LayerComputationCycle=(term1+term2*term3)*term4*term5;

            if inputBurstNum==1||outputBurstNum==1

                layerTime.LayerProcessCycle=layerTime.LayerComputationCycle+layerTime.LayerInputBusrtCycle+layerTime.LayerOutputBusrtCycle;
            else


                layerTime.LayerProcessCycle=layerTime.LayerComputationCycle+layerTime.LayerInputBusrtCycle;
            end

            Resize2DLayerTime.layer=layerTime;
        end
    end
end


