classdef ProfileLogsNetAnalysis<handle







    properties

        CNNevent=containers.Map;
CNNparams
    end

    methods

        function[NetworkParams,NetworkEvents]=getNetworkInfo(this,fpgaLayerParams,cnnp)

            fpgaLayerParams=this.filterSoftLayer(fpgaLayerParams);



            this.populateCNNevents(fpgaLayerParams,cnnp);
            NetworkParams=this.CNNparams;
            NetworkEvents=this.CNNevent;
        end

        function convp=getconvp(this,cnnp)

            convp=cnnp.getConvProcessor;
        end

        function populateCNNevents(this,fpgaLayerParams,cnnp)


            this.CNNparams=fpgaLayerParams;

            for i=1:length(fpgaLayerParams)


                processor=fpgaLayerParams{i};
                processorLayers=processor.params;

                processorName=processor.type;


                if strcmp(processorName,'FPGA_Conv')

                    for j=1:length(processorLayers)

                        Layer=processorLayers{j};


                        this.populateConvLayerEventNums(cnnp,Layer,processorLayers,i,j);
                    end
                end
            end
        end


        function populateConvLayerEventNums(this,cnnp,Layer,processorLayers,processorNum,layerNum)


            convp=this.getconvp(cnnp);
            cc=convp.getCC;
            threadNum=cc.conv.threadNumLimit;




            LayerName=Layer.phase;
            tileIRParams=convp.getTileIR(Layer);

            NewParam=this.getNewParam(Layer,tileIRParams);

            this.CNNparams{processorNum}.params{layerNum}=NewParam;

            layerevent=containers.Map;

            for i=1:length(tileIRParams)


                tileITParam=tileIRParams{i};
                tileEvent=this.getTileEventNumbers(tileITParam,threadNum);

                if layerNum==length(processorLayers)&&i==length(tileIRParams)
                    tileEvent.valid=1;
                end
                tileEvent.number=tileEvent.input+tileEvent.output+tileEvent.conv+tileEvent.valid;
                layerevent(string(i))=tileEvent;
            end
            this.CNNevent(LayerName)=layerevent;

        end

        function NewParam=getNewParam(this,layer,tileIRParams)

            NewParam.type=layer.type;
            NewParam.phase=layer.phase;
            NewParam.frontendLayers=layer.frontendLayers;
            NewParam.tileNum=length(tileIRParams);
        end


        function cnntileevent=getTileEventNumbers(this,tileITParam,threadNum)








            cnntileevent.input=2*tileITParam.ipBurstNum;
            cnntileevent.output=2*tileITParam.opBurstNum;
            cnntileevent.conv=2;
            cnntileevent.valid=0;

            cnntileevent.IPlongburst=threadNum*(tileITParam.imageTilePos(2)-tileITParam.imageTilePos(1));
            cnntileevent.OPlongburst=threadNum*(tileITParam.resultTilePos(2)-tileITParam.resultTilePos(1));
            cnntileevent.tilesize=[(tileITParam.resultTilePos(2)-tileITParam.resultTilePos(1)),(tileITParam.resultTilePos(4)-tileITParam.resultTilePos(3)),tileITParam.outputFeatureNum];
        end

        function fpgaLayerParams=filterSoftLayer(this,fpgaLayerParams)
            fpgaLayerParamsFiltered={};
            for i=1:length(fpgaLayerParams)
                if strcmp(fpgaLayerParams{i}.type,'SW_SeriesNetwork')||strcmp(fpgaLayerParams{i}.type,'SW_SeriesNetwork2FPGA')||strcmp(fpgaLayerParams{i}.type,'SW_FPGA2SeriesNetwork')
                    continue;
                else
                    fpgaLayerParamsFiltered{end+1}=fpgaLayerParams{i};
                end
            end
            fpgaLayerParams=fpgaLayerParamsFiltered;
        end

    end
end

