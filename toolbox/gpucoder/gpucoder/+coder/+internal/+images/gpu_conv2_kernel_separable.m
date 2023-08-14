function c=gpu_conv2_kernel_separable(work_in,c_in,hcol,hrow,a,shape)



%#codegen
    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    narginchk(6,6);

    if~iscolumn(hcol)
        filter=hcol';
    else
        filter=hcol;
    end
    work=coder.internal.images.gpu_conv2_kernel(work_in,a,filter,shape);

    if~isrow(hrow)
        filter=hrow';
    else
        filter=hrow;
    end
    c=coder.internal.images.gpu_conv2_kernel(c_in,work,filter,shape);

end
