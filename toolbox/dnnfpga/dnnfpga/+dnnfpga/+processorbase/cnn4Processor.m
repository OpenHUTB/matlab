classdef cnn4Processor<dnnfpga.processorbase.abstractProcessor



    properties(Access=public,Hidden=true)



convp
fcp
debug
    end

    methods(Access=public,Hidden=true)
        function obj=cnn4Processor(bcc)
            obj@dnnfpga.processorbase.abstractProcessor(bcc);
            obj.convp=dnnfpga.processorbase.conv4Processor(bcc.convp);
            obj.fcp=dnnfpga.processorbase.fc4Processor(bcc.fcp);
            obj.debug=dnnfpga.processorbase.debugModule(bcc);
        end
    end

    methods(Access=public)

        function result=estimateThroughput(this,params,bitstream)
            result=0;
        end


        function Cycles=estimateFIFO1ProcessorThroughput(this,params,bitstream)
            Cycles=0;
        end

        function nc=resolveNC(this,params)
            nc.conv=this.getConvProcessor().resolveNC(params.conv);
            nc.fc=this.getFCProcessor().resolveNC(params.fc);
            nc.fifo1=this.getFIFO1Processor().resolveNC(params.fifo1);
        end

        function s=resolveOutputSize(this,params)
            s=this.getFCProcessor().resolveOutputSize({params{end}});
        end

        function s=resolveOutputSizeLayer(this,param)
            assert(false,'Shall not reach here');
        end

        function lcs=resolveLC(this,params)
            lcs.conv=this.getConvProcessor().resolveLC(params.conv);
            lcs.fc=this.getFCProcessor().resolveLC(params.fc);
            lcs.fifo1=[];
        end

        function convp=getConvProcessor(this)
            convp=dnnfpga.processorbase.conv4Processor(this.getBCC().convp);
        end

        function fcp=getFCProcessor(this)
            fcp=dnnfpga.processorbase.fc4Processor(this.getBCC().fcp);
        end

        function fifo1p=getFIFO1Processor(this)
            fifo1p=dnnfpga.processorbase.fifo1Processor(this.getBCC().fifo1);
        end

        function s=resolveInputSize(this,params)
            s=this.getConvProcessor().resolveInputSize({params{1}});
        end

        function s=resolveInputSizeLayer(this,param)
            assert(false,'Shall not reach here');
        end

        function data=getSeqLCAndOpPerLayer(this,param)
            assert(false,'Shouldn''t be called');
        end
    end

    methods(Access=protected)
        function cc=resolveCC(this)

            conv_cc=this.convp.getCC();


            fc_cc=this.fcp.getCC();


            debug_cc=this.debug.getCC();


            cc.convp=conv_cc;
            cc.fcp=fc_cc;
            cc.debug=debug_cc;

            cc.ramSrcLibPath='dnnfpgaSharedGenericlib/Simple Dual Port RAM System Forced Addr';
            cc.dataTransNum=this.getBCC.dataTransNum;

        end

        function lc=resolveLCPerLayer(~,~)
            assert(false,'cnnProcessor doesn''t resovle individual layers');
            lc=[];
        end
    end
end
