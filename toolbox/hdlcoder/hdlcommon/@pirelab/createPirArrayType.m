function pirType=createPirArrayType(baseTp,portDims)







    arrtypef=pir_arr_factory_tc;
    if length(portDims)==1
        vecLen=portDims(1);
        arrtypef.addDimension(vecLen);
    elseif length(portDims)==2
        [vectorLength,vectorOrientation,foundMatrix]=getVectorLengthAndOrientation(portDims);
        if foundMatrix
            arrtypef.addDimension(portDims(1));
            arrtypef.addDimension(portDims(2));
        else
            arrtypef.addDimension(vectorLength);
            arrtypef.VectorOrientation=vectorOrientation;
        end
    else


        if(length(portDims)>3&&(portDims(1)==1||portDims(1)==-2))


            error(message('hdlcoder:matrix:TooManyMatrixDims'));
        end

        if(length(portDims)>4)

            error(message('hdlcoder:matrix:TooManyMatrixDims'));
        end

        [vectorLen,vectorOrientation,isMatrix]=getVectorLengthAndOrientation(portDims);
        if isMatrix
            for ii=1:length(portDims)
                arrtypef.addDimension(portDims(ii))
            end
        else
            arrtypef.addDimension(vectorLen);
        end
        arrtypef.VectorOrientation=vectorOrientation;
    end

    arrtypef.addBaseType(baseTp);
    pirType=pir_array_t(arrtypef);
end


function[vectorLen,vectorOrientation,foundMatrix]=getVectorLengthAndOrientation(portDims)






    foundMatrix=false;

    if numel(portDims)==2
        if portDims(1)==0
            error(message('hdlcoder:engine:MatrixInvalidType'));
        elseif portDims(2)==0
            vectorLen=portDims(1);
            vectorOrientation='unoriented';
            return;
        elseif portDims(1)==1
            vectorLen=portDims(2);
            vectorOrientation='row';
            return;
        elseif portDims(2)==1
            vectorLen=portDims(1);
            vectorOrientation='column';
            return;
        end
    end

    vectorLen=-1;
    vectorOrientation='unoriented';
    foundMatrix=true;
end


