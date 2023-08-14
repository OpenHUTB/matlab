
























classdef cuFFTNDCallback<coder.internal.CustomFFTCallback %#codegen
    methods(Static)

        function obj=cuFFTNDCallback
            coder.allowpcode('plain');
        end

        function updateBuildInfo(buildInfo,ctx)
            coder.internal.fft.addCUFFTDependency(buildInfo,ctx);
        end

        function[typename]=getcuFFTOutType(x)
            if isa(x,'double')
                typename='cufftDoubleComplex';
            else
                typename='cufftComplex';
            end
        end

        function[fcnname,typename]=getcuFFTMethodAndcuFFTType(x)
            coder.inline('always');
            if isreal(x)
                if isa(x,'double')
                    fcnname='cufftExecD2Z';
                    typename='cufftDoubleReal';
                else
                    fcnname='cufftExecR2C';
                    typename='cufftReal';
                end
            else
                if isa(x,'double')
                    fcnname='cufftExecZ2Z';
                    typename='cufftDoubleComplex';

                else
                    fcnname='cufftExecC2C';
                    typename='cufftComplex';
                end
            end
        end

    end

    methods(Sealed)

        function y=fft1d(obj,x,dimension,isInverse)


            coder.inline('always');
            coder.internal.prefer_const(dimension,isInverse);

            ONE=ones(coder.internal.indexIntClass);

            if dimension==ONE
                istride=ONE;
                idist=size(x,dimension);
                batchesPerSlab=coder.internal.prodsize(x,'above',ONE);
                numberOfSlabs=ONE;
            else
                istride=coder.internal.prodsize(x,'below',dimension);
                idist=ONE;
                batchesPerSlab=istride;
                numberOfSlabs=coder.internal.prodsize(x,'above',dimension);
            end
            inembed=int32(size(x,dimension));
            elementsPerSlab=coder.internal.indexTimes(batchesPerSlab,inembed);









            if isreal(x)&&dimension~=ONE&&mod(elementsPerSlab,2)==1
                y=complex(x);
                y=obj.fft1d(y,dimension,isInverse);
                return;
            end

            rank=1;
            lenProd=inembed(1);
            y=obj.fftCevalCall(x,rank,dimension,inembed,istride,idist,lenProd,batchesPerSlab,numberOfSlabs,isInverse);
        end

        function y=fft2d(obj,x,dimensions,isInverse)



            coder.inline('always');
            coder.internal.prefer_const(dimensions,isInverse);
            xSize=coder.internal.indexInt(size(x));
            ONE=ones(coder.internal.indexIntClass);
            TWO=coder.internal.indexInt(2);
            inembed=coder.nullcopy(zeros(1,2,'like',int32(0)));



            if dimensions(1)==ONE&&dimensions(2)==TWO
                istride=ONE;
                idist=xSize(ONE)*xSize(TWO);
                batchesPerSlab=coder.internal.prodsize(x,'above',TWO);
                numberOfSlabs=ONE;
            else
                istride=coder.internal.prodsize(x,'below',dimensions(1));
                if dimensions(ONE)~=ONE
                    idist=1;
                else
                    idist=size(x,ONE);
                end
                batchesPerSlab=ONE;
                coder.unroll();
                for k=ONE:coder.internal.indexInt(dimensions(TWO))-1
                    if k~=dimensions(ONE)
                        batchesPerSlab=batchesPerSlab*coder.internal.indexInt(size(x,k));
                    end
                end

                numberOfSlabs=coder.internal.prodsize(x,'above',dimensions(2));
            end

            inembed(2)=size(x,dimensions(ONE));
            inembed(1)=size(x,dimensions(TWO));

            rank=2;
            lenProd=inembed(2)*inembed(1);
            y=obj.fftCevalCall(x,rank,dimensions,inembed,istride,idist,lenProd,batchesPerSlab,numberOfSlabs,isInverse);
        end


        function y=fft3d(obj,x,dimensions,isInverse)
            coder.inline('always');
            coder.internal.prefer_const(dimensions,isInverse);
            xSize=coder.internal.indexInt(size(x));
            ONE=ones(coder.internal.indexIntClass);
            TWO=coder.internal.indexInt(2);
            THREE=coder.internal.indexInt(3);

            leading_three_dims=dimensions(ONE)==ONE;
            if leading_three_dims
                istride=ONE;
                idist=xSize(ONE)*xSize(TWO)*xSize(THREE);
                batchesPerSlab=coder.internal.prodsize(x,'above',dimensions(THREE));
                numberOfSlabs=ONE;
            else
                istride=coder.internal.prodsize(x,'below',dimensions(ONE));
                batchesPerSlab=istride;
                idist=ONE;
                numberOfSlabs=coder.internal.prodsize(x,'above',dimensions(THREE));
            end

            inembed=coder.nullcopy(zeros(1,3,'like',int32(0)));
            inembed(3)=size(x,dimensions(ONE));
            inembed(2)=size(x,dimensions(TWO));
            inembed(1)=size(x,dimensions(THREE));
            rank=3;
            lenProd=inembed(3)*inembed(2)*inembed(1);

            y=obj.fftCevalCall(x,rank,dimensions,inembed,istride,idist,lenProd,batchesPerSlab,numberOfSlabs,isInverse);

        end

        function y=fftCevalCall(obj,x,rank,dimensions,inembed,istride,idist,lenProd,batchesPerSlab,numberOfSlabs,isInverse)
            coder.inline('always');
            coder.internal.prefer_const(dimensions,inembed,istride,idist,lenProd,batchesPerSlab,numberOfSlabs,isInverse);
            ONE=coder.internal.indexInt(1);
            fftIsReal=isreal(x);
            fftStr=getFFTTypeString(x);
            typeName=class(x);

            header_name='cufft.h';
            [fcnname,itypename]=obj.getcuFFTMethodAndcuFFTType(x);
            itype=coder.opaque(itypename,'HeaderFile',header_name);
            otype=coder.opaque(obj.getcuFFTOutType(x),'HeaderFile',header_name);


            elementsPerSlab=coder.internal.indexTimes(batchesPerSlab,lenProd);
            offset=ONE;

            if(isInverse)
                fftDirection=getcuFFTDirection('i');
            else
                fftDirection=getcuFFTDirection('f');
            end

            xSize=size(x);
            y=coder.nullcopy(complex(zeros(xSize,typeName)));
            fftType=coder.opaque('cufftType',fftStr);
            fftPlanHandle=coder.opaque('cufftHandle','NULL');
            fftPlanHandle=coder.ceval('acquireCUFFTPlan',int32(rank),...
            coder.ref(inembed),coder.ref(inembed),...
            int32(istride),int32(idist),fftType,batchesPerSlab);

            for i=coder.unroll(1:numberOfSlabs,coder.internal.isConst(numberOfSlabs)&&numberOfSlabs<8)
                if fftIsReal

                    coder.ceval(fcnname,fftPlanHandle,...
                    coder.rref(x(offset),'like',itype,'gpu'),...
                    coder.wref(y(offset),'like',otype,'gpu'));
                else

                    coder.ceval(fcnname,fftPlanHandle,...
                    coder.rref(x(offset),'like',itype,'gpu'),...
                    coder.wref(x(offset),'like',otype,'gpu'),fftDirection);

                    y=x;
                end

                offset=coder.internal.indexPlus(offset,elementsPerSlab);
            end

            if fftIsReal
                y=gpucoder.internal.fillFftComplexConjugateMirror(y,xSize,dimensions);
            end


            if isInverse
                y=y./cast(lenProd,typeName);
            end
        end

        function y=fftnd(obj,x,dimensions,isInverse)
            coder.inline('always');
            coder.internal.prefer_const(dimensions,isInverse);
            [numOf3d,numOf2d,numOf1d]=coder.const(@getFactors,numel(dimensions));

            ZERO=zeros(1,1,coder.internal.indexIntClass);

            y=obj.fft3d(x,dimensions(1:3),isInverse);

            coder.unroll;
            for i3=4:3:coder.internal.indexTimes(numOf3d,3)
                y=fft3d(obj,y,dimensions(i3:coder.internal.indexPlus(i3,2)),isInverse);
            end

            if numOf2d>ZERO
                y=fft2d(obj,y,dimensions(end-1:end),isInverse);
            end

            if numOf1d>ZERO
                y=fft1d(obj,y,dimensions(end),isInverse);
            end
        end

        function y=fft1dVarSize(obj,x,len,dim,isInverse)
            coder.inline('always');
            coder.internal.prefer_const(len,dim);
            if size(x,dim)~=len
                y=fftResizeOptimization(x,len,dim);
                y=obj.fft1d(y,dim,isInverse);
            else
                y=obj.fft1d(x,dim,isInverse);
            end

        end


        function y=fft(obj,x,lens,dims,isInverse)
            coder.inline('always');
            coder.internal.CustomFFTCallback.assertInvariant(x,lens,dims,isInverse);
            coder.cinclude('MWCUFFTPlanManager.hpp');
            coder.cinclude('cufft.h');

            rank=coder.internal.indexInt(numel(dims));


            if rank==1&&~coder.internal.isConst(size(x))
                y=obj.fft1dVarSize(x,lens,dims,isInverse);
                return;
            end

            if isreal(x)&&isInverse
                y=fft(obj,complex(x),lens,dims,isInverse);
                return;
            end

            performResize=false;
            coder.unroll();
            for i=1:rank
                if size(x,dims(i))~=lens(i)
                    performResize=true;
                end
            end
            if performResize
                y=fftResizeOptimization(x,lens,dims);
            else
                y=x;
            end

            if rank==coder.internal.indexInt(1)
                y=fft1d(obj,y,dims,isInverse);
                return;
            end

            if rank==coder.internal.indexInt(2)
                y=fft2d(obj,y,dims,isInverse);
                return;
            end

            if rank==coder.internal.indexInt(3)
                y=fft3d(obj,y,dims,isInverse);
                return;
            end

            y=fftnd(obj,y,dims,isInverse);

        end
    end
end




function y=fftResizeOptimization(x,lens,dims)
    coder.inline('always');
    coder.internal.prefer_const(lens,dims);

    rank=coder.internal.indexInt(numel(dims));




    initWithZeros=false;
    for i=1:rank
        if size(x,dims(i))<lens(i)
            initWithZeros=true;
        end
    end

    ySize=coder.internal.indexInt(size(x));
    coder.unroll();
    for i=1:rank
        ySize(dims(i))=lens(i);
    end




    if initWithZeros
        y=complex(zeros(ySize,'like',x));
    else
        y=coder.nullcopy(complex(zeros(ySize,'like',x)));
    end

    loopSize=coder.nullcopy(size(x));
    numDims=coder.internal.indexInt(numel(size(x)));
    coder.unroll();
    for i=1:numDims
        loopSize(i)=min(size(x,i),ySize(i));
    end

    switch(numel(loopSize))
    case 2
        for a=1:loopSize(2)
            for b=1:loopSize(1)
                y(b,a)=complex(x(b,a));
            end
        end

    case 3
        for a=1:loopSize(3)
            for b=1:loopSize(2)
                for c=1:loopSize(1)
                    y(c,b,a)=complex(x(c,b,a));
                end
            end
        end

    case 4
        for a=1:loopSize(4)
            for b=1:loopSize(3)
                for c=1:loopSize(2)
                    for d=1:loopSize(1)
                        y(d,c,b,a)=complex(x(d,c,b,a));
                    end
                end
            end
        end

    case 5
        for a=1:loopSize(5)
            for b=1:loopSize(3)
                for c=1:loopSize(3)
                    for d=1:loopSize(2)
                        for e=1:loopSize(1)
                            y(e,d,c,b,a)=complex(x(e,d,c,b,a));
                        end
                    end
                end
            end
        end

    case 6
        for a=1:loopSize(6)
            for b=1:loopSize(5)
                for c=1:loopSize(4)
                    for d=1:loopSize(3)
                        for e=1:loopSize(2)
                            for f=1:loopSize(1)
                                y(f,e,d,c,b,a)=complex(x(f,e,d,c,b,a));
                            end
                        end
                    end
                end
            end
        end

    case 7
        for a=1:loopSize(7)
            for b=1:loopSize(6)
                for c=1:loopSize(5)
                    for d=1:loopSize(4)
                        for e=1:loopSize(3)
                            for f=1:loopSize(2)
                                for g=1:loopSize(1)
                                    y(g,f,e,d,c,b,a)=complex(x(g,f,e,d,c,b,a));
                                end
                            end
                        end
                    end
                end
            end
        end

    case 8
        for a=1:loopSize(8)
            for b=1:loopSize(7)
                for c=1:loopSize(6)
                    for d=1:loopSize(5)
                        for e=1:loopSize(4)
                            for f=1:loopSize(3)
                                for g=1:loopSize(2)
                                    for h=1:loopSize(1)
                                        y(h,g,f,e,d,c,b,a)=complex(x(h,g,f,e,d,c,b,a));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    case 9
        for a=1:loopSize(9)
            for b=1:loopSize(8)
                for c=1:loopSize(7)
                    for d=1:loopSize(6)
                        for e=1:loopSize(5)
                            for f=1:loopSize(4)
                                for g=1:loopSize(3)
                                    for h=1:loopSize(2)
                                        for i=1:loopSize(1)
                                            y(i,h,g,f,e,d,c,b,a)=complex(x(i,h,g,f,e,d,c,b,a));
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    case 10
        for a=1:loopSize(10)
            for b=1:loopSize(9)
                for c=1:loopSize(8)
                    for d=1:loopSize(7)
                        for e=1:loopSize(6)
                            for f=1:loopSize(5)
                                for g=1:loopSize(4)
                                    for h=1:loopSize(3)
                                        for i=1:loopSize(2)
                                            for j=1:loopSize(1)
                                                y(j,i,h,g,f,e,d,c,b,a)=complex(x(j,i,h,g,f,e,d,c,b,a));
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    otherwise
        numDims=numel(size(x));
        index=cell(1,numDims);
        for i=1:numDims
            index{i}=1:loopSize(i);
        end
        y(index{:})=complex(x([index{:}]));
    end
end



function fftDir=getcuFFTDirection(d)
    fftDir=coder.opaque('int','CUFFT_FORWARD');
    if nargin<1
        return;
    end

    assert(ischar(d));

    if d(1)=='i'||d(1)=='I'
        fftDir=coder.opaque('int','CUFFT_INVERSE');
    end
end

function fftTypeStr=getFFTTypeString(x)
    coder.internal.prefer_const(class(x),isreal(x));
    if isreal(x)
        if isa(x,'double')
            fftTypeStr='CUFFT_D2Z';
            return;
        else
            fftTypeStr='CUFFT_R2C';
            return;
        end
    else
        if isa(x,'double')
            fftTypeStr='CUFFT_Z2Z';
            return;
        else
            fftTypeStr='CUFFT_C2C';
            return;
        end
    end
end

function[numOf3d,numOf2d,numOf1d]=getFactors(value)
    numOf3d=fix(value/3);
    value=rem(value,3);
    numOf2d=fix(value/2);
    value=rem(value,2);
    if(value>0)
        numOf1d=1;
    else
        numOf1d=0;
    end
end

