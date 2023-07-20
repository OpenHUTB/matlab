classdef outputProcessor<dnnfpga.processorbase.abstractProcessor





    methods(Access=public,Hidden=true)
        function obj=outputProcessor(bcc)
            obj@dnnfpga.processorbase.abstractProcessor(bcc);
        end
    end

    methods(Access=public)
        function outputp=getOutputProcessor(this)
            outputp=this;
        end

        function cycles=estimateThroughput(this,params,~)
            cycles=[];
        end

        function output=cosimOutputLayer(this,param,input)



            if param.inputSource==0
                seqImg=dnnfpga.processorbase.processorUtils.generateCameraCompatibleImage(input);

            elseif param.inputSource==1
                seqImg=single(zeros(1,param.deltaX*param.deltaY*param.deltaZ));
                ind=1;
                for z=1:ceil(param.deltaZ/this.getCC.threadNumLimit)
                    for k=(param.Y+1):(param.Y+param.deltaY)
                        for j=(param.X+1):(param.X+param.deltaX)
                            for i=(param.Z+1):(param.Z+this.getCC.threadNumLimit)
                                if ind>size(seqImg,2)
                                    break;
                                end
                                if i+(z-1)*this.getCC.threadNumLimit>size(input,3)
                                    continue;
                                end
                                seqImg(ind)=input(k,j,i+(z-1)*this.getCC.threadNumLimit);
                                ind=ind+1;
                            end
                        end
                    end
                end
            else
                assert(false,'invalid inputSource ID');
            end


            seqImg=typecast(seqImg,'single');
            save([param.phase,'_seqImg.mat'],'seqImg');


            output=this.serializeFeatureMap(param,input);
            save([param.phase,'_seqResult.mat'],'output');



            output=this.serializeFeatureMap2(param,input);
            save([param.phase,'_seqImg2.mat'],'output');

        end

        function nc=resolveNC(~,params)
            assert(length(params)==1);
            nc=[];
        end

        function output=cosim(this,param,input)
            switch param.type
            case 'SW_Cosim_FPGA_OutputP'
                output=this.cosimOutputLayer(param.params{1},input);
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
            case 'FPGA_OutputP'
                output=this.getSeqLCAndOpPerLayerOutputP(param);
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
            cc.paddingLogicDataTypeConvertLatency=bcc.Fixdt_0_16_0_To_SingleLatency;
            cc.kernelDataType=bcc.kernelDataType;
            cc.halfProgLCFIFODepth=bcc.halfProgLCFIFODepth;
            cc.dataTransNum=bcc.dataTransNum;






            cc.inputMemAddrBitWidth=ceil(log2(prod(cc.inputMemDepthLimit)))+1;
            cc.resultMemAddrBitWidth=ceil(log2(prod(cc.resultMemDepthLimit)))+1;
        end

        function lc=resolveLCPerLayer(this,param)
            lc=dnnfpga.processorbase.processorUtils.resolveLCPerLayerOutputP(param,this.getCC());
        end

        function output=serializeFeatureMap(this,param,input)

            output=serializeFeatureMapM(this,param,input);




        end

        function output=serializeFeatureMapM(this,param,input)
            assert(param.deltaX+param.X<=size(input,2),"IR deltaX exceeds feature map size on X axis");
            assert(param.deltaY+param.Y<=size(input,1),"IR deltaY exceeds feature map size on Y axis");



            inputNew=input;
            dataTransNum=this.getCC.dataTransNum;
            threadNumLimit=this.getCC.threadNumLimit;
            if(dataTransNum>1)
                inputFeatureNum=size(input,3);
                modNum=mod(inputFeatureNum,threadNumLimit);
                if(modNum~=0)
                    inputNew=dnnfpga.assembler.padImage(input,[0,0,threadNumLimit-modNum],'post');
                end
            end

            output=single(zeros(1,param.deltaX*param.deltaY*param.deltaZ));
            ind=1;
            for i2=1:ceil(param.deltaZ/threadNumLimit)
                for k=1:param.deltaY
                    for j=1:param.deltaX
                        for i1=1:threadNumLimit
                            if ind>size(output,2)
                                break;
                            end
                            i=(i2-1)*threadNumLimit+i1;
                            if i>size(inputNew,3)
                                continue;
                            end
                            output(ind)=inputNew(k+param.Y,j+param.X,i);
                            ind=ind+1;
                        end
                    end
                end
            end
        end



        function output=serializeFeatureMap2(this,param,input)
            outputX=ceil(param.deltaX/this.getCC.opW)*this.getCC.opW;
            outputY=ceil(param.deltaY/this.getCC.opW)*this.getCC.opW;
            outputZ=ceil(param.deltaZ/this.getCC.threadNumLimit)*this.getCC.threadNumLimit;
            output=single(zeros(outputX*outputY*outputZ,1));
            ind=1;
            for z2=1:ceil(outputZ/this.getCC.threadNumLimit)
                for y2=1:ceil(param.deltaY/this.getCC.opW)
                    for x2=1:ceil(param.deltaX/this.getCC.opW)
                        for z1=1:this.getCC.threadNumLimit
                            for x1=1:this.getCC.opW
                                for y1=1:this.getCC.opW
                                    x=(x2-1)*this.getCC.opW+x1+param.X;
                                    y=(y2-1)*this.getCC.opW+y1+param.Y;
                                    z=z1+(z2-1)*this.getCC.threadNumLimit+param.Z;
                                    if z>size(input,3)
                                        ind=ind+1;
                                        continue;
                                    end

                                    if(x>param.Xlimit)||(y>param.Ylimit)
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

        function output=getSeqLCAndOpPerLayerOutputP(this,param)
            output.seqOp=[];
            layerConfig=dnnfpga.processorbase.processorUtils.resolveLCPerLayerOutputP(param,this.getCC());



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



