function paddedImage=padForNegativeData(paddedImage,originalImage,padMode)




    imageSize=size(paddedImage);

    if(length(imageSize)==2)
        features=1;
    else
        features=imageSize(3);
    end
    padTop=padMode(1);
    padBottom=padMode(2);
    padLeft=padMode(3);
    padRight=padMode(4);


    if(isa((originalImage),'int32'))
        padZero=int32(0);
    elseif(isa((originalImage),'int8'))
        padZero=int8(0);
    elseif(isa((originalImage),'half'))
        padZero=half(0);
    elseif(isfi(originalImage))
        padZero=cast(0,'like',originalImage);
    else
        padZero=single(0);
    end

    for featureNum=1:features





















        numberOfTopPaddingRows=padTop;
        for topPadIndex=1:numberOfTopPaddingRows

            rowValue=originalImage(1,:,featureNum);
            rowValue(rowValue>=0)=padZero;
            paddedImage(topPadIndex,1+padLeft:end-padRight,featureNum)=rowValue;
        end









        numberOfBottomPaddingRows=padBottom;
        for bottomPadIndex=1:numberOfBottomPaddingRows

            rowValue=originalImage(end,:,featureNum);
            rowValue(rowValue>=0)=padZero;
            paddedImage(end-bottomPadIndex+1,1+padLeft:end-padRight,featureNum)=rowValue;
        end









        numberOfLeftPaddingCols=padLeft;
        for leftPadIndex=1:numberOfLeftPaddingCols

            colValue=originalImage(:,1,featureNum);
            colValue(colValue>=0)=padZero;
            paddedImage(1+padTop:end-padBottom,leftPadIndex,featureNum)=colValue;
        end









        numberOfRightPaddingCols=padRight;
        for rightPadIndex=1:numberOfRightPaddingCols

            colValue=originalImage(:,end,featureNum);
            colValue(colValue>=0)=padZero;
            paddedImage(1+padTop:end-padBottom,end-rightPadIndex+1,featureNum)=colValue;
        end









        if(padTop>0&&padLeft>0)

            cornerRows=padTop;
            cornerColumns=padLeft;
            padValue=padZero;
            if(paddedImage(cornerRows+1,cornerColumns+1,featureNum)<0)
                padValue=paddedImage(cornerRows+1,cornerColumns+1,featureNum);
            end
            for i=1:cornerRows
                for j=1:cornerColumns
                    paddedImage(i,j,featureNum)=padValue;
                end
            end
        end









        if(padTop>0&&padRight>0)
            cornerRows=padTop;
            cornerColumns=padRight;
            padValue=padZero;
            if(paddedImage(cornerRows+1,end-cornerColumns,featureNum)<0)
                padValue=paddedImage(cornerRows+1,end-cornerColumns,featureNum);
            end
            for i=1:cornerRows
                for j=1:cornerColumns
                    paddedImage(i,end-j+1,featureNum)=padValue;
                end
            end
        end









        if(padBottom>0&&padLeft>0)
            cornerRows=padBottom;
            cornerColumns=padLeft;
            padValue=padZero;
            if(paddedImage(end-cornerRows,cornerColumns+1,featureNum)<0)
                padValue=paddedImage(end-cornerRows,cornerColumns+1,featureNum);
            end
            for i=1:cornerRows
                for j=1:cornerColumns
                    paddedImage(end-i+1,j,featureNum)=padValue;
                end
            end
        end









        if(padBottom>0&&padRight>0)
            cornerRows=padBottom;
            cornerColumns=padRight;
            padValue=padZero;
            if(paddedImage(end-cornerRows,end-cornerColumns,featureNum)<0)
                padValue=paddedImage(end-cornerRows,end-cornerColumns,featureNum);
            end
            for i=1:cornerRows
                for j=1:cornerColumns
                    paddedImage(end-i+1,end-j+1,featureNum)=padValue;
                end
            end
        end
    end

end
