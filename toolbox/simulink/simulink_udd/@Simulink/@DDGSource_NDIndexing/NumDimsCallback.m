function NumDimsCallback(this,dlg,varargin)





    oldNumDims=str2double(this.DialogData.NumberOfDimensions);
    numDims=str2double(varargin{1});


    refreshFlag=~isequal(oldNumDims,numDims);

    if~isnan(numDims)&&length(numDims)==1&&numDims>0&&floor(numDims)==numDims&&isreal(numDims)...
        &&numDims<=65535


        this.DialogData.NumberOfDimensions=varargin{1};
    end

    if refreshFlag
        dlg.refresh;
    end

end

