classdef APPDecoder<comm.gpu.internal.CUDAKernelSystemBase

    properties(Nontunable)

        TrellisStructure=poly2trellis(4,[13,15],13);
    end


    properties

        NumFrames(1,1){mustBePositive,mustBeInteger}=1;
    end


    properties(Access=private)
plannedNumFrames
    end

    properties(Access=private,Nontunable)
        pMaxStates=16;
    end

    properties(Access=private)
galpha
gbeta
galphaPS
gbetaPS
gprevOut
gnextOut
gprevLinIdx
gnextLinIdx
gOutSym1in
gOutSym0in
gNS_1in
gNS_0in
gframeSize
gnum2proc
gsubsegments
    end


    properties(Access=private)

        pKernel1params=struct('Name','appdecode_level1','TemplateOrder',{{'Type','NUMSTATES','N','ALGORITHM'}});
        pKernel2params=struct('Name','appdecode_level2','TemplateOrder',{{'Type','NUMSTATES','ALGORITHM'}});
        pKernel3params=struct('Name','appdecode_level3','TemplateOrder',{{'Type','NUMSTATES','N','ALGORITHM'}});

pKernel1
pKernel2
pKernel3

mDT
pSubsegments

lastFrameSize
templStruct

    end



    methods


        function obj=APPDecoder(varargin)
            setProperties(obj,nargin,varargin{:},'TrellisStructure');
        end

    end

    methods(Access=protected)

        function setupImpl(obj,LuI,LcI)

            detectGPUInputs(obj,LuI,LcI);


            mDT=underlyingType(LuI);
            mDT2=underlyingType(LcI);

            if~strcmp(mDT,mDT2)

                error(message('MATLAB:system:invalidDataType',2,mDT,mDT2));
            end


            gDT=comm.gpu.internal.getGPUDataType(mDT);


            templStruct.Type=gDT;
            templStruct.N=log2(obj.TrellisStructure.numOutputSymbols);
            templStruct.ALGORITHM=0;
            templStruct.NUMSTATES=obj.TrellisStructure.numStates;





            if~(obj.isRealBuiltinFloat(LcI)),
                error(message('comm:gpu:APPDecoder:InputMustBeFloat'));
            end


            if~(obj.isRealBuiltinFloat(LuI)),
                error(message('comm:gpu:APPDecoder:InputMustBeFloat'));
            end

            framesize=numel(LuI)./obj.NumFrames;
            obj.mDT=mDT;




            obj.templStruct=templStruct;
            makeKernels(obj,templStruct);
            makePlan(obj,framesize);
            setupKernelTrellisParams(obj);

        end

        function y=stepImpl(obj,LuI,LcI)

            if(numel(LcI)~=2*numel(LuI))
                error(message('MATLAB:system:invalidInputDims',2,numel(LuI),2*numel(LuI)));
            end
            if~iscolumn(LcI)||isempty(LcI)
                matlab.system.internal.error(...
                'MATLAB:system:inputMustBeColVector','X');
            end

            [gLuI,gLcI]=moveInputsToGPU(obj,LuI,LcI);

            if(obj.plannedNumFrames~=obj.NumFrames)

                framesize=numel(LuI)./obj.NumFrames;
                makePlan(obj,framesize);
            end

            galpha=obj.galpha;
            gbeta=obj.gbeta;
            galphaPS=obj.galphaPS;
            gbetaPS=obj.gbetaPS;
            gprevOut=obj.gprevOut;
            gnextOut=obj.gnextOut;
            gprevLinIdx=obj.gprevLinIdx;
            gnextLinIdx=obj.gnextLinIdx;
            gOutSym1in=obj.gOutSym1in;
            gOutSym0in=obj.gOutSym0in;
            gNS_1in=obj.gNS_1in;
            gNS_0in=obj.gNS_0in;
            gframeSize=obj.gframeSize;
            gnum2proc=obj.gnum2proc;
            gsubsegments=obj.gsubsegments;

            obj.galpha=gpuArray([]);
            obj.gbeta=gpuArray([]);
            obj.galphaPS=gpuArray([]);
            obj.gbetaPS=gpuArray([]);
            obj.gprevOut=gpuArray([]);
            obj.gnextOut=gpuArray([]);
            obj.gprevLinIdx=gpuArray([]);
            obj.gnextLinIdx=gpuArray([]);
            obj.gOutSym1in=gpuArray([]);
            obj.gOutSym0in=gpuArray([]);
            obj.gNS_1in=gpuArray([]);
            obj.gNS_0in=gpuArray([]);
            obj.gframeSize=gpuArray([]);
            obj.gnum2proc=gpuArray([]);
            obj.gsubsegments=gpuArray([]);

            blkLen=numel(LuI)/obj.NumFrames;

            y=gpuArray.zeros(blkLen*obj.NumFrames,1,obj.mDT);


            [galpha,gbeta,galphaPS,gbetaPS]=feval(obj.pKernel1,...
            galpha,gbeta,galphaPS,...
            gbetaPS,gLuI,gLcI,gprevOut,...
            gnextOut,gprevLinIdx,...
            gnextLinIdx,gnum2proc,gframeSize);

            [galphaPS,gbetaPS]=feval(obj.pKernel2,galphaPS,gbetaPS,gsubsegments);

            y=feval(obj.pKernel3,y,galpha,...
            gbeta,galphaPS,gbetaPS,gLuI,gLcI,gOutSym1in,...
            gOutSym0in,gNS_1in,gNS_0in,gframeSize,gnum2proc,uint32(gsubsegments));


            y=obj.moveOutputsIfNeeded(y);

            obj.galpha=galpha;
            obj.gbeta=gbeta;
            obj.galphaPS=galphaPS;
            obj.gbetaPS=gbetaPS;
            obj.gprevOut=gprevOut;
            obj.gnextOut=gnextOut;
            obj.gprevLinIdx=gprevLinIdx;
            obj.gnextLinIdx=gnextLinIdx;
            obj.gOutSym1in=gOutSym1in;
            obj.gOutSym0in=gOutSym0in;
            obj.gNS_1in=gNS_1in;
            obj.gNS_0in=gNS_0in;
            obj.gframeSize=gframeSize;
            obj.gnum2proc=gnum2proc;
            obj.gsubsegments=gsubsegments;

        end
    end

    methods(Access=private)

        [funcname,ptxfile,cproto]=dispatch(obj,dispatchKey);
    end

    methods(Access=private)
        function setupKernelTrellisParams(obj)
            trellis=obj.TrellisStructure;
            numStates=trellis.numStates;
            outputs=oct2dec(trellis.outputs);
            nextStates=trellis.nextStates;
            n=log2(trellis.numOutputSymbols);
            k=log2(trellis.numInputSymbols);

            modifiedOutputs=outputs;
            modifiedOutputs(:,2)=modifiedOutputs(:,2)+(2^n);
            [prevState,prevOutput]=getPrevious(nextStates,modifiedOutputs);

            prevLinIdx=sub2ind([numStates,numStates],repmat((1:numStates)',2^k,1),prevState(:)+1);
            obj.gprevLinIdx=gpuArray(uint32(prevLinIdx-1));
            obj.gprevOut=gpuArray(uint32(prevOutput(:)));



            nextLinIdx=sub2ind([numStates,numStates],repmat((1:numStates)',2^k,1),nextStates(:)+1);

            obj.gnextLinIdx=gpuArray(uint32(nextLinIdx-1));
            obj.gnextOut=gpuArray(uint32(modifiedOutputs));

            obj.gOutSym1in=gpuArray(uint32(outputs(:,2)));
            obj.gOutSym0in=gpuArray(uint32(outputs(:,1)));
            obj.gNS_1in=gpuArray(uint32(nextStates(:,2)));
            obj.gNS_0in=gpuArray(uint32(nextStates(:,1)));
        end
        function makeKernels(obj,templStruct)
            obj.pKernel1=makeAPPKernel(obj,obj.pKernel1params,templStruct);
            obj.pKernel2=makeAPPKernel(obj,obj.pKernel2params,templStruct);
            obj.pKernel3=makeAPPKernel(obj,obj.pKernel3params,templStruct);
        end
        function[subsegments,num2proc]=makePlan(obj,frameSize)
            templStruct=obj.templStruct;

            if(obj.NumFrames>obj.kMaxGridSize)
                error(message('comm:gpu:APPDecoder:TooManyFrames'));
            end
            if(templStruct.NUMSTATES==16),
                subsegments=ceil(sqrt(frameSize));
                num2proc=ceil(frameSize/subsegments);

                tbsize=[16,2,2];

                obj.pKernel1.ThreadBlockSize=tbsize;
                obj.pKernel1.GridSize=[subsegments,2*obj.NumFrames];


                obj.pKernel2.ThreadBlockSize=tbsize;
                obj.pKernel2.GridSize=[1,2*obj.NumFrames];


                symbolsPerBlock=4;
                obj.pKernel3.ThreadBlockSize=[16,symbolsPerBlock];
                obj.pKernel3.GridSize=[ceil(frameSize/symbolsPerBlock),obj.NumFrames];
            else
                subsegments=ceil(sqrt(frameSize));
                num2proc=ceil(frameSize/subsegments);
                symbolsPerBlock=64/templStruct.NUMSTATES;

                tbsize=[templStruct.NUMSTATES,symbolsPerBlock];

                obj.pKernel1.ThreadBlockSize=tbsize;
                obj.pKernel1.GridSize=[subsegments,2*obj.NumFrames];


                obj.pKernel2.ThreadBlockSize=tbsize;
                obj.pKernel2.GridSize=[1,2*obj.NumFrames];


                obj.pKernel3.ThreadBlockSize=tbsize;

                obj.pKernel3.GridSize=[ceil(frameSize/symbolsPerBlock),obj.NumFrames];
            end
            if((ceil(frameSize/symbolsPerBlock)>obj.kMaxGridSize)||...
                (subsegments>obj.kMaxGridSize)),
                error(message('comm:gpu:APPDecoder:FrameSizeTooLarge'));
            end

            mDT=obj.mDT;
            matrixSize=templStruct.NUMSTATES*templStruct.NUMSTATES;
            obj.galpha=gpuArray.zeros(1,obj.NumFrames*frameSize*matrixSize,mDT);
            obj.gbeta=gpuArray.zeros(1,obj.NumFrames*frameSize*matrixSize,mDT);
            obj.galphaPS=gpuArray.zeros(1,obj.NumFrames*subsegments*matrixSize,mDT);
            obj.gbetaPS=gpuArray.zeros(1,obj.NumFrames*subsegments*matrixSize,mDT);
            obj.gframeSize=gpuArray(cast(frameSize,'uint32'));
            obj.gnum2proc=gpuArray(cast(num2proc,'uint32'));
            obj.gsubsegments=gpuArray(cast(subsegments,'uint32'));
            obj.pSubsegments=subsegments;
            obj.plannedNumFrames=obj.NumFrames;
        end

        function ker=makeAPPKernel(obj,kernelParamStruct,templS)
            dispatchKey=obj.makeTmplFuncName(kernelParamStruct,templS);
            try
                [funcname,ptxfile,cproto]=dispatch(obj,dispatchKey);
            catch



                error(message('comm:system:TurboDecoder:UnsupportedMode'));
            end
            kerFile=makePTXFilename(obj,ptxfile);



            ker=parallel.gpu.CUDAKernel(kerFile,cproto,funcname);
        end

    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
        end
    end

    methods
        function set.NumFrames(obj,v)
            validateattributes(v,{'numeric'},...
            {'positive','integer','scalar',...
            'finite','real'},'NumFrames');
            obj.NumFrames=v;
        end
        function set.TrellisStructure(obj,T)

            if~istrellis(T),
                error(message('comm:system:TurboDecoder:BadTrellis'));
            end

            k=log2(T.numInputSymbols);
            n=log2(T.numOutputSymbols);

            badrate=true;
            supportedRates=[1,2;1,3;1,4];
            for ii=1:size(supportedRates,1),
                if(isequal(supportedRates(ii,:),[k,n])),
                    badrate=false;
                end
            end

            if(badrate),
                error(message('comm:system:TurboDecoder:UnsupportedRate'));
            end


            if((T.numStates>obj.pMaxStates)||(T.numStates<2)),
                error(message('comm:system:TurboDecoder:UnsupportedConstraintLength'));

            end
            obj.TrellisStructure=T;
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=2;
        end
        function flag=isInputSizeMutableImpl(obj,~)
            flag=true;
        end
        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end
    end
    methods(Static,Hidden)
        function b=generatesCode
            b=false;
        end
        function s=makeTmplFuncName(kernelParamStruct,templS)
            ord=kernelParamStruct.TemplateOrder;
            funcname=kernelParamStruct.Name;


            templC={};
            for ii=1:numel(ord),
                templC{ii}=templS.(ord{ii});
            end
            templsurround={'T','T_'};
            funcsurround={'X_','T_X'};
            s=[funcname,funcsurround{1}];

            for ii=1:(numel(templC)-1),
                x=templC{ii};
                if isnumeric(x),
                    x=num2str(x);
                end
                s=[s,templsurround{1},x,templsurround{2}];%#ok<AGROW>
            end
            x=templC{end};
            if isnumeric(x),
                x=num2str(x);
            end
            s=[s,templsurround{1},x,funcsurround{2}];
        end
    end
end

function[prevState,prevOutput]=getPrevious(nextStates,outputs)

    prevState=[];
    for ii=0:max(nextStates(:)),
        [x,~]=find(nextStates==ii);
        prevState=[prevState;(x-1)'];
    end
    prevState=uint32(prevState);
    prevOutput=[];
    for ii=0:max(nextStates(:)),
        y=find(nextStates==ii);
        prevOutput=[prevOutput;outputs(y)'];
    end
    prevState=double(prevState);

end



