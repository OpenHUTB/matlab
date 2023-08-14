function numericAxis=charAxis2Numeric(tempAxis,numTilt)


    if ischar(tempAxis)
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
        numericAxis=tempAxis_modif;
    else
        numericAxis=tempAxis;
    end
end