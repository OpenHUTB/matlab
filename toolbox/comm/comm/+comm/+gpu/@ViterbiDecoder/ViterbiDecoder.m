classdef(StrictDefaults)ViterbiDecoder<comm.gpu.internal.CUDAKernelSystemBase






























































































    properties(Nontunable)








        TrellisStructure=poly2trellis(7,[171,133]);

















        InputFormat='Unquantized';




        SoftInputWordLength(1,1){mustBePositive,mustBeInteger}=4;


        InvalidQuantizedInputAction='Ignore';














        TracebackDepth(1,1){mustBePositive,mustBeInteger}=34;















        TerminationMethod='Continuous';






        ResetInputPort(1,1)logical=false;



        DelayedResetAction(1,1)logical=false;






        PuncturePatternSource='None';







        PuncturePattern=[1;1;0;1;0;1];


        ErasuresInputPort=false;



        OutputDataType='Full precision';







        NumFrames(1,1){mustBePositive,mustBeInteger}=1;
    end

    properties(Constant,Hidden)
        InputFormatSet=matlab.system.StringSet({'Unquantized','Hard','Soft'});
        TerminationMethodSet=comm.CommonSets.getSet('TerminationMethod');
        PuncturePatternSourceSet=comm.CommonSets.getSet('NoneOrProperty');
        InvalidQuantizedInputActionSet=matlab.system.StringSet({'Ignore'});
        OutputDataTypeSet=matlab.system.StringSet({'Full precision'});


    end
    properties(Constant,GetAccess=private)


        MaxStates=256;
        MaxTraceback=256;
        MaxRegistersPerThread=64;
        GPUCompiledArch=1.3;
    end


    properties(Access=private)
        gStateMetric;
        gTraceBack;
gMaxOne
gPrevState
gOutputSym
gPuncPatternLength
gPuncPattern
gDout
gAcqDep
gTracebackDepth
gInputBlockSize
gNumToProcess
gSizeDin
gSizeDout
gMode
    end

    properties(Access=private)
pAcquisitionDepth
        pKernel;
pStateMetricInit
    end




    methods
        function obj=ViterbiDecoder(varargin)
            setProperties(obj,nargin,varargin{:},'TrellisStructure');
        end
    end

    methods(Access=private)

        [funcname,ptxfile,cproto]=dispatch(obj,dispatchKey);


        function Tord=templateOrder(obj)%#ok<MANU>


            Tord={'Type','K','TB','N'};
        end


        function s=makeTmplFuncName(obj,funcname,templS)
            ord=templateOrder(obj);
            templC=cell(numel(fieldnames(templS)),1);
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

        function updateAcquisitionDepth(obj)
            constraintK=log2(obj.TrellisStructure.numStates)+1;
            obj.pAcquisitionDepth=max(2*obj.TracebackDepth,2*5*(constraintK));
        end

        function makePlan(obj,templStruct)


            constraintKminus1=log2(obj.TrellisStructure.numStates);

            dispatchKey=obj.makeTmplFuncName('vit',templStruct);
            try
                [funcname,ptxfile,cproto]=dispatch(obj,dispatchKey);
            catch



                error(message('comm:system:ViterbiDecoder:UnsupportedMode'));
            end
            kerFile=makePTXFilename(obj,ptxfile);



            obj.pKernel=parallel.gpu.CUDAKernel(kerFile,cproto,funcname);




            threads=2^constraintKminus1;
            obj.pKernel.ThreadBlockSize=[threads,1,1];

            dev=gpuDevice;




            smBytes=obj.pKernel.StaticSharedMemorySize;


            numRegs=obj.pKernel.NumRegistersPerThread;


            maxBlocksPerMP=comm.gpu.internal.computeMaxBlocksPerMP(...
            threads,numRegs,smBytes,...
            str2double(dev.ComputeCapability));


            gridmax=maxBlocksPerMP*dev.MultiprocessorCount;
            gridmax=max(gridmax,1);

            if~strcmpi(obj.TerminationMethod,'Continuous')

                blksPerRow=floor(gridmax/obj.NumFrames);
                if blksPerRow<1
                    blksPerRow=1;
                end
                if(obj.NumFrames>obj.kMaxGridSize)
                    error(message('comm:gpu:ViterbiDecoder:TooManyFrames'));
                end
                obj.pKernel.GridSize=[blksPerRow,obj.NumFrames];

            else
                obj.pKernel.GridSize=gridmax;
            end


        end

        function setupKernelParams(obj,templStruct,mDT,sz)


            switch obj.InputFormat
            case 'Unquantized'
                obj.gMaxOne=gpuArray(uint32(0));
            case 'Hard'
                obj.gMaxOne=gpuArray(uint32(1));
            case 'Soft'
                obj.gMaxOne=gpuArray(uint32((2^obj.SoftInputWordLength)-1));

            end



            [framelen,localnumframe]=getFrameSize(obj,sz(1));

            tmpPuncPat=getInternalPuncPat(obj);
            symSize=getSymbolSize(obj);
            puncPatLen=numel(tmpPuncPat);




            obj.pStateMetricInit=[0,repmat(realmax(mDT),1,(obj.pKernel.ThreadBlockSize(1)-1))];



            prevState=[];
            for ii=0:max(obj.TrellisStructure.nextStates(:))
                [x,~]=find(obj.TrellisStructure.nextStates==ii);
                prevState=[prevState;(x-1)'];%#ok<AGROW>
            end
            prevOutput=[];
            for ii=0:max(obj.TrellisStructure.nextStates(:))
                y=find(obj.TrellisStructure.nextStates==ii);
                prevOutput=[prevOutput;obj.TrellisStructure.outputs(y)'];%#ok<AGROW>
            end
            osym=oct2dec(prevOutput(:));


            numelDout=computeOutputSize(obj,framelen,puncPatLen,symSize);


            gridX=obj.pKernel.GridSize(1);
            numel2proc=ceil((framelen/symSize)/gridX);

            switch obj.TerminationMethod
            case 'Continuous'
                obj.gMode=gpuArray(uint32(1));
            case 'Truncated'
                obj.gMode=gpuArray(uint32(2));
            case 'Terminated'
                obj.gMode=gpuArray(uint32(3));
            end



            obj.gStateMetric=gpuArray(obj.pStateMetricInit);

            obj.gTraceBack=gpuArray.zeros(1,...
            templStruct.TB*obj.pKernel.ThreadBlockSize(1),'uint32');

            obj.gPrevState=gpuArray(uint32(prevState));
            obj.gOutputSym=gpuArray(uint32(osym));
            obj.gPuncPatternLength=gpuArray(uint32(puncPatLen));

            obj.gPuncPattern=gpuArray([tmpPuncPat;false(16-puncPatLen,1)]);
            obj.gDout=gpuArray.zeros(numelDout*localnumframe,1,mDT);

            obj.gAcqDep=gpuArray(uint32(obj.pAcquisitionDepth));
            obj.gInputBlockSize=gpuArray(uint32(symSize));
            obj.gNumToProcess=gpuArray(uint64(numel2proc));
            obj.gSizeDin=gpuArray(uint64(framelen));
            obj.gSizeDout=gpuArray(uint64(numelDout));
            obj.gTracebackDepth=gpuArray(uint32(obj.TracebackDepth));
        end

        function[framelen,localnumframe]=getFrameSize(obj,insize)
            if strcmpi(obj.TerminationMethod,'Continuous')
                framelen=insize;
                localnumframe=1;
            else
                framelen=insize/obj.NumFrames;
                localnumframe=obj.NumFrames;
            end
        end
        function symSize=getSymbolSize(obj)
            if strcmpi(obj.PuncturePatternSource,'None')
                n=log2(obj.TrellisStructure.numOutputSymbols);
                symSize=n;
            else
                privPP=obj.getPrivPuncturePattern;
                symSize=sum(privPP);
            end
        end

        function pp=getInternalPuncPat(obj)
            if strcmpi(obj.PuncturePatternSource,'None')
                n=log2(obj.TrellisStructure.numOutputSymbols);
                pp=true(n,1);
            else
                pp=logical(obj.getPrivPuncturePattern);
            end
        end


        function sz=computeOutputSize(obj,framelen,puncPatLen,symSize)
            n=log2(obj.TrellisStructure.numOutputSymbols);
            symsPerPP=puncPatLen/n;
            numdoutSyms=(framelen/symSize)*symsPerPP;

            ratek=log2(obj.TrellisStructure.numInputSymbols);
            sz=numdoutSyms*ratek;

        end


        function setPrivPuncturePattern(obj)





        end
        function x=getPrivPuncturePattern(obj)



            x=obj.PuncturePattern;

        end



        function tf=inResetMode(obj)
            tf=((obj.ResetInputPort)&&strcmpi(obj.TerminationMethod,'Continuous'));
        end
    end

    methods(Access=protected)
        function resetImpl(obj)
            obj.gStateMetric=gpuArray(obj.pStateMetricInit);
            obj.gTraceBack=gpuArray.zeros(1,...
            ceil(obj.TracebackDepth/32)*obj.pKernel.ThreadBlockSize(1),'uint32');
        end
        function out=stepImpl(obj,varargin)
            gDin=moveInputsToGPU(obj,varargin{:});


            obj.pKernel.setConstantMemory(...
            'PuncturePattern',obj.gPuncPattern);



            if(obj.inResetMode)
                if(varargin{2})
                    obj.gStateMetric=gpuArray(obj.pStateMetricInit);

                    obj.gTraceBack=gpuArray.zeros(1,...
                    ceil(obj.TracebackDepth/32)*obj.pKernel.ThreadBlockSize(1),'uint32');
                end
            end;

            if~strcmpi(obj.InputFormat,'Unquantized')
                gDin=fix(gDin);

            end

            [obj.gDout,obj.gTraceBack,obj.gStateMetric]=feval(obj.pKernel,...
            obj.gDout,...
            gDin,...
            obj.gTraceBack,...
            obj.gStateMetric,...
            obj.gOutputSym,...
            obj.gPrevState,...
            obj.gAcqDep,...
            obj.gTracebackDepth,...
            obj.gMaxOne,...
            obj.gMode,...
            obj.gPuncPatternLength,...
            obj.gInputBlockSize,...
            obj.gNumToProcess,...
            obj.gSizeDin,...
            obj.gSizeDout...
            );

            out=obj.moveOutputsIfNeeded(obj.gDout);


        end

        function setupImpl(obj,varargin)

            in=varargin{1};
            detectGPUInputs(obj,varargin{:});



            if~iscolumn(in)||isempty(in)
                matlab.system.internal.error(...
                'MATLAB:system:inputMustBeColVector','X');
            end


            if~(obj.isRealBuiltinFloat(in))
                error(message('comm:system:ViterbiDecoder:BadInputType'));
            end




            mDT=underlyingType(in);
            sz=size(in);

            gDT=comm.gpu.internal.getGPUDataType(mDT);




            templStruct.Type=gDT;
            templStruct.K=(obj.TrellisStructure.numInputSymbols);
            templStruct.TB=ceil(obj.TracebackDepth/32);
            templStruct.N=log2(obj.TrellisStructure.numOutputSymbols);


            if~strcmpi(obj.TerminationMethod,'Continuous')
                framesize=sz(1)/obj.NumFrames;
            else
                framesize=sz(1);
            end

            numOnesPP=sum(obj.PuncturePattern);
            numelPP=numel(obj.PuncturePattern);






            if~strcmpi(obj.TerminationMethod,'Continuous')
                if(mod(sz(1),obj.NumFrames)~=0)
                    error(message('comm:system:ViterbiDecoder:BadNumFrames'));
                end




                if strcmpi(obj.PuncturePatternSource,'None')
                    symsInInput=framesize/templStruct.N;
                else
                    depuncInSize=framesize*numelPP/numOnesPP;
                    symsInInput=depuncInSize/templStruct.N;
                end
                if(symsInInput<obj.TracebackDepth)
                    error(message('comm:system:ViterbiDecoder:BadNonContInputLength'));
                end
            end


            if strcmpi(obj.PuncturePatternSource,'None')

                multN=(mod(framesize,templStruct.N)==0);
                if~(multN)
                    error(message('comm:system:ViterbiDecoder:BadInputLength'));
                end

            else



                multPP=(mod(framesize,numOnesPP)==0);


                depuncSize=(framesize/numOnesPP)*numelPP;
                multN=(mod(depuncSize,templStruct.N)==0);

                if~(multN&&multPP)
                    error(message('comm:system:ViterbiDecoder:BadPuncturedInputLength'));
                end
            end

            if(obj.inResetMode)

                if~(isscalar(varargin{2})&&(obj.isfloat(varargin{2})||...
                    obj.islogical(varargin{2})))
                    error(message('comm:system:ViterbiDecoder:BadResetInput'));
                end
            end





            setPrivPuncturePattern(obj);


            updateAcquisitionDepth(obj);


            makePlan(obj,templStruct);



            setupKernelParams(obj,templStruct,mDT,sz)

        end

        function s=infoImpl(obj)



















            pp=getPrivPuncturePattern(obj);
            updateAcquisitionDepth(obj);
            if strcmpi(obj.PuncturePatternSource,'None')

                s.AcquisitionDepth=obj.pAcquisitionDepth;
            else

                n=log2(obj.TrellisStructure.numOutputSymbols);
                scalefac=numel(pp)/n;
                s.AcquisitionDepth=(obj.pAcquisitionDepth)*scalefac;
            end
        end


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'SoftInputWordLength'
                flag=~strcmpi(obj.InputFormat,'Soft');
            case 'ResetInputPort'
                flag=~strcmpi(obj.TerminationMethod,'Continuous');
            case 'PuncturePattern'
                flag=strcmpi(obj.PuncturePatternSource,'None');



            case 'NumFrames'
                flag=strcmpi(obj.TerminationMethod,'Continuous');



            case 'DelayedResetAction'
                flag=~inResetMode(obj);

            case 'InvalidQuantizedInputAction'
                flag=strcmpi(obj.InputFormat,'Unquantized');

            case 'ErasuresInputPort'
                flag=false;

            case 'OutputDataType'
                flag=false;
            end

        end


        function num=getNumInputsImpl(obj)
            if inResetMode(obj)
                num=2;
            else
                num=1;
            end
        end

        function num=getNumOutputsImpl(obj)%#ok<MANU>
            num=1;
        end

        function validatePropertiesImpl(obj)
            if strcmpi(obj.PuncturePatternSource,'Property')
                codewordSize=log2(obj.TrellisStructure.numOutputSymbols);
                pplen=numel(obj.PuncturePattern);
                if(mod(pplen,codewordSize)~=0)
                    error(message('comm:system:ViterbiDecoder:BadPuncturePatternLength'));
                end
            end
        end
    end


    methods(Access=protected)

        function numelDout=getOutputSizeImpl(obj)

            sz=propagatedInputSize(obj,1);

            [framelen,~]=getFrameSize(obj,sz(1));

            tmpPuncPat=getInternalPuncPat(obj);
            symSize=getSymbolSize(obj);
            puncPatLen=numel(tmpPuncPat);


            numelDout=[computeOutputSize(obj,framelen,puncPatLen,symSize),1];
        end

        function outtype=getOutputDataTypeImpl(obj)
            outtype=propagatedInputDataType(obj,1);
        end

        function ocplx=isOutputComplexImpl(obj)%#ok
            ocplx=false;
        end

        function osizefixed=isOutputFixedSizeImpl(obj)%#ok
            osizefixed=true;
        end
    end



    methods
        function set.TrellisStructure(obj,T)

            if~isfeedforward(T)
                error(message('comm:system:ViterbiDecoder:BadTrellis'));
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
                error(message('comm:system:ViterbiDecoder:UnsupportedRate'));
            end


            if((T.numStates>obj.MaxStates)||(T.numStates<4))
                error(message('comm:system:ViterbiDecoder:UnsupportedConstraintLength'));
            end

            obj.TrellisStructure=T;

        end

        function set.TracebackDepth(obj,tb)


            if((tb>obj.MaxTraceback)||(tb<1)||~isfinite(tb)||...
                (floor(tb)~=tb))
                error(message('comm:system:ViterbiDecoder:BadTracebackDepth'));
            end
            obj.TracebackDepth=tb;
        end

        function set.PuncturePattern(obj,pp)
            [r,c]=size(pp);
            badpp=false;

            if((r>16)||(c~=1)||isscalar(pp))
                badpp=true;
            end


            if~all(ismember(pp,[0,1]))
                badpp=true;
            end
            if(badpp)
                error(message('comm:system:ViterbiDecoder:BadPuncturePattern'));
            end



            obj.PuncturePattern=pp;

        end

        function set.DelayedResetAction(obj,v)
            if(v)
                error(message('comm:system:ViterbiDecoder:BadDelayedResetProp'));
            end
        end

        function set.ErasuresInputPort(obj,v)
            if(v)
                error(message('comm:system:ViterbiDecoder:BadErasuresInputPort'));
            end
        end

        function set.NumFrames(obj,v)
            validateattributes(v,{'numeric'},...
            {'positive','integer'},'','NumFrames');
            obj.NumFrames=v;
        end




    end



    methods(Static,Hidden)


        function b=generatesCode
            b=false;
        end
    end

end


function tf=isfeedforward(T)

    if~(istrellis(T))
        tf=false;
        return;
    end
    k=log2(T.numInputSymbols);
    nS=T.numStates;
    nextS=T.nextStates;




    if(k==1)



        reqnextS=[floor(([1:nS]-1)/2);floor(([1:nS]-1)/2)+nS/2]';%#ok
        cs=(reqnextS==nextS);
        tf=logical(sum(sum(cs(:,:)))==nS*2);

    else
        tf=false;
    end

end








