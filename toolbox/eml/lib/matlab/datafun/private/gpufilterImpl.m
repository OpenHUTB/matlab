function[y,zf]=gpufilterImpl(b,a,x,zi,ISCONSTFIR)%#codegen



    coder.allowpcode('plain');

    coder.gpu.internal.kernelfunImpl(false);





    kernel=reshape(b,length(b),1);
    if length(a)>length(b)



        kernel1D=[kernel;zeros((length(a)-length(b)),1)];
    else
        kernel1D=kernel;
    end


    zfSize=size(x);


    zfSize(1)=size(kernel1D,1)-1;




    if isempty(x)
        if isa(b,'single')||isa(a,'single')||isa(x,'single')||isa(zi,'single')
            y=coder.nullcopy(zeros(size(x),'single'));
            if nargout==2
                zf=coder.nullcopy(zeros(zfSize,'single'));
            end
        else
            y=coder.nullcopy(zeros(size(x),'double'));
            if nargout==2
                zf=coder.nullcopy(zeros(zfSize,'double'));
            end
        end
    else

        convOut=gpucoder.stencilKernel(@applyKernel,x(:,:),size(kernel1D),'full',kernel1D,zi,a);


        if~isempty(zi)
            if isrow(zi)
                for m=1:size(convOut,2)
                    for i=1:size(zi,2)
                        convOut(i,m)=convOut(i,m)+zi(1,i);
                    end
                end
            elseif iscolumn(zi)
                for m=1:size(convOut,2)
                    for i=1:size(zi,1)
                        convOut(i,m)=convOut(i,m)+zi(i,1);
                    end
                end
            else
                convOut(1:size(zi,1),:)=convOut(1:size(zi,1),:)+zi(:,:);
            end
        end

        if~ISCONSTFIR

            for m=1:size(convOut,2)
                for i=1:size(x,1)+length(a)-1
                    for j=2:min(i,length(a))
                        convOut(i,m)=convOut(i,m)-convOut(i-j+1,m)*a(j);
                    end
                end
            end
        end


        if nargout==2
            if ISCONSTFIR
                zf=reshape(convOut(size(x,1)+1:end,:),zfSize);
            else
                zfIIR=convOut(size(x,1)+1:end,:);
                for m=1:size(convOut,2)
                    for i=2:length(a)-1
                        for j=2:min(i,length(a))
                            zfIIR(i,m)=zfIIR(i,m)+convOut((size(x,1)+i-j+1),m)*a(j);
                        end
                    end
                end
                zf=reshape(zfIIR,zfSize);
            end
        end


        y=reshape(convOut(1:size(x,1),:),size(x));
    end
end


function s=applyKernel(a,b,zi,x)
    coder.inline('always');
    s=zeros('like',coder.internal.scalarEg(a,b,zi,x));
    coder.gpu.internal.constantMemoryImpl(b,false);
    [h,w]=size(b);
    for n=1:w
        for m=1:h
            s=s+a(m,n)*b(h-m+1,w-n+1);
        end
    end
end
