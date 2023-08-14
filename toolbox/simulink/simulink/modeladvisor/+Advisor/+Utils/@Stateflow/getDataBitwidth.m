
function dataBitWidth=getDataBitwidth(dataType)
    if strcmp(dataType,'unknown')||strcmp(dataType,'ml')
        dataBitWidth=NaN;
    else
        nt=numerictype(dataType);
        dataBitWidth=nt.WordLength;
    end
end