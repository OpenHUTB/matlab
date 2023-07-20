classdef paramFactory







    properties

    end

    methods
        function obj=paramFactory()
        end
    end

    methods(Access=protected)
        pvpairs=parseParams(this,params);
        param=commonInputParams(this,layer,pvpairs);
        param=quantizedinputParams(this,WL,param,layer,mapObjInputExp,mapObjOutputExp,fiMath);

        param=commonConvParams(this,layer,previousLayerParam);
        param=groupconvParams(this,layer,param,processor);
        param=unpoolParams(this,layer,fpgaParamLayers,pvpairs);
        param=transposeconvParams(this,layer,fpgaParamLayers,pvpairs);
        param=quantizedConvparams(this,WL,param,previousLayerParam,layer,mapObjInputExp,mapObjOutputExp,fiMath);
        param=quantizedGroupconvParams(this,WL,param,layer,fiMath);

        param=commonReluParams(this,layer,param);
        param=leakyreluParams(this,layer,param);
        param=clippedreluParams(this,layer,param);
        param=quantizedReluParams(this,WL,previousLayerParam,layer,mapObjOutputExp);
        param=quantizedLeakyreluParams(this,WL,previousLayerParam,layer,mapObjInputExp,mapObjOutputExp);
        param=quantizedClippedreluParams(this,WL,previousLayerParam,layer,mapObjOutputExp);

        param=commonOutputParams(this,layer,pvpairs);
        param=quantizedOutputParams(this,WL,param,previousLayerParam,layer,mapObjOutputExp);

        param=commonPoolParams(this,WL,layer,processor,param,pvpairs,net);
        param=averagepoolParams(this,layer,param);
        param=quantizedMaxpoolParams(this,WL,param,previousLayerParam,layer,mapObjOutputExp);
        param=quantizedAveragepoolParams(this,WL,param,layer);

        param=commonFCParams(this,WL,layer,processor,fpgaParamLayers);
        param=quantizedFCParams(this,WL,param,previousLayerParam,layer,mapObjInputExp,mapObjOutputExp,fiMath);


    end

    methods(Access=public)
        function fpgaParamLayers=createParams(this,net,layerObjects,processor,varargin)
            params=varargin(1:end);
            pvpairs=this.parseParams(params);

            if(isfield(pvpairs,'processordatatype'))
                processorDataType=pvpairs.processordatatype;
            else
                processorDataType='single';
            end

            if~isfield(pvpairs,'targetdir')||isempty(pvpairs.targetdir)
                pvpairs.targetdir=[pwd,filesep,'codegen'];
            end

            codegendir=pvpairs.targetdir;
            dnnfpga.compiler.makeCodegendir(codegendir);

            fpgaParamLayers={};

            switch(processorDataType)
            case 'int4'
                WL=4;

                fiMath=fimath("SumMode","SpecifyPrecision","SumWordLength",16,"SumFractionLength",3,"ProductWordLength",16,...
                "OverflowAction","Saturate","RoundingMethod","Convergent");

            case 'int8'
                WL=8;
                fiMath=fimath("SumMode","FullPrecision","SumWordLength",32,"SumFractionLength",3,"ProductWordLength",32,...
                "OverflowAction","Saturate","RoundingMethod","Convergent");

            otherwise
                WL=1;
                fiMath=[];
            end

            if(~(WL==1))
                [mapObjInputExp,mapObjOutputExp]=dnnfpga.compiler.mapLayerExponents(pvpairs.exponentdata,net);
            else
                mapObjInputExp=[];
                mapObjOutputExp=[];
            end

            for i=1:numel(layerObjects)
                layerObject=layerObjects{i};
                switch(layerObject.type)
                case 'input'
                    fpgaParamLayers{end+1}=this.commonInputParams(layerObject.layer,pvpairs);
                    fpgaParamLayers{end}=this.quantizedinputParams(WL,fpgaParamLayers{end},layerObject.layer,mapObjInputExp,mapObjOutputExp,fiMath);

                case 'conv'
                    fpgaParamLayers{end+1}=this.commonConvParams(layerObject.layer,fpgaParamLayers{end});
                    fpgaParamLayers{end}=this.groupconvParams(layerObject.layer,fpgaParamLayers{end},processor);
                    fpgaParamLayers{end}=this.unpoolParams(layerObject.layer,fpgaParamLayers,pvpairs);
                    fpgaParamLayers{end}=this.transposeconvParams(layerObject.layer,fpgaParamLayers,pvpairs);



                    fpgaParamLayers{end}=this.quantizedConvparams(WL,fpgaParamLayers{end},fpgaParamLayers{end-1},layerObject.layer,mapObjInputExp,mapObjOutputExp,fiMath);
                    fpgaParamLayers{end}=this.quantizedGroupconvParams(WL,fpgaParamLayers{end},layerObject.layer,fiMath);

                    dnnfpga.layer.checkParams.convParams(fpgaParamLayers{end},layerObject.layer,processor);

                case 'relu'

                    fpgaParamLayers{end}=this.commonReluParams(layerObject.layer,fpgaParamLayers{end});
                    fpgaParamLayers{end}=this.leakyreluParams(layerObject.layer,fpgaParamLayers{end});
                    fpgaParamLayers{end}=this.clippedreluParams(layerObject.layer,fpgaParamLayers{end});

                    fpgaParamLayers{end}=this.quantizedReluParams(WL,fpgaParamLayers{end},layerObject.layer,mapObjOutputExp);
                    fpgaParamLayers{end}=this.quantizedLeakyreluParams(WL,fpgaParamLayers{end},layerObject.layer,mapObjInputExp,mapObjOutputExp);
                    fpgaParamLayers{end}=this.quantizedClippedreluParams(WL,fpgaParamLayers{end},layerObject.layer,mapObjOutputExp);

                    dnnfpga.layer.checkParams.reluParams(fpgaParamLayers{end},layerObject.layer);

                case 'output'
                    fpgaParamLayers{end+1}=this.commonOutputParams(layerObject.layer,pvpairs);
                    fpgaParamLayers{end}=this.quantizedOutputParams(WL,fpgaParamLayers{end},fpgaParamLayers{end-1},layerObject.layer,mapObjOutputExp);


                case 'pool'
                    fpgaParamLayers{end+1}=this.commonPoolParams(WL,layerObject.layer,processor,fpgaParamLayers{end},pvpairs,net);
                    fpgaParamLayers{end}=this.averagepoolParams(layerObject.layer,fpgaParamLayers{end});

                    fpgaParamLayers{end}=this.quantizedMaxpoolParams(WL,fpgaParamLayers{end},fpgaParamLayers{end-1},layerObject.layer,mapObjOutputExp);
                    fpgaParamLayers{end}=this.quantizedAveragepoolParams(WL,fpgaParamLayers{end},layerObject.layer);

                    dnnfpga.layer.checkParams.poolParams(fpgaParamLayers{end},processor);

                case 'fc'
                    fpgaParamLayers{end+1}=this.commonFCParams(WL,layerObject.layer,processor,fpgaParamLayers);
                    fpgaParamLayers{end}=this.quantizedFCParams(WL,fpgaParamLayers{end},fpgaParamLayers{end-1},layerObject.layer,mapObjInputExp,mapObjOutputExp,fiMath);

                otherwise

                end

            end
        end
    end

end
