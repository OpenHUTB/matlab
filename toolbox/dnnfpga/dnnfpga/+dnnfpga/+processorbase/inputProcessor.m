classdef inputProcessor<dnnfpga.processorbase.abstractProcessor





    methods(Access=public,Hidden=true)
        function obj=inputProcessor(bcc)
            obj@dnnfpga.processorbase.abstractProcessor(bcc);
        end
    end

    methods(Access=public)
        function inputp=getInputProcessor(this)
            inputp=this;
        end

        function cycles=estimateThroughput(this,params,~)
            cycles=[];
        end

        function output=cosimInputLayer(this,param,input)




            if param.inputSource==0
                seqImg=dnnfpga.processorbase.processorUtils.generateCameraCompatibleImage(input);


            elseif param.inputSource==1

                cc=this.getCC;
                threadNumLimit=cc.threadNumLimit;
                dataTransNum=cc.dataTransNum;
                input=single(input);



                inputNew=dnnfpga.format.paddingtoDataParallelTransferNumber(input,dataTransNum,threadNumLimit);



                seqImg=dnnfpga.format.convert3DInputToDDRVectorFormatConv4(inputNew,dataTransNum);

            else
                assert(false,'invalid inputSource ID');
            end


            seqImg=typecast(seqImg,'single');
            save([param.phase,'_seqImg.mat'],'seqImg');


            if param.inputSource
                output=this.serializeFeatureMap(param,input);
            else
                output=this.serializeFeatureMapHWPadding(param,input);
            end
            save([param.phase,'_seqResult.mat'],'output');
        end

        function nc=resolveNC(~,params)
            assert(length(params)==1);
            nc=[];
        end

        function output=cosim(this,param,input)
            switch param.type
            case 'SW_Cosim_FPGA_InputP'
                output=this.cosimInputLayer(param.params{1},input);
            otherwise
                assert(false,'Unexpected layer type %s',param.type);
            end
        end

        function s=resolveInputSizeLayer(~,~)
            s=0;
        end

        function s=resolveOutputSizeLayer(~,~)
            s=0;
        end

        function logs=sanityCheckNetwork(this,params)
            logs={};
        end

        function output=getSeqLCAndOp(this,params)
            output=this.getSeqLCAndOpPerLayer(params{1});
        end

        function output=getSeqLCAndOpPerLayer(this,param)
            layerType=param.type;
            switch layerType
            case 'FPGA_InputP'
                output=this.getSeqLCAndOpPerLayerInputP(param);
            otherwise
                assert(false,'Unknown layer type "%s"',layerType);
            end
        end
    end

    methods(Access=protected)
        function cc=resolveCC(this)
            bcc=this.getBCC();
            cc.layerNumWLimit=bcc.layerNumWLimit;
            cc.layerConfigNumWLimit=bcc.layerConfigNumWLimit;
            cc.imageNumWLimit=bcc.imageNumWLimit;
            cc.layerModeNumWLimit=bcc.layerModeNumWLimit;
            cc.resultMemDepthLimit=[ceil(bcc.resultMemDepthLimit(1)/bcc.threadNumLimit);ceil(bcc.resultMemDepthLimit(2:3)/bcc.opW)];
            if(bcc.inputMemDepthLimit(1)<=bcc.threadNumLimit/2)
                cc.inputMemDepthLimit=ceil(prod([1;ceil(bcc.inputMemDepthLimit(2:3)/bcc.opW)])/2);
            else
                cc.inputMemDepthLimit=prod([ceil(bcc.inputMemDepthLimit(1)/bcc.threadNumLimit);ceil(bcc.inputMemDepthLimit(2:3)/bcc.opW)]);
            end
            cc.opW=bcc.opW;
            cc.imgSizeLimit=[bcc.imgWLimit;bcc.imgWLimit;1];
            cc.opSize=[bcc.opW;bcc.opW;1];
            cc.debugIDAddrW=ceil(log2(bcc.debugIDNumWLimit));
            cc.debugBankAddrW=ceil(log2(bcc.debugBankNumWLimit));
            cc.blockNumWLimit=bcc.blockNumWLimit;
            cc.requestAddrWLimit=bcc.requestAddrWLimit;
            cc.dataMemAddrW=ceil(log2(max([bcc.resultMemDepthLimit;bcc.inputMemDepthLimit;bcc.featureSizeLimit])));
            cc.lcMemAddrW=ceil(log2(bcc.layerNumWLimit*bcc.layerConfigNumWLimit));
            cc.debugMemAddrW=max(ceil(log2(max(prod(bcc.resultMemDepthLimit),prod(bcc.inputMemDepthLimit)))),cc.lcMemAddrW);
            cc.threadNumLimit=bcc.threadNumLimit;
            cc.CONV_TRANS_CTRL_LATENCY=bcc.CONV_TRANS_CTRL_LATENCY;
            cc.halfProgLCFIFODepth=bcc.halfProgLCFIFODepth;
            cc.paddingLogicDataTypeConvertLatency=bcc.Fixdt_0_16_0_To_SingleLatency;
            cc.kernelDataType=bcc.kernelDataType;
            cc.dataTransNum=bcc.dataTransNum;






            cc.inputMemAddrBitWidth=ceil(log2(prod(cc.inputMemDepthLimit)))+1;
            cc.resultMemAddrBitWidth=ceil(log2(prod(cc.resultMemDepthLimit)))+1;
        end

        function lc=resolveLCPerLayer(this,param)
            lc=dnnfpga.processorbase.processorUtils.resolveLCPerLayerInputP(param,this.getCC());
        end

        function output=serializeFeatureMap(this,param,input)










            output=serializeFeatureMapM(this,param,input);
        end

        function output=serializeFeatureMapM(this,param,input)
            outputX=ceil(param.deltaX/this.getCC.opW)*this.getCC.opW;
            outputY=ceil(param.deltaY/this.getCC.opW)*this.getCC.opW;
            if param.inputSource
                outputZ=ceil(param.deltaZ/this.getCC.threadNumLimit)*this.getCC.threadNumLimit;
            else
                outputZ=this.getCC.threadNumLimit;
            end
            output=single(zeros(outputX*outputY*outputZ,1));
            ind=1;



            for z2=1:(outputZ/this.getCC.threadNumLimit)
                for y2=1:ceil(param.deltaY/this.getCC.opW)
                    for x2=1:ceil(param.deltaX/this.getCC.opW)
                        for z1=1:this.getCC.threadNumLimit
                            z=(z2-1)*this.getCC.threadNumLimit+z1+param.Z;
                            if z>outputZ
                                break;
                            end
                            for x1=1:this.getCC.opW
                                for y1=1:this.getCC.opW
                                    x=(x2-1)*this.getCC.opW+x1+param.X;
                                    y=(y2-1)*this.getCC.opW+y1+param.Y;

                                    if(x>param.deltaX+param.X)||(y>param.deltaY+param.Y)
                                        ind=ind+1;
                                        continue;
                                    end
                                    if z>size(input,3)
                                        output(ind)=single(0);
                                        ind=ind+1;
                                        continue;
                                    end
                                    output(ind)=input(y,x,z);
                                    ind=ind+1;
                                end
                            end
                        end
                    end
                end
            end
        end

        function output=serializeFeatureMapHWPadding(this,param,input)
            assert(param.deltaZ<=this.getCC.threadNumLimit,'delta Z should be no larger than thread number');
            outputX=ceil(param.deltaX/this.getCC.opW)*this.getCC.opW;
            outputY=ceil(param.deltaY/this.getCC.opW)*this.getCC.opW;
            if param.inputSource
                outputZ=param.deltaZ;
            else
                outputZ=this.getCC.threadNumLimit;
            end
            output=single(zeros(outputX*outputY*outputZ,1));
            ind=1;



            for y2=1:ceil(param.deltaY/this.getCC.opW)
                for x2=1:ceil(param.deltaX/this.getCC.opW)
                    for z1=1:outputZ
                        for x1=1:this.getCC.opW
                            for y1=1:this.getCC.opW
                                x=(x2-1)*this.getCC.opW+x1+param.X;
                                y=(y2-1)*this.getCC.opW+y1+param.Y;
                                z=z1+param.Z;

                                if(x>param.deltaX+param.X)||(y>param.deltaY+param.Y)
                                    ind=ind+1;
                                    continue;
                                end
                                if z>size(input,3)
                                    output(ind)=0;
                                else
                                    output(ind)=input(y,x,z);
                                end
                                ind=ind+1;
                            end
                        end
                    end
                end
            end

        end

        function output=getSeqLCAndOpPerLayerInputP(this,param)
            output.seqOp=[];
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerInputP(param,this.getCC());



            output.seqLC=dnnfpga.builtin.SeqConfigPrivate(layerConfig);
        end
    end

    methods(Access=public,Static=true)
        function ret=tc(val,type)
            val=dnnfpga.assembler.ConvtoUint32U(val);
            ret=typecast(val,type);
        end























    end
end



