function result=cropImage(img,theColor,padding)








    if nargin<3
        padding=0;
    end
    if padding<0
        padding=0;
    end

    if nargin<2||isempty(theColor)
        theColor=img(1,1,:);
    end
    [rows,cols,~]=size(img);






    [firstRow,lastRow,leftCol,rightCol]=matlab.graphics.internal.export.findPixelDiff(img,theColor);


    croppedRows=lastRow-firstRow+1;
    croppedCols=rightCol-leftCol+1;


    if firstRow==lastRow&&lastRow==0
        croppedRows=rows;

        firstRow=1;
        lastRow=rows;
    end
    if leftCol==rightCol&&rightCol==0
        croppedCols=cols;

        leftCol=1;
        rightCol=cols;
    end


    newRows=croppedRows+padding*2;
    newCols=croppedCols+padding*2;






    if firstRow>padding&&leftCol>padding&&...
        (rows-lastRow)>=padding&&...
        (cols-rightCol)>=padding

        needNewImage=false;
    else

        needNewImage=true;
    end

    if needNewImage
        result=repmat(theColor,newRows,newCols);

        firstRowIdx=padding+1;
        firstColIdx=padding+1;
        lastRowIdx=croppedRows+padding;
        lastColIdx=croppedCols+padding;


        result(firstRowIdx:lastRowIdx,firstColIdx:lastColIdx,:)=...
        img(firstRow:lastRow,leftCol:rightCol,:);
    else


        firstRow=firstRow-padding;
        if firstRow<1
            firstRow=1;
        end

        lastRow=lastRow+padding;
        if lastRow>rows
            lastRow=rows;
        end

        leftCol=leftCol-padding;
        if leftCol<1
            leftCol=1;
        end

        rightCol=rightCol+padding;
        if rightCol>cols
            rightCol=cols;
        end

        result=img(firstRow:lastRow,leftCol:rightCol,:);
    end

end

