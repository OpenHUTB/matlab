function numDims=getNumDims(this)





    numDims=str2double(this.DialogData.NumberOfDimensions);
    if isnan(numDims)||length(numDims)~=1||numDims<=0||floor(numDims)~=numDims||~isreal(numDims)
        numDims=1;
    end

end