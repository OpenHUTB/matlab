function[c,s]=wavedec2(x,n,Lo_D,Hi_D)%#codegen




    coder.allowpcode('plain');


    coder.gpu.internal.kernelfunImpl(false);


    nd=ndims(x);


    cell_xv=coder.nullcopy(cell(1,n+1));
    cell_h=coder.nullcopy(cell(1,n));
    cell_v=coder.nullcopy(cell(1,n));
    cell_d=coder.nullcopy(cell(1,n));
    s=coder.nullcopy(zeros(n+2,nd));
    sizeMat=coder.nullcopy(zeros(1,n+1));
    cell_xv{1}=x;


    if~coder.internal.isConst(n)
        if nd==3
            coder.varsize('cell_xv{:}',[inf(1,2),3],[1,1,0]);
        else
            coder.varsize('cell_xv{:}',inf(1,2));
        end
    end


    coeffLen=0;

    s(n+2,:)=size(x);


    for k=1:n
        [cell_xv{k+1},cell_h{k},cell_v{k},cell_d{k}]=dwt2(cell_xv{k},Lo_D,Hi_D);
        sizeMat(k)=3*numel(cell_h{k}(:));
        s(n-k+2,:)=size(cell_h{k});
        coeffLen=coeffLen+sizeMat(k);
    end


    sizeMat(n+1)=numel(cell_xv{n+1}(:));
    c=coder.nullcopy(zeros(1,coeffLen+sizeMat(n+1)));
    startVal=length(c);


    for k=1:n
        endVal=startVal;
        startVal=startVal-sizeMat(k);
        c(startVal+1:endVal)=[cell_h{k}(:).',cell_v{k}(:).',cell_d{k}(:).'];
        if k==n
            c(1:sizeMat(end))=cell_xv{n+1}(:).';
            s(1,:)=size(cell_xv{n+1});
        end
    end
end