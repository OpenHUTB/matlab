classdef cnn5Processor<dnnfpga.processorbase.cnn4Processor



    properties(Access=public,Hidden=true)



addp
    end

    methods(Access=public,Hidden=true)

        function obj=cnn5Processor(bcc)
            obj@dnnfpga.processorbase.cnn4Processor(bcc);
            obj.fcp=dnnfpga.processorbase.fc5Processor(bcc.fcp);
            obj.addp=dnnfpga.processorbase.adderProcessor(bcc.addp);
            obj.convp=dnnfpga.processorbase.conv5Processor(bcc.convp);
            obj.debug=dnnfpga.processorbase.debugModule(bcc);
        end
    end

    methods(Access=public)

        function nc=resolveNC(this,params)
            nc.fc=this.getFCProcessor().resolveNC(params.fc);
            nc.conv=[];
            nc.add=[];
        end




        function lcs=resolveLC(this,params)
            lcs.fc=this.getFCProcessor().resolveLC(params.fc);
            lcs.conv=[];
            lcs.add=[];
        end

        function fcp=getFCProcessor(this)
            fcp=dnnfpga.processorbase.fc5Processor(this.getBCC().fcp);
        end

        function convp=getConvProcessor(this)
            convp=dnnfpga.processorbase.conv5Processor(this.getBCC().convp);
        end

        function addp=getAddProcessor(this)

            addp=dnnfpga.processorbase.adderProcessor(this.getBCC().addp);
        end

    end

    methods(Access=protected)
        function cc=resolveCC(this)


            fc_cc=this.fcp.getCC();


            add_cc=this.addp.getCC();


            conv_cc=this.convp.getCC();


            debug_cc=this.debug.getCC();


            cc.fcp=fc_cc;
            cc.addp=add_cc;
            cc.convp=conv_cc;
            cc.debug=debug_cc;


            cc.ramSrcLibPath='dnnfpgaSharedGenericlib/Simple Dual Port RAM System Forced Addr';
            cc.dataTransNum=this.getBCC.dataTransNum;
            cc.moduleEnable=this.getBCC.moduleEnable;
            cc.enableAxiStream=this.getBCC.enableAxiStream;
            cc.customLayersInfo=this.getBCC.customLayersInfo;






            cc.schedulerStackSize.adder=64;
            cc.schedulerStackSize.concat=64;
            cc.schedulerStackSize.conv=64;
            cc.schedulerStackSize.fc=64;

            cc.schedulerStackSize.input=8;
            cc.schedulerStackSize.output=8;

            cc.schedulerRegMap=containers.Map('KeyType','char','ValueType','uint32');


            cc.schedulerRegMap('frameBufferCount')=hex2dec('04');


            cc.schedulerRegMap('inputBaseAddr')=hex2dec('10');


            cc.schedulerRegMap('outputBaseAddr')=hex2dec('20');


            cc.schedulerRegMap('inputSize')=hex2dec('30');


            cc.schedulerRegMap('outputSize')=hex2dec('40');


            cc=resolveReadArbitratorNumber(this,cc);
        end

        function cc=resolveReadArbitratorNumber(obj,cc)







            moduleList={{'activations_'},...
            {'conv',1},...
            {'fc',1},...
            {'hs',1},...
            {'adder',2},...
            {'axiStream',1},...
            {'weights_'},...
            {'conv',1},...
            {'fc',1},...
            {'instruction_'},...
            {'conv_ip',1},...
            {'conv',1},...
            {'conv_op',1},...
            {'debugger',1},...
            {'fc',1},...
            {'skd',1},...
            {'adder',1},...
            };


            arbitratorMap=containers.Map();
            for idx=1:numel(moduleList)
                module=moduleList{idx};
                if numel(module)==1
                    namePrefix=module{1};
                else
                    arbitratorMap=obj.addToArbitratorMap(arbitratorMap,[namePrefix,module{1}],module{2});
                end
            end


            if dnnfpgafeature('Verbose')>1
                dnnfpga.disp('Resolve read arbitrator ID number: ');
                for idx=1:numel(moduleList)
                    module=moduleList{idx};
                    if numel(module)==1
                        namePrefix=module{1};
                    else
                        IDName=[namePrefix,module{1}];
                        dnnfpga.disp(sprintf('%25s: %d',IDName,arbitratorMap(IDName)));
                    end
                end
            end

            cc.arbitrator=arbitratorMap;
        end
        function arbitratorMap=addToArbitratorMap(~,arbitratorMap,IDName,numInputs)

            keyName='numInputs';
            if~isKey(arbitratorMap,keyName)
                arbitratorMap(keyName)=uint8(1);
            end
            arbitratorMap(IDName)=arbitratorMap(keyName);
            arbitratorMap(keyName)=uint8(arbitratorMap(keyName)+numInputs);
        end
    end
end


