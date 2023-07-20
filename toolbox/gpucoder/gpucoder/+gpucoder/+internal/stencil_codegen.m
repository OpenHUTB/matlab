function im1=stencil_codegen(func,input,windowr,windowc,shape,varargin)







%#codegen
    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(shape);
    coder.gpu.internal.kernelfunImpl(false);

    coder.internal.assert(isa(func,'function_handle'),...
    'gpucoder:common:StencilInvalidFunctionHandle');

    gpucoder.internal.getStencilParams_codegen(input,[windowr,windowc]);


    coder.internal.assert(nargout(func)==1,...
    'gpucoder:common:StencilInvalidFunctionHandleOutput');
    coder.internal.assert(nargin(func)==numel(varargin)+1,...
    'gpucoder:common:StencilInvalidFunctionHandleInput',...
    numel(varargin)+1,nargin(func));

    threads=32;
    coder.internal.prefer_const(threads);

    im1=stencil2D(func,input,windowr,windowc,shape,threads,varargin{:});

end


function Op=stencil2D(func,input,windowr,windowc,shape,threads,varargin)

    coder.inline('always');
    [IH,IW]=size(input);
    [OH,OW,padH,padW]=getSizes(input,windowr,windowc,shape);
    coder.internal.prefer_const(IH,IW,OH,OW,padH,padW);

    [threadDims,blockDims]=derive2DThreads(threads,OH,OW);
    method=1;
    if(method==1)
        Op=stencil2Impl(func,input,...
        int32(OW),...
        int32(OH),...
        int32(IW),...
        int32(IH),...
        int32(windowc),...
        int32(windowr),...
        int32(padW),...
        int32(padH),...
        blockDims,...
        threadDims,...
        varargin{:});
    elseif(method==2)
        Op=stencil2D_v2(func,input,...
        int32(OW),...
        int32(OH),...
        int32(IW),...
        int32(IH),...
        int32(windowc),...
        int32(windowr),...
        int32(padW),...
        int32(padH),...
        blockDims,...
        threadDims,...
        varargin{:});
    elseif(method==3)
        Op=stencil2D_v3(func,input,...
        int32(OW),...
        int32(OH),...
        int32(IW),...
        int32(IH),...
        int32(windowc),...
        int32(windowr),...
        blockDims,...
        threadDims,...
        shape,...
        varargin{:});
    end
end


function[OH,OW,padH,padW]=getSizes(input,windowr,windowc,shape)
    coder.inline('always');
    coder.internal.prefer_const(windowr,windowc,shape);
    [IH,IW]=size(input);
    switch coder.const(lower(shape))
    case 'same'
        padH=0;
        padW=0;
        OH=IH;
        OW=IW;
    case 'full'
        padH=floor(windowr/2);
        padW=floor(windowc/2);
        OH=IH+windowr-1;
        OW=IW+windowc-1;
    case 'valid'
        padH=-floor((windowr-1)/2);
        padW=-floor((windowc-1)/2);
        OH=IH-windowr+1;
        OW=IW-windowc+1;
        if OH<0
            OH=0;
        end
        if OW<0
            OW=0;
        end
    otherwise
        coder.internal.assert(false,'gpucoder:common:InvalidShape',...
        'same, valid or full.');
    end
    padH=padH;%#ok<ASGSL>
    padW=padW;%#ok<ASGSL>
    OH=OH;%#ok<ASGSL>
    OW=OW;%#ok<ASGSL>

end


function Op=stencil2Impl(func,im,OW,OH,IW,IH,KW,KH,...
    padW,padH,blocks,threads,varargin)

    coder.inline('always');


    offsetW=padW+floor((double(KW)-1)/2);
    offsetH=padH+floor((double(KH)-1)/2);
    expanded=zeros(OH+KH-1,OW+KW-1,'like',im);
    expanded(offsetH+(1:IH),offsetW+(1:IW))=im(:,:);

    rows=0:KH-1;
    cols=0:KW-1;


    Op=initOutput(OH,OW,KH,KW,im,func,varargin{:});

    if(OH==0)||(OW==0)
        return;
    end

    coder.gpu.internal.kernelImpl(false,blocks,threads);
    if coder.isRowMajor
        for orow=1:OH
            for ocol=1:OW
                coder.gpu.internal.noKernelRegion;
                coder.gpu.internal.sharedMemoryImpl(expanded,false,true,[orow,KH],[ocol,KW]);
                newIm=expanded(orow+rows,ocol+cols);

                cv=func(newIm,varargin{:});
                coder.internal.assert(isscalar(cv)&&isa(cv,class(Op)),...
                'gpucoder:common:StencilInvalidFunctionHandleOutput');
                Op(orow,ocol)=cv;
            end
        end
    else
        for ocol=1:OW
            for orow=1:OH
                coder.gpu.internal.noKernelRegion;
                coder.gpu.internal.sharedMemoryImpl(expanded,false,false,[orow,KH],[ocol,KW]);
                newIm=expanded(orow+rows,ocol+cols);

                cv=func(newIm,varargin{:});
                coder.internal.assert(isscalar(cv)&&isa(cv,class(Op)),...
                'gpucoder:common:StencilInvalidFunctionHandleOutput');
                Op(orow,ocol)=cv;
            end
        end
    end

end


function Op=initOutput(OH,OW,KH,KW,im,func,varargin)
    coder.inline('always');
    dummy_in=zeros(KH,KW,'like',im);
    coder.internal.prefer_const(dummy_in);
    a=coder.internal.scalarEg(...
    func(dummy_in,varargin{:}));
    Op=coder.nullcopy(zeros(OH,OW,'like',a));
end


function[threads,blocks]=derive2DThreads(threads,IH,IW)
    coder.inline('always');



    if coder.isRowMajor
        x=eml_min(threads,IW);
        y=eml_min(threads,IH);
        threads=[x,y,1];
        blocks=[floor((IW+(x-1))/x),floor((IH+(y-1))/y),1];
    else
        x=eml_min(threads,IH);
        y=eml_min(threads,IW);
        threads=[x,y,1];
        blocks=[floor((IH+(x-1))/x),floor((IW+(y-1))/y),1];
    end
    threads=int32(threads);

end


function im1=stencil2D_v2(func,im,OW,OH,IW,IH,KW,KH,padW,padH,blocks,threads,varargin)%#ok
    coder.inline('always');

    im1=coder.nullcopy(zeros(IH,IW,'like',im));

    blkDim_x=int32(threads(1));
    blkDim_y=int32(threads(2));
    bx=blocks(1);
    by=blocks(2);

    KW_radius=int32(floor((double(KW)-1)/2));
    KH_radius=int32(floor((double(KH)-1)/2));

    coder.gpu.internal.kernelImpl(false,blocks,[blkDim_x,blkDim_y,1]);
    for i=1:by*blkDim_y
        coder.gpu.internal.kernelImpl(false);
        for j=1:bx*blkDim_x
            coder.gpu.internal.noKernelRegion;
            idx=int32(0);
            idy=int32(0);
            blx=int32(0);
            bly=int32(0);

            idx=coder.ceval('__gpu_threadIdx_x');
            idy=coder.ceval('__gpu_threadIdx_y');
            blx=coder.ceval('__gpu_blockIdx_x');
            bly=coder.ceval('__gpu_blockIdx_y');

            im_shared=coder.nullcopy(zeros(blkDim_x+KH-1,blkDim_y+KW-1));
            coder.ceval('__gpu_smem',coder.ref(im_shared));

            b_threadIdX=blkDim_x*blx+idx;
            b_threadIdY=blkDim_y*bly+idy;
            baseR=b_threadIdX-KH_radius-padH;
            srow=idx;
            scol=idy;

            y_idx=srow;
            while(y_idx<size(im_shared,1))
                baseC=b_threadIdY-KW_radius-padW;
                x_idx=scol;
                while(x_idx<size(im_shared,2))
                    if((baseR>=0)&&(baseR<IH)&&((baseC>=0)&&(baseC<IW)))
                        im_shared(y_idx+1,x_idx+1)=im(baseR+1,baseC+1);
                    else
                        im_shared(y_idx+1,x_idx+1)=0;
                    end
                    baseC=baseC+blkDim_y;
                    x_idx=x_idx+blkDim_y;
                end
                baseR=baseR+blkDim_x;
                y_idx=y_idx+blkDim_x;
            end
            coder.ceval('__syncthreads');
            if((b_threadIdX<OH)&&(b_threadIdY<OW))
                nhood=im_shared((srow+1):(srow+KH),(scol+1):(scol+KW));
                cv=func(nhood,varargin{:});
                coder.internal.assert(isscalar(cv)&&isa(cv,class(im1)),...
                'gpucoder:common:StencilInvalidFunctionHandleOutput');
                im1(b_threadIdX+1,b_threadIdY+1)=cv;
            end
        end
    end
end

function im1=stencil2D_v3(func,im,OW,OH,IW,IH,KW,KH,blocks,threads,shape,varargin)
    coder.inline('always');
    im1=coder.nullcopy(zeros([OH,OW],'like',im));
    imageSize=[OH,OW];
    windowSize=[KH,KW];

    for i=1:2
        coder.internal.assert((threads(i)+windowSize(i)-1<=64),'gpucoder:common:InvalidStencil');
    end

    tempCell=varargin;
    if(isempty(tempCell))
        coder.ceval('#_generateStencilKernel_',...
        coder.internal.functionpointer(func,...
        cast(zeros(KH,KW),'like',im)),...
        coder.const(0),...
        coder.rref(im),...
        coder.rref(imageSize),...
        coder.rref(windowSize),...
        coder.rref(blocks),...
        coder.rref(threads),...
        coder.const(0*strcmp(shape,'valid')+...
        1*strcmp(shape,'same')+...
        2*strcmp(shape,'full')),...
        coder.const(1),...
        coder.const(0),...
        coder.wref(im1));
    else
        coder.ceval('#_generateStencilKernel_',...
        coder.internal.functionpointer(func,...
        cast(zeros(KH,KW),'like',im),...
        tempCell{:}),...
        coder.const(numel(tempCell)),...
        coder.rref(im),...
        coder.rref(imageSize),...
        coder.rref(windowSize),...
        coder.rref(blocks),...
        coder.rref(threads),...
        coder.const(0*strcmp(shape,'valid')+...
        1*strcmp(shape,'same')+...
        2*strcmp(shape,'full')),...
        coder.const(1),...
        coder.const(0),...
        coder.internal.valuelistfun(@coder.rref,tempCell),...
        coder.wref(im1));
    end
end
