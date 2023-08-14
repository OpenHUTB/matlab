function c=gpu_conv2_kernel(c_in,a,b,shape)



%#codegen
    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    coder.inline('always');
    narginchk(4,4);
    coder.internal.prefer_const(shape);
    coder.internal.assert(isfloat(a)&&isfloat(b),'Coder:toolbox:InputsMustBeFloats');

    if isempty(a)||isempty(b)
        c=c_in;
        return;
    end

    if(isscalar(a)&&isscalar(b))
        c=c_in;
        c(:)=a*b;
        return;
    end

    if shape==FULL
        c=conv2Full(a,b);
    elseif shape==SAME
        c=conv2Same(a,b);
    else
        c=conv2Valid(a,b);
    end



    function c=conv2Full(a,b)
        coder.inline('always');
        coder.internal.allowHalfInputs;
        if coder.target('MATLAB')
            c=gpucoder.internal.stencil_sim(@applyKernel,a,size(b),'full',b);
        else
            c=gpucoder.internal.stencil_codegen(@applyKernel,a,size(b,1),size(b,2),'full',b);
        end



        function c=conv2Same(a,b)
            coder.inline('always');
            c=gpucoder.stencilKernel(@applyKernel,a,size(b),'same',b);



            function c=conv2Valid(a,b)
                coder.inline('always');
                c=gpucoder.stencilKernel(@applyKernel,a,size(b),'valid',b);



                function s=applyKernel(a,b)
                    coder.inline('always');
                    if(isa(a,'half')||isa(b,'half'))
                        s=applyHalfKernel(a,b);
                        return
                    end

                    s=zeros('like',coder.internal.scalarEg(a,b));
                    coder.gpu.internal.constantMemoryImpl(b,false);
                    [h,w]=size(b);
                    for n=1:w
                        for m=1:h
                            s=s+a(m,n)*b(h-m+1,w-n+1);
                        end
                    end



                    function y=FULL
                        coder.inline('always');
                        y=coder.const(coder.internal.convShapeStrToID('f'));

                        function y=SAME
                            coder.inline('always');
                            y=coder.const(coder.internal.convShapeStrToID('s'));



                            function out=applyHalfKernel(a,b)
                                coder.inline('always');
                                if(isa(a,'double')||isa(b,'double'))

                                    s=zeros('like',coder.internal.scalarEg(double(a),double(b)));
                                else

                                    s=zeros('like',coder.internal.scalarEg(single(a),single(b)));
                                end

                                coder.gpu.internal.constantMemoryImpl(b,false);
                                [h,w]=size(b);

                                for n=1:w
                                    for m=1:h
                                        l=cast(a(m,n),'like',s)*cast(b(h-m+1,w-n+1),'like',s);
                                        s=s+l;
                                    end
                                end

                                out=cast(s,'half');



