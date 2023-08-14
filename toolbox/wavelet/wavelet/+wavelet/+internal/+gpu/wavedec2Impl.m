function[ca,cell_h,cell_v,cell_d,c]=wavedec2Impl(x,n,Lo_D,Hi_D)%#codegen











    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');

    cell_xv=coder.nullcopy(cell(1,n+1));
    cell_h=coder.nullcopy(cell(1,n));
    cell_v=coder.nullcopy(cell(1,n));
    cell_d=coder.nullcopy(cell(1,n));
    sizeMat=coder.nullcopy(zeros(1,n+1,'like',x));
    cell_xv{1}=x;
    coeffLen=0;


    if~coder.internal.isConst(n)
        coder.varsize('cell_xv{:}');
    end


    coder.gpu.kernel;
    for k=1:n
        [cell_xv{k+1},cell_h{k},cell_v{k},cell_d{k}]=dwt2(cell_xv{k},Lo_D,Hi_D);
        sizeMat(k)=3*numel(cell_h{k}(:));
        coeffLen=coeffLen+sizeMat(k);
    end

    ca=cell_xv{n+1};

    sizeMat(n+1)=numel(cell_xv{n+1}(:));
    c=coder.nullcopy(zeros(1,coeffLen+sizeMat(n+1),'like',x));
    startVal=length(c);


    for k=1:n
        endVal=startVal;
        startVal=startVal-sizeMat(k);
        c(startVal+1:endVal)=[cell_h{k}(:).',cell_v{k}(:).',cell_d{k}(:).'];
        if k==n
            c(1:sizeMat(end))=cell_xv{n+1}(:).';
        end
    end

end
