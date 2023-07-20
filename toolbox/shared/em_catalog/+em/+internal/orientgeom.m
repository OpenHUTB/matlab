function pnew=orientgeom(p,tempTilt,numTilt,tempAxis)


    if ischar(tempAxis)||(isstring(tempAxis)&&isscalar(tempAxis))
        tempAxis_modif=zeros(max(size(tempAxis)),3);
        for i=1:numTilt
            switch tempAxis(i)
            case 'X'
                tempAxis_modif(i,:)=[1,0,0];
            case 'Y'
                tempAxis_modif(i,:)=[0,1,0];
            case 'Z'
                tempAxis_modif(i,:)=[0,0,1];
            end
        end
        tempAxis=tempAxis_modif;
    end

    szOfAxis=size(tempAxis);












    numAxisVectors=size(tempAxis,1);





    valid_case1=isequal(numTilt,numAxisVectors);
    valid_case2=isequal(numTilt,numAxisVectors/2);

    if valid_case1
        pnew=p;
        for i=1:numTilt
            pnew=em.internal.rotateshape(pnew,[0,0,0],tempAxis(i,:),tempTilt(i));
        end
    elseif valid_case2
        pnew=p;
        for i=1:numTilt
            pnew=em.internal.rotateshape(pnew,tempAxis(2*i-1,:),tempAxis(2*i,:),tempTilt(i));
        end

    end
end