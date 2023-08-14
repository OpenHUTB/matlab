
function[A,D,sx,coeffs]=mdwtdec(x,LoD,HiD,dwtEXTM,perFLAG,first,lev,dirDec)

%#codegen




    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');



    x=double(x);



    if strcmp(dirDec,'c')
        temp_X=gpucoder.transpose(x);
    else
        temp_X=x;
    end


    isRow=coder.internal.isConst(isrow(temp_X))&&isrow(temp_X);

    inpSize=size(temp_X);


    cell_A=coder.nullcopy(cell(1,lev+1));
    cell_D=coder.nullcopy(cell(1,lev));



    sizeMat=coder.nullcopy(zeros(1,lev+2));
    cell_A{1}=temp_X;

    sizeMat(1)=size(temp_X,2);
    coeffLen=0;


    for i=1:lev
        lf=length(LoD);
        lx=sizeMat(i);



        dCol=lf-1;
        if~perFLAG
            lenEXT=lf-1;
            lenKEPT=lx+lf-1;
        else
            lenEXT=lf/2;
            lenKEPT=2*ceil(lx/2);
        end

        idxCOL=(first+dCol:2:lenKEPT+dCol);


        y=wextend('addcol',dwtEXTM,cell_A{i},lenEXT);


        aConv=conv2(y,LoD,'full');
        dConv=conv2(y,HiD,'full');


        cell_A{i+1}=aConv(:,idxCOL);
        cell_D{i}=dConv(:,idxCOL);
        sizeMat(i+1)=length(idxCOL);
        coeffLen=coeffLen+length(idxCOL);
    end

    sizeMat(lev+2)=sizeMat(lev+1);
    coeffVals=coder.nullcopy(zeros(inpSize(1),coeffLen+size(cell_A{lev+1},2)));



    startVal=size(coeffVals,2);
    for i=1:lev
        endVal=startVal;
        startVal=startVal-sizeMat(i+1);

        if isRow
            coeffVals(startVal+1:endVal)=cell_D{i}(:);
        else
            for j=startVal+1:endVal
                coeffVals(:,j)=cell_D{i}(:,j-startVal);
            end
        end
        if i==lev
            if isRow
                coeffVals(1:sizeMat(end))=cell_A{lev+1}(:);
            else
                coeffVals(:,1:sizeMat(end))=cell_A{lev+1};
            end
        end
    end

    cA=cell_A{lev+1};

    D=coder.nullcopy(cell(1,lev));


    sizeMat=fliplr(sizeMat);


    if strcmp(dirDec,'c')
        coeffs=gpucoder.transpose(coeffVals);
        sx=gpucoder.transpose(sizeMat);
        A=gpucoder.transpose(cA);
        for i=1:lev
            D{i}=gpucoder.transpose(cell_D{i});
        end
    else
        coeffs=coeffVals;
        sx=sizeMat;
        A=cA;
        for i=1:lev
            D{i}=cell_D{i};
        end
    end
end


