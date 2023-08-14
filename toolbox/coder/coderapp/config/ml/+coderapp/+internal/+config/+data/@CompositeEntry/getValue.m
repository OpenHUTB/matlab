function value=getValue(this)


    if~isempty(this.Bytes)
        value=getArrayFromByteStream(matlab.net.base64decode(this.Bytes));
    elseif~isempty(this.Code)
        [~,value]=evalc(this.Code);
    else
        value=[];
    end
end