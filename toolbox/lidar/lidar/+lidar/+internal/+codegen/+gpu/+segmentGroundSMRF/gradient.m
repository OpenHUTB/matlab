function[outX,outY]=gradient(inpImg)%#codegen























    coder.allowpcode('plain');




    outX=imfilter(inpImg,[-0.5,0,0.5]);
    outY=imfilter(inpImg,[-0.5;0;0.5]);


    if isscalar(outX)
        return;
    end




    if isvector(inpImg)
        outX(1)=inpImg(2)-inpImg(1);
        outX(end)=inpImg(end)-inpImg(end-1);
        outY(1)=inpImg(2)-inpImg(1);
        outY(end)=inpImg(end)-inpImg(end-1);

    else
        outX(:,1)=inpImg(:,2)-inpImg(:,1);
        outX(:,end)=inpImg(:,end)-inpImg(:,end-1);
        outY(1,:)=inpImg(2,:)-inpImg(1,:);
        outY(end,:)=inpImg(end,:)-inpImg(end-1,:);
    end
end

