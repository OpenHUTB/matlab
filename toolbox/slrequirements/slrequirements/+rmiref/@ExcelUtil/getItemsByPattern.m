function contents=getItemsByPattern(doc,pattern)

    contents=cell(0,4);
    count=0;
    utilObj=rmiref.ExcelUtil.docUtilObj(doc);

    for row=1:length(utilObj.iLevels)
        if utilObj.iLevels==0
            continue;
        end
        [hRange,text,address]=findPattern(utilObj,row,pattern);
        if~isempty(hRange)
            count=count+1;
            contents{count,1}=text;
            contents{count,2}=address;
            targetFilePath=rmiref.ExcelUtil.getCacheFilePath(doc,text);
            resultsFile=rmiref.ExcelUtil.rangeToHtml(hRange,targetFilePath,utilObj);
            if~isempty(resultsFile)&&exist(resultsFile,'file')==2
                contents{count,3}=resultsFile;
                contents{count,4}=rmi.Informer.htmlFileToString(resultsFile);
            else
                contents(count,3:4)={'',''};
            end
        end
    end

end

function[range,text,address]=findPattern(obj,row,pattern)



    range=[];
    text='';
    address='';
    label=obj.getLabel(row);
    if~isempty(regexp(label,pattern,'once'))
        range=obj.hDoc.Sheets.Item(1).Rows.Item(row);
        col=1;
        last=100;
        while isempty(text)
            oneCellText=range.Cells.Item(col).Text;
            if~isempty(regexp(oneCellText,pattern,'once'))
                text=oneCellText;
                address=range.Cells.Item(col).Address;
                break;
            elseif col==last
                break;
            else
                col=col+1;
            end
        end
    end
end
