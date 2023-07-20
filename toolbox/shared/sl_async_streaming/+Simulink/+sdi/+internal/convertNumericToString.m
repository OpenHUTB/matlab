function strData=convertNumericToString(numData,strVals)




    strData=cell(size(numData));
    numStrings=length(strVals);
    for idx=1:length(numData)
        if numData(idx)>=0&&numData(idx)<numStrings
            strData{idx}=strVals{numData(idx)+1};
        else
            strData{idx}='';
        end
    end
    strData=string(strData);
end
