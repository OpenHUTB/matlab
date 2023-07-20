function x=mdwtrecWdenoise(temp_cD,temp_cA,levMAX,LoR,HiR,dataSize)%#codegen




    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');


    sx=coder.nullcopy(zeros(levMAX+1,1));
    sx(1)=dataSize(1);
    for j=2:levMAX+1
        temp=temp_cD{j-1};
        sx(j)=size(temp,1);
    end

    cD=coder.nullcopy(cell(size(temp_cD)));
    sx=fliplr(sx);




    cA=gpucoder.transpose(temp_cA);
    for j=1:levMAX
        tempcD_j=temp_cD{j};
        cD_j=gpucoder.transpose(tempcD_j);
        cD{j}=cD_j;
    end

    cellX=coder.nullcopy(cell(1,levMAX+1));
    cellX{end}=cA;


    coder.gpu.nokernel;
    for i=levMAX:-1:1
        cellX{i}=upConvGPU(cellX{i+1},LoR,sx(i))+upConvGPU(cD{i},HiR,sx(i));
    end

    tempX=cellX{1};



    x=gpucoder.transpose(tempX);
end

function y=upConvGPU(x,f,lenKept)



    if isempty(x),y=0;return;end

    [sx1,sx2]=size(x);
    sx2=2*sx2;

    yz=zeros(sx1,sx2-1);
    yz(:,1:2:end)=x;
    yConv=conv2(yz,f,'full');
    sy=size(yConv,2);
    if lenKept>sy,lenKept=sy;end
    d=(sy-lenKept)/2;
    first=1+floor(d);
    last=sy-ceil(d);

    y=coder.nullcopy(zeros(sx1,lenKept));
    y=yConv(:,first:last);
end