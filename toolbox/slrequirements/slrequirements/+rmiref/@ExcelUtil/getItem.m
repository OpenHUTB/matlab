function contents=getItem(filename,arg)

    utilObj=rmiref.ExcelUtil.docUtilObj(filename);

    if ischar(arg)

        if isExcelAddress(arg)
            rowNumber=excelAddressToRowNumber(arg);
            contents=getRowContents(utilObj,rowNumber);
        elseif isRangeName(utilObj,arg)
            contents=rmiref.ExcelUtil.getBookmarkedItems(filename,arg);
        else
            contents=rmiref.ExcelUtil.getItemsByPattern(filename,arg);
        end
    else
        contents=getRowContents(utilObj,arg);
    end
end

function yesno=isExcelAddress(arg)
    yesno=~isempty(regexp(arg,'^\$\S+\$\d+$','once'));
end

function rowNumber=excelAddressToRowNumber(address)
    match=regexp(address,'^\$?[A-Z]*\$(\d+)$','tokens');
    if isempty(match)
        error('ExcelUtil.getItem(): invalid address argument %s',address);
    end
    rowNumber=str2num(match{1}{1});%#ok<ST2NM>
end

function yesno=isRangeName(utilObj,arg)
    try
        utilObj.hDoc.Names.Item(arg);
        yesno=true;
    catch
        yesno=false;
    end
end

function contents=getRowContents(utilObj,row)
    contents{1,1}=utilObj.getLabel(row);
    contents{1,2}=row;
    targetFilePath=rmiref.ExcelUtil.getCacheFilePath(utilObj.sFullName,sprintf('row%d',row));
    hRange=utilObj.hDoc.Sheets.Item(1).Rows.Item(row);
    resultsFile=rmiref.ExcelUtil.rangeToHtml(hRange,targetFilePath,utilObj);
    if~isempty(resultsFile)&&exist(resultsFile,'file')==2
        contents{1,3}=resultsFile;
        contents{1,4}=rmi.Informer.htmlFileToString(resultsFile);
    else
        contents(1,3:4)={'',''};
    end
end

