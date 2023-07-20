%#codegen










function out=transposeHWDims(in)




    coder.inline('always');
    coder.allowpcode('plain');

    out=coder.nullcopy(zeros(size(in,2),...
    size(in,1),...
    size(in,3),...
    size(in,4),...
    class(in)));
    if coder.const((size(in,3)>1)||(size(in,4)>1))
        coder.gpu.internal.kernelImpl(false);
        for k=1:size(in,4)
            coder.gpu.internal.kernelImpl(false);
            for p=1:size(in,3)
                plane=in(:,:,p,k);
                out(:,:,p,k)=plane';
            end
        end
    else
        out=in';
    end
end
