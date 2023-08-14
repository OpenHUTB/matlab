classdef cnn5LegBackend<dnnfpga.compiler.cnn4ProcessorBackend


    properties(Access=public)


hLegDDROffsetMap
    end

    methods(Access=public,Hidden=true)
        function obj=cnn5LegBackend(verbose)
            obj@dnnfpga.compiler.cnn4ProcessorBackend(verbose);
        end

    end

    methods(Access=public)

        function deployableNW=doit(this,deployableLayerParams,processor,varargin)




            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'TopLevelDDRAddrOffsetMap',[],@(x)isa(x,'containers.Map'));
            addParameter(p,'LegLevelDDRAddrOffsetMap',[]);
            parse(p,varargin{:});
            this.hDDROffsetMap=p.Results.TopLevelDDRAddrOffsetMap;
            this.hLegDDROffsetMap=p.Results.LegLevelDDRAddrOffsetMap;


            deployableLayerParams=this.allocateConvDDR(deployableLayerParams,processor);



            deployableNW=this.constructDeployableNetwork(deployableLayerParams,processor,varargin{:});

        end
    end

    methods(Access=protected)


        function deployableLayerParams=allocateConvDDR(this,deployableLayerParams,processor)


            for i=1:length(deployableLayerParams)
                layerType=deployableLayerParams{i}.type;
                switch layerType
                case 'FPGA_Conv'


                    DDRAddrA=this.hDDROffsetMap('convInputBufferOffset');
                    DDRAddrB=this.hDDROffsetMap('convOutputBufferOffset');




                    DDRAddrInput=uint32(0);
                    DDRAddrResult=uint32(0);

                    for jj=1:length(deployableLayerParams{i}.params)






                        deployableLayerParams{i}.params{jj}.DDRAddrA=DDRAddrA;
                        deployableLayerParams{i}.params{jj}.DDRAddrB=DDRAddrB;
                        if(jj==1)
                            deployableLayerParams{i}.params{jj}.DDRAddrA=DDRAddrInput;
                        end
                        if(jj==length(deployableLayerParams{i}.params))
                            deployableLayerParams{i}.params{jj}.DDRAddrB=DDRAddrResult;
                        end





                        tmpDDRAddr=DDRAddrA;
                        DDRAddrA=DDRAddrB;
                        DDRAddrB=tmpDDRAddr;
                    end
                otherwise

                end
            end
        end

        function deployableNW=constructDeployableNetwork(this,deployableLayerParams,cnnp,varargin)

            layers={};
            convData=[];
            fcData=[];
            state=0;

            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'ActivationLayer','',@ischar);
            addParameter(p,'ActivationTile',[]);
            addParameter(p,'FCWeightBaseAddrOffset',0,@isnumeric);
            addParameter(p,'ConvWeightBaseAddrOffset',0,@isnumeric);
            parse(p,varargin{:});
            activationLayer=p.Results.ActivationLayer;
            tileActivation=p.Results.ActivationTile;
            fcWeightBaseAddrOffset=p.Results.FCWeightBaseAddrOffset;
            ConvWeightBaseAddrOffset=p.Results.ConvWeightBaseAddrOffset;

            notRunTiledLayerPos=[];
            for i=1:length(deployableLayerParams)
                dlp=deployableLayerParams{i};
                layerType=dlp.type;
                switch state
                case 0
                    switch layerType
                    case 'SW_SeriesNetwork2FPGA'
                        assert(i<length(deployableLayerParams));
                        dlpNext=deployableLayerParams{i+1};
                        layers{end+1}=this.createSN2FPGALayer(dlp,dlpNext,cnnp);
                        state=1;
                    case 'FPGA_Conv'
                        [convData,notRunTiledLayerPos]=cnnp.getConvProcessor().backend(dlp.params,ConvWeightBaseAddrOffset,this.verbose,tileActivation);
                        convData.params=dlp;
                        state=2;

                    case 'FPGA_FC'
                        fcData=cnnp.getFCProcessor().backend(dlp.params,cnnp.getCC.dataTransNum,fcWeightBaseAddrOffset);
                        fcData.params=dlp;
                        state=3;

                    case 'SW_SeriesNetwork'
                        if(strcmpi(dlp.params{1}.internal_type,'SW_Sigmoid'))
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.sigmoidLayerPredict(dlp.params{1}.snLayer,input)));
                        elseif(strcmpi(dlp.params{1}.internal_type,'SW_Exponential'))
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.exponentialLayerPredict(dlp.params{1}.snLayer,input)));
                        else
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.compiler.compilerUtils.SNLayerPredict(dlp.params{1}.snLayer,input)));
                        end
                        if(strcmpi(dlp.params{1}.internal_type,'SW_SeriesNetwork_Input')&&(dlp.params{1}.WL==8))
                            layers{end+1}=this.QuantizeInput(dlp,cnnp);
                        end

                        state=0;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                case 1
                    switch layerType
                    case 'FPGA_Conv'
                        conv5p=cnnp.getConvProcessor;
                        [convData,notRunTiledLayerPos]=conv5p.backend(dlp.params,ConvWeightBaseAddrOffset,this.verbose,tileActivation);
                        convData.params=dlp;
                        state=1;

                    case 'FPGA_FC'
                        fcData=cnnp.getFCProcessor().backend(dlp.params,cnnp.getCC.dataTransNum,fcWeightBaseAddrOffset);
                        fcData.params=dlp;
                        state=2;

                    case 'SW_FPGA2SeriesNetwork'
                        layers{end+1}=dnnfpga.compiler.cnn5LegBackend.createFPGALayer(cnnp,convData,fcData,deployableLayerParams,activationLayer,notRunTiledLayerPos);
                        convData=[];
                        fcData=[];
                        if((dlp.params{1}.WL==8))
                            layers{end+1}=this.QuantizeOutput(dlp,cnnp);
                        end


                        state=3;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                case 2
                    switch layerType
                    case 'FPGA_Conv'
                        conv4p=cnnp.getConvProcessor;

                        [convData,notRunTiledLayerPos]=conv4p.backend(dlp.params,this.verbose,tileActivation);
                        convData.params=dlp;
                        state=1;

                    case 'FPGA_FC'

                        fc4p=cnnp.getFCProcessor;
                        fcData=fc4p.backend(dlp.params);
                        fcData.params=dlp;
                        state=2;

                    case 'SW_FPGA2SeriesNetwork'
                        layers{end+1}=dnnfpga.compiler.cnn5LegBackend.createFPGALayer(cnnp,convData,fcData,deployableLayerParams,activationLayer,notRunTiledLayerPos);
                        convData=[];
                        fcData=[];
                        notRunTiledLayerPos=[];
                        if((dlp.params{1}.WL==8))
                            layers{end+1}=this.QuantizeOutput(dlp,cnnp);
                        end
                        layers{end+1}=dnnfpga.deployablenetwork.swLayer('InputToFPGA',@(input)(dnnfpga.compiler.cnn4ProcessorBackend.reshapeMulti({input,false})));
                        state=3;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end

                case 3
                    switch layerType
                    case 'SW_SeriesNetwork'
                        if(strcmpi(dlp.params{1}.internal_type,'SW_Sigmoid'))
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.sigmoidLayerPredict(dlp.params{1}.snLayer,input)));
                        elseif(strcmpi(dlp.params{1}.internal_type,'SW_Exponential'))
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.processorbase.processorUtils.exponentialLayerPredict(dlp.params{1}.snLayer,input)));
                        else
                            layers{end+1}=dnnfpga.deployablenetwork.swLayer(dlp.params{1}.snLayer,@(input)(dnnfpga.compiler.compilerUtils.SNLayerPredict(dlp.params{1}.snLayer,input)));
                        end
                        state=3;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                otherwise
                    assert(false,'Unexpected state: %d',state);
                end

            end

            if(~isempty(convData)||~isempty(fcData))
                layers{end+1}=dnnfpga.compiler.cnn5LegBackend.createFPGALayer(cnnp,convData,fcData,deployableLayerParams,activationLayer,notRunTiledLayerPos);
            end
            deployableNW=dnnfpga.deployablenetwork.deployableNetwork(layers);
        end
    end

    methods(Access=protected,Static=true)

        function fl=createFPGALayer(cnnp,convData,fcData,deployableLayerParams,activationLayer,notRunTiledLayerPos,hDDROffsetMap)



            if nargin<7
                hDDROffsetMap=containers.Map('KeyType','char','ValueType','uint32');
            end
            if nargin<6
                notRunTiledLayerPos=[];
            end
            seqOp=[];
            seqLC=[];
            NC=[];
            syncSeqLC=[];
            moduleSeqLC=[];
            fpgaLayerParams=[];
            weightBaseAddrOffset=[];

            if(~isempty(convData))
                seqOp.conv=convData.seqOp;
                seqLC.conv=convData.seqLC;
                NC.conv=convData.NC;
                syncSeqLC=convData.syncSeqLC;
                fpgaLayerParams{end+1}=convData.params;
                weightBaseAddrOffset.conv=convData.weightBaseAddrOffset;
            end
            if(~isempty(fcData))
                seqOp.fc=fcData.seqOp;
                seqLC.fc=fcData.seqLC;
                moduleSeqLC.fc=fcData.moduleSeqLC;
                NC.fc=fcData.NC;
                fpgaLayerParams{end+1}=fcData.params;
                weightBaseAddrOffset.fc=fcData.weightBaseAddrOffset;
            end

            initData.seqOp=seqOp;
            initData.seqLC=seqLC;
            initData.NC=NC;
            initData.syncSeqLC=syncSeqLC;
            initData.moduleSeqLC=moduleSeqLC;
            initData.weightBaseAddrOffset=weightBaseAddrOffset;
            forwardArgs.params=fpgaLayerParams;

            fl=dnnfpga.deployablenetwork.fpgaLayer('FPGA_CNN',cnnp,initData,forwardArgs,deployableLayerParams,hDDROffsetMap,activationLayer,notRunTiledLayerPos);

        end

        function ed=createEmptyData()
            ed.seqOp=[];
            ed.seqLC=[];
            ed.NC=[];
        end
    end
end


