function contents=getItemsByColumn(doc,column)

    contents=cell(0,4);
    count=0;
    utilObj=rmiref.ExcelUtil.docUtilObj(doc);

    for row=1:length(utilObj.iLevels)
        if utilObj.iLevels==0
            continue;
        end
        [hRange,text,address]=getContent(utilObj,row,column);
        if~isempty(hRange)
            count=count+1;
            contents{count,1}=text;
            contents{count,2}=address;
            targetFilePath=rmiref.WordUtil.getCacheFilePath(doc,textToVarname(text));
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

function[range,text,address]=getContent(obj,row,col)
    range=[];
    address='';
    hRow=obj.hDoc.Sheets.Item(1).Rows.Item(row);
    hCell=hRow.Cells.Item(col);
    text=hCell.Text;
    if~isempty(text)&&isGoodRow(hRow,col)
        range=hRow;
        address=hCell.Address;
    end
end

function yesno=isGoodRow(hRow,col)
    lastCol=col+4;
    while col<lastCol
        col=col+1;
        myText=hRow.Cells.Item(col).Text;
        if~isempty(myText)&&(length(myText)>33||length(find(myText==' '))>3)
            yesno=true;
            return;
        else
            continue;
        end
    end
    yesno=false;
end

function out=textToVarname(in)
    out=matlab.lang.makeValidName(in);
    if length(out)>22
        out=out(1:22);
    end
end
