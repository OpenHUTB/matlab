function a=waverec2Impl(cfs,ca,cell_h,cell_v,cell_d,level,Lo_R,Hi_R,sx)%#codegen












    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');

    rmax=level+2;

    cell_a=coder.nullcopy(cell(1,(level+1)));
    cell_a{level+1}=ca;
    rm=rmax+1;


    coder.gpu.kernel;
    for iter=1:level
        numEl=numel(cfs{iter});
        cell_h{iter}=reshape(cfs{iter}(1:numEl/3),size(cell_h{iter}));
        cell_v{iter}=reshape(cfs{iter}(numEl/3+1:(2/3)*numEl),size(cell_h{iter}));
        cell_d{iter}=reshape(cfs{iter}((2/3)*numEl+1:end),size(cell_h{iter}));
    end


    coder.gpu.kernel;
    for p=level:-1:1
        cell_a{p}=idwt2(cell_a{p+1},cell_h{p},cell_v{p},cell_d{p},Lo_R,Hi_R,sx(rm-p,:));
    end

    a=cell_a{1};
end
