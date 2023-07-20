classdef abstractProcessor<fpconfig.DeepCopiable



    properties(Access=public,Hidden=true)
m_bcc
    end

    methods(Access=public,Hidden=true)
        function obj=abstractProcessor(varargin)
            if(nargin==1&&isa(varargin{1},'fpconfig.ConstructArgs'))
                fpconfig.DeepCopiable.initWithPV(obj,varargin{:});
                return;
            end

            bcc=varargin{1};
            obj.m_bcc=bcc;
        end
    end

    methods(Access=public)
        function lcs=resolveLC(this,params)
            if(isempty(params))
                lcs=struct;

            elseif strcmp(params{1}.type,'FPGA_InputP')
                lcs=this.resolveLCPerLayer(params{1});
            elseif strcmp(params{1}.type,'FPGA_OutputP')
                lcs=this.resolveLCPerLayer(params{1});
            else
                memDir=true;
                for i=1:length(params)
                    lc=this.resolveLCPerLayer(params{i});
                    if(strcmp(params{i}.type,'FPGA_Lrn2D'))
                        memDir=~memDir;
                    end
                    lc.memDirection=memDir;
                    if~strcmp(params{i}.type,'FPGA_Input')
                        memDir=~memDir;
                    end
                    if(i==1)
                        lcs(1)=lc;
                    else
                        lcs(end+1)=lc;%#ok<AGROW>
                    end
                    save([params{i}.phase,'_LC.mat'],'lc');
                end
            end
        end

        function bcc=getBCC(this)
            bcc=this.m_bcc;
        end

        function kind=getKind(this)
            kind='abstract';
        end

        function setBCC(this,bcc)
            this.m_bcc=bcc;
        end

        function cc=getCC(this)
            cc=this.resolveCC();
        end

        function cc=getCCS(this)
            cc=this.resolveCC();
            cc=dnnfpga.processorbase.abstractProcessor.getSubCC(this.getKind(),cc);
        end

        function convp=getConvProcessor(~)
            convp=[];
        end

        function fcp=getFCProcessor(~)
            fcp=[];
        end

        function inputp=getInputProcessor(~)
            inputp=[];
        end

        function outputp=getOutputProcessor(~)
            outputp=[];
        end

        function output=backend(this,params)
            layerData=struct('seqOp',[],'seqLC',[]);


            if~iscell(params)&&(length(params)==1)
                params={params};
            end

            for i=1:length(params)
                param=params{i};
                layerData(i)=this.getSeqLCAndOpPerLayer(param);
            end
            output.seqOp=[layerData.seqOp];
            output.seqLC=[layerData.seqLC];
            output.NC=this.resolveNC(params);

        end

        function output=cosim(this,input)
            output=input;
        end

        function s=resolveInputSize(this,params)
            s=this.resolveInputSizeLayer(params{1});
        end

        function s=resolveOutputSize(this,params)
            s=this.resolveOutputSizeLayer(params{end});
        end

        function active=inputMemZAdapterActivePred(this,param)
            active=false;
        end

        function logs=sanityCheckLayer(this,param)
            logs={};
        end

        function logs=sanityCheckNetwork(this,params)
            logs={};
        end
    end

    methods(Access=public,Abstract=true)
        cycles=estimateThroughput(this,params,hw)

        nc=resolveNC(this,params)

        s=resolveInputSizeLayer(this,param);
        s=resolveOutputSizeLayer(this,param);
    end

    methods(Access=protected,Abstract=true)
        cc=resolveCC(this)

        lc=resolveLCPerLayer(this,param)
    end

    methods(Access=public)
        function data=getSeqLCAndOpPerLayer(~,~)
            data.seqOp=[];
            data.seqLC=[];
        end
    end

    methods(Access=public,Static=true)

        function scc=getSubCC(kind,cc)
            switch kind
            case 'fc'
                scc=cc.fc;
            case 'conv'
                if(isfield(cc,'conv'))
                    scc=cc.conv;
                else
                    scc=cc;
                end
            case 'convp'
                scc=cc.convp;
            otherwise
                scc=cc;
            end
        end
    end
end

