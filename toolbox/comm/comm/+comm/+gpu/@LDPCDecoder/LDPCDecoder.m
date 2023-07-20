classdef(StrictDefaults)LDPCDecoder<comm.gpu.internal.CUDAKernelSystemBase

































































































    properties(Nontunable)






        ParityCheckMatrix=dvbs2ldpc(1/2);








        OutputValue='Information part';






        DecisionMethod='Hard decision';









        MaximumIterationCount=50;












        IterationTerminationCondition='Maximum iteration count';



        NumIterationsOutputPort(1,1)logical=false;



        FinalParityChecksOutputPort(1,1)logical=false;
    end

    properties(Access=protected)
Gfnodenumel
Gcnodenumel
GcnodeStartInq
GfnodeStartInr
Gq2r
Gr2q
Gr_arr
Gq_arr
GbigQ
GSyndrome
updateRkernel
updateQkernel
inputReorderKernel
PCfindCols
    end

    properties(Access=private);
        kernelFile='ldpcDecoderKernels';
    end

    properties(Access=private)

pboolDoParityChecks
pboolHardDecision
pOutputLength
pNumframes
    end

    properties(Constant,Hidden)
        DecisionMethodSet=matlab.system.StringSet({'Hard decision',...
        'Soft decision'});
        IterationTerminationConditionSet=matlab.system.StringSet(...
        {'Maximum iteration count','Parity check satisfied'});
        OutputValueSet=matlab.system.StringSet({'Information part',...
        'Whole codeword'});
    end

    methods
        function obj=LDPCDecoder(varargin)
            setProperties(obj,nargin,varargin{:},'ParityCheckMatrix');
        end
    end
    methods(Access=protected)

        function[decoded,out2,out3]=stepImpl(obj,c_in)






            msgsPerFrame=nnz(obj.ParityCheckMatrix);

            [numParityBits,blockLength]=size(obj.ParityCheckMatrix);


            Gc_in=obj.moveInputsToGPU(c_in);


            tGr_arr=obj.Gr_arr;
            tGq_arr=obj.Gq_arr;
            tGSyndrome=obj.GSyndrome;
            tGr2q=obj.Gr2q;
            tGq2r=obj.Gq2r;
            tGfnodeStartInr=obj.GfnodeStartInr;
            tGfnodenumel=obj.Gfnodenumel;
            tGcnodeStartInq=obj.GcnodeStartInq;
            tGcnodenumel=obj.Gcnodenumel;
            tGbigQ=obj.GbigQ;


            obj.Gr_arr=gpuArray([]);
            obj.Gq_arr=gpuArray([]);
            obj.GSyndrome=gpuArray([]);
            obj.Gr2q=gpuArray([]);
            obj.Gq2r=gpuArray([]);
            obj.GfnodeStartInr=gpuArray([]);
            obj.Gfnodenumel=gpuArray([]);
            obj.GcnodeStartInq=gpuArray([]);
            obj.Gcnodenumel=gpuArray([]);
            obj.GbigQ=gpuArray([]);





            tGq_arr=feval(obj.inputReorderKernel,tGq_arr,Gc_in,tGcnodeStartInq,...
            tGcnodenumel,blockLength,msgsPerFrame,obj.pNumframes);


            if~(obj.pboolDoParityChecks)

                [tGr_arr,tGSyndrome]=feval(obj.updateRkernel,tGr_arr,...
                tGSyndrome,tGq_arr,tGr2q,...
                tGfnodeStartInr,tGfnodenumel,...
                numParityBits,msgsPerFrame,false);


                for ii=1:obj.MaximumIterationCount-1

                    [tGq_arr,tGbigQ]=feval(obj.updateQkernel,tGq_arr,tGbigQ,Gc_in,...
                    tGr_arr,tGq2r,tGcnodeStartInq,...
                    tGcnodenumel,blockLength,msgsPerFrame,false,false);

                    [tGr_arr,tGSyndrome]=feval(obj.updateRkernel,tGr_arr,...
                    tGSyndrome,tGq_arr,tGr2q,...
                    tGfnodeStartInr,tGfnodenumel,...
                    numParityBits,msgsPerFrame,false);
                end
                [tGq_arr,tGbigQ]=feval(obj.updateQkernel,tGq_arr,tGbigQ,Gc_in,...
                tGr_arr,tGq2r,tGcnodeStartInq,...
                tGcnodenumel,blockLength,msgsPerFrame,true,obj.pboolHardDecision);




                [tGr_arr,tGSyndrome]=feval(obj.updateRkernel,tGr_arr,...
                tGSyndrome,tGq_arr,tGr2q,...
                tGfnodeStartInr,tGfnodenumel,...
                numParityBits,msgsPerFrame,true);

                actualNumIterations=obj.MaximumIterationCount;
                finalParityChecks=tGSyndrome';
            else
                done=false;

                [tGr_arr,tGSyndrome]=feval(obj.updateRkernel,tGr_arr,...
                tGSyndrome,tGq_arr,tGr2q,...
                tGfnodeStartInr,tGfnodenumel,...
                numParityBits,msgsPerFrame,false);


                for ii=1:obj.MaximumIterationCount-1
                    [tGq_arr,tGbigQ]=feval(obj.updateQkernel,tGq_arr,tGbigQ,Gc_in,...
                    tGr_arr,tGq2r,tGcnodeStartInq,...
                    tGcnodenumel,blockLength,msgsPerFrame,true,obj.pboolHardDecision);

                    [tGr_arr,tGSyndrome]=feval(obj.updateRkernel,tGr_arr,...
                    tGSyndrome,tGq_arr,tGr2q,...
                    tGfnodeStartInr,tGfnodenumel,...
                    numParityBits,msgsPerFrame,true);

                    if~gather(any(tGSyndrome))
                        synd=tGSyndrome';
                        done=true;
                        break;
                    end
                end

                if~done
                    [tGq_arr,tGbigQ]=feval(obj.updateQkernel,tGq_arr,tGbigQ,Gc_in,...
                    tGr_arr,tGq2r,tGcnodeStartInq,...
                    tGcnodenumel,blockLength,msgsPerFrame,true,obj.pboolHardDecision);




                    [tGr_arr,tGSyndrome]=feval(obj.updateRkernel,tGr_arr,...
                    tGSyndrome,tGq_arr,tGr2q,...
                    tGfnodeStartInr,tGfnodenumel,...
                    numParityBits,msgsPerFrame,true);

                    finalParityChecks=tGSyndrome';
                    actualNumIterations=obj.MaximumIterationCount;
                else

                    finalParityChecks=synd;
                    actualNumIterations=ii;

                end

            end


            obj.Gr_arr=tGr_arr;
            obj.Gq_arr=tGq_arr;
            obj.GSyndrome=tGSyndrome;
            obj.Gr2q=tGr2q;
            obj.Gq2r=tGq2r;
            obj.GfnodeStartInr=tGfnodeStartInr;
            obj.Gfnodenumel=tGfnodenumel;
            obj.GcnodeStartInq=tGcnodeStartInq;
            obj.Gcnodenumel=tGcnodenumel;
            obj.GbigQ=tGbigQ;


            if obj.pboolHardDecision

                Gdecodedall=logical(obj.GbigQ);
            else
                Gdecodedall=obj.GbigQ;
            end

            decodedall=obj.moveOutputsIfNeeded(Gdecodedall);

            decodedr=reshape(decodedall,blockLength,obj.pNumframes);
            decoded=reshape(decodedr(1:obj.pOutputLength,:),obj.pOutputLength*obj.pNumframes,1);


            if(nargout==3)
                if isOutputCPUArray(obj)
                    out2=actualNumIterations;
                    out3=gather(finalParityChecks);
                else
                    out2=gpuArray(actualNumIterations);
                    out3=finalParityChecks;
                end
            elseif(nargout==2)
                if(obj.NumIterationsOutputPort)
                    if isOutputCPUArray(obj)
                        out2=actualNumIterations;
                    else
                        out2=gpuArray(actualNumIterations);
                    end
                else
                    out2=obj.moveOutputsIfNeeded(finalParityChecks);
                end
            end

        end

        function setupImpl(obj,in)
            detectGPUInputs(obj,in);

            sz=size(in);
            mDT=underlyingType(in);
            [numParityBits,blockLength]=size(obj.ParityCheckMatrix);


            numframes=sz(1)/blockLength;











            if~iscolumn(in)||isempty(in)
                matlab.system.internal.error(...
                'MATLAB:system:inputMustBeColVector','X');
            end


            if isInputGPUArray(obj,1)
                isInvalidDataType=~isreal(in)||...
                (~strcmp(mDT,'single')&&~strcmp(mDT,'double'));
            else


                isInvalidDataType=~obj.isRealBuiltinFloat(in);
            end
            if isInvalidDataType
                error(message('comm:system:LDPCDecoder:gpuBadInputType'));
            end


            if(numframes~=floor(numframes))
                error(message('comm:system:LDPCDecoder:gpuInvalidInputLength'));
            end


            if((numframes>1)&&strcmpi(obj.IterationTerminationCondition,...
                'Parity check satisfied'))
                error(message('comm:system:LDPCDecoder:gpuMultiframeError'));
            end





            obj.pNumframes=numframes;

            gDT=comm.gpu.internal.getGPUDataType(mDT);



            [cnodenumel,cnodeStartInq,fnodenumel,fnodeStartInr,r2q,q2r]=gpuldpcExtractStructure(obj.ParityCheckMatrix);



            obj.Gfnodenumel=gpuArray(fnodenumel);
            obj.Gcnodenumel=gpuArray(cnodenumel);
            obj.GcnodeStartInq=gpuArray(cnodeStartInq);
            obj.GfnodeStartInr=gpuArray(fnodeStartInr);
            obj.Gq2r=gpuArray(q2r);
            obj.Gr2q=gpuArray(r2q);


            msgsPerFrame=nnz(obj.ParityCheckMatrix);
            obj.Gr_arr=comm.gpu.internal.gpuArrayAlloc(1,obj.pNumframes*msgsPerFrame,mDT);
            obj.Gq_arr=comm.gpu.internal.gpuArrayAlloc(1,obj.pNumframes*msgsPerFrame,mDT);

            obj.GbigQ=comm.gpu.internal.gpuArrayAlloc(1,obj.pNumframes*blockLength,mDT);
            obj.GSyndrome=comm.gpu.internal.gpuArrayAlloc(1,obj.pNumframes*numParityBits,'logical');



            maxcn=double(max(cnodenumel));
            makeUpdateRkernel(obj,gDT,double(max(fnodenumel)))
            makeUpdateQkernel(obj,gDT,maxcn)
            makeInputReorderKernel(obj,gDT,maxcn,blockLength);

            [~,obj.PCfindCols]=find(obj.ParityCheckMatrix);

            obj.pOutputLength=privgetOutputSize(obj);
            obj.pboolDoParityChecks=~strcmpi(obj.IterationTerminationCondition,'Maximum iteration count');
            obj.pboolHardDecision=strcmpi(obj.DecisionMethod,'Hard decision');



        end


        function num=getNumInputsImpl(obj)%#ok<MANU>
            num=1;
        end

        function num=getNumOutputsImpl(obj)
            num=1+obj.NumIterationsOutputPort+obj.FinalParityChecksOutputPort;
        end

    end

    methods(Access=private)

        function makeUpdateRkernel(obj,gDT,maxMsgPerNode)

            kerProto=[gDT,' *, bool *, const ',gDT,' *, const unsigned int *, const unsigned int *, const unsigned short int *, int, int, bool'];


            obj.updateRkernel=makeKernel(obj,kerProto,'updateRmsg',{gDT},obj.kernelFile);


            [tblk,grd]=obj.makePlan_Kind1(maxMsgPerNode,...
            size(obj.ParityCheckMatrix,1),...
            obj.pNumframes);
            obj.updateRkernel.ThreadBlockSize=tblk;
            obj.updateRkernel.GridSize=grd;


            dtSize=comm.gpu.internal.getGPUDataTypeSize(gDT);
            obj.updateRkernel.SharedMemorySize=dtSize*(tblk(1)*(1+tblk(2)));


        end

        function makeUpdateQkernel(obj,gDT,maxMsgPerNode)

            kerProto=[gDT,' *, ',gDT,' *, const ',gDT,' *, const ',gDT,' *, const unsigned int *, const unsigned int *, const unsigned short int *, int, int, bool, bool'];


            obj.updateQkernel=makeKernel(obj,kerProto,'updateQmsg',{gDT},obj.kernelFile);


            [tblk,grd]=obj.makePlan_Kind1(maxMsgPerNode,...
            size(obj.ParityCheckMatrix,2),...
            obj.pNumframes);
            obj.updateQkernel.ThreadBlockSize=tblk;
            obj.updateQkernel.GridSize=grd;


            dtSize=comm.gpu.internal.getGPUDataTypeSize(gDT);
            obj.updateQkernel.SharedMemorySize=dtSize*(tblk(1)*(tblk(2)));

        end

        function makeInputReorderKernel(obj,gDT,maxMsgPerNode,blockLength)
            kerProto=[gDT,' * , const ',gDT,' * , const unsigned int *, const unsigned short int *, int, int, int'];
            obj.inputReorderKernel=makeKernel(obj,kerProto,'inputReorder',...
            {gDT},obj.kernelFile);

            threadY=floor(comm.gpu.internal.CUDAKernelSystemBase.MaxThreadBlockSize/maxMsgPerNode);
            gpuThreadBlock=[maxMsgPerNode,threadY];
            gpuGrid=[1,obj.pNumframes*ceil(blockLength/threadY)];

            if(gpuGrid(2)>obj.kMaxGridSize)
                error(message('comm:gpu:LDPCDecoder:ProblemTooLarge'));
            end


            obj.inputReorderKernel.SharedMemorySize=0;
            obj.inputReorderKernel.ThreadBlockSize=gpuThreadBlock;
            obj.inputReorderKernel.GridSize=gpuGrid;

        end

        function[gpuThreadBlock,gpuGrid]=makePlan_Kind1(obj,blockDimX_max,numThreadsY,numblocksX)










            threadY=floor(obj.MaxThreadBlockSize/blockDimX_max);
            gpuThreadBlock=[blockDimX_max,threadY];
            gpuGrid=[numblocksX,ceil(numThreadsY/threadY)];

            if(gpuGrid(1)>obj.kMaxGridSize)
                error(message('comm:gpu:LDPCDecoder:TooManyFrames'));
            end

            if(gpuGrid(2)>obj.kMaxGridSize)
                error(message('comm:gpu:LDPCDecoder:FrameSizeTooLarge'));
            end

        end

        function osize=privgetOutputSize(obj)
            outputValueIdx=find(strcmp({'Information part','Whole codeword'},obj.OutputValue));
            osize=...
            (size(obj.ParityCheckMatrix,2)-size(obj.ParityCheckMatrix,1)*...
            (2-outputValueIdx));
        end

    end





















































    methods(Static,Hidden)
        function b=generatesCode
            b=false;
        end
    end

    methods
        function set.ParityCheckMatrix(obj,val)
            if~issparse(val)
                error(message('comm:system:LDPCDecoder:gpuNonSparseParityCheckMatrix'));
            end

            N=size(val,2);
            K=N-size(val,1);

            if N<=0
                error(message('comm:system:LDPCDecoder:gpuInvalidNumColumns'));
            end

            if K<=0
                error(message('comm:system:LDPCDecoder:gpuTooFewColumns'));
            end

            if~isempty(find(nonzeros(val)~=1,1))
                error(message('comm:system:LDPCDecoder:gpuNotZeroOneMatrix'));
            end


            [fr,fc]=find(val);
            colmat=true(1,N);
            rowmat=true(1,size(val,1));
            colmat(fc)=false;
            rowmat(fr)=false;

            if any(colmat)
                error(message('comm:system:LDPCDecoder:gpuEmptyColumn'));
            end

            if any(rowmat)
                error(message('comm:system:LDPCDecoder:gpuEmptyRow'));
            end


            obj.ParityCheckMatrix=logical(val);
        end

        function set.MaximumIterationCount(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','integer'},'','MaximumIterationCount');
            obj.MaximumIterationCount=val;
        end
    end
end





