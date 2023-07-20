classdef adderProcessor<dnnfpga.processorbase.abstractProcessor




    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=adderProcessor(bcc)
            obj@dnnfpga.processorbase.abstractProcessor(bcc);
        end
    end

    methods(Access=public)
        function cycles=estimateThroughput(~,~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.adderProcessor doesn''t have estimateThroughput');
            cycles=[];
        end

        function nc=resolveNC(~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.adderProcessor doesn''t have resolveNC');
            nc=[];
        end

        function s=resolveOutputSizeLayer(~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.adderProcessor doesn''t have resolveOutputSizeLayer');
            s=[];
        end

        function s=resolveInputSizeLayer(~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.adderProcessor doesn''t have resolveInputSizeLayer');
            s=[];
        end

        function output=MLEmulationAddLayer(this,component,input,cnnp)

            processorInfo=cnnp.getBCC();
            dataType=processorInfo.addp.kernelDataType;
            numInputs=component.numInputs;
            finalOutExp=0;
            if(strcmp(dataType,'int8'))
                signedbit=1;

                numBitsRequiredForAddition=ceil(log2(numInputs+signedbit));

                adjustedExponent_in1=component.inputExp(1)-(32-numBitsRequiredForAddition-8);
                adjustedExponent_in2=component.inputExp(2)-(32-numBitsRequiredForAddition-8);


                minExp=min(adjustedExponent_in1,adjustedExponent_in2);
                maxExp=max(adjustedExponent_in1,adjustedExponent_in2);

                utils=dlquantization.Utils;
                input{1}=utils.scaleToInt32(single(input{1}(:)),-component.inputExp(1)+adjustedExponent_in1,false);
                input{2}=utils.scaleToInt32(single(input{2}(:)),-component.inputExp(2)+adjustedExponent_in2,false);

                if(minExp~=maxExp)
                    if(maxExp-minExp>1)










                        outIndex=find(component.inputExp==min(component.inputExp));
                        input{outIndex}=utils.scaleToInt32(int32(input{outIndex}(:)),-minExp+maxExp,false);
                        finalOutExp=maxExp;
                    else


                        outIndex=find(component.inputExp==max(component.inputExp));
                        input{outIndex}=utils.scaleToInt32(int32(input{outIndex}(:)),-maxExp+minExp,false);
                        finalOutExp=minExp;
                    end
                else
                    finalOutExp=minExp;
                end
                output=int32(zeros(size(input{1})));
                for i=1:numInputs
                    output=output+int32(input{i});
                end
            else
                output=zeros(size(input{1}));
                for i=1:numInputs
                    output=output+input{i};
                end
            end


            if(component.reLUMode)
                output=dnnfpga.processorbase.adderProcessor.reLUOutput(component,output,dataType,finalOutExp);
            end
            if(strcmp(dataType,'int8'))


                output=utils.scale(int32(output(:)),-(finalOutExp-component.outputExp),false);
                output=reshape(output,size(input{1}));
            end
        end
    end
    methods(Access=protected,Static=true)
        function reLUResults=reLUOutput(component,reLUInput,dataType,finalOutExp)
            if(component.reLUMode==3)
                if(strcmp(dataType,'int8'))
                    quantReLUValue=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(component.reLUValue,finalOutExp);
                    reLUResults=(reLUInput.*int32(reLUInput<0)*(0)+int32(reLUInput>=quantReLUValue)*int32(quantReLUValue)+reLUInput.*int32(reLUInput>0&(reLUInput<quantReLUValue))*1);
                else
                    reLUResults=(reLUInput.*(reLUInput<0)*(0)+(reLUInput>=component.reLUValue)*(component.reLUValue)+reLUInput.*((reLUInput>0&reLUInput<component.reLUValue))*1);
                end
            else
                if(strcmp(dataType,'int8'))


                    quantReLUValue=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(component.reLUValue,component.reLUExp);
                    reLUResults=((reLUInput.*int32(int32(reLUInput<0)*int32(quantReLUValue)))*2^(double(component.reLUExp)))+(reLUInput.*(int32(reLUInput>=0)*(1)));
                else
                    reLUResults=reLUInput.*((reLUInput<0)*(component.reLUValue)+(reLUInput>=0)*(1));
                end
            end
        end
    end

    methods(Access=protected)
        function cc=resolveCC(this)
            bcc=this.getBCC();


            cc.kernelDataType=bcc.kernelDataType;
            cc.SumLatency=bcc.SumLatency;
            cc.ProdLatency=bcc.ProdLatency;
            cc.CmpLatency=bcc.CmpLatency;
            cc.inputMemDepthLimit=bcc.inputMemDepthLimit;
            cc.resultMemDepthLimit=bcc.resultMemDepthLimit;
            cc.inputBurstLength=bcc.inputBurstLength;
            cc.outputBurstLength=bcc.outputBurstLength;
            cc.RoundingMode=bcc.RoundingMode;
            cc.ExpLatency=26;
            cc.IdentityLatency=1;
            cc.TanhLatency=25;
            cc.DivideLatency=32;
            cc.SingleProdLatency=8;
            if(strcmp(cc.kernelDataType,'single'))
                cc.PipelineLatency=0;
                cc.NumBytes=4;
            elseif(strcmp(cc.kernelDataType,'half'))
                cc.PipelineLatency=0;
                cc.NumBytes=2;
            else

                cc.PipelineLatency=1;
                cc.NumBytes=1;
            end
            cc.lcParams=bcc.lcParams;
            cc.layerConfigNumWLimit=bcc.layerConfigNumWLimit;
            cc.halfProgLCFIFODepth=bcc.halfProgLCFIFODepth;





            cc.ResizeLineLen=512;

            cc.ResizeNearestScale=256;

        end

        function lc=resolveLCPerLayer(~,~)
            assert(false,'Shall not reach here: dnnfpga.processorbase.adderProcessor doesn''t have LC');
            lc=[];
        end

    end

    methods(Access=protected,Static=true)
    end

    methods(Access=public,Static=true)
        function layerDataModule=getModuleSeqLC(adderComponent,ddrSupport)

            import dnnfpga.processorbase.adderProcessor.*
            import dnnfpga.dagCompile.*;


            componentInputs=adderComponent.inputs;
            numInputs=numel(componentInputs);
            inputsLength=zeros(1,2,'uint32');
            for idx=1:numel(componentInputs)
                inputsLength(idx)=uint32(getLengthFromSize(ddrSupport,componentInputs(idx).net.size));
            end

            layerConfig.inputsLength=inputsLength;
            layerConfig.outputLength=uint32(getLengthFromSize(ddrSupport,adderComponent.outputs.net.size));


            layerConfig.numInputs=fi(numInputs,0,2,0);

            if adderComponent.hasKind(LayerKind.Relu)
                reluLayer=adderComponent.nLayer(2);
                if isa(reluLayer,'nnet.cnn.layer.ReLULayer')
                    layerConfig.reluMode=fi(1,0,3,0);
                end
                if isa(reluLayer,'nnet.cnn.layer.LeakyReLULayer')
                    layerConfig.reluMode=fi(2,0,3,0);
                end
                if isa(reluLayer,'nnet.cnn.layer.ClippedReLULayer')
                    layerConfig.reluMode=fi(3,0,3,0);
                end
            else
                layerConfig.reluMode=fi(0,0,3,0);
            end



            customLayerInfo=adderComponent.CustomLayerInfo;
            layerConfig.layerMode=uint8(customLayerInfo.CurrentLayerID);





            assert(customLayerInfo.CurrentLayerID,'Custom layer ID should not be zero.');


            for pvPair=customLayerInfo.TotalLayersPVList
                layerConfig.(pvPair.property)=zeros(size(pvPair.value),'like',pvPair.value);
            end


            if adderComponent.hasKind(LayerKind.CustomLayer)
                for pvPair=customLayerInfo.CurrentLayerPVList
                    layerConfig.(pvPair.property)=pvPair.value;
                end
            end


            layerDataModule.moduleSeqLC=dnnfpga.assembler.seqLayerConfigPrivate(layerConfig,'single',fieldnames(layerConfig));
        end

        function length=getLengthFromSize(ddrSupport,size)





            normalizeSize=ddrSupport.normalizeSize(size);
            length=prod(normalizeSize);
            length=length/ddrSupport.dataTransNum;
        end

    end
end


