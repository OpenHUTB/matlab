function[D,A]=mdwtdecWdenoise(x,lev,LoD,HiD)%#codegen




    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');


    [dwtEXTM,shift]=wavelet.internal.defaultDWTExtModeAndShift('get');
    first=2-rem(shift,2);





    x=double(x);
    temp_X=gpucoder.transpose(x);


    cellA=coder.nullcopy(cell(1,lev+1));
    cellD=coder.nullcopy(cell(1,lev));

    sizeMat=coder.nullcopy(zeros(1,lev+2,'like',x));
    cellA{1}=temp_X;


    if~coder.internal.isConst(lev)
        coder.varsize('cellA{:}');
    end
    sizeMat(1)=size(temp_X,2);


    for i=1:lev
        lf=length(LoD);
        lx=sizeMat(i);

        dCol=lf-1;
        lenEXT=lf-1;
        lenKEPT=lx+lf-1;

        idxCOL=(first+dCol:2:lenKEPT+dCol);


        y=wextend('addcol',dwtEXTM,cellA{i},lenEXT);


        aConv=conv2(y,LoD,'full');
        dConv=conv2(y,HiD,'full');


        cellA{i+1}=aConv(:,idxCOL);
        cellD{i}=dConv(:,idxCOL);
        sizeMat(i+1)=length(idxCOL);
    end


    cA=cellA{lev+1};



    D=coder.nullcopy(cell(1,lev));
    A=gpucoder.transpose(cA);
    for i=1:lev
        cD_i=cellD{i};
        D_i=gpucoder.transpose(cD_i);
        D{i}=D_i;
    end

end
