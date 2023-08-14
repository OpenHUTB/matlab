function sx=sizeOfCoefficientsWdenoise2(sizeX,level,sizeLo_D)%#codegen




    coder.allowpcode('plain');

    nd=numel(sizeX);
    sx=coder.nullcopy(zeros(level+2,nd));
    sx(level+2,:)=sizeX;

    if nd==3
        sx(:,3)=3;
    end


    for i=level+1:-1:2
        sizeEXT=sizeLo_D(2)-1;
        last=sx(i+1,1:2)+sizeEXT;
        sx(i,1:2)=sizeCompute(sx(i+1,1:2),sizeEXT,sizeLo_D,last);
    end

    sx(1,1:2)=sx(2,1:2);

end

function sizeX=sizeCompute(sizeX,sizeEXTM,sizeLo_D,last)




    sizeX(2)=sizeX(2)+(2*sizeEXTM);
    sizeX=sizeX-sizeLo_D+1;
    if mod(last(2),2)
        sizeX(2)=(last(2)-1)/2;
    else
        sizeX(2)=(last(2))/2;
    end


    sizeX(1)=sizeX(1)+(2*sizeEXTM);

    tempS=sizeX(1);
    sizeX(1)=sizeX(2);
    sizeX(2)=tempS;

    sizeX=sizeX-sizeLo_D+1;

    tempS=sizeX(1);
    sizeX(1)=sizeX(2);
    sizeX(2)=tempS;

    if mod(last(1),2)
        sizeX(1)=(last(1)-1)/2;
    else
        sizeX(1)=(last(1))/2;
    end

end
