classdef conv2Processor<dnnfpga.processorbase.abstractProcessor





    properties(Access=private)

weightloadingoffset
    end

    methods(Access=public,Hidden=true)
        function obj=conv2Processor(bcc)
            obj@dnnfpga.processorbase.abstractProcessor(bcc);
        end
    end

    methods(Access=public)
        function cycles=estimateThroughput(this,params,~)
            cc=this.getCC();
            lcs=this.resolveLC(params);
            cycles.latency=0;
            cycles.throughput=0;
            for i=1:length(lcs)
                lc=lcs(i);
                switch(lc.convMode)
                case 1
                    tCurr=this.calConvTime(lc);
                case 2
                    tCurr=this.calLrnTime(lc);
                case 0
                    tCurr=this.calMaxpoolTime(lc);
                case 3
                    tCurr=this.calMaxpoolTime(lc);
                case 4
                    tCurr=this.calInputTime(params);
                case 5
                    tCurr=this.calConvTime(lc);
                otherwise
                end
                cycles.latency=cycles.latency+tCurr;
            end

            cycles.latency=cycles.latency+cc.layerConfigNumWLimit;
            cycles.throughput=cycles.latency;
        end

        function nc=resolveNC(this,params)
            nc.layerNumMinusOne=length(params)-1;

            nc.image_count=3;
            nc.image_length=this.resolveInputSize(params);
            nc.imgSizeDivByOpW=ceil(params{1}.origImgSize(1)/this.getBCC.opW);
            nc.imgSizeModByOpW=mod(params{1}.origImgSize(1),this.getBCC.opW);
            if nc.imgSizeModByOpW==0
                nc.imgSizeModByOpW=this.getBCC.opW;
            end
            nc.kernelWidth=this.getBCC.opW;
            nc.numofBlocks=ceil(params{1}.inputFeatureNum/this.getCC.threadNumLimit);
            nc.PaddingLogicSel=params{1}.selectPaddingType;

        end

        function output=cosimConvLayer(this,param,input)
            chipConfig=this.getCC();
            [paddedImg,seqImg]=dnnfpga.processorbase.conv2Processor.preprocessImage(input,...
            param.inputFeatureNum,param.inputFeatureNumToPadForSplit,param.origImgSize,chipConfig.opSize,...
            chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqImg.mat'],'seqImg');
            end
            [paddedOp,paddedBias,seqOp,param]=this.preprocessOperatorU(param);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqOp.mat'],'seqOp');
            end
            resultSize=dnnfpga.processorbase.conv2Processor.getResultSize(param.origImgSize,param.origOpSizeValue,param.paddingMode,param.strideMode,param.stridePhase,param.dilationMode);
            param.finalWriteSize=resultSize;
            quantDataTypes={'int4','int8'};
            if(any(strcmpi(chipConfig.kernelDataType,quantDataTypes)))
                if(param.reLUMode==2)

                    quantReLUValue=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(param.reLUValue,param.reLUScaleExp);
                elseif(param.reLUMode==3)

                    quantReLUValue=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(param.reLUValue,param.rescaleExp);
                else
                    quantReLUValue=0;
                end
                [xConv,~]=dnnfpga.processorbase.conv2Processor.calBaseline(param,paddedImg,paddedOp,paddedBias(1:2:end),...
                param.inputFeatureNum,param.outputFeatureNum,param.finalWriteSize,...
                param.strideMode,param.stridePhase,param.reLUMode,param.convSplitMode,param.paddingMode,param.dilationMode,quantReLUValue,param.reLUScaleExp);
            else
                [xConv,~]=dnnfpga.processorbase.conv2Processor.calBaseline(param,paddedImg,paddedOp,paddedBias,...
                param.inputFeatureNum,param.outputFeatureNum,param.finalWriteSize,...
                param.strideMode,param.stridePhase,param.reLUMode,param.convSplitMode,param.paddingMode,param.dilationMode,param.reLUValue,param.reLUScaleExp);

            end
            if(param.convSplitMode)
                firstHalf=xConv(1:param.outputFeatureNum/2,:,:);
                xConvPaddedForThreadFirstHalf=dnnfpga.assembler.padImage(firstHalf,[mod(-param.outputFeatureNum/2,chipConfig.threadNumLimit),0,0],'post');
                secondHalf=xConv(param.outputFeatureNum/2+1:end,:,:);
                xConvPaddedForThreadSecondHalf=dnnfpga.assembler.padImage(secondHalf,[mod(-param.outputFeatureNum/2,chipConfig.threadNumLimit),0,0],'post');
                xConvPaddedForThread=[xConvPaddedForThreadFirstHalf;xConvPaddedForThreadSecondHalf];
            else
                xConvPaddedForThread=dnnfpga.assembler.padImage(xConv,[mod(-param.outputFeatureNum,chipConfig.threadNumLimit),0,0],'post');
            end
            xConvPaddedForThreadUnpaddedForOpW=xConvPaddedForThread(:,1:double(resultSize(1)),1:double(resultSize(2)));
            seqResult=reshape(permute(xConvPaddedForThreadUnpaddedForOpW,[2,3,1]),[1,numel(xConvPaddedForThreadUnpaddedForOpW)]);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult.mat'],'seqResult');
            end
            output=dnnfpga.convbase.exportImage(xConv);
            [output,param]=dnnfpga.processorbase.conv2Processor.unpadForSplit(output,param);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_output.mat'],'output');
            end
            [~,seqResult]=dnnfpga.processorbase.conv2Processor.preprocessImage(output,param.outputFeatureNum,param.outputFeatureNumToPadForSplit,[resultSize(1);resultSize(2);1],chipConfig.opSize,chipConfig.threadNumLimit,param.convSplitMode,inf);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult2.mat'],'seqResult');
            end
        end

        function output=cosimConvNLayer(this,param,input)
            chipConfig=this.getCC();
            [paddedImg,seqImg]=dnnfpga.processorbase.conv2Processor.preprocessImage(input,...
            param.inputFeatureNum,param.inputFeatureNumToPadForSplit,param.origImgSize,chipConfig.opSize,...
            chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqImg.mat'],'seqImg');
            end
            [paddedOp,paddedBias,seqOp,param]=this.preprocessOperatorU(param);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqOp.mat'],'seqOp');
            end
            resultSize=dnnfpga.processorbase.conv2Processor.getResultSize(param.origImgSize,param.origOpSizeValue,param.paddingMode,param.strideMode,param.stridePhase,param.dilationMode);
            param.finalWriteSize=resultSize;
            if(~isfield(param,'reLUValue'))
                param.reLUValue=0;
            end
            if(~isfield(param,'reLUScaleExp'))
                param.reLUScaleExp=0;
            end
            if(strcmp(chipConfig.kernelDataType,'int8'))
                if(param.reLUMode==2)

                    quantReLUValue=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(param.reLUValue,param.reLUScaleExp);
                elseif(param.reLUMode==3)

                    quantReLUValue=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(param.reLUValue,param.rescaleExp);
                else
                    quantReLUValue=0;
                end
                [xConv,~]=dnnfpga.processorbase.conv2Processor.calBaseline(param,paddedImg,paddedOp,paddedBias(1:2:end),...
                param.inputFeatureNum,param.outputFeatureNum,param.finalWriteSize,...
                param.strideMode,param.stridePhase,param.reLUMode,param.convSplitMode,param.paddingMode,param.dilationMode,quantReLUValue,param.reLUScaleExp);
            else
                [xConv,~]=dnnfpga.processorbase.conv2Processor.calBaseline(param,paddedImg,paddedOp,paddedBias,...
                param.inputFeatureNum,param.outputFeatureNum,param.finalWriteSize,...
                param.strideMode,param.stridePhase,param.reLUMode,param.convSplitMode,param.paddingMode,param.dilationMode,param.reLUValue,param.reLUScaleExp);

            end
            xConv1(:,:,:)=reshape(xConv(:,:,:,:),[size(xConv,2),size(xConv,3),size(xConv,4)]);
            xConvPaddedForThread=dnnfpga.assembler.padImage(xConv1,[mod(-param.outputFeatureNum,chipConfig.threadNumLimit),0,0],'post');


            xConvPaddedForThreadUnpaddedForOpW=xConvPaddedForThread(1:double(resultSize(1)),1:double(resultSize(2)),:);
            seqResult=reshape(permute(xConvPaddedForThreadUnpaddedForOpW,[2,3,1]),[1,numel(xConvPaddedForThreadUnpaddedForOpW)]);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult.mat'],'seqResult');
            end

            output=xConv1;
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_output.mat'],'output');
            end
            [~,seqResult]=dnnfpga.processorbase.conv2Processor.preprocessImage(output,param.outputFeatureNum,param.outputFeatureNumToPadForSplit,[resultSize(1);resultSize(2);1],chipConfig.opSize,chipConfig.threadNumLimit,param.convSplitMode,inf);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult2.mat'],'seqResult');
            end
        end


        function output=cosimTransposedConvLayer(this,param,input)
            chipConfig=this.getCC();
            [paddedImg,seqImg]=dnnfpga.processorbase.conv2Processor.preprocessImage(input,...
            param.inputFeatureNum,param.inputFeatureNumToPadForSplit,param.origImgSize,chipConfig.opSize,...
            chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqImg.mat'],'seqImg');
            end
            [paddedOp,paddedBias,seqOp,param]=this.preprocessOperatorU(param);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqOp.mat'],'seqOp');
            end
            param.finalWriteSize=param.outputSize;
            xConv=dnnfpga.processorbase.conv2Processor.calBaselineTransposedConv(param,input);
            seqResult=xConv;
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult.mat'],'seqResult');
            end
            output=xConv;
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_output.mat'],'output');
            end
        end


        function output=cosimMaxpoolLayer(this,param,input)
            chipConfig=this.getCC();



            paddedImg=dnnfpga.assembler.padImage(input,[param.paddingMode(1),param.paddingMode(3),0],'pre');

            paddedImg=dnnfpga.assembler.padImage(paddedImg,[param.paddingMode(2),param.paddingMode(4),0],'post');


            paddedImg=dnnfpga.assembler.padForNegativeData(paddedImg,input,param.paddingMode);
            [paddedImg,seqImg]=dnnfpga.processorbase.conv2Processor.preprocessImage(paddedImg,...
            param.inputFeatureNum,param.inputFeatureNumToPadForSplit,[size(paddedImg,1);size(paddedImg,2);1],param.origOpSizeValue,...
            chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqImg.mat'],'seqImg');
            end
            [xMaxpool,~]=dnnfpga.convbase.calBaselineMaxpool(paddedImg,size(paddedImg),param.origOpSizeValue,dnnfpga.convbase.resolveStrideMode(param.strideMode),param.stridePhase,param.maxpoolType);
            xMaxpoolPermuted=permute(xMaxpool,[2,3,1]);
            seqResult=reshape(xMaxpoolPermuted,[1,numel(xMaxpoolPermuted)]);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult.mat'],'seqResult');
            end
            output=dnnfpga.convbase.exportImage(xMaxpool);
            param1=param;
            param1.outputFeatureNum=param1.outputFeatureNum+param1.outputFeatureNumToPadForSplit;
            [output,~]=dnnfpga.processorbase.conv2Processor.unpadForSplit(output,param1);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_output.mat'],'output');
            end
            [~,seqResult]=dnnfpga.processorbase.conv2Processor.preprocessImage(output,param.outputFeatureNum,param.outputFeatureNumToPadForSplit,[size(output,1);size(output,2);1],chipConfig.opSize,chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult2.mat'],'seqResult');
            end
        end


        function output=cosimAveragepoolLayer(this,param,input)
            chipConfig=this.getCC();

            paddedImg=dnnfpga.assembler.padImage(input,[param.paddingMode(1),param.paddingMode(3),0],'pre');

            paddedImg=dnnfpga.assembler.padImage(paddedImg,[param.paddingMode(2),param.paddingMode(4),0],'post');

            [paddedImg,seqImg]=dnnfpga.processorbase.conv2Processor.preprocessImage(paddedImg,...
            param.inputFeatureNum,param.inputFeatureNumToPadForSplit,[size(paddedImg,1);size(paddedImg,2);1],param.origOpSizeValue,...
            chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);%#ok<ASGLU>
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqImg.mat'],'seqImg');
            end

            [xAvgpool,~]=dnnfpga.convbase.calBaselineAveragepool(paddedImg,size(paddedImg),param.origOpSizeValue,dnnfpga.convbase.resolveStrideMode(param.strideMode),param.stridePhase,param.avgMultiplier);
            xAvgpoolPermuted=permute(xAvgpool,[2,3,1]);
            seqResult=reshape(xAvgpoolPermuted,[1,numel(xAvgpoolPermuted)]);

            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult.mat'],'seqResult');
            end
            output=dnnfpga.convbase.exportImage(xAvgpool);
            param1=param;
            param1.outputFeatureNum=param1.outputFeatureNum+param1.outputFeatureNumToPadForSplit;
            [output,~]=dnnfpga.processorbase.conv2Processor.unpadForSplit(output,param1);

            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_output.mat'],'output');
            end
            [~,seqResult]=dnnfpga.processorbase.conv2Processor.preprocessImage(output,param.outputFeatureNum,param.outputFeatureNumToPadForSplit,[size(output,1);size(output,2);1],chipConfig.opSize,chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult2.mat'],'seqResult');
            end
        end


        function output=cosimLrnLayer(this,param,input)
            chipConfig=this.getCC();
            [x,y,z]=size(input);
            lps=mod(-size(input)',chipConfig.opSize);
            param.lrnPadddingSize(1:2)=lps(1:2);
            param.lrnPadddingSize(3)=mod(-size(input,3),chipConfig.threadNumLimit);
            lrnResult=zeros(x,y,z+param.lrnFeaturePadding);
            AddMorePadd=mod(-size(lrnResult,3),chipConfig.threadNumLimit);

            totalPadding=(param.lrnFeaturePadding+AddMorePadd);
            padImg=zeros(x,y,totalPadding);
            newConv=zeros(x,y,z+totalPadding);


            newConv(:,:,1:end-totalPadding)=input;
            newConv(:,:,end-totalPadding+1:end)=padImg;
            [newX,newY,newZ]=size(newConv);
            if(mod(param.lrnLocalSize,2)==0)
                MinIdxLmt=param.lrnFeaturePadding-1;
                MaxIdxLmt=param.lrnFeaturePadding;
            else
                MinIdxLmt=param.lrnFeaturePadding;
                MaxIdxLmt=param.lrnFeaturePadding;
            end
            temp_i=1:newX;
            temp_j=1:newY;
            for k=1:newZ
                minIdx=max(1,k-MinIdxLmt);
                maxIdx=min(newZ,k+MaxIdxLmt);
                lrnResult(temp_i,temp_j,k)=newConv(temp_i,temp_j,k)./...
                ((param.lrnK+(param.lrnAlpha*(sum((newConv(temp_i,temp_j,minIdx:maxIdx).^2),3)))).^param.lrnBeta);
            end
            lrnResultPadding=zeros(newX+param.lrnPadddingSize(1),newY+param.lrnPadddingSize(2),newZ);
            lrnResultPadding(1:newX,1:newY,:)=lrnResult;
            if(mod(totalPadding,chipConfig.threadNumLimit)==0)
                lrnResult1=lrnResult(:,:,1:size(lrnResult,3)-totalPadding);
                lrnResultOut=lrnResultPadding(:,:,1:size(lrnResult,3)-totalPadding);
            elseif(totalPadding>chipConfig.threadNumLimit)
                lrnResult1=lrnResult(:,:,1:size(lrnResult,3)-chipConfig.threadNumLimit);
                lrnResultOut=lrnResultPadding(:,:,1:size(lrnResult,3)-chipConfig.threadNumLimit);
            else
                lrnResult1=lrnResult;
                lrnResultOut=lrnResultPadding(:,:,1:size(lrnResult,3));
            end

            [outX,outY,outZ]=size(lrnResultOut);
            outX=ceil(outX/chipConfig.opW);
            outY=ceil(outY/chipConfig.opW);
            outZ=ceil(outZ/chipConfig.threadNumLimit);
            newBlock=zeros(chipConfig.opW,chipConfig.opW,chipConfig.threadNumLimit);
            newLrnOut=zeros(numel(lrnResultOut),1);
            for k=1:outZ
                for i=1:outX
                    for j=1:outY

                        newBlock=lrnResultOut((i-1)*chipConfig.opW+1:i*chipConfig.opW,(j-1)*chipConfig.opW+1:j*chipConfig.opW,(k-1)*chipConfig.threadNumLimit+1:k*chipConfig.threadNumLimit);
                        newLrn=reshape(permute(newBlock,[1,2,3]),[1,numel(newBlock)]);
                        newIdxstart=((i-1)*outY*chipConfig.opW*chipConfig.opW*chipConfig.threadNumLimit)+((j-1)*chipConfig.opW*chipConfig.opW*chipConfig.threadNumLimit)+(((k-1)*outY*outX*chipConfig.opW*chipConfig.opW*chipConfig.threadNumLimit))+1;
                        newIdxEnd=((i-1)*outY*chipConfig.opW*chipConfig.opW*chipConfig.threadNumLimit)+((j-1)*chipConfig.opW*chipConfig.opW*chipConfig.threadNumLimit)+(((k-1)*outY*outX*chipConfig.opW*chipConfig.opW*chipConfig.threadNumLimit))+(chipConfig.threadNumLimit*prod(chipConfig.opSize));
                        newLrnOut(newIdxstart:newIdxEnd)=newLrn;
                    end
                end
            end
            lrn1Result=lrnResultPadding(:,:,1:size(lrnResult,3)-totalPadding);
            norm2=dnnfpga.processorbase.conv2Processor.lrnLocal(input,param.lrnLocalSize,param.lrnAlpha*param.lrnLocalSize,param.lrnBeta,param.lrnK);
            output=lrn1Result(1:size(norm2,1),1:size(norm2,2),1:size(norm2,3));

            [lrnResultPadded,~]=dnnfpga.processorbase.conv2Processor.preprocessImage(output,...
            param.inputFeatureNum,param.inputFeatureNumToPadForSplit,param.origImgSize,param.origOpSizeValue,...
            chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);%#ok<ASGLU>
            lrnResultNew=permute(lrnResultPadded,[2,3,1]);

            seqResult=reshape(lrnResultNew,[1,numel(lrnResultNew)]);

            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult.mat'],'seqResult');
            end

            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_output.mat'],'output');
            end
            [~,seqResult]=dnnfpga.processorbase.conv2Processor.preprocessImage(output,param.outputFeatureNum,param.outputFeatureNumToPadForSplit,[size(output,1);size(output,2);1],chipConfig.opSize,chipConfig.threadNumLimit,param.convSplitMode,chipConfig.inputMemZAddrLimit);
            if(strcmp(dnnfpgafeature('DLHDLSaveMatFiles'),'on'))
                save([param.phase,'_seqResult2.mat'],'seqResult');
            end
        end

        function output=cosim(this,param,input)
            switch param.type
            case{'SW_Cosim_FPGA_Conv2D','SW_Emulation_FPGA_Conv2D'}
                output=this.cosimConvLayer(param.params{1},input);
            case{'SW_Cosim_FPGA_Maxpool2D','SW_Emulation_FPGA_Maxpool2D'}
                output=this.cosimMaxpoolLayer(param.params{1},input);
            case 'SW_Cosim_FPGA_Avgpool2D'
                output=this.cosimAveragepoolLayer(param.params{1},input);
            case 'SW_Cosim_FPGA_Lrn2D'
                output=this.cosimLrnLayer(param.params{1},input);
            case 'SW_Cosim_FPGA_ConvND'
                output=this.cosimConvNLayer(param.params{1},input);
            case 'SW_Cosim_FPGA_TransposedConv'
                output=this.cosimTransposedConvLayer(param.params{1},input);
            otherwise
                assert(false,'Unexpected layer type %s',param.type);
            end
        end

        function convp=getConvProcessor(this)
            convp=this;
        end

        function s=resolveInputSizeLayer(this,param)
            outputXY=param.origImgSize;
            outputXY=outputXY(1:2);
            outputXY=outputXY+mod(-outputXY,this.getCC.opSize(1:2));
            outFNum=param.inputFeatureNum+param.inputFeatureNumToPadForSplit;
            outFNum=outFNum+mod(-outFNum,this.getCC.threadNumLimit);
            s=[outputXY(1:2);outFNum];
        end

        function s=resolveInputSize(this,params)
            if(params{1}.selectPaddingType==0)

                assert(strcmpi(params{1}.type,'FPGA_Input'));




                imageW=params{1}.origImgSize(1);
                s=imageW*imageW*2;
            else

                assert(strcmpi(params{1}.type,'FPGA_Input'));
                imageW=ceil(params{1}.origImgSize(1)/this.getCC.opSize(1))*this.getCC.opSize(1);
                if params{1}.outputFeatureNumToPadForSplit>0
                    NumOfFeatureMaps=2*ceil(params{1}.inputFeatureNum/2/this.getCC.threadNumLimit)*this.getCC.threadNumLimit;
                else
                    NumOfFeatureMaps=ceil(params{1}.inputFeatureNum/this.getCC.threadNumLimit)*this.getCC.threadNumLimit;
                end
                s1=imageW*imageW*NumOfFeatureMaps;
                zDepth=s1/(this.getCC.opSize(1)*this.getCC.opSize(1)*this.getCC.threadNumLimit);
                if(params{1}.inputFeatureNumToPadForSplit||zDepth<=this.getCC.inputMemZAddrLimit)
                    s=s1;
                else
                    s=this.getCC.opSize(1)*this.getCC.opSize(1)*this.getCC.threadNumLimit*this.getCC.inputMemZAddrLimit;
                end
            end
        end

        function s=resolveOutputSizeLayer(this,param)
            outputXY=dnnfpga.compiler.propagateConvLayerOutputSize(param);
            outputXY=outputXY(1:2);
            outputXY=outputXY+mod(-outputXY,this.getCC.opSize(1:2));
            outFNum=param.outputFeatureNum+param.outputFeatureNumToPadForSplit;
            outFNum=outFNum+mod(-outFNum,this.getCC.threadNumLimit);
            s=[outputXY(1:2);outFNum];
        end

        function s=resolveOutputSizeLayerWithoutPadding(this,param)










            outputXY=dnnfpga.compiler.propagateConvLayerOutputSize(param);




            outputXY=outputXY(1:2);


            outFNum=param.outputFeatureNum;
            s=[outputXY(1:2);outFNum];
        end

        function active=inputMemZAdapterActivePred(this,param)
            if(param.memDirection==true)
                active=dnnfpga.processorbase.conv2Processor.inputMemZAdapterActivePredCore(this.getCC.threadNumLimit,param.convSplitMode,param.inputFeatureNum);
            else
                active=dnnfpga.processorbase.conv2Processor.inputMemZAdapterActivePredCore(this.getCC.threadNumLimit,param.convSplitMode,param.outputFeatureNum);
            end
        end

        function output=getSeqLCAndOpPerLayer(this,param)
            layerType=param.type;
            switch layerType
            case{'FPGA_Conv2D','FPGA_ConvND'}
                output=this.getSeqLCAndOpPerLayerConv(param);
            case 'FPGA_Maxpool2D'
                output=this.getSeqLCAndOpPerLayerMaxpool(param);
            case 'FPGA_Avgpool2D'
                output=this.getSeqLCAndOpPerLayerAvgpool(param);
            case{'FPGA_Unpool2D','FPGA_TransposedConv'}
                output=this.getSeqLCAndOpPerLayerUnpool(param);
            case 'FPGA_Lrn2D'
                output=this.getSeqLCAndOpPerLayerLrn(param);
            case 'FPGA_Input'
                output=this.getSeqLCAndOpPerLayerInput(param);
            otherwise
                assert(false,'Unknown layer type "%s"',layerType);
            end
        end

        function logs=sanityCheckLayer(this,param)
            logs={};

            cc=this.getCC();

            switch param.type
            case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_ConvND'}
                logs=[logs,this.sanityCheckLayerInputFeatureSize(param)];
                logs=[logs,this.sanityCheckLayerOutputFeatureSize(param)];

                if(any(param.origOpSizeValue>cc.origOpSizeLimit))
                    l=sprintf('Convolution kernel size (%s) is larger than the limit(%s).',mat2str(param.origOpSizeValue(1:2)),mat2str(cc.origOpSizeLimit(1:2)));
                    logs=[logs,l];
                end

                if(max(param.paddingMode)>=cc.paddingModeWLimit)
                    l=sprintf('PaddingSize (%d) is larger than the limit (%d).',max(param.paddingMode),cc.strideModeWLimit);
                    logs=[logs,l];
                end
                if(param.strideMode~=1&&param.strideMode~=2&&param.strideMode~=4)
                    l=sprintf('Stride must be 1, 2, or 4, but it is (%d).',param.strideMode);
                    logs=[logs,l];
                end
                if~all(param.dilationMode==1)



                    l=sprintf('DilationFactor must be [1 1], but it is [%d %d].',param.dilationMode(1),param.dilationMode(2));
                    logs=[logs,l];
                end
            case 'FPGA_Lrn2D'
                logs=[logs,this.sanityCheckLrnLocalSize(param)];
            case 'FPGA_Input'
                logs=[logs,this.sanityCheckLayerInputFeatureSize(param)];
            otherwise
                assert(false,'Unknown layer type "%s"',layerType);
            end
        end

        function logs=sanityCheckNetwork(this,params)
            logs={};


            layerNum=length(params);
            layerNumLimit=this.getCC().layerNumWLimit;
            if(layerNum>layerNumLimit)
                logs{end+1}=sprintf('The number of conv layers(%d) is greater than the limit (%d).',layerNum,layerNumLimit);
            end
        end

        function kind=getKind(this)
            kind='abstract';
        end
    end

    methods(Access=protected)
        function cc=resolveCC(this)
            bcc=this.getBCC();
            cc.kernelDataType=bcc.kernelDataType;
            cc.RoundingMode=bcc.RoundingMode;
            cc.MemoryMinDepth=bcc.MemoryMinDepth;
            cc.threadNumLimit=bcc.threadNumLimit;
            cc.threadNumLimitSquared=bcc.threadNumLimit^2;
            cc.imageNumWLimit=bcc.imageNumWLimit;
            cc.layerModeNumWLimit=bcc.layerModeNumWLimit;
            cc.featureSizeLimit=bcc.featureSizeLimit;






            if(bcc.resultMemDepthLimit(1)<=bcc.threadNumLimit/2)












                cc.resultMemDepthLimit=[ceil(bcc.resultMemDepthLimit(1)/bcc.threadNumLimit)*2;ceil(ceil(bcc.resultMemDepthLimit(2:3)/bcc.opW)/2)];
            else

                cc.resultMemDepthLimit=[ceil(bcc.resultMemDepthLimit(1)/bcc.threadNumLimit);ceil(bcc.resultMemDepthLimit(2:3)/bcc.opW)];
            end











            if(bcc.inputMemDepthLimit(1)<=bcc.threadNumLimit/2)







                cc.inputMemDepthLimit=ceil(prod([1;ceil(bcc.inputMemDepthLimit(2:3)/bcc.opW)])/2);
            else
                cc.inputMemDepthLimit=prod([ceil(bcc.inputMemDepthLimit(1)/bcc.threadNumLimit);ceil(bcc.inputMemDepthLimit(2:3)/bcc.opW)]);
            end
            cc.resultMemZAddrLimit=cc.resultMemDepthLimit;
            cc.inputMemZAddrLimit=cc.inputMemDepthLimit;
            cc.layerNumWLimit=bcc.layerNumWLimit;
            cc.layerConfigNumWLimit=bcc.layerConfigNumWLimit;
            cc.debugIDNumWLimit=bcc.debugIDNumWLimit;
            cc.debugBankNumWLimit=bcc.debugBankNumWLimit;
            cc.smallPoolLatency=bcc.smallPoolLatency;
            if(strcmp(cc.kernelDataType,'single'))
                cc.Fixdt_0_16_0_To_SingleLatency=0;
                cc.opBitWidthLimit=bcc.opBitWidthLimit;
                cc.ReducerLatency=bcc.SumLatency*ceil(log2(cc.threadNumLimit));
                cc.biasFactor=1;


                cc.PipelineLatency=0;
            else



                cc.Fixdt_0_16_0_To_SingleLatency=bcc.Fixdt_0_16_0_To_SingleLatency;
                cc.opBitWidthLimit=8;





                cc.ReducerLatency=1*ceil(log2(cc.threadNumLimit));
                cc.biasFactor=8;
                cc.PipelineLatency=1;
            end
            cc.ProdLatency=bcc.ProdLatency;
            cc.SumLatency=bcc.SumLatency;
            cc.CmpLatency=bcc.CmpLatency;
            cc.MADLatency=bcc.MADLatency;
            cc.ExpLatency=bcc.ExpLatency;
            cc.LogLatency=bcc.LogLatency;
            cc.DivideLatency=bcc.DivideLatency;
            cc.MemReadLatency=bcc.MemReadLatency;
            cc.DataMemReadLatency=bcc.DataMemReadLatency;
            cc.DebugMemReadLatency=bcc.DebugMemReadLatency;
            cc.DebugMemRegularReadLatency=bcc.DebugMemRegularReadLatency;
            cc.lrnLocalSizeLimit=bcc.lrnLocalSizeLimit;
            cc.Addr3DTo1DLatency=bcc.Addr3DTo1DLatency;

            cc.opW=bcc.opW;
            cc.imgSizeLimit=[bcc.imgWLimit;bcc.imgWLimit;1];
            cc.imgAddrW=ceil(log2(max(cc.imgSizeLimit)));
            cc.imgAddrDivByOpWW=ceil(log2(max(cc.imgSizeLimit/cc.opW)));
            cc.opSize=[bcc.opW;bcc.opW;1];
            cc.origOpSizeLimit=[bcc.origOpWLimit;bcc.origOpWLimit;1];
            cc.paddingModeWLimit=bcc.paddingModeWLimit;
            cc.strideModeWLimit=bcc.strideModeWLimit;
            cc.dilationModeWLimit=bcc.dilationModeWLimit;
            cc.wSizeLimit=prod(cc.opSize)+1;
            cc.zSizeLimit=ceil(bcc.imgWLimit/cc.opW);
            cc.zAddrW=ceil(log2(cc.zSizeLimit));
            cc.dilatedOpSizeLimit=3+(bcc.dilationModeWLimit-1)*(cc.opW-1);
            cc.dwLimit=cc.opW;
            cc.drLimit=cc.strideModeWLimit+cc.dilatedOpSizeLimit;
            cc.dzLimit=ceil(cc.drLimit/cc.opW);

            cc.zKernelAddrW=ceil(log2(ceil(bcc.imgWLimit/min(bcc.unpoolKernelMinSize))));
            cc.unpoolKernelAddrW=ceil(log2(bcc.origOpWLimit));
            cc.unpoolKernelDivByOpWAddrW=max(1,ceil(log2(ceil(bcc.origOpWLimit/bcc.opW))));

            cc.opDDRRatio=bcc.opDDRBitWidthLimit/cc.opBitWidthLimit;
            cc.opDUTBitWidthLimit=bcc.opDUTBitWidthLimit;
            cc.convWeightBurstLength=ceil((prod(cc.opSize)*cc.threadNumLimitSquared+cc.threadNumLimit*cc.biasFactor)/cc.opDDRRatio);












            cc.convIndexActsBurstLength=floor(((cc.convWeightBurstLength-1)*cc.opDDRRatio+1)/cc.threadNumLimit);
            cc.convIndexActsBurstLengthAddrW=ceil(log2(cc.convIndexActsBurstLength))+1;
            cc.convIndexActsSelectorOffsetAddrW=ceil(log2(cc.opDDRRatio));
            cc.threadNumLimitAddrW=ceil(log2(cc.threadNumLimit))+1;

            cc.superConvolutionSizeLimit(1)=bcc.superConvolutionFirstDimensionLimit;
            cc.superConvolutionSizeLimit(bcc.ControlLogicTileXAddrIdx)=cc.imgSizeLimit(1);
            cc.superConvolutionSizeLimit(bcc.ControlLogicTileYAddrIdx)=ceil(cc.imgSizeLimit(2)/cc.convIndexActsBurstLength);
            cc.superConvolutionSizeLimit(bcc.ControlLogicInputFeatureAddrIdx:bcc.ControlLogicOutputFeatureAddrIdx)=[max(bcc.featureSizeLimit);max(bcc.featureSizeLimit)];

            cc.strideModeAddrW=ceil(log2(bcc.strideModeWLimit));
            cc.paddingModeAddrW=ceil(log2(bcc.paddingModeWLimit));
            cc.dilationModeAddrW=ceil(log2(bcc.dilationModeWLimit));

            cc.debugIDAddrW=ceil(log2(bcc.debugIDNumWLimit));
            cc.debugBankAddrW=ceil(log2(bcc.debugBankNumWLimit));
            cc.debugSelectionAddrW=cc.debugIDAddrW+cc.debugBankAddrW;
            cc.debugCounterWLimit=bcc.debugCounterWLimit;
            cc.debugDMADepthLimit=bcc.debugDMADepthLimit;
            cc.debugDMAWidthLimit=bcc.debugDMAWidthLimit;

            cc.dataMemAddrW=ceil(log2(max([bcc.resultMemDepthLimit;bcc.inputMemDepthLimit;bcc.featureSizeLimit])));
            cc.lcMemAddrW=ceil(log2(bcc.layerNumWLimit*bcc.layerConfigNumWLimit));
            cc.debugMemAddrW=max(ceil(log2(max(prod(bcc.resultMemDepthLimit),prod(bcc.inputMemDepthLimit)))),cc.lcMemAddrW);

            cc.PELatency=bcc.MADLatency;
            cc.ConvLatency=cc.PELatency*(prod(cc.opSize)-1)+bcc.MADLatency;

            cc.ControlLogicInputFeatureAddrIdx=bcc.ControlLogicInputFeatureAddrIdx;
            cc.ControlLogicOutputFeatureAddrIdx=bcc.ControlLogicOutputFeatureAddrIdx;
            cc.ControlLogicTileXAddrIdx=bcc.ControlLogicTileXAddrIdx;
            cc.ControlLogicTileYAddrIdx=bcc.ControlLogicTileYAddrIdx;

            cc.CONV_TRANS_CTRL_LATENCY=bcc.CONV_TRANS_CTRL_LATENCY;

            cc.paddingLogicDataTypeConvertLatency=bcc.Fixdt_0_16_0_To_SingleLatency;

            cc.lcParam=bcc.lcParam;
            cc.DebugParams=bcc.DebugParams;
            cc.supportedDebugMem=bcc.supportedDebugMem;
            cc.offset=bcc.offset;
            cc.lrnCompWindowSize=bcc.lrnCompWindowSize;
            cc.halfProgLCFIFODepth=bcc.halfProgLCFIFODepth;






            cc.inputMemAddrBitWidth=ceil(log2(prod(cc.inputMemDepthLimit)))+1;
            cc.resultMemAddrBitWidth=ceil(log2(prod(cc.resultMemDepthLimit)))+1;
        end

        function lc=resolveLCPerLayer(this,param)
            lc=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,this.getCC());
        end

        function output=getSeqLCAndOpPerLayerConv(this,param)

            [~,~,seqOp,~]=this.preprocessOperatorU(param);
            if(strcmp(this.getCC.kernelDataType,'single'))
                output.seqOp=seqOp;
            else
                output.seqOp=typecast(int8(seqOp),'uint32');
            end
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,this.getCC());
            output.seqLC=dnnfpga.processorbase.conv2Processor.seqLayerConfig(layerConfig,'single',this.getCC().lcParam);
        end

        function output=getSeqLCAndOpPerLayerMaxpool(this,param)
            if(param.outputFeatureNumToPadForSplit>0)
                param.inputFeatureNum=param.inputFeatureNum+param.inputFeatureNumToPadForSplit;
                param.outputFeatureNum=param.inputFeatureNum+param.outputFeatureNumToPadForSplit;
            end

            seqOp=[];
            output.seqOp=seqOp;
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,this.getCC());
            output.seqLC=dnnfpga.processorbase.conv2Processor.seqLayerConfig(layerConfig,'single',this.getCC().lcParam);
        end

        function output=getSeqLCAndOpPerLayerAvgpool(this,param)
            if(param.outputFeatureNumToPadForSplit>0)
                param.inputFeatureNum=param.inputFeatureNum+param.inputFeatureNumToPadForSplit;
                param.outputFeatureNum=param.inputFeatureNum+param.outputFeatureNumToPadForSplit;
            end

            seqOp=[];
            output.seqOp=seqOp;
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,this.getCC());
            output.seqLC=dnnfpga.processorbase.conv2Processor.seqLayerConfig(layerConfig,'single',this.getCC().lcParam);
        end

        function output=getSeqLCAndOpPerLayerUnpool(this,param)
            if(param.outputFeatureNumToPadForSplit>0)
                param.inputFeatureNum=param.inputFeatureNum+param.inputFeatureNumToPadForSplit;
                param.outputFeatureNum=param.inputFeatureNum+param.outputFeatureNumToPadForSplit;
            end
            [~,~,seqOp,~]=this.preprocessOperatorU(param);
            if(strcmp(this.getCC.kernelDataType,'single'))
                output.seqOp=seqOp;
            else
                output.seqOp=typecast(int8(seqOp),'uint32');
            end
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,this.getCC());
            output.seqLC=dnnfpga.processorbase.conv2Processor.seqLayerConfig(layerConfig,'single',this.getCC().lcParam);
        end

        function output=getSeqLCAndOpPerLayerLrn(this,param)
            output.seqOp=[];
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,this.getCC());
            output.seqLC=dnnfpga.processorbase.conv2Processor.seqLayerConfig(layerConfig,'single',this.getCC().lcParam);
        end

        function output=getSeqLCAndOpPerLayerInput(this,param)
            output.seqOp=[];
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerConv2(param,this.getCC());
            output.seqLC=dnnfpga.processorbase.conv2Processor.seqLayerConfig(layerConfig,'single',this.getCC().lcParam);
        end


        function[paddedOp,paddedBias,seqOp,param]=preprocessOperatorU(this,param)
            chipConfig=this.getCC();
            [conv2Kernels,conv2Bias,param]=dnnfpga.processorbase.conv2Processor.padOpForSplit(param.weights,param.bias,param);
            inputFeatureNum=param.inputFeatureNum;
            outputFeatureNum=param.outputFeatureNum;

            inputFeatureSizeLimit=max(chipConfig.featureSizeLimit);
            outputFeatureSizeLimit=max(chipConfig.featureSizeLimit);
            [importedOp,importedBias]=dnnfpga.processorbase.conv2Processor.importOperator(conv2Kernels,conv2Bias,inputFeatureNum,outputFeatureNum,param.convSplitMode);

            [paddedOp,paddedBias,linearOp,linearBias]=dnnfpga.processorbase.conv2Processor.setupCosimOpU(importedOp,importedBias,...
            inputFeatureNum,outputFeatureNum,param.origOpSizeValue,param.convSplitMode,...
            inputFeatureSizeLimit,outputFeatureSizeLimit,chipConfig.origOpSizeLimit,-param.rescaleExp);
            if(strcmp(param.type,'FPGA_Unpool2D')||strcmp(param.type,'FPGA_TransposedConv'))
                [~,~,~,~,~,wAddr0,~,~,~,~]=dnnfpga.processorbase.initCtrlDataUnpool(param.paddingMode,param.strideMode,param.stridePhase,param.dilationMode,param.origImgSize(1:2),param.origOpSizeValue,chipConfig.wSizeLimit,chipConfig.opW,param.unpoolRemainder);
            else
                [~,~,~,~,~,wAddr0,~,~,~,~]=dnnfpga.processorbase.initCtrlData(param.paddingMode,param.strideMode,param.stridePhase,param.dilationMode,param.origImgSize(1:2),param.origOpSizeValue,chipConfig.wSizeLimit,chipConfig.opW);
            end

            if(isfi(paddedOp))
                seqOp=[];
            else
                seqOpT=dnnfpga.processorbase.conv2Processor.seqOperator(linearOp,linearBias,...
                inputFeatureNum,outputFeatureNum,chipConfig.threadNumLimit,...
                outputFeatureSizeLimit,...
                param.origOpSizeValue,chipConfig.opSize,chipConfig.origOpSizeLimit,param.convSplitMode,uint8(wAddr0));
                seqOp=dnnfpga.assembler.packData(seqOpT,...
                prod(chipConfig.opSize)*chipConfig.threadNumLimitSquared+chipConfig.threadNumLimit*chipConfig.biasFactor,...
                chipConfig.opBitWidthLimit,chipConfig.opDDRRatio*chipConfig.opBitWidthLimit);
            end

        end






        function logs=sanityCheckLayerMemSize(this,requiredSize,isInputSideMem,isInputFeature)
            logs={};

            cc=this.getCC();
            if(isInputSideMem)
                memDepthLimit=cc.inputMemDepthLimit;
            else
                memDepthLimit=cc.resultMemDepthLimit;
            end
            if(isInputFeature)
                side='Input';
            else
                side='Output';
            end
            imgSizeLimit=cc.imgSizeLimit+mod(-cc.imgSizeLimit,cc.opSize);

            if(any(requiredSize(1:2)>imgSizeLimit(1:2)))
                logs{end+1}=sprintf('%s feature width or height (%s) is larger than the limit (%s).',side,mat2str(requiredSize(1:2)),mat2str(imgSizeLimit(1:2)));
            end
            if(requiredSize(3)>cc.featureSizeLimit(1))
                logs{end+1}=sprintf('The number of %s feature (%d) is larger than the limit (%d).',lower(side),requiredSize(3),cc.featureSizeLimit(1));
            end
            if(prod(requiredSize)>prod(memDepthLimit)*prod(cc.opSize)*cc.threadNumLimit)
                logs{end+1}=sprintf('The overall %s feature size (%d) is larger than the limit (%d).',lower(side),prod(requiredSize),prod(memDepthLimit)*prod(cc.opSize)*cc.threadNumLimit);
            end
        end

        function logs=sanityCheckLayerInputMemSideSize(this,param,inputMemSideSize,isInputFeature)
            if(this.inputMemZAdapterActivePred(param))
                if(param.memDirection)
                    inputMemSideSize(3)=param.inputFeatureNum;
                else
                    inputMemSideSize(3)=param.outputFeatureNum;
                end
            end
            logs=this.sanityCheckLayerMemSize(inputMemSideSize,true,isInputFeature);
        end

        function logs=sanityCheckLayerResultMemSideSize(this,~,resultMemSideSize,isInputFeature)
            logs=this.sanityCheckLayerMemSize(resultMemSideSize,false,isInputFeature);
        end

        function logs=sanityCheckLayerInputFeatureSize(this,param)
            inputSize=this.resolveInputSizeLayer(param);
            [ifOnIM,~]=dnnfpga.processorbase.abstractProcessor.resolveMemoryDirection(param);
            if(ifOnIM==false)
                logs=this.sanityCheckLayerResultMemSideSize(param,inputSize,true);
            else
                logs=this.sanityCheckLayerInputMemSideSize(param,inputSize,true);
            end
        end

        function logs=sanityCheckLayerOutputFeatureSize(this,param)
            outputSize=this.resolveOutputSizeLayer(param);
            [~,ofOnIM]=dnnfpga.processorbase.abstractProcessor.resolveMemoryDirection(param);
            if(ofOnIM==false)
                logs=this.sanityCheckLayerResultMemSideSize(param,outputSize,false);
            else
                logs=this.sanityCheckLayerInputMemSideSize(param,outputSize,false);
            end
        end

        function logs=sanityCheckLrnLocalSize(this,param)
            logs={};
            cc=this.getCC();

            lrnLocalSize=param.lrnLocalSize;
            lrnLocalSizeLimit=this.getCC.lrnLocalSizeLimit;
            if((lrnLocalSize>lrnLocalSizeLimit))
                logs=sprintf(' LRN Window Size (%s) is larger than the limit (%s).\n',mat2str(lrnLocalSize),mat2str(lrnLocalSizeLimit));
            elseif(lrnLocalSize<3)
                logs=sprintf(' LRN Window Size (%s) is smaller than the min limit (3).\n',mat2str(lrnLocalSize));
            end




            layerConfigNumWLimit=cc.layerConfigNumWLimit;
            lrnComputationWindowSize=cc.lrnCompWindowSize;
            lrnInputSize=[param.origImgSize(1:2);param.inputFeatureNum];
            if(isstruct(param))
                param.inputMemZAdapterActive=0;
                param1={param};
            else
                param1=param;
            end
            lrnCompTime=this.calLrnTime(this.resolveLC(param1));
            if((layerConfigNumWLimit>lrnCompTime)||(lrnLocalSize<3))
                logs=[logs,sprintf(' LRN input size (%s) is too small to compute using LRN window size (%s).',mat2str(lrnInputSize),mat2str(lrnComputationWindowSize))];
            end
        end
    end

    methods





        function tConv=calConvTime(this,lc,boardName,targetFrequency,burstLength,calData)

            this.weightloadingoffset=dnnfpga.estimate.EstimatorTransfer.getWeightLoadingOverhead(boardName,targetFrequency,burstLength,calData);




















            cc=this.getCC();









            tConv1=this.calPureConvTime(double(lc.resultSize),double(lc.convTileSize));



            tConv2=this.calConvTimePrivate2(double(cc.opSize),double(lc.convTileSize),cc.threadNumLimit,cc.threadNumLimitSquared,cc.opDDRRatio,this.weightloadingoffset);

            convKernelSize=3;
            if cc.kernelDataType=="single"
                tConv=max(tConv1,tConv2)+cc.ConvLatency;
            else
                tConv=max(tConv1,tConv2)+cc.ReducerLatency+convKernelSize;
            end
        end

        function tConv=calMaxpoolTime(this,lc)
            cc=this.getCC();

            computeLatency=this.calPureConvTime(double(lc.resultSize),double(lc.convTileSize));

            convKernelSize=3;

            if cc.kernelDataType=="single"
                tConv=computeLatency+cc.ConvLatency;
            else
                tConv=computeLatency;
            end
        end

        function tConv=calUnpoolTime(this,lc,boardName,targetFrequency,burstLength,calData)

            this.weightloadingoffset=dnnfpga.estimate.EstimatorTransfer.getWeightLoadingOverhead(boardName,targetFrequency,burstLength,calData);
            cc=this.getCC();


            tConv1=this.calPureUnpoolTime(double(lc.resultSize),double(lc.convTileSize));




            tConv2=this.calConvTimePrivate2(double(cc.opSize),double(lc.convTileSize),cc.threadNumLimit,cc.threadNumLimitSquared,cc.opDDRRatio,this.weightloadingoffset);

            convKernelSize=3;
            if cc.kernelDataType=="single"
                tConv=max(tConv1,tConv2)+cc.ConvLatency;
            else
                tConv=max(tConv1,tConv2)+cc.ReducerLatency+convKernelSize;
            end
        end

        function tConv=calLrnTime(this,lc)
            cc=this.getCC();


            DataAddrLatency=cc.DataMemReadLatency+cc.CONV_TRANS_CTRL_LATENCY+2*cc.PipelineLatency;

            computePathDelay=cc.ProdLatency*3+cc.SumLatency*5+cc.ExpLatency+cc.LogLatency...
            +cc.DivideLatency+double(lc.lrnLocalSize)-double(ceil(lc.lrnLocalSize/2));
            totalLatency=DataAddrLatency+computePathDelay;
            convOpSize=double(lc.convOpSize);
            imgSizeDivByOpW=double(lc.imgSizeDivByOpW);

            tConv=((prod(imgSizeDivByOpW)*prod(convOpSize)/cc.lrnCompWindowSize)*double(lc.lrnFeaturePadding))+totalLatency;

        end

        function tConv=calInputTime(this,params)
            tConv=this.resolveInputSize(params)+7;
        end
    end

    methods(Access=protected,Static=true)
        function tConv=calConvTimePrivate2(opSize,convTileSize,threadNumLimit,threadNumLimitSquared,opDDRRatio,weightloadingoffset)


            convExtra=20;
            weigthLength=prod(opSize);
            tAtomicConv=weigthLength*threadNumLimitSquared+threadNumLimit+convExtra;

            tConv=prod(convTileSize)*(tAtomicConv/opDDRRatio+weightloadingoffset);
        end

        function tConv=calPureConvTime(resultSize,convTileSize)

            convExtra=4;
            atomicConvSize=resultSize;
            tAtomicConv=prod(atomicConvSize)+convExtra;
            tConv=prod(convTileSize)*tAtomicConv;
        end

        function tConv=calPureUnpoolTime(resultSize,convTileSize)

            convExtra=4;













            tConv=prod(resultSize)*convTileSize(4)...
            +prod(convTileSize)*convExtra;
        end

        function active=inputMemZAdapterActivePredCore(threadNumLimit,convSplitMode,featureNum)
            if(~convSplitMode)
                if(featureNum<=floor(threadNumLimit/2))
                    active=true;
                else
                    active=false;
                end
            else
                active=false;
            end
        end
    end

    methods(Access=public,Static=true)



        function img=makeInputSquare(img)
            [H,W,C]=size(img);
            if H==W
                return
            end

            if(H>W)
                img=[img,zeros(H,H-W,C)];
            else
                img=[img;zeros(W-H,W,C)];
            end
        end

        function[paddedImg,seqImg]=preprocessImage(input,inputFeatureNum,inputFeatureNumToPadForSplit,origImgSize,opSize,threadNumLimit,convSplitMode,zAddrLimit)
            input=dnnfpga.processorbase.conv2Processor.padInputForSplit(input,inputFeatureNum,inputFeatureNumToPadForSplit);
            importedImg=dnnfpga.convbase.importImage(input);
            [paddedImg,linearImg]=dnnfpga.processorbase.conv2Processor.setupCosimImage(importedImg,...
            inputFeatureNum+inputFeatureNumToPadForSplit,origImgSize,opSize,...
            threadNumLimit,convSplitMode);
            paddedImgSize=[size(paddedImg,2);size(paddedImg,3);1];
            paddingImgSize=mod(-paddedImgSize,opSize);
            paddedImgSize=paddedImgSize+paddingImgSize;
            seqImgT=dnnfpga.processorbase.conv2Processor.seqImage(linearImg,inputFeatureNum+inputFeatureNumToPadForSplit,paddedImgSize,opSize,threadNumLimit);
            seqImg=dnnfpga.processorbase.conv2Processor.foldToSpareThreads(seqImgT,convSplitMode,inputFeatureNum,paddedImgSize,opSize,threadNumLimit,zAddrLimit);
        end

        function[top]=lrnLocal(bottom,localSize,alpha,beta,k)











            [W,H,N]=size(bottom);
            top=zeros(W,H,N);
            if(mod(localSize,2)==0)
                MinIdxLimit=floor(localSize/2)-1;
                MaxIdxLimit=floor(localSize/2);
            else
                MinIdxLimit=floor(localSize/2);
                MaxIdxLimit=floor(localSize/2);
            end
            temp_whn=zeros(W,H,N);
            for n=1:N
                nStart=max(n-MinIdxLimit,1);
                nEnd=min(n+MaxIdxLimit,N);
                temp_whn(:,:,n)=sum(bottom(:,:,nStart:nEnd).^2,3);
            end
            w=1:W;
            h=1:H;
            n=1:N;
            top(w,h,n)=bottom(w,h,n)./...
            ((k+alpha/localSize*temp_whn(w,h,n)).^beta);
        end

        function seqImg=getSeqImage(input,inputFeatureNum,inputFeatureNumToPadForSplit,origImgSize,opSize,threadNumLimit,convSplitMode,zAddrLimit,paddingSelect)
            imgCount=size(input,4);
            seqImg=[];
            for i=1:imgCount


                inputTemp=input(:,:,:,i);
                if(paddingSelect==0)
                    seqImgTemp=dnnfpga.processorbase.conv2Processor.generateCameraCompatibleImage(inputTemp);
                else
                    [~,seqImgTemp]=dnnfpga.processorbase.conv2Processor.preprocessImage(inputTemp,inputFeatureNum,inputFeatureNumToPadForSplit,origImgSize,opSize,threadNumLimit,convSplitMode,zAddrLimit);
                end
                seqImg=cat(2,seqImg,seqImgTemp');
            end
        end

        function seqLC=seqLayerConfig(lcs,storedType,lcParam)



            lcParam=cell2mat(lcParam);
            fieldNames={lcParam.name};
            seqLC=eval([storedType,'([])']);
            for i=1:length(lcs)
                temp=eval([storedType,'([])']);
                lc=lcs(i);
                sum=1;
                for j=1:length(fieldNames)
                    fd=fieldNames{j};
                    vals=lc.(fd);

                    sum=sum+numel(vals);
                    for k=1:numel(vals)
                        val=vals(k);
                        sval=dnnfpga.processorbase.conv2Processor.tc(val,storedType);
                        temp(end+1)=sval;

                    end

                end

                seqLC=[seqLC,flip(temp)];
            end
        end

        function lc=typeLayerConfig(cc,layerConfig)
            lc.activeFIFOEn=logical(layerConfig.activeFIFOEn);
            lc.activeFIFOMemSel=logical(layerConfig.activeFIFOMemSel);
            lc.memDirection=logical(layerConfig.memDirection);
            lc.convMode=fi(layerConfig.convMode,0,cc.layerModeNumWLimit,0);
            lc.strideMode=fi(layerConfig.strideMode,0,cc.strideModeAddrW,0);
            lc.reLUMode=fi(layerConfig.reLUMode,0,3,0);
            lc.paddingMode=fi(layerConfig.paddingMode,0,cc.paddingModeAddrW,0);
            lc.halfInputFeatureNum=fi(layerConfig.halfInputFeatureNum,0,ceil(log2(max(cc.featureSizeLimit)))-1,0);
            lc.halfOutputFeatureNum=fi(layerConfig.halfOutputFeatureNum,0,ceil(log2(max(cc.featureSizeLimit)))-1,0);
            lc.convTileSize=fi(layerConfig.convTileSize,0,ceil(log2(max(cc.superConvolutionSizeLimit)))+1,0);
            lc.convTileThreadExpansionSize=fi(layerConfig.convTileThreadExpansionSize,0,ceil(log2(max(cc.superConvolutionSizeLimit)))+1,0);
            lc.convImgSize=fi(layerConfig.convImgSize,0,ceil(log2(max(cc.imgSizeLimit)))+1,0);
            lc.convOpSize=fi(layerConfig.convOpSize,0,ceil(log2(max(cc.origOpSizeLimit)))+1,0);
            lc.leftMemSize=fi(layerConfig.leftMemSize,0,cc.dataMemAddrW+1,0);
            lc.rightMemSize=fi(layerConfig.rightMemSize,0,cc.dataMemAddrW+1,0);

            lc.stride=fi(layerConfig.stride,0,cc.strideModeWLimit,0);
            lc.padding=fi(layerConfig.padding,0,cc.paddingModeWLimit,0);
            lc.dilation=fi(layerConfig.dilation,0,cc.dilationModeWLimit,0);
            lc.finalWriteSize=fi(layerConfig.finalWriteSize,0,cc.imgAddrW,0);
            lc.firstWritePos=fi(layerConfig.firstWritePos,0,cc.imgAddrW,0);
            lc.resultSize=fi(layerConfig.resultSize,0,cc.imgAddrW,0);
            lc.resultSizeDivByOpW=fi(layerConfig.resultSizeDivByOpW,0,cc.zAddrW,0);
            lc.resultSizeDivByOpWSquared=fi(layerConfig.resultSizeDivByOpWSquared,0,cc.zAddrW*2,0);
            lc.imgSize=fi(layerConfig.imgSize,0,cc.imgAddrW,0);
            lc.imgSizeDivByOpW=fi(layerConfig.imgSizeDivByOpW,0,cc.zAddrW,0);
            lc.imgSizeDivByOpWSquared=fi(layerConfig.imgSizeDivByOpWSquared,0,cc.zAddrW*2,0);
            lc.xy0=fi(layerConfig.xy0,1,cc.zAddrW+1,0);
            lc.rxy0=fi(layerConfig.rxy0,1,cc.imgAddrW+1,0);
            lc.wAddr0=fi(layerConfig.wAddr0,0,1,0);
            lc.dw=fi(layerConfig.dw,0,ceil(log2(cc.dwLimit)),0);
            lc.dr=fi(layerConfig.dr,0,ceil(log2(cc.drLimit)),0);
            lc.dz=fi(layerConfig.dz,0,ceil(log2(cc.dzLimit)),0);
            lc.rzLimitOriginal=fi(layerConfig.rzLimitOriginal,1,cc.imgAddrW+1,0);

            lc.lrnLocalSize=fi(layerConfig.lrnLocalSize,0,ceil(log2(max(cc.superConvolutionSizeLimit*cc.threadNumLimit)))+1,0);
            lc.lrnAlpha=fi(typecast(single(layerConfig.lrnAlpha),'uint32'),0,32,0);
            lc.lrnBeta=fi(typecast(single(layerConfig.lrnBeta),'uint32'),0,32,0);
            lc.lrnK=fi(typecast(single(layerConfig.lrnK),'uint32'),0,32,0);



            lc.lrnFeaturePadding=fi(layerConfig.lrnFeaturePadding,0,10,0);
            lc.convOutputFeature=fi(layerConfig.convOutputFeature,0,10,0);
            lc.lrnPadddingSize=fi(layerConfig.lrnPadddingSize,0,10,0);
            lc.inputMemZAdapterActive=fi(layerConfig.inputMemZAdapterActive,0,1,0);
            lc.accumulateRightMem=fi(layerConfig.accumulateRightMem,0,1,0);

            lc.convTileSizeMinusOne=fi(layerConfig.convTileSizeMinusOne,0,ceil(log2(max(cc.superConvolutionSizeLimit)))+1,0);
            lc.convTileSizeMinusTwo=fi(layerConfig.convTileSizeMinusTwo,0,ceil(log2(max(cc.superConvolutionSizeLimit)))+1,0);
            lc.convOpSizePlusPaddingSizeMinusOne=fi(layerConfig.convOpSizePlusPaddingSizeMinusOne,1,7,0);
            lc.convImgSizeMinusOne=fi(layerConfig.convImgSizeMinusOne,0,ceil(log2(max(cc.imgSizeLimit)))+1,0);
            lc.convImgSizeMinusOpSizePlusTwoPaddingSize=fi(layerConfig.convImgSizeMinusOpSizePlusTwoPaddingSize,0,10,0);
            lc.int8ToSingleExp=fi(layerConfig.int8ToSingleExp,1,8,0);
            lc.singleToInt8Exp=fi(layerConfig.singleToInt8Exp,1,8,0);
            lc.int32ToInt8Exp=fi(layerConfig.int32ToInt8Exp,1,8,0);
            lc.smallPoolLayerEn=fi(layerConfig.smallPoolLayerEn,1,8,0);

            if(strcmp(cc.kernelDataType,'single'))


                lc.avgpoolMultiplier=fi(typecast(single(layerConfig.avgpoolMultiplier),'uint32'),0,32,0);
            else


                lc.avgpoolMultiplier=fi(typecast(int32(layerConfig.avgpoolMultiplier),'uint32'),0,32,0);
            end
            lc.convReLUValue=fi(typecast(single(layerConfig.convReLUValue),'uint32'),0,32,0);
            lc.reLUScaleExp=fi(layerConfig.reLUScaleExp,1,8,0);
            if~isfield(layerConfig,'weightBaseAddrOffset')
                layerConfig.weightBaseAddrOffset=0;
            end

            lc.IndexActsSelectorOffsetInit=fi(layerConfig.IndexActsSelectorOffsetInit,0,cc.convIndexActsSelectorOffsetAddrW,0);
            lc.IndexActsDimensionalOffsetsInit=fi(layerConfig.IndexActsDimensionalOffsetsInit,0,cc.convIndexActsSelectorOffsetAddrW,0);

            lc.isMaxpoolIndexLeg=fi(layerConfig.isMaxpoolIndexLeg,0,1,0);

            lc.fullFeatureSize=fi(typecast(int32(layerConfig.fullFeatureSize),'uint32'),0,32,0);
            lc.fullColumnsSize=fi(typecast(int32(layerConfig.fullColumnsSize),'uint32'),0,32,0);
            lc.weightBaseAddrOffset=fi(typecast(int32(layerConfig.weightBaseAddrOffset),'uint32'),0,32,0);
            lc.nextTileOffset=fi(typecast(int32(layerConfig.nextTileOffset),'uint32'),0,32,0);
        end

        function[paddedImg,linearImg]=setupCosimImage(img,...
            inputFeatureNum,origImgSize,opSize,...
            threadNum,convSplitMode)

            if(~convSplitMode)
                inputFeatureNumPaddedForThread=dnnfpga.convbase.roundup(inputFeatureNum,threadNum);
                [paddedImg,linearImg]=dnnfpga.processorbase.conv2Processor.setupCosimImagePrivate(img,...
                inputFeatureNum,origImgSize,opSize,...
                inputFeatureNumPaddedForThread);
            else
                if(convSplitMode==2)
                    inputFeatureNumPaddedForThread=dnnfpga.convbase.roundup(inputFeatureNum/2,threadNum);
                    halfFeatureNum=floor(size(img,3)/2);
                    [paddedImg1,linearImg1]=dnnfpga.processorbase.conv2Processor.setupCosimImagePrivate(img(:,:,1:halfFeatureNum),...
                    inputFeatureNum/2,origImgSize,opSize,...
                    inputFeatureNumPaddedForThread);
                    [paddedImg2,linearImg2]=dnnfpga.processorbase.conv2Processor.setupCosimImagePrivate(img(:,:,halfFeatureNum+1:end),...
                    inputFeatureNum/2,origImgSize,opSize,...
                    inputFeatureNumPaddedForThread);
                    paddedImg=[paddedImg1;paddedImg2];
                    linearImg=[linearImg1,linearImg2];
                else
                    inputFeatureNumPaddedForThread=dnnfpga.convbase.roundup(inputFeatureNum,threadNum);
                    [paddedImg,linearImg]=dnnfpga.processorbase.conv2Processor.setupCosimImagePrivate(img,...
                    inputFeatureNum,origImgSize,opSize,...
                    inputFeatureNumPaddedForThread);
                end

            end
        end

        function seqImg=seqImage(imgLinear,inputFeatureNum,imgSize,opSize,threadNumLimit)



            seqImg=[];
            bSize=imgSize(1)*imgSize(2);
            for ifIdx=0:threadNumLimit:inputFeatureNum-1
                if(ifIdx+threadNumLimit>inputFeatureNum)
                    x=[imgLinear(ifIdx*bSize+1:inputFeatureNum*bSize),zeros(1,(ifIdx+threadNumLimit-inputFeatureNum)*bSize)];
                else
                    x=imgLinear(ifIdx*bSize+1:(ifIdx+threadNumLimit)*bSize);
                end
                y=reshape(x,[imgSize(1),imgSize(2),threadNumLimit]);
                z=[];
                ibx=0:opSize(1)-1;
                iby=0:opSize(2)-1;
                for i=0:opSize(1):imgSize(1)-1
                    for j=0:opSize(2):imgSize(2)-1
                        temp(ibx+1,iby+1,:)=y(i+ibx+1,j+iby+1,:);
                        z=reshape(temp,[1,prod(opSize)*threadNumLimit]);
                        seqImg=[seqImg,z];
                    end
                end
            end
        end

        function seqImg=foldToSpareThreads(seqImgT,convSplitMode,inputFeatureNum,paddedImgSize,opSize,threadNumLimit,zAddrLimit)
            if(~dnnfpga.processorbase.conv2Processor.inputMemZAdapterActivePredCore(threadNumLimit,convSplitMode,inputFeatureNum))
                seqImg=seqImgT;
            else
                zDepth=numel(seqImgT)/(opSize(1)*opSize(2)*threadNumLimit);
                if(zDepth<=zAddrLimit)
                    seqImg=seqImgT;
                else
                    paddedImg=reshape(seqImgT,[opSize(1),opSize(2),threadNumLimit,zDepth]);
                    for i=zAddrLimit+1:size(paddedImg,4)
                        assert(inputFeatureNum<=threadNumLimit/2);
                        paddedImg(:,:,floor(threadNumLimit/2)+1:floor(threadNumLimit/2)*2,i-zAddrLimit)=paddedImg(:,:,1:floor(threadNumLimit/2),i);
                        paddedImg(:,:,1:floor(threadNumLimit/2),i)=single(zeros(opSize(1),opSize(2),floor(threadNumLimit/2),1));
                    end
                    seqImg=reshape(paddedImg(:,:,:,1:zAddrLimit),[1,numel(paddedImg(:,:,:,1:zAddrLimit))]);
                end
            end
        end

        function seqImgT=unfoldToSpareThreads(seqImg,inputFeatureNum,paddedImgSize,opSize,threadNumLimit,zAddrLimit)
            if(inputFeatureNum>threadNumLimit/2)
                seqImgT=seqImg;
            else
                zDepth=numel(seqImg)/(opSize(1)*opSize(2)*threadNumLimit);
                if(zDepth<zAddrLimit)
                    seqImgT=seqImg;
                else
                    paddedImg=single(zeros(opSize(1),opSize(2),threadNumLimit,paddedImgSize/opSize(1)*paddedImgSize/opSize(2)));
                    rr=reshape(seqImg,[opSize(1),opSize(2),threadNumLimit,zDepth]);
                    for i=1:size(paddedImg,4)
                        assert(inputFeatureNum<=threadNumLimit/2);
                        if(i<=zAddrLimit)
                            paddedImg(:,:,1:floor(threadNumLimit/2),i)=rr(:,:,1:floor(threadNumLimit/2),i);
                        else
                            paddedImg(:,:,1:floor(threadNumLimit/2),i)=rr(:,:,floor(threadNumLimit/2)+1:floor(threadNumLimit/2)*2,i-zAddrLimit);
                        end
                    end
                    seqImgT=reshape(paddedImg,[1,numel(paddedImg)]);
                end
            end
        end

        function linear=unfoldForThreadKernel(folded,threadNumLimit,opW,outputFeatureNum,resultSize)
            cmpL=numel(folded);
            resultSizeDivByOpW=ceil(double(resultSize)/opW);

            rr=reshape(folded,[double(opW),double(opW),double(threadNumLimit),double(resultSizeDivByOpW(2)),double(resultSizeDivByOpW(1)),double(outputFeatureNum)]);
            rrr=permute(rr,[1,5,2,4,3,6]);
            paddedResultSize=double(resultSizeDivByOpW*opW);
            rrrr=reshape(rrr,double([paddedResultSize',cmpL/prod(paddedResultSize)]));
            resultSize=double(resultSize);
            rrrrr=rrrr(1:resultSize(1),1:resultSize(2),1:outputFeatureNum*threadNumLimit);
            linear=reshape(rrrrr,1,numel(rrrrr));
        end








        function seqImg_temp2=generateCameraCompatibleImage(data)
            data=dnnfpga.processorbase.conv2Processor.makeInputSquare(data);


            temp2=data;
            temp=fi(temp2,0,32,0);
            tempD=bitshift(temp(:,:,3),-8);
            tempC=bitshift(temp(:,:,3),24);
            tempB=bitshift(temp(:,:,2),12);
            tempA=bitshift(temp(:,:,1),0);

            [w,h,~]=size(temp);

            formatted_imageA(:,:)=uint32(bitor(tempC,bitor(tempB,tempA)));
            formatted_imageB(:,:)=uint32(tempD);

            seqImg_tempA=reshape(formatted_imageA,1,w*h);
            seqImg_tempB=reshape(formatted_imageB,1,w*h);
            seqImg_temp2=uint32(zeros(1,w*h*2));

            for i=0:w*h-1
                seqImg_temp2(i*2+1)=seqImg_tempA(i+1);
                seqImg_temp2(i*2+1+1)=seqImg_tempB(i+1);
            end
        end






        function val=determinePaddingType(param,numberOfThreads,meanSubtraction)
            if(numberOfThreads<param.inputFeatureNum...
                ||param.origImgSize(1)~=param.origImgSize(2)...
                ||param.inputFeatureNum~=3...
                ||meanSubtraction)
                val=1;
            else
                val=0;
            end
        end

        function resultSize=getResultSize(imgSize,opSize,padding,stride,stridePhase,dilationMode)
            if(numel(padding)==1)
                padding=ones(1,4)*padding;
            end
            paddedImgSize=imgSize(1:2)+[padding(1)+padding(2);padding(3)+padding(4)]-stridePhase;


            if(opSize(1)==opSize(2))
                opW=opSize(1);
                dilation=dilationMode(1);



                dilatedOpSize=opW+(dilation-1)*(opW-1);
                resultSize=ceil((paddedImgSize-dilatedOpSize+1)/stride);
            else


                opH=opSize(1);
                opW=opSize(2);

                dilation=dilationMode(1);
                dilatedOpSizeW=opW+(dilation-1)*(opW-1);
                dilatedOpSizeH=opH+(dilation-1)*(opH-1);
                resultSize(1)=ceil((paddedImgSize(1)-dilatedOpSizeH+1)/stride);
                resultSize(2)=ceil((paddedImgSize(2)-dilatedOpSizeW+1)/stride);
                resultSize=resultSize';
            end
        end

    end

    methods(Access=protected,Static=true)
        function[x,xSize]=calBaseline(param,paddedImg,paddedOp,paddedBias,inputFeatureNum,outputFeatureNum,finalWriteSize,strideMode,stridePhase,reLUMode,convSplitMode,paddingMode,dilationMode,reLUValue,reLUScaleExp)

            if(isfi(paddedImg))
                xfi=fi(0,1,param.WLA,param.fiMath.SumFractionLength,param.fiMath);
            else
                xfi=[];
            end
            coder.varsize('x');
            if(convSplitMode==0)
                [x,xSize]=dnnfpga.processorbase.conv2Processor.calBaselineImpl(xfi,paddedImg,paddedOp,paddedBias,1,inputFeatureNum,1,outputFeatureNum,outputFeatureNum,finalWriteSize,strideMode,stridePhase,reLUMode,paddingMode,dilationMode,reLUValue,reLUScaleExp);
            elseif(convSplitMode>2)
                paddedImgSize=size(paddedImg);
                paddedOpSize=size(paddedOp);
                resultImgSize=dnnfpga.processorbase.conv2Processor.getResultSize(paddedImgSize(2:3)',paddedOpSize(3:4),paddingMode,strideMode,stridePhase,dilationMode);
                if(isinteger(paddedImg))

                    x=int32(zeros([1,resultImgSize(1),resultImgSize(2),outputFeatureNum]));
                    xSize=int32(zeros([outputFeatureNum,resultImgSize(1),resultImgSize(2)]));
                elseif(isfi(paddedImg))
                    x=zeros([1,resultImgSize(1),resultImgSize(2),outputFeatureNum],'like',xfi);
                    xSize=zeros([outputFeatureNum,resultImgSize(1),resultImgSize(2)]);
                else
                    x=zeros([1,resultImgSize(1),resultImgSize(2),outputFeatureNum]);
                    xSize=zeros([outputFeatureNum,resultImgSize(1),resultImgSize(2)]);
                end
                for i=1:convSplitMode
                    if(isscalar(reLUValue))
                        x(:,:,:,i)=dnnfpga.processorbase.conv2Processor.calBaselineImpl(xfi,paddedImg(i,:,:),paddedOp(i,1,:,:),paddedBias(i,:),1,1,1,1,1,finalWriteSize,strideMode,stridePhase,reLUMode,paddingMode,dilationMode,reLUValue,reLUScaleExp);
                    else
                        x(:,:,:,i)=dnnfpga.processorbase.conv2Processor.calBaselineImpl(xfi,paddedImg(i,:,:),paddedOp(i,1,:,:),paddedBias(i,:),1,1,1,1,1,finalWriteSize,strideMode,stridePhase,reLUMode,paddingMode,dilationMode,reLUValue(i),reLUScaleExp);
                    end
                end
            else
                [x1,x1Size]=dnnfpga.processorbase.conv2Processor.calBaselineImpl(xfi,paddedImg,paddedOp,paddedBias,1,inputFeatureNum/2,1,outputFeatureNum/2,outputFeatureNum,finalWriteSize,strideMode,stridePhase,reLUMode,paddingMode,dilationMode,reLUValue,reLUScaleExp);
                [x2,x2Size]=dnnfpga.processorbase.conv2Processor.calBaselineImpl(xfi,paddedImg,paddedOp,paddedBias,inputFeatureNum/2+1,inputFeatureNum,outputFeatureNum/2+1,outputFeatureNum,outputFeatureNum,finalWriteSize,strideMode,stridePhase,reLUMode,paddingMode,dilationMode,reLUValue,reLUScaleExp);
                x=coder.nullcopy(x1);
                x(:)=x1+x2;
                assert(isequal(x1Size,x2Size));
                xSize=x1Size;
            end
        end

        function output=calBaselineTransposedConv(param,input)
            outputSize=param.outputSize;
            transformedStride=size(param.weights);

            assert(transformedStride(1)==transformedStride(2));
            if(transformedStride(1)>1)

                zeroPositionsRows=[];
                for i=2:outputSize(1)
                    if(mod(i,transformedStride(1))~=1)
                        zeroPositionsRows=[zeroPositionsRows,i];
                    end
                end

                zeroPositionsCols=[];
                for i=2:outputSize(2)
                    if(mod(i,transformedStride(1))~=1)
                        zeroPositionsCols=[zeroPositionsCols,i];
                    end
                end


                tmp=ones(outputSize);
                tmp(zeroPositionsRows,:,:)=0;
                tmp(:,zeroPositionsCols,:)=0;
                tmp(logical(tmp))=input;
            else

                tmp=input;
            end
            output=tmp;
        end

        function[x,xSize]=calBaselineImpl(xfi,paddedImg,paddedOp,paddedBias,ifStart,ifEnd,ofStart,ofEnd,outputFeatureNum,finalWriteSize,strideMode,stridePhase,reLUMode,paddingMode,dilationMode,reLUValue,reLUScaleExp)
            paddedImgSize=size(paddedImg);
            paddedOpSize=size(paddedOp);
            paddedBiasSize=size(paddedBias);
            coder.varsize('paddedOpSize');
            assert(paddedOpSize(2)==paddedBiasSize(1));


            if(numel(paddedOpSize)==2)
                paddedOpSize(3)=1;
                paddedOpSize(4)=1;
            end


            coder.varsize('paddedImgSize');
            if(numel(paddedImgSize)==2)
                paddedImgSize(3)=1;
            end


            if(numel(paddedOpSize)==3)


                paddedOpSize(4)=1;
            end


            resultImgSize=dnnfpga.processorbase.conv2Processor.getResultSize(paddedImgSize(2:3)',paddedOpSize(3:4),paddingMode,strideMode,stridePhase,dilationMode);
            xSize=[outputFeatureNum,resultImgSize'];
            if(isinteger(paddedOp))

                paddedImg=int32(paddedImg);
                paddedOp=int32(paddedOp);
                paddedBias=int32(paddedBias);
                x=zeros(xSize,'int32');
                temp_out=zeros(xSize,'int32');
            elseif(isfi(paddedOp))
                x=zeros((xSize),'like',xfi);
                temp_out=zeros((xSize),'like',xfi);
            else
                x=zeros((xSize),'single');
                temp_out=zeros((xSize),'single');
            end
            for i=ifStart:ifEnd
                a=reshape(paddedImg(i,:,:),[size(paddedImg,2),size(paddedImg,3)]);
                for j=ofStart:ofEnd
                    b=reshape(paddedOp(i,j,:,:),[size(paddedOp,3),size(paddedOp,4)]);
                    xT=dnnfpga.processorbase.conv2Processor.baseline(xfi,a,b,paddingMode,strideMode,stridePhase,dilationMode);
                    temp_out(j,:,:)=xT;
                end
                x=x+temp_out;
            end
            for j=ofStart:ofEnd
                x(j,1:finalWriteSize(1),1:finalWriteSize(2))=x(j,1:finalWriteSize(1),1:finalWriteSize(2))+paddedBias(j);
            end
            if(reLUMode)
                x=dnnfpga.processorbase.conv2Processor.reLUOutput(reLUMode,paddedOp,x,reLUValue,reLUScaleExp);
            end

        end
        function reLUResults=reLUOutput(reLUMode,paddedOp,reLUInput,reLUValue,reLUScaleExp)
            if(reLUMode==3)
                if(isinteger(paddedOp))
                    reLUResults=(reLUInput.*int32(reLUInput<0)*(0)+int32(reLUInput>=reLUValue)*int32(reLUValue)+reLUInput.*int32(reLUInput>0&(reLUInput<reLUValue))*1);
                else
                    reLUResults=(reLUInput.*(reLUInput<0)*(0)+(reLUInput>=reLUValue)*(reLUValue)+reLUInput.*((reLUInput>0&reLUInput<reLUValue))*1);
                end
            else
                if(isinteger(paddedOp))


                    reLUResults=((reLUInput.*int32(int32(reLUInput<0)*int32(reLUValue)))*2^(double(reLUScaleExp)))+(reLUInput.*(int32(reLUInput>=0)*(1)));
                else
                    reLUResults=reLUInput.*((reLUInput<0)*(reLUValue)+(reLUInput>=0)*(1));
                end
            end
        end

        function results=baseline(xfi,img,weights,padding,stride,stridePhase,dilationMode)
            paddedImg=dnnfpga.assembler.padImage(img,[padding(1),padding(3)],'pre');

            paddedImg=dnnfpga.assembler.padImage(paddedImg,[padding(2),padding(4)],'post');
            opH=size(weights,1);
            opW=size(weights,2);

            dilation=dilationMode(1);
            dilatedOpSizeH=opH+(dilation-1)*(opH-1);
            dilatedOpSizeW=opW+(dilation-1)*(opW-1);
            if(isfi(weights))
                dilatedWeights=zeros(dilatedOpSizeH,dilatedOpSizeW,'like',weights);
            else
                dilatedWeights=zeros(dilatedOpSizeH,dilatedOpSizeW);
            end
            for i=0:opH-1
                for j=0:opW-1
                    dilatedWeights(i*dilation+1,j*dilation+1)=weights(i+1,j+1);
                end
            end
            if(isinteger(img))

                paddedImg=int32(paddedImg);
                dilatedWeights=int32(dilatedWeights);
            end
            if(isfi(img))
                tempResults=dnnfpga.layer.conv2d(paddedImg,dilatedWeights,xfi);
            else
                tempResults=conv2(paddedImg,dilatedWeights,'valid');
            end
            xidx=1+stridePhase(1):stride:size(tempResults,1);
            yidx=1+stridePhase(2):stride:size(tempResults,2);
            results=tempResults(xidx,yidx);
            if(isinteger(img))

                results=int32(results);
            end
        end



        function[paddedOp,paddedBias,linearOp,linearBias]=setupCosimOpU(op,bias,...
            inputFeatureNum,outputFeatureNum,origOpSizeValue,convSplitMode,...
            inputFeatureSizeLimit,outputFeatureSizeLimit,origOpSizeLimit,dataExp)



            paddedOpSize=origOpSizeValue;

            paddedOp=[];
            linearOp=[];
            paddedBias=[];
            linearBias=[];
            if(~convSplitMode)
                [paddedOp,linearOp,paddedBias,linearBias]=dnnfpga.processorbase.conv2Processor.computeOpsU(op,bias,...
                inputFeatureSizeLimit,outputFeatureSizeLimit,inputFeatureNum,outputFeatureNum,...
                paddedOpSize,origOpSizeLimit,origOpSizeValue,1,inputFeatureNum,1,outputFeatureNum,convSplitMode,dataExp);
            elseif(convSplitMode>2)


                [paddedOp,linearOp,paddedBias,linearBias]=dnnfpga.processorbase.conv2Processor.computeOpsU(op,bias,...
                inputFeatureSizeLimit,1,inputFeatureNum,1,...
                paddedOpSize,origOpSizeLimit,origOpSizeValue,1,inputFeatureNum,1,1,convSplitMode,dataExp);
            elseif(convSplitMode==2)
                [paddedOp0,opLinear0,paddedBias0,biasLinear0]=dnnfpga.processorbase.conv2Processor.computeOpsU(op,bias,...
                inputFeatureSizeLimit,outputFeatureSizeLimit,inputFeatureNum,outputFeatureNum,...
                paddedOpSize,origOpSizeLimit,origOpSizeValue,1,inputFeatureNum/2,1,outputFeatureNum/2,convSplitMode,dataExp);
                [paddedOp1,opLinear1,paddedBias1,biasLinear1]=dnnfpga.processorbase.conv2Processor.computeOpsU(op,bias,...
                inputFeatureSizeLimit,outputFeatureSizeLimit,inputFeatureNum,outputFeatureNum,...
                paddedOpSize,origOpSizeLimit,origOpSizeValue,inputFeatureNum/2+1,inputFeatureNum,outputFeatureNum/2+1,outputFeatureNum,convSplitMode,dataExp);
                paddedOp=paddedOp0+paddedOp1;
                paddedBias=paddedBias0+paddedBias1;

                linearOp=opLinear0+opLinear1;
                linearBias=biasLinear0+biasLinear1;
            else
                assert(0);
            end
        end



        function[paddedOp,linearOp,paddedBias,linearBias]=computeOpsU(op,bias,...
            inputFeatureSizeLimit,outputFeatureSizeLimit,inputFeatureNum,outputFeatureNum,...
            paddedOpSize,origOpSizeLimit,origOpSizeValue,...
            ifStart,ifEnd,ofStart,ofEnd,convSplitMode,dataExp)
            paddedOp=[];





            origOpSizeValueMultipleOfThree=origOpSizeValue;
            origOpSizeValueMultipleOfThree(1:2)=ceil(origOpSizeValue(1:2)/3)*3;

            if(isinteger(op))
                paddedOp=zeros([inputFeatureNum,outputFeatureNum,origOpSizeValue(1:2)'],'int8');
                linearOp=zeros(1,inputFeatureNum*outputFeatureNum*prod(origOpSizeValueMultipleOfThree),'int8');
            elseif(isfi(op))
                paddedOp=zeros([inputFeatureNum,outputFeatureNum,origOpSizeValue(1:2)'],'like',op);
                linearOp=zeros(1,inputFeatureNum*outputFeatureNum*prod(origOpSizeValueMultipleOfThree),'like',op);
            else
                paddedOp=zeros([inputFeatureNum,outputFeatureNum,origOpSizeValue(1:2)'],'single');
                linearOp=zeros(1,inputFeatureNum*outputFeatureNum*prod(origOpSizeValueMultipleOfThree),'single');
            end
            if(isinteger(op))
                paddedOpForExternalMem=int8(zeros(origOpSizeValueMultipleOfThree(1:2)'))';
            elseif(isfi(op))
                paddedOpForExternalMem=zeros(origOpSizeValueMultipleOfThree(1:2)','like',op);
            else
                paddedOpForExternalMem=single(zeros(origOpSizeValueMultipleOfThree(1:2)'))';
            end





            for i=1:inputFeatureNum
                if(i>=ifStart&&i<=ifEnd)

                    for j=1:outputFeatureNum
                        if(j>=ofStart&&j<=ofEnd)
                            if(isempty(op))
                                operator=[];
                            else

                                operator=op(:,:,i,j);
                            end



                            [opP,opL]=dnnfpga.processorbase.conv2Processor.getOpU(operator,origOpSizeValue,paddedOpSize,origOpSizeValueMultipleOfThree,paddedOpForExternalMem);
                            paddedOp(i,j,:,:)=opP;

                            idx=((i-1)*outputFeatureNum+j-1)*prod(origOpSizeValueMultipleOfThree);
                            linearOp(idx+1:idx+prod(origOpSizeValueMultipleOfThree))=opL;
                        end
                    end
                end
            end

            if(isinteger(op))

                paddedBias=zeros([outputFeatureNum*2,1],'int32');
            elseif(isfi(op))
                paddedBias=zeros([outputFeatureNum*2,1],'like',bias);
            else
                paddedBias=zeros([outputFeatureNum,1],'single');
            end
            if(isscalar(dataExp))
                dataExp=repmat(dataExp,ofEnd,1);
                dataExp=int32(dataExp(:));
            else
                dataExp=int32(dataExp);
            end
            if(isempty(bias))
                paddedBias(ofStart:ofEnd)=dnnfpga.cosimbase.randNum([ofEnd-ofStart+1,1],[-1,+1]);
            else




                if(isinteger(op)||isfi(op))
                    if((ofStart==ofEnd)&&convSplitMode>2)
                        paddedBias(ifStart:2:ifEnd*2)=bias(ifStart:ifEnd);
                        paddedBias(ifStart+1:2:ifEnd*2)=dataExp(ifStart:ifEnd);
                    else
                        if(size(size(bias),2)>2)
                            bias=reshape(bias,[numel(bias),1]);
                        end
                        if(ofStart~=1)
                            paddedBias((ofStart-1)*2+1:2:ofEnd*2)=bias(ofStart:ofEnd);
                            paddedBias((ofStart-1)*2+2:2:ofEnd*2)=dataExp(ofStart:ofEnd);
                        else
                            paddedBias(ofStart:2:ofEnd*2)=bias(ofStart:ofEnd);
                            paddedBias(ifStart+1:2:ofEnd*2)=dataExp(ifStart:ofEnd);
                        end
                    end
                else
                    if((ofStart==ofEnd)&&convSplitMode>2)
                        paddedBias(ifStart:ifEnd)=bias(ifStart:ifEnd);
                    else
                        paddedBias(ofStart:ofEnd)=bias(ofStart:ofEnd);
                    end
                end




                if isrow(paddedBias)
                    paddedBias=paddedBias';
                end

                linearBias=paddedBias;
            end
        end









        function[paddedOp,opStream]=getOpU(op,origOpSizeValue,paddedOpSize,origOpSizeValueMultipleOfThree,paddedOpForExternalMem)
            assert(isequal(origOpSizeValue,paddedOpSize));
            if(isempty(op))
                op=dnnfpga.cosimbase.randNum(origOpSizeValue',[-1,+1]);
            end

            paddedOp=op;
            paddedOp=permute(paddedOp,(length(origOpSizeValue):-1:1));
            flipedOp=flip(flip(op,1),2);

            H=origOpSizeValue(1);
            W=origOpSizeValue(2);



            paddedOpForExternalMem(1:W,1:H)=flipedOp;

            paddedOpForExternalMem=permute(paddedOpForExternalMem,(length(origOpSizeValue):-1:1));
            opStream=reshape(paddedOpForExternalMem,1,prod(origOpSizeValueMultipleOfThree));
        end


        function input=padInputForSplit(input,inputFeatureNum,inputFeatureNumToPadForSplit)
            if(inputFeatureNumToPadForSplit>0)
                halfInputFeatureNum=inputFeatureNum/2;
                halfInputFeatureNumToPad=inputFeatureNumToPadForSplit/2;

                if(isinteger(input))
                    imgPadding=int32(zeros(size(input,1),size(input,2),halfInputFeatureNumToPad));
                    newInput=int32(zeros(size(input,1),size(input,2),inputFeatureNum+inputFeatureNumToPadForSplit));
                elseif(isfi(input))
                    imgPadding=zeros(size(input,1),size(input,2),halfInputFeatureNumToPad,'like',input);
                    newInput=zeros(size(input,1),size(input,2),inputFeatureNum+inputFeatureNumToPadForSplit,'like',input);
                else
                    imgPadding=zeros(size(input,1),size(input,2),halfInputFeatureNumToPad);
                    newInput=zeros(size(input,1),size(input,2),inputFeatureNum+inputFeatureNumToPadForSplit);
                end
                newInput(:,:,1:halfInputFeatureNum)=input(:,:,1:halfInputFeatureNum);
                newInput(:,:,halfInputFeatureNum+1:halfInputFeatureNum+halfInputFeatureNumToPad)=imgPadding;
                newInput(:,:,halfInputFeatureNum+halfInputFeatureNumToPad+1:inputFeatureNum+halfInputFeatureNumToPad)=input(:,:,halfInputFeatureNum+1:end);
                newInput(:,:,inputFeatureNum+halfInputFeatureNumToPad+1:end)=imgPadding;
                input=newInput;
            end
        end

        function ret=tc(val,type)
            val=dnnfpga.assembler.ConvtoUint32U(val);
            ret=typecast(val,type);
        end

        function[paddedImg,linearImg]=setupCosimImagePrivate(img,...
            inputFeatureNum,origImgSize,opSize,...
            inputFeatureNumPaddedForThread)

            paddedImg=[];
            linearImg=[];
            for i=1:inputFeatureNumPaddedForThread
                if(i<=inputFeatureNum)
                    image=img(:,:,i);
                    [imgP,imgL]=dnnfpga.processorbase.conv2Processor.getImg(image,origImgSize,opSize);
                    paddedImg=[paddedImg;imgP];
                else
                    imgL=ones(1,prod(origImgSize+mod(-origImgSize,opSize)))*-2;
                    paddedImg=[paddedImg;zeros(1,size(img,2),size(img,1))];
                end
                linearImg=[linearImg,imgL];
            end
            if(isfi(img))
                paddedImg=cast(paddedImg,'like',img);
                linearImg=cast(linearImg,'like',img);
            end
        end

        function[paddedImg,linearImg]=getImg(img,origImgSize,opSize)
            assert(isequal(size(img),flip(origImgSize(1:2))'));
            if(isinteger(img))
                img=img;
            else
                img=single(img);
            end
            paddedImg=img;


            paddedImg=permute(paddedImg,(length(origImgSize):-1:1));
            paddedImgForResultMem=dnnfpga.assembler.padImage(img,mod(-flip(origImgSize(1:2)),opSize(1:2))','post');
            paddedImgForResultMem=permute(paddedImgForResultMem,(length(origImgSize):-1:1));
            linearImg=reshape(paddedImgForResultMem,[1,numel(paddedImgForResultMem)]);
        end

        function[importedOp,importedBias]=importOperator(weights,bias,inputFeatureNum,outputFeatureNum,convSplitMode)
            [importedOp,importedBias]=dnnfpga.convbase.importOperator(weights,bias,inputFeatureNum,outputFeatureNum,convSplitMode);
        end

        function seqOp=seqOperator(opLinear,biasLinear,...
            inputFeatureNum,outputFeatureNum,threadNumLimit,...
            outputFeatureSizeLimit,...
            origOpSizeValue,opSize,origOpSizeLimit,convSplitMode,wxy0)


            if(convSplitMode>2)
                if(isinteger(opLinear))
                    seqOp=zeros(1,inputFeatureNum*outputFeatureNum*origOpSizeValue(1)*origOpSizeLimit(2),'int8');
                else
                    seqOp=zeros(1,1*outputFeatureNum*origOpSizeValue(1)*origOpSizeLimit(2),'single');
                end
            else
                if(isinteger(opLinear))
                    seqOp=zeros(1,inputFeatureNum*outputFeatureNum*origOpSizeValue(1)*origOpSizeLimit(2),'int8');
                else
                    seqOp=zeros(1,inputFeatureNum*outputFeatureNum*origOpSizeValue(1)*origOpSizeLimit(2),'single');
                end
            end

            if(convSplitMode==0)
                seqOp=dnnfpga.processorbase.conv2Processor.setOp(1,inputFeatureNum,1,outputFeatureNum,threadNumLimit,opLinear,biasLinear,outputFeatureNum,origOpSizeValue,opSize,origOpSizeLimit,wxy0,convSplitMode);
            elseif(convSplitMode>2)
                seqOp=dnnfpga.processorbase.conv2Processor.setOp(1,inputFeatureNum,1,1,threadNumLimit,opLinear,biasLinear,1,origOpSizeValue,opSize,origOpSizeLimit,wxy0,convSplitMode);
            elseif(convSplitMode==2)

                seqOp0=dnnfpga.processorbase.conv2Processor.setOp(1,inputFeatureNum/2,1,outputFeatureNum/2,threadNumLimit,opLinear,biasLinear,outputFeatureNum,origOpSizeValue,opSize,origOpSizeLimit,wxy0,convSplitMode);

                seqOp1=dnnfpga.processorbase.conv2Processor.setOp(inputFeatureNum/2+1,inputFeatureNum,outputFeatureNum/2+1,outputFeatureNum,threadNumLimit,opLinear,biasLinear,outputFeatureNum,origOpSizeValue,opSize,origOpSizeLimit,wxy0,convSplitMode);
                seqOp=[seqOp0,seqOp1];
            else
                assert(0);
            end
        end

        function seqOp=setOp(ifStart,ifEnd,ofStart,ofEnd,threadNumLimit,opLinear,biasLinear,outputFeatureSizeLimit,origOpSizeValue,opSize,origOpSizeLimit,wxy0,convSplitMode)
            cnt=1;






            origOpSizeValueMultipleOfThree=origOpSizeValue;
            origOpSizeValueMultipleOfThree(1:2)=ceil(origOpSizeValue(1:2)/3)*3;





            tileXEnd=ceil(origOpSizeValue(2)/opSize(1));
            tileYEnd=ceil(origOpSizeValue(1)/opSize(2));
            if(isinteger(biasLinear))

                biasFactor=8;
                biasLinearInt8=reshape(typecast(int32(biasLinear),'int8'),[size(biasLinear,1)*4,1]);
                if(mod(size(biasLinearInt8,1),threadNumLimit*biasFactor)~=0)
                    biasLinearInt8=[biasLinearInt8;zeros(mod(-size(biasLinearInt8,1),threadNumLimit*biasFactor),1)];
                end
            end











            mul_factor1=ceil(((ofEnd-ofStart)+1)/threadNumLimit)*ceil(((ifEnd-ifStart)+1)/threadNumLimit)*tileXEnd*tileYEnd;



            temp_mul_factor2=(opSize(2)*opSize(1)*threadNumLimit*threadNumLimit);

            if(isinteger(biasLinear))
                mul_factor2=temp_mul_factor2+(threadNumLimit*biasFactor);
            else
                mul_factor2=temp_mul_factor2+threadNumLimit;
            end


            temp_cnt=mul_factor1*mul_factor2;

            seqOp=zeros(1,temp_cnt,class(opLinear));







            for tileYIdx=1:tileYEnd
                for tileXIdx=1:tileXEnd

                    for ifIdx=ifStart:threadNumLimit:ifEnd


                        for ofIdx=ofStart:threadNumLimit:ofEnd

                            for othdIdx=0:threadNumLimit-1


                                for ithdIdx=0:threadNumLimit-1

                                    for opXIdx=1:opSize(1)
                                        for opYIdx=1:opSize(2)

                                            iiffIdx=ifIdx+ithdIdx;
                                            ooffIdx=ofIdx+othdIdx;




                                            if(iiffIdx>ifEnd||ooffIdx>ofEnd)
                                                seqOp(cnt)=0;
                                            else


                                                xBase=(tileXIdx-1)*opSize(1);
                                                yBase=(tileYIdx-1)*opSize(2);





                                                wxy=wxy0(opXIdx,opYIdx);


                                                opXIdxT=floor(double(wxy)/opSize(2))+1;
                                                opYIdxT=mod(double(wxy),opSize(2))+1;


                                                xAddr=xBase+opXIdxT-1;
                                                yAddr=yBase+opYIdxT-1;

                                                idx=1+yAddr+...
                                                origOpSizeValueMultipleOfThree(1)*(xAddr+...
                                                origOpSizeValueMultipleOfThree(2)*((ooffIdx-1)+...
                                                outputFeatureSizeLimit*(iiffIdx-1)));

                                                seqOp(cnt)=opLinear(idx);
                                            end
                                            cnt=cnt+1;
                                        end
                                    end
                                end
                            end

                            if(isinteger(biasLinear))


                                if(convSplitMode>2)
                                    biasLinearInt8_1toNLinear=biasLinearInt8((ifIdx-1)*biasFactor+1:(ifIdx+threadNumLimit-1)*biasFactor);
                                else
                                    biasLinearInt8_1toNLinear=biasLinearInt8((ofIdx-1)*biasFactor+1:(ofIdx+threadNumLimit-1)*biasFactor);
                                end



























                                for i=1:8:length(biasLinearInt8_1toNLinear)-1
                                    biasLinearInt8_1toN(i:i+7)=flip(biasLinearInt8_1toNLinear(i:i+7));
                                end
                                for othdIdx=0:threadNumLimit-1
                                    ooffIdx=ofIdx+othdIdx;
                                    if(ifIdx>ifEnd)
                                        seqOp(cnt:cnt+biasFactor-1)=zeros(biasFactor,1);
                                    else
                                        seqOp(cnt:cnt+biasFactor-1)=biasLinearInt8_1toN((othdIdx)*biasFactor+1:(othdIdx+1)*biasFactor);
                                    end
                                    cnt=cnt+biasFactor;

                                end
                            else

                                for othdIdx=0:threadNumLimit-1
                                    if~((ofStart==ofEnd)&&convSplitMode>2)

                                        ooffIdx=ofIdx+othdIdx;
                                        if(ooffIdx>ofEnd||ifIdx>ifEnd)
                                            seqOp(cnt)=0;
                                        else
                                            seqOp(cnt)=biasLinear(ooffIdx);
                                        end
                                    else


                                        ooffIdx=ifIdx+othdIdx;
                                        if(ooffIdx>numel(biasLinear))
                                            seqOp(cnt)=0;
                                        else
                                            seqOp(cnt)=biasLinear(ooffIdx);
                                        end
                                    end
                                    cnt=cnt+1;
                                end
                            end

                        end
                    end
                end
            end
            sizeofseqOp=size(seqOp);
            assert(isequal(temp_cnt,sizeofseqOp(2)),'size of seqOp doesnot match!');
        end

        function[output,param]=unpadForSplit(output,param)


            if(param.outputFeatureNumToPadForSplit>0)
                halfOutputFeatureNum=param.outputFeatureNum/2;
                halfOutputFeatureNumToPad=param.outputFeatureNumToPadForSplit/2;
                if(isinteger(output))

                    newOutput=int32(zeros(size(output,1),size(output,2),param.outputFeatureNum-param.outputFeatureNumToPadForSplit));
                else
                    newOutput=zeros(size(output,1),size(output,2),param.outputFeatureNum-param.outputFeatureNumToPadForSplit);
                end
                for ofIdx=1:halfOutputFeatureNum
                    if(ofIdx<=halfOutputFeatureNum-halfOutputFeatureNumToPad)
                        newOutput(:,:,ofIdx)=output(:,:,ofIdx);
                    else
                        assert(isequal(output(:,:,ofIdx),zeros(size(output,1),size(output,2))));
                    end
                end
                for ofIdx=halfOutputFeatureNum+1:param.outputFeatureNum
                    if(ofIdx<=param.outputFeatureNum-halfOutputFeatureNumToPad)
                        newOutput(:,:,ofIdx-halfOutputFeatureNumToPad)=output(:,:,ofIdx);
                    else
                        assert(isequal(output(:,:,ofIdx),zeros(size(output,1),size(output,2))));
                    end
                end
                output=newOutput;
                param.outputFeatureNum=param.outputFeatureNum-param.outputFeatureNumToPadForSplit;
            end
        end

        function[conv2Kernels,conv2Bias,param]=padOpForSplit(conv2Kernels,conv2Bias,param)




            [conv2Kernels,conv2Bias,param]=dnnfpga.processorbase.conv2Processor.padForSplitOnInput(conv2Kernels,conv2Bias,param);
            [conv2Kernels,conv2Bias,param]=dnnfpga.processorbase.conv2Processor.padForSplitOnOutput(conv2Kernels,conv2Bias,param);
        end

        function newWeights=padOpForSplitOnInput(conv2Kernels,inputFeatureNum,outputFeatureNum,paddingInputFeatureNum)
            newWeights=zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
            inputFeatureNum+paddingInputFeatureNum,outputFeatureNum);
            if(isfi(conv2Kernels))
                newWeights=cast(newWeights,'like','conv2Kernels');
            end
            for ifIdx=1:inputFeatureNum
                for ofIdx=1:outputFeatureNum
                    newWeights(:,:,ifIdx,ofIdx)=conv2Kernels(:,:,ifIdx,ofIdx);
                end
            end
        end

        function[conv2Kernels,conv2Bias,param]=padForSplitOnInput(conv2Kernels,conv2Bias,param)
            if(param.inputFeatureNumToPadForSplit>0)
                halfInputFeatureNum=param.inputFeatureNum/2;
                halfInputFeatureNumToPad=param.inputFeatureNumToPadForSplit/2;
                halfOutputFeatureNum=param.outputFeatureNum/2;


                if(param.convSplitMode)
                    if(isinteger(conv2Kernels))

                        newWeights=int32(zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        halfInputFeatureNum+halfInputFeatureNumToPad,param.outputFeatureNum));
                    else
                        newWeights=zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        halfInputFeatureNum+halfInputFeatureNumToPad,param.outputFeatureNum);
                    end
                    newWeights(:,:,:,1:halfOutputFeatureNum)=...
                    dnnfpga.processorbase.conv2Processor.padOpForSplitOnInput(conv2Kernels(:,:,:,1:halfOutputFeatureNum),...
                    halfInputFeatureNum,halfOutputFeatureNum,halfInputFeatureNumToPad);
                    newWeights(:,:,:,halfOutputFeatureNum+1:end)=...
                    dnnfpga.processorbase.conv2Processor.padOpForSplitOnInput(conv2Kernels(:,:,:,halfOutputFeatureNum+1:end),...
                    halfInputFeatureNum,halfOutputFeatureNum,halfInputFeatureNumToPad);
                else
                    if(isinteger(conv2Kernels))

                        newWeights=int32(zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        param.inputFeatureNum+param.inputFeatureNumToPadForSplit,param.outputFeatureNum));
                    elseif(isfi(conv2Kernels))
                        newWeights=zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        param.inputFeatureNum+param.inputFeatureNumToPadForSplit,param.outputFeatureNum,'like',conv2Kernels);
                    else
                        newWeights=zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        param.inputFeatureNum+param.inputFeatureNumToPadForSplit,param.outputFeatureNum);
                    end
                    newWeights(:,:,1:halfInputFeatureNum+halfInputFeatureNumToPad,:)=...
                    dnnfpga.processorbase.conv2Processor.padOpForSplitOnInput(conv2Kernels(:,:,1:halfInputFeatureNum,:),...
                    halfInputFeatureNum,param.outputFeatureNum,halfInputFeatureNumToPad);
                    newWeights(:,:,halfInputFeatureNum+halfInputFeatureNumToPad+1:end,:)=...
                    dnnfpga.processorbase.conv2Processor.padOpForSplitOnInput(conv2Kernels(:,:,halfInputFeatureNum+1:end,:),...
                    halfInputFeatureNum,param.outputFeatureNum,halfInputFeatureNumToPad);
                end
                conv2Kernels=newWeights;




                param.inputFeatureNum=param.inputFeatureNum+param.inputFeatureNumToPadForSplit;

            end
        end

        function newWeights=padOpForSplitOnOutput(conv2Kernels,inputFeatureNum,outputFeatureNum,paddingOutputFeatureNum)
            newWeights=zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
            inputFeatureNum,outputFeatureNum+paddingOutputFeatureNum);
            for ifIdx=1:inputFeatureNum
                for ofIdx=1:outputFeatureNum
                    newWeights(:,:,ifIdx,ofIdx)=conv2Kernels(:,:,ifIdx,ofIdx);
                end
            end
        end

        function[conv2Kernels,conv2Bias,param]=padForSplitOnOutput(conv2Kernels,conv2Bias,param)
            if(param.outputFeatureNumToPadForSplit>0)
                halfInputFeatureNum=param.inputFeatureNum/2;
                halfOutputFeatureNum=param.outputFeatureNum/2;
                halfOutputFeatureNumToPad=param.outputFeatureNumToPadForSplit/2;



                if(param.convSplitMode)
                    if(isinteger(conv2Kernels))

                        newWeights=int32(zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        halfInputFeatureNum,param.outputFeatureNum+param.outputFeatureNumToPadForSplit));
                    else
                        newWeights=zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        halfInputFeatureNum,param.outputFeatureNum+param.outputFeatureNumToPadForSplit);
                    end
                    newWeights(:,:,:,1:halfOutputFeatureNum+halfOutputFeatureNumToPad)=...
                    dnnfpga.processorbase.conv2Processor.padOpForSplitOnOutput(conv2Kernels(:,:,:,1:halfOutputFeatureNum),...
                    halfInputFeatureNum,halfOutputFeatureNum,halfOutputFeatureNumToPad);
                    newWeights(:,:,:,halfOutputFeatureNum+halfOutputFeatureNumToPad+1:end)=...
                    dnnfpga.processorbase.conv2Processor.padOpForSplitOnOutput(conv2Kernels(:,:,:,halfOutputFeatureNum+1:end),...
                    halfInputFeatureNum,halfOutputFeatureNum,halfOutputFeatureNumToPad);
                else
                    if(isinteger(conv2Kernels))

                        newWeights=int32(zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        param.inputFeatureNum,param.outputFeatureNum+param.outputFeatureNumToPadForSplit));
                    else
                        newWeights=zeros(size(conv2Kernels,1),size(conv2Kernels,2),...
                        param.inputFeatureNum,param.outputFeatureNum+param.outputFeatureNumToPadForSplit);
                    end
                    newWeights(:,:,:,1:halfOutputFeatureNum+halfOutputFeatureNumToPad)=...
                    dnnfpga.processorbase.conv2Processor.padOpForSplitOnOutput(conv2Kernels(:,:,:,1:halfOutputFeatureNum),...
                    param.inputFeatureNum,halfOutputFeatureNum,halfOutputFeatureNumToPad);
                    newWeights(:,:,:,halfOutputFeatureNum+halfOutputFeatureNumToPad+1:end)=...
                    dnnfpga.processorbase.conv2Processor.padOpForSplitOnOutput(conv2Kernels(:,:,:,halfOutputFeatureNum+1:end),...
                    param.inputFeatureNum,halfOutputFeatureNum,halfOutputFeatureNumToPad);
                end
                conv2Kernels=newWeights;


                if(isinteger(conv2Kernels))

                    newBias=int32(zeros(param.outputFeatureNum+param.outputFeatureNumToPadForSplit,1));
                else
                    newBias=zeros(param.outputFeatureNum+param.outputFeatureNumToPadForSplit,1);
                end
                newBias(1:halfOutputFeatureNum)=conv2Bias(1:halfOutputFeatureNum);
                newBias(halfOutputFeatureNum+1:halfOutputFeatureNum+halfOutputFeatureNumToPad)=zeros(halfOutputFeatureNumToPad,1);
                newBias(halfOutputFeatureNum+halfOutputFeatureNumToPad+1:param.outputFeatureNum+halfOutputFeatureNumToPad)=conv2Bias(halfOutputFeatureNum+1:end);
                newBias(param.outputFeatureNum+halfOutputFeatureNumToPad+1:end)=zeros(halfOutputFeatureNumToPad,1);
                conv2Bias=newBias;


                param.outputFeatureNum=param.outputFeatureNum+param.outputFeatureNumToPadForSplit;

            end
        end
    end
end





