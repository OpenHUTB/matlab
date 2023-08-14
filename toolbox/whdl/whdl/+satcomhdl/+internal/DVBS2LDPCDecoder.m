classdef(StrictDefaults)DVBS2LDPCDecoder<matlab.System








%#codegen


    properties(Nontunable)



        FECFrameSource='Input port';


        FECFrame='Normal';


        CodeRateSource='Property';


        CodeRateNormal='1/4';


        CodeRateShort='1/4';


        Algorithm='Min-sum';


        ScalingFactor=0.75;


        Termination='Max';


        SpecifyInputs='Property'


        NumIterations=8;


        MaxNumIterations=8;


        ParityCheckStatus(1,1)logical=false;
    end

    properties(Constant,Hidden)
        FECFrameSourceSet=matlab.system.StringSet({'Input port','Property'});
        FECFrameSet=matlab.system.StringSet({'Normal','Short'});
        CodeRateSourceSet=matlab.system.StringSet({'Input port','Property'});
        CodeRateNormalSet=matlab.system.StringSet({'1/4','1/3','2/5','1/2','3/5','2/3','3/4','4/5','5/6','8/9','9/10'});
        CodeRateShortSet=matlab.system.StringSet({'1/4','1/3','2/5','1/2','3/5','2/3','3/4','4/5','5/6','8/9'});
        SpecifyInputsSet=matlab.system.StringSet({'Input port','Property'});
        AlgorithmSet=matlab.system.StringSet({'Min-sum','Normalized min-sum'});
        TerminationSet=matlab.system.StringSet({'Max','Early'});
    end

    properties(Nontunable,Access=private)
        memDepth;
        nLayersLUT;
        nColumnsLUT;
        outLenLUT;
        degreeLUT;
        SF;
        alphaWL;
        alphaFL;
    end


    properties(Access=private)


        codeParameters;
        ldpcDecoderCore;


        refIter;
        blkLenIdx;
        codeRateIdx;
        nLayers;
        nColumns;
        outLen;
        invalidCodeRateIdx;
        frameValid;
        countData;
        invalidLength;
        maxCount;
        dataReg;
        ctrlReg;
        ctrlOutReg;


        dataOut;
        ctrlOut;
        iterOut;
        parCheck;
        nextFrame;
    end

    methods

        function obj=DVBS2LDPCDecoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end

        function set.ScalingFactor(obj,val)
            NMSVec=[1,0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375];
            validateattributes(val,{'double'},{'scalar'},'DVBS2LDPCDecoder','Scaling factor');
            coder.internal.errorIf(~(any(val==NMSVec)),...
            'whdl:DVBS2LDPCDecoder:InvalidScalingFactor');
            obj.ScalingFactor=val;
        end

        function set.NumIterations(obj,val)
            validateattributes(val,{'double'},{'scalar','integer'},'DVBS2LDPCDecoder','Number of Iterations');
            coder.internal.errorIf(~(val>=1&&val<=63),...
            'whdl:DVBS2LDPCDecoder:InvalidNumIterations');
            obj.NumIterations=val;
        end

        function set.MaxNumIterations(obj,val)
            validateattributes(val,{'double'},{'scalar','integer'},'DVBS2LDPCDecoder','Number of Iterations');
            coder.internal.errorIf(~(val>=1&&val<=63),...
            'whdl:DVBS2LDPCDecoder:InvalidMaxNumIterations');
            obj.MaxNumIterations=val;
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl
            text=[...
'Decode low-density parity-check (LDPC) code according to DVB-S2 standard.'...
            ,newline...
            ,newline...
            ,'The block supports scalar inputs and uses layered belief propagation with '...
            ,'min-sum or normalized min-sum approximation algorithm.'
            ];

            header=matlab.system.display.Header('satcomhdl.internal.DVBS2LDPCDecoder',...
            'Title','DVB-S2 LDPC Decoder',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl
            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'FECFrameSource','FECFrame','CodeRateSource','CodeRateNormal',...
            'CodeRateShort','Algorithm','ScalingFactor','Termination','SpecifyInputs',...
            'NumIterations','MaxNumIterations','ParityCheckStatus'});

            main=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',struc);

            groups=main;
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

    end

    methods(Access=protected)

        function icon=getIconImpl(~)
            icon=sprintf('DVB-S2 \n LDPC Decoder');
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function resetImpl(obj)


            reset(obj.codeParameters);
            reset(obj.ldpcDecoderCore);

            obj.dataOut(:)=0;
            obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
            obj.iterOut(:)=uint8(0);
            obj.parCheck(:)=false;
            obj.nextFrame(:)=true;
        end

        function setupImpl(obj,varargin)

            obj.memDepth=45;

            if isa(varargin{1},'int8')
                WL=8;
                FL=0;
            elseif isa(varargin{1},'int16')
                WL=16;
                FL=0;
            elseif isa(varargin{1},'embedded.fi')
                WL=varargin{1}.WordLength;
                FL=varargin{1}.FractionLength;
            else
                WL=4;
                FL=0;
            end

            if(strcmpi(obj.Algorithm,'Min-sum'))
                obj.SF=1;
            else
                obj.SF=obj.ScalingFactor;
            end

            intwl=WL-FL;

            if obj.SF==1
                obj.alphaFL=FL;
            else
                obj.alphaFL=FL+4;
            end

            obj.alphaWL=intwl+3+obj.alphaFL;


            if strcmpi(obj.FECFrameSource,'Property')
                if strcmpi(obj.CodeRateSource,'Property')&&strcmpi(obj.FECFrame,'Normal')
                    if(strcmpi(obj.CodeRateNormal,'1/4'))
                        obj.nLayersLUT=1080;
                        obj.outLenLUT=16200;
                        obj.degreeLUT=4;
                    elseif(strcmpi(obj.CodeRateNormal,'1/3'))
                        obj.nLayersLUT=960;
                        obj.outLenLUT=21600;
                        obj.degreeLUT=5;
                    elseif(strcmpi(obj.CodeRateNormal,'2/5'))
                        obj.nLayersLUT=864;
                        obj.outLenLUT=25920;
                        obj.degreeLUT=6;
                    elseif(strcmpi(obj.CodeRateNormal,'1/2'))
                        obj.nLayersLUT=720;
                        obj.outLenLUT=32400;
                        obj.degreeLUT=7;
                    elseif(strcmpi(obj.CodeRateNormal,'3/5'))
                        obj.nLayersLUT=576;
                        obj.outLenLUT=38880;
                        obj.degreeLUT=11;
                    elseif(strcmpi(obj.CodeRateNormal,'2/3'))
                        obj.nLayersLUT=480;
                        obj.outLenLUT=43200;
                        obj.degreeLUT=10;
                    elseif(strcmpi(obj.CodeRateNormal,'3/4'))
                        obj.nLayersLUT=360;
                        obj.outLenLUT=48600;
                        obj.degreeLUT=14;
                    elseif(strcmpi(obj.CodeRateNormal,'4/5'))
                        obj.nLayersLUT=288;
                        obj.outLenLUT=51840;
                        obj.degreeLUT=18;
                    elseif(strcmpi(obj.CodeRateNormal,'5/6'))
                        obj.nLayersLUT=240;
                        obj.outLenLUT=54000;
                        obj.degreeLUT=22;
                    elseif(strcmpi(obj.CodeRateNormal,'8/9'))
                        obj.nLayersLUT=160;
                        obj.outLenLUT=57600;
                        obj.degreeLUT=27;
                    else
                        obj.nLayersLUT=144;
                        obj.outLenLUT=58320;
                        obj.degreeLUT=30;
                    end
                elseif strcmpi(obj.CodeRateSource,'Property')&&strcmpi(obj.FECFrame,'Short')
                    if(strcmpi(obj.CodeRateShort,'1/4'))%#ok<*IFBDUP>
                        obj.nLayersLUT=288;
                        obj.outLenLUT=3240;
                        obj.degreeLUT=[4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;...
                        4;4;4;4;4;4;3;3;3;3;3;3;3;3;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;...
                        4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;...
                        3;3;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;...
                        4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;...
                        3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;4;4;4;4;...
                        4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4];
                    elseif(strcmpi(obj.CodeRateShort,'1/3'))
                        obj.nLayersLUT=240;
                        obj.outLenLUT=5400;
                        obj.degreeLUT=5;
                    elseif(strcmpi(obj.CodeRateShort,'2/5'))
                        obj.nLayersLUT=216;
                        obj.outLenLUT=6480;
                        obj.degreeLUT=6;
                    elseif(strcmpi(obj.CodeRateShort,'1/2'))
                        obj.nLayersLUT=200;
                        obj.outLenLUT=7200;
                        obj.degreeLUT=[5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;7;7;7;7;7;7;7;7;6;6;6;6;6;6;6;6;4;4;4;4;4;4;4;4;5;5;...
                        5;5;5;5;5;5;4;4;4;4;4;4;4;4;5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;5;5;5;5;...
                        5;5;5;5;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;5;5;5;5;5;5;...
                        5;5;4;4;4;4;4;4;4;4;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;4;4;4;4;4;4;4;4;6;6;6;6;6;6;6;6;...
                        5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;7;7;7;7;7;7;7;7;7];
                    elseif(strcmpi(obj.CodeRateShort,'3/5'))
                        obj.nLayersLUT=144;
                        obj.outLenLUT=9720;
                        obj.degreeLUT=11;
                    elseif(strcmpi(obj.CodeRateShort,'2/3'))
                        obj.nLayersLUT=120;
                        obj.outLenLUT=10800;
                        obj.degreeLUT=10;
                    elseif(strcmpi(obj.CodeRateShort,'3/4'))
                        obj.nLayersLUT=96;
                        obj.outLenLUT=11880;
                        obj.degreeLUT=[10;10;10;10;10;10;10;10;12;12;12;12;12;12;12;12;11;11;11;11;11;...
                        11;11;11;9;9;9;9;9;9;9;9;10;10;10;10;10;10;10;10;13;13;...
                        13;13;13;13;13;13;11;11;11;11;11;11;11;11;12;12;12;12;12;12;12;...
                        12;11;11;11;11;11;11;11;11;10;10;10;10;10;10;10;10;11;11;11;11;...
                        11;11;11;11;12;12;12;12;12;12;12;12;13];
                    elseif(strcmpi(obj.CodeRateShort,'4/5'))
                        obj.nLayersLUT=80;
                        obj.outLenLUT=12600;
                        obj.degreeLUT=[12;12;12;12;12;12;12;12;11;11;11;11;11;11;11;11;13;13;13;13;13;...
                        13;13;13;12;12;12;12;12;12;12;12;12;12;12;12;12;12;12;12;13;13;...
                        13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;...
                        13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13];
                    elseif(strcmpi(obj.CodeRateShort,'5/6'))
                        obj.nLayersLUT=64;
                        obj.outLenLUT=13320;
                        obj.degreeLUT=[16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;...
                        16;16;16;16;16;16;16;16;16;16;16;19;19;19;19;19;19;19;19;18;18;...
                        18;18;18;18;18;18;19;19;19;19;19;19;19;19;17;17;17;17;17;17;17;17;17];
                    else
                        obj.nLayersLUT=40;
                        obj.outLenLUT=14400;
                        obj.degreeLUT=27;
                    end
                elseif strcmpi(obj.FECFrame,'Normal')
                    obj.nLayersLUT=[1080,960,864,720,576,480,360,288,240,160,144,144,144,144,144,144];
                    obj.outLenLUT=[16200,21600,25920,32400,38880,43200,48600,51840,54000,57600,58320,58320,58320,58320,58320,58320];
                    obj.degreeLUT=[4;5;6;7;11;10;14;18;22;27;30;30;30;30;30;30];
                else
                    obj.nLayersLUT=[288,240,216,200,144,120,96,80,64,40,40,40,40,40,40,40];
                    obj.outLenLUT=[3240,5400,6480,7200,9720,10800,11880,12600,13320,14400,14400,14400,14400,14400,14400,14400];
                    obj.degreeLUT=[4;5;6;7;11;10;13;13;19;27;27;27;27;27;27;27];
                end
            else
                obj.nLayersLUT=[1080,960,864,720,576,480,360,288,240,160,144,144,144,144,144,144,288,240,216...
                ,200,144,120,96,80,64,40,40,40,40,40,40,40];
                obj.outLenLUT=[16200,21600,25920,32400,38880,43200,48600,51840,54000,57600,58320,58320,58320,58320...
                ,58320,58320,3240,5400,6480,7200,9720,10800,11880,12600,13320,14400,14400,14400,14400,14400,14400,14400];
                obj.degreeLUT=[4;5;6;7;11;10;14;18;22;27;30;30;30;30;30;30];
            end



            obj.codeParameters=satcomhdl.internal.DVBS2LDPCCodeParameters('Termination',obj.Termination,...
            'SpecifyInputs',obj.SpecifyInputs,'NumIterations',obj.NumIterations,'MaxNumIterations',obj.MaxNumIterations);


            obj.ldpcDecoderCore=satcomhdl.internal.DVBS2LDPCDecoderCore('FECFrameSource',obj.FECFrameSource,...
            'FECFrame',obj.FECFrame,'CodeRateSource',obj.CodeRateSource,'CodeRateNormal',obj.CodeRateNormal,...
            'CodeRateShort',obj.CodeRateShort,'Termination',obj.Termination,'ScalingFactor',obj.SF,'alphaWL',...
            obj.alphaWL,'alphaFL',obj.alphaFL,'ParityCheckStatus',obj.ParityCheckStatus,'degreeLUT',obj.degreeLUT);

            obj.maxCount=fi(64800,0,16,0);
            obj.outLen=fi(58320,0,16,0);
            obj.nLayers=fi(1080,0,11,0);
            obj.codeRateIdx=fi(0,0,4,0);
            obj.blkLenIdx=fi(0,0,1,0);
            obj.invalidCodeRateIdx=false;
            obj.frameValid=false;
            obj.countData=fi(58320,0,16,0);
            obj.invalidLength=false;
            obj.refIter=uint8(0);
            obj.dataReg=cast(zeros(1,1),'like',varargin{1});
            obj.ctrlReg=struct('start',false,'end',false,'valid',false);
            obj.ctrlOutReg=struct('start',false,'end',false,'valid',false);


            obj.dataOut=zeros(1,1)>0;
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.iterOut=uint8(0);
            obj.parCheck=false;
            obj.nextFrame=true;

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.ctrlOut;

            if strcmpi(obj.Termination,'Early')
                varargout{3}=obj.iterOut;
                if obj.ParityCheckStatus
                    varargout{4}=obj.parCheck;
                    varargout{5}=obj.nextFrame;
                else
                    varargout{4}=obj.nextFrame;
                end
            else
                if obj.ParityCheckStatus
                    varargout{3}=obj.parCheck;
                    varargout{4}=obj.nextFrame;
                else
                    varargout{3}=obj.nextFrame;
                end
            end
        end

        function updateImpl(obj,varargin)

            datain=varargin{1};
            ctrlin=varargin{2};
            num=2;
            if(strcmpi(obj.FECFrameSource,'Property'))
                if(strcmpi(obj.CodeRateSource,'Input port'))
                    rateidx=varargin{num+1};
                    num=num+1;

                    if ctrlin.start&&ctrlin.valid
                        obj.codeRateIdx(:)=rateidx;
                        if(obj.codeRateIdx>fi(10,0,4,0)||(strcmpi(obj.FECFrame,'Short')&&obj.codeRateIdx==fi(10,0,4,0)))
                            obj.invalidCodeRateIdx(:)=true;
                            obj.codeRateIdx(:)=0;
                            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                                coder.internal.warning('whdl:DVBS2LDPCDecoder:InvalidCodeRateIndex');
                            end
                        else
                            obj.invalidCodeRateIdx=false;
                        end
                        obj.outLen(:)=obj.outLenLUT(obj.codeRateIdx+1);
                        obj.nLayers(:)=obj.nLayersLUT(obj.codeRateIdx+1);
                    end
                else
                    obj.outLen(:)=obj.outLenLUT;
                    obj.nLayers(:)=obj.nLayersLUT;
                end
            else
                blklenidx=varargin{num+1};
                rateidx=varargin{num+2};
                num=num+2;

                if ctrlin.start&&ctrlin.valid
                    obj.blkLenIdx(:)=blklenidx;
                    obj.codeRateIdx(:)=rateidx;
                    if(obj.codeRateIdx>fi(10,0,4,0)||(obj.blkLenIdx==fi(1,0,1,0)&&obj.codeRateIdx==fi(10,0,4,0)))
                        obj.invalidCodeRateIdx=true;
                        obj.codeRateIdx(:)=0;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:DVBS2LDPCDecoder:InvalidCodeRateIndex');
                        end
                    else
                        obj.invalidCodeRateIdx=false;
                    end
                    obj.outLen(:)=obj.outLenLUT(fi(bitconcat(obj.blkLenIdx,obj.codeRateIdx)+1,0,5,0));
                    obj.nLayers(:)=obj.nLayersLUT(fi(bitconcat(obj.blkLenIdx,obj.codeRateIdx)+1,0,5,0));
                end
            end

            if(strcmpi(obj.SpecifyInputs,'Input port'))
                iterin=varargin{num+1};
                if ctrlin.start&&ctrlin.valid
                    obj.refIter(:)=iterin;
                end
            else
                if strcmpi(obj.Termination,'Max')
                    obj.refIter(:)=obj.NumIterations;
                else
                    obj.refIter(:)=obj.MaxNumIterations;
                end
            end


            [data_cp,valid_cp,framevalid_cp,reset,softreset,...
            niter,parity_cp]=obj.codeParameters(obj.dataReg,obj.ctrlReg,obj.refIter,obj.outLen);
            obj.dataReg(:)=datain;
            obj.ctrlReg(:)=ctrlin;


            if(strcmpi(obj.FECFrameSource,'Property'))
                if(strcmpi(obj.FECFrame,'Normal'))
                    obj.maxCount(:)=64800;
                else
                    obj.maxCount(:)=16200;
                end
            else
                if obj.blkLenIdx
                    obj.maxCount(:)=16200;
                else
                    obj.maxCount(:)=64800;
                end
            end
            endvalid=ctrlin.end&&ctrlin.valid&&obj.frameValid;

            if ctrlin.start&&ctrlin.valid
                obj.frameValid(:)=true;
                obj.countData(:)=0;
                obj.invalidLength(:)=false;
            elseif endvalid
                obj.frameValid(:)=false;
            end


            if endvalid&&~obj.nextFrame
                if(~obj.invalidCodeRateIdx)
                    if obj.countData~=obj.maxCount-1
                        obj.invalidLength=true;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:DVBS2LDPCDecoder:InvalidInputLength');
                        end
                    else
                        obj.invalidLength=false;
                    end
                end
            end

            validframe=(obj.frameValid&&ctrlin.valid);

            if(validframe)
                obj.countData(:)=obj.countData+fi(1,0,1,0,hdlfimath);
            end
            core_reset=reset||obj.nextFrame;

            [data_out,ctrl_out,iter_out,parcheck_out]=obj.ldpcDecoderCore(data_cp,...
            valid_cp,framevalid_cp,core_reset,softreset,niter,parity_cp,obj.nLayers,obj.outLen,obj.codeRateIdx,obj.blkLenIdx);

            if obj.nextFrame||obj.frameValid
                obj.dataOut(:)=zeros(1,1);
                obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
                obj.iterOut(:)=uint8(0);
                obj.parCheck(:)=false;
            else
                obj.dataOut(:)=data_out;
                obj.ctrlOut(:)=ctrl_out;
                obj.parCheck(:)=parcheck_out;
                obj.iterOut(:)=iter_out;
            end


            if ctrlin.start&&ctrlin.valid
                obj.nextFrame(:)=false;
            elseif((obj.ctrlOutReg.end&&obj.ctrlOutReg.valid)||...
                ((obj.invalidCodeRateIdx||obj.invalidLength)&&(ctrlin.end&&ctrlin.valid)))
                obj.nextFrame(:)=true;
            end

            if obj.frameValid
                obj.ctrlOutReg(:)=struct('start',false,'end',false,'valid',false);
            else
                obj.ctrlOutReg(:)=ctrl_out;
            end


        end

        function num=getNumInputsImpl(obj)
            num=2;
            if(strcmpi(obj.FECFrameSource,'Property'))
                if(strcmpi(obj.CodeRateSource,'Input port'))
                    num=3;
                end
            else
                num=4;
            end

            if(strcmpi(obj.SpecifyInputs,'Input port'))
                num=num+1;
            end

        end

        function num=getNumOutputsImpl(obj)
            if strcmpi(obj.Termination,'Early')
                num=4;
            else
                num=3;
            end

            if obj.ParityCheckStatus
                num=num+1;
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            outputPortInd=3;
            if(strcmpi(obj.FECFrameSource,'Property'))
                if(strcmpi(obj.CodeRateSource,'Input port'))
                    varargout{outputPortInd}='codeRateIdx';
                    outputPortInd=outputPortInd+1;
                end
            else
                varargout{outputPortInd}='frameType';
                outputPortInd=outputPortInd+1;
                varargout{outputPortInd}='codeRateIdx';
                outputPortInd=outputPortInd+1;
            end
            if(strcmpi(obj.SpecifyInputs,'Input port'))
                varargout{outputPortInd}='iter';
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            if(strcmpi(obj.Termination,'Early'))
                varargout{3}='actIter';
                if obj.ParityCheckStatus
                    varargout{4}='parityCheck';
                    varargout{5}='nextFrame';
                else
                    varargout{4}='nextFrame';
                end
            else
                if obj.ParityCheckStatus
                    varargout{3}='parityCheck';
                    varargout{4}='nextFrame';
                else
                    varargout{3}='nextFrame';
                end
            end
        end

        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                datain=varargin{1};
                validateattributes(datain,{'embedded.fi','int8','int16'},{'scalar','real'},'DVBS2LDPCDecoder','data');


                if isa(datain,'embedded.fi')
                    if~(issigned(datain))
                        coder.internal.error('whdl:DVBS2LDPCDecoder:InvalidSignedType');
                    end
                    maxWordLength=16;
                    minWordLength=4;
                    coder.internal.errorIf(...
                    ((datain.WordLength>maxWordLength)||(datain.WordLength<minWordLength)),...
                    'whdl:DVBS2LDPCDecoder:InvalidInputWordLength');
                end
                ctrlIn=varargin{2};
                if~isstruct(ctrlIn)
                    coder.internal.error('whdl:DVBS2LDPCDecoder:InvalidSampleCtrlBus');
                end

                ctrlNames=fieldnames(ctrlIn);
                if~isequal(numel(ctrlNames),3)
                    coder.internal.error('whdl:DVBS2LDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                    validateattributes(ctrlIn.start,{'logical'},...
                    {'scalar'},'DVBS2LDPCDecoder','start');
                else
                    coder.internal.error('whdl:DVBS2LDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                    validateattributes(ctrlIn.end,{'logical'},...
                    {'scalar'},'DVBS2LDPCDecoder','end');
                else
                    coder.internal.error('whdl:DVBS2LDPCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                    validateattributes(ctrlIn.valid,{'logical'},...
                    {'scalar'},'DVBS2LDPCDecoder','valid');
                else
                    coder.internal.error('whdl:DVBS2LDPCDecoder:InvalidSampleCtrlBus');
                end

                if(strcmpi(obj.FECFrameSource,'Property'))
                    if(strcmpi(obj.CodeRateSource,'Input port'))
                        rateidx=varargin{3};
                        validateattributes(rateidx,{'embedded.fi'},{'scalar','real'},'DVBS2LDPCDecoder','codeRateIdx');
                        if isa(rateidx,'embedded.fi')
                            if(issigned(rateidx))
                                coder.internal.error('whdl:DVBS2LDPCDecoder:InvalidCodeRateUnsignedType');
                            end
                            coder.internal.errorIf(...
                            ~((rateidx.WordLength==4)&&(rateidx.FractionLength==0)),...
                            'whdl:DVBS2LDPCDecoder:InvalidCodeRateType');
                        end
                        if strcmpi(obj.SpecifyInputs,'Input port')
                            niter=varargin{4};
                            validateattributes(niter,{'uint8'},{'scalar','real'},'DVBS2LDPCDecoder','Number of iterations');
                        end
                    end
                else
                    blklenidx=varargin{3};
                    rateidx=varargin{4};
                    validateattributes(blklenidx,{'boolean','logical'},{'scalar','real'},'DVBS2LDPCDecoder','fecFrameType');
                    validateattributes(rateidx,{'embedded.fi'},{'scalar','real'},'DVBS2LDPCDecoder','codeRateIdx');
                    if isa(rateidx,'embedded.fi')
                        if(issigned(rateidx))
                            coder.internal.error('whdl:DVBS2LDPCDecoder:InvalidCodeRateUnsignedType');
                        end
                        coder.internal.errorIf(...
                        ~((rateidx.WordLength==4)&&(rateidx.FractionLength==0)),...
                        'whdl:DVBS2LDPCDecoder:InvalidCodeRateType');
                    end
                    if strcmpi(obj.SpecifyInputs,'Input port')
                        niter=varargin{5};
                        validateattributes(niter,{'uint8'},{'scalar','real'},'DVBS2LDPCDecoder','Number of iterations');
                    end
                end
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            if strcmpi(obj.FECFrameSource,'Input port')
                props=[{'FECFrame'},{'CodeRateSource'},{'CodeRateNormal'},{'CodeRateShort'}];
            else
                if strcmpi(obj.FECFrame,'Normal')
                    props={'CodeRateShort'};
                    if strcmpi(obj.CodeRateSource,'Input port')
                        props=[props,{'CodeRateNormal'}];
                    end
                else
                    props={'CodeRateNormal'};
                    if strcmpi(obj.CodeRateSource,'Input port')
                        props=[props,{'CodeRateShort'}];
                    end
                end
            end
            if strcmpi(obj.Termination,'Max')
                props=[props,...
                {'MaxNumIterations'}];
                switch obj.SpecifyInputs
                case 'Input port'
                    props=[props,...
                    {'NumIterations'}];
                end
            end
            switch obj.Algorithm
            case 'Min-sum'
                props=[props,...
                {'ScalingFactor'}];
            end
            switch obj.Termination
            case 'Early'
                props=[props,...
                {'NumIterations'}];
                switch obj.SpecifyInputs
                case 'Input port'
                    props=[props,...
                    {'MaxNumIterations'}];
                end
            end
            flag=ismember(prop,props);
        end





        function varargout=getOutputDataTypeImpl(obj,varargin)
            if strcmpi(obj.Termination,'Early')
                varargout={'logical',samplecontrolbustype,numerictype(0,8,0),'logical','logical'};
            else
                varargout={'logical',samplecontrolbustype,'logical','logical'};
            end
        end



        function varargout=isOutputComplexImpl(obj)
            if strcmpi(obj.Termination,'Early')
                varargout={false,false,false,false,false,false,false,false};
            else
                varargout={false,false,false,false,false,false,false};
            end
        end



        function[sz1,sz2,sz3,sz4,sz5,sz6]=getOutputSizeImpl(obj)
            sz1=propagatedInputSize(obj,1);sz2=[1,1];sz3=[1,1];sz4=[1,1];sz5=[1,1];sz6=[1,1];
        end



        function varargout=isOutputFixedSizeImpl(obj)
            if strcmpi(obj.Termination,'Early')
                varargout={true,true,true,true,true,true,true,true};
            else
                varargout={true,true,true,true,true,true,true};
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.codeParameters=obj.codeParameters;
                s.ldpcDecoderCore=obj.ldpcDecoderCore;


                s.blkLenIdx=obj.blkLenIdx;
                s.codeRateIdx=obj.codeRateIdx;
                s.refIter=obj.refIter;
                s.nLayers=obj.nLayers;
                s.outLen=obj.outLen;
                s.invalidCodeRateIdx=obj.invalidCodeRateIdx;
                s.frameValid=obj.frameValid;
                s.countData=obj.countData;
                s.invalidLength=obj.invalidLength;
                s.maxCount=obj.maxCount;
                s.dataReg=obj.dataReg;
                s.ctrlReg=obj.ctrlReg;
                s.ctrlOutReg=obj.ctrlOutReg;
                s.memDepth=obj.memDepth;
                s.nLayersLUT=obj.nLayersLUT;
                s.nColumnsLUT=obj.nColumnsLUT;
                s.outLenLUT=obj.outLenLUT;
                s.degreeLUT=obj.degreeLUT;
                s.SF=obj.SF;
                s.alphaWL=obj.alphaWL;
                s.alphaFL=obj.alphaFL;


                s.dataOut=obj.dataOut;
                s.ctrlOut=obj.ctrlOut;
                s.iterOut=obj.iterOut;
                s.parCheck=obj.parCheck;
                s.nextFrame=obj.nextFrame;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

    end
end
