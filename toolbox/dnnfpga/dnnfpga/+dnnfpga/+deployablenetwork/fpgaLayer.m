classdef fpgaLayer<dnnfpga.deployablenetwork.abstractLayer




    properties(Access=private)
m_name
m_processor
m_initData
m_deployableIR
m_forwardArgs
        m_platform=[]
m_activationLayer
        m_notRunTiledLayerPos=[];


        hDDROffsetMap=[];

        StreamingMode=false;
        StreamingContinuous=false;
        InputBaseAddr=uint32(0);
        OutputBaseAddr=uint32(0);
    end

    properties(Access=protected)


        NetworkChecksum='';
    end

    methods(Access=public,Hidden=true)
        function obj=fpgaLayer(name,processor,initData,forwardArgs,deployableIR,hDDROffsetMap,activationLayer,notRunTiledLayerPos)

            if nargin<4
                forwardArgs=[];
            end

            if nargin<5
                deployableIR=[];
            end

            if nargin<6
                hDDROffsetMap=[];
            end

            if nargin<7
                activationLayer='';
            end

            if nargin<8
                notRunTiledLayerPos=[];
            end

            obj@dnnfpga.deployablenetwork.abstractLayer(name);
            obj.m_processor=processor;
            obj.m_initData=initData;
            obj.m_forwardArgs=forwardArgs;
            obj.m_deployableIR=deployableIR;
            obj.m_activationLayer=activationLayer;
            obj.m_notRunTiledLayerPos=notRunTiledLayerPos;
            obj.hDDROffsetMap=hDDROffsetMap;




            if~isa(processor,'dnnfpga.processorbase.cnn5Processor')



                obj.generateNetworkChecksum();
            end
        end
    end

    methods(Access=public)
        function setPlatform(this,platform)
            this.m_platform=platform;
        end

        function processor=getProcessor(this)
            processor=this.m_processor;
        end

        function data=getData(this)
            data=this.m_initData;
        end

        function setData(this,data)
            this.m_initData=data;
        end

        function args=getForwardArgs(this)
            args=this.m_forwardArgs;
        end




        function params=getDepolyableIR(this,takeAll)
            if nargin<2
                takeAll=false;
            end
            params=this.m_deployableIR;
            if~takeAll&&isfield(params,'sgraph')
                params=params.sgraph;
            end
        end
        function setDepolyableIR(this,params)
            this.m_deployableIR=params;
        end

        function activationLayer=getActivationLayer(this)
            activationLayer=this.m_activationLayer;
        end

        function setActivationLayer(this,activationLayer)
            this.m_activationLayer=activationLayer;
        end

        function notRunTiledLayerPos=getNotRunTiledLayerPos(this)
            notRunTiledLayerPos=this.m_notRunTiledLayerPos;
        end

        function init(this,verbose)
            this.sanityCheckHW();

            ismatch=this.isNetworkChecksumMatches;
            if~ismatch

                this.m_platform.deploy(this);
            else
                dnnfpga.disp(message('dnnfpga:dnnfpgadisp:ProgNetworkSkip'),verbose);
            end
            this.m_platform.writeNetworkChecksumToFPGA(this.NetworkChecksum);
        end

        function resetState(this)
            this.init(2);
            this.m_platform.initializeStateData(this);
        end

        function output=forward(this,input)
            this.sanityCheckHW();

            output=this.m_platform.execute(input,this);
        end

        function offsetMap=getDDROffsetMap(this)

            offsetMap=this.hDDROffsetMap;
        end
        function setDDROffsetMap(this,offsetMap)

            this.hDDROffsetMap=offsetMap;
        end
        function networkChecksum=getNetworkChecksum(this)

            networkChecksum=this.NetworkChecksum;
        end
        function setNetworkChecksum(this,networkChecksum)

            this.NetworkChecksum=networkChecksum;
        end

        function generateNetworkChecksum(this)
            if isempty(this.NetworkChecksum)

                data=this.m_initData;
                cksmFileName='cksm_Network.mat';
                save(cksmFileName,'data');



                this.removeVersionAndDateInfoFromMATFile(cksmFileName);
                this.NetworkChecksum=dnnfpga.tool.getFileChecksum(cksmFileName);
            end
        end

        function setStreamingMode(this,mode)
            this.StreamingMode=mode;
        end

        function mode=getStreamingMode(this)
            mode=this.StreamingMode;
        end

        function setStreamingContinuous(this,continuous)
            this.StreamingContinuous=continuous;
        end

        function continuous=getStreamingContinuous(this)
            continuous=this.StreamingContinuous;
        end

    end

    methods(Access=protected)
        function sanityCheckHW(this)

        end

        function ismatch=isNetworkChecksumMatches(this)


            this.generateNetworkChecksum();
            pf=this.m_platform;
            fpgaChecksum=pf.readNetworkChecksumFromFPGA;
            ismatch=isequal(fpgaChecksum,this.NetworkChecksum);
        end

        function removeVersionAndDateInfoFromMATFile(~,fileName)





            fid=fopen(fileName,'r+');
            firstLine=fgetl(fid);
            frewind(fid);










            versionAndDateString=cell2mat(regexp(firstLine,".+\d+:\d+:\d+\s\d+",'match'));

            fwrite(fid,blanks(length(versionAndDateString)));
            fclose(fid);
        end
    end
end


