classdef(StrictDefaults)TurboDecoder<comm.gpu.internal.CUDAKernelSystemBase



































































































    properties(Nontunable)







        TrellisStructure=poly2trellis(4,[13,15],13);



        InterleaverIndicesSource='Property';






        InterleaverIndices=(64:-1:1).';



        Algorithm='True APP';


        NumScalingBits(1,1){mustBePositive,mustBeInteger}=3;






        NumIterations(1,1){mustBePositive,mustBeInteger}=6;





        NumFrames(1,1){mustBePositive,mustBeInteger}=1;
    end

    properties(Constant,Hidden)
        InterleaverIndicesSourceSet=matlab.system.StringSet({'Property'});
        AlgorithmSet=matlab.system.StringSet({'True APP'});
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


gAPP1LcI
gAPP1LuI

gAPP2LcI
gAPP2LuI




gSystematic_SR
gSystematic_SA
gEnc2_SR
gEnc1_SR

gEnc_SA



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
pN
pMLen
pNumTails


    end


    methods

        function obj=TurboDecoder(varargin)
            setProperties(obj,nargin,varargin{:},'TrellisStructure',...
            'InterleaverIndices','NumIterations');
        end

    end

    methods(Access=protected)


        function setupImpl(obj,LcI)
            detectGPUInputs(obj,LcI);

            if~iscolumn(LcI)||isempty(LcI)
                matlab.system.internal.error(...
                'MATLAB:system:inputMustBeColVector','X');
            end

            if~(obj.isRealBuiltinFloat(LcI))
                error(message('comm:system:TurboDecoder:BadInputType'));
            end

            mDT=underlyingType(LcI);


            gDT=comm.gpu.internal.getGPUDataType(mDT);


            templStruct.Type=gDT;
            templStruct.N=log2(obj.TrellisStructure.numOutputSymbols);
            templStruct.ALGORITHM=0;
            templStruct.NUMSTATES=obj.TrellisStructure.numStates;

            T=obj.TrellisStructure;
            obj.pN=log2(T.numOutputSymbols);
            obj.pMLen=log2(T.numStates);
            obj.pNumTails=obj.pMLen*(obj.pN);









            frameSize=...
            (((numel(LcI)/obj.NumFrames)-2*obj.pNumTails)/(2*obj.pN-1));

            if((mod(frameSize,numel(obj.InterleaverIndices))~=0)||...
                (frameSize<numel(obj.InterleaverIndices)))


                error(message('comm:system:TurboDecoder:BadInputLength'));
            end




            msgAndTailsSize=frameSize+obj.pMLen;
            [subsegments,num2proc]=makePlan(obj,templStruct,msgAndTailsSize);






            matrixSize=templStruct.NUMSTATES*templStruct.NUMSTATES;

            setupKernelTrellisParams(obj);

            obj.galpha=gpuArray.zeros(1,obj.NumFrames*msgAndTailsSize*matrixSize,mDT);
            obj.gbeta=gpuArray.zeros(1,obj.NumFrames*msgAndTailsSize*matrixSize,mDT);
            obj.galphaPS=gpuArray.zeros(1,obj.NumFrames*subsegments*matrixSize,mDT);
            obj.gbetaPS=gpuArray.zeros(1,obj.NumFrames*subsegments*matrixSize,mDT);
            obj.gframeSize=gpuArray(cast(msgAndTailsSize,'uint32'));
            obj.gnum2proc=gpuArray(cast(num2proc,'uint32'));
            obj.gsubsegments=gpuArray(cast(subsegments,'uint32'));

            obj.mDT=mDT;
            obj.pSubsegments=subsegments;



            blkLen=numel(obj.InterleaverIndices);

            gFalseMat2Enc=gpuArray.false((obj.pN*2-1),blkLen);
            gFalseMat=gpuArray.false(obj.pN,blkLen);

            obj.gSystematic_SR=gFalseMat2Enc;
            obj.gSystematic_SR(1,:)=true;
            obj.gSystematic_SR=reshape(obj.gSystematic_SR,[],1);

            obj.gSystematic_SA=gFalseMat;
            obj.gSystematic_SA(1,:)=true;
            obj.gSystematic_SA=reshape(obj.gSystematic_SA,[],1);

            obj.gEnc2_SR=gFalseMat2Enc;
            obj.gEnc2_SR((obj.pN+1):end,:)=true;
            obj.gEnc2_SR=reshape(obj.gEnc2_SR,[],1);


            obj.gEnc1_SR=gFalseMat2Enc;
            obj.gEnc1_SR(2:obj.pN,:)=true;
            obj.gEnc1_SR=reshape(obj.gEnc1_SR,[],1);


            obj.gEnc_SA=gFalseMat;
            obj.gEnc_SA(2:(obj.pN),:)=true;
            obj.gEnc_SA=reshape(obj.gEnc_SA,[],1);



            sysTails=false(2*obj.pNumTails,1);
            enc2Tails=[false(obj.pNumTails,1);true(obj.pNumTails,1)];
            enc1Tails=[true(obj.pNumTails,1);false(obj.pNumTails,1)];

            obj.gEnc2_SR(end+1:end+2*obj.pNumTails)=gpuArray(enc2Tails);
            obj.gEnc1_SR(end+1:end+2*obj.pNumTails)=gpuArray(enc1Tails);
            obj.gSystematic_SR(end+1:end+2*obj.pNumTails)=gpuArray(sysTails);


            obj.gSystematic_SA(end+1:end+obj.pNumTails)=false;
            obj.gEnc_SA(end+1:end+obj.pNumTails)=true;




        end







        function y=stepImpl(obj,x)
            gx=moveInputsToGPU(obj,x);

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

            blkLen=numel(obj.InterleaverIndices);
            gOutput1=gpuArray.zeros(blkLen+obj.pMLen,obj.NumFrames,obj.mDT);
            gOutput2=gpuArray.zeros(blkLen+obj.pMLen,obj.NumFrames,obj.mDT);


            LuI1=gpuArray.zeros(blkLen+obj.pMLen,obj.NumFrames,obj.mDT);



            LcI1=gpuArray.zeros(obj.pN*blkLen+obj.pNumTails,obj.NumFrames,obj.mDT);
            LcI2=gpuArray.zeros(obj.pN*blkLen+obj.pNumTails,obj.NumFrames,obj.mDT);

            gx=reshape(gx,[],obj.NumFrames);

            tmp=gx(obj.gSystematic_SR,:);

            LcI1(obj.gSystematic_SA,:)=tmp;
            LcI1(obj.gEnc_SA,:)=gx(obj.gEnc1_SR,:);

            LcI2(obj.gSystematic_SA,:)=gpuArray.zeros(blkLen,obj.NumFrames,obj.mDT);
            LcI2(obj.gEnc_SA,:)=gx(obj.gEnc2_SR,:);

            tmp(:)=0;
            out=gpuArray.zeros(blkLen,obj.NumFrames);



            for ii=1:obj.NumIterations


                [galpha,gbeta,galphaPS,gbetaPS]=feval(obj.pKernel1,galpha,gbeta,galphaPS,gbetaPS,LuI1,LcI1,gprevOut,gnextOut,gprevLinIdx,gnextLinIdx,gnum2proc,gframeSize);


                [galphaPS,gbetaPS]=feval(obj.pKernel2,galphaPS,gbetaPS,gsubsegments);
                [gOutput1]=feval(obj.pKernel3,gOutput1,galpha,gbeta,galphaPS,gbetaPS,LuI1,LcI1,gOutSym1in,...
                gOutSym0in,gNS_1in,gNS_0in,gframeSize,gnum2proc,uint32(gsubsegments));



                tmp=gOutput1(obj.InterleaverIndices,:);

                LuI2=[tmp;gpuArray.zeros(obj.pMLen,obj.NumFrames,obj.mDT)];

                [galpha,gbeta,galphaPS,gbetaPS]=feval(obj.pKernel1,galpha,gbeta,galphaPS,gbetaPS,LuI2,LcI2,gprevOut,gnextOut,gprevLinIdx,gnextLinIdx,gnum2proc,gframeSize);


                [galphaPS,gbetaPS]=feval(obj.pKernel2,galphaPS,gbetaPS,gsubsegments);
                [gOutput2]=feval(obj.pKernel3,gOutput2,galpha,gbeta,galphaPS,gbetaPS,LuI2,LcI2,gOutSym1in,...
                gOutSym0in,gNS_1in,gNS_0in,gframeSize,gnum2proc,uint32(gsubsegments));



                out(obj.InterleaverIndices,:)=gOutput2(1:blkLen,:);
                LuI1=[out;gpuArray.zeros(obj.pMLen,obj.NumFrames,obj.mDT)];
            end

            llr=out+gOutput1(1:blkLen,:);
            harddec=cast((llr>=0),obj.mDT);
            y=obj.moveOutputsIfNeeded(reshape(harddec,[],1));








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


        function[subsegments,num2proc]=makePlan(obj,templStruct,frameSize)



            obj.pKernel1=makeAPPKernel(obj,obj.pKernel1params,templStruct);
            obj.pKernel2=makeAPPKernel(obj,obj.pKernel2params,templStruct);
            obj.pKernel3=makeAPPKernel(obj,obj.pKernel3params,templStruct);



            if(obj.NumFrames>obj.kMaxGridSize)
                error(message('comm:gpu:TurboDecoder:TooManyFrames'));
            end




            if(templStruct.NUMSTATES==16)
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
                (subsegments>obj.kMaxGridSize))
                error(message('comm:gpu:TurboDecoder:FrameSizeTooLarge'));
            end


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
            switch prop

            case 'NumScalingBits'
                flag=true;
            end
        end
    end

    methods
        function set.InterleaverIndices(obj,value)
            validateattributes(value,...
            {'numeric'},{'real','finite','positive','integer',...
            'vector'},'','InterleaverIndices');%#ok<EMCA>
            if(~isequal(reshape(1:numel(value),[],1),...
                reshape(sort(value),[],1)))
                error(message('comm:system:TurboDecoder:BadInterleaverIndices'));
            end

            obj.InterleaverIndices=value;
        end

        function set.NumScalingBits(obj,value)
            validateattributes(value,...
            {'numeric'},{'real','finite','nonnegative','integer',...
            'scalar','>=',0,'<=',8},'','NumScalingBits');%#ok<EMCA>
            obj.NumScalingBits=value;
        end

        function set.NumIterations(obj,value)
            validateattributes(value,...
            {'numeric'},{'real','finite','positive','integer',...
            'scalar'},'','NumIterations');%#ok<EMCA>
            obj.NumIterations=value;
        end

        function set.NumFrames(obj,v)
            validateattributes(v,{'numeric'},...
            {'positive','integer','scalar',...
            'finite','real'},'NumFrames');
            obj.NumFrames=v;
        end

        function set.TrellisStructure(obj,T)

            if~istrellis(T)
                error(message('comm:system:TurboDecoder:BadTrellis'));
            end

            k=log2(T.numInputSymbols);
            n=log2(T.numOutputSymbols);

            badrate=true;
            supportedRates=[1,2;1,3;1,4];
            for ii=1:size(supportedRates,1)
                if(isequal(supportedRates(ii,:),[k,n]))
                    badrate=false;
                end
            end

            if(badrate)
                error(message('comm:system:TurboDecoder:UnsupportedRate'));
            end


            if((T.numStates>obj.pMaxStates)||(T.numStates<2))
                error(message('comm:system:TurboDecoder:UnsupportedConstraintLength'));

            end
            obj.TrellisStructure=T;

        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=1;
        end

        function flag=isInputSizeMutableImpl(obj,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end
    end


    methods(Access=protected)

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=numel(obj.InterleaverIndices)*obj.NumFrames;
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=propagatedInputDataType(obj,1);
        end

        function varargout=isOutputComplexImpl(obj)%#ok
            varargout{1}=false;
        end

        function varargout=isOutputFixedSizeImpl(obj)%#ok
            varargout{1}=true;
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
            for ii=1:numel(ord)
                templC{ii}=templS.(ord{ii});
            end
            templsurround={'T','T_'};
            funcsurround={'X_','T_X'};
            s=[funcname,funcsurround{1}];

            for ii=1:(numel(templC)-1)
                x=templC{ii};
                if isnumeric(x)
                    x=num2str(x);
                end
                s=[s,templsurround{1},x,templsurround{2}];%#ok<AGROW>
            end
            x=templC{end};
            if isnumeric(x)
                x=num2str(x);
            end

            s=[s,templsurround{1},x,funcsurround{2}];
        end

    end
end

function[prevState,prevOutput]=getPrevious(nextStates,outputs)

    prevState=[];
    for ii=0:max(nextStates(:))
        [x,~]=find(nextStates==ii);
        prevState=[prevState;(x-1)'];
    end
    prevState=uint32(prevState);
    prevOutput=[];
    for ii=0:max(nextStates(:))
        y=find(nextStates==ii);
        prevOutput=[prevOutput;outputs(y)'];
    end
    prevState=double(prevState);

end


