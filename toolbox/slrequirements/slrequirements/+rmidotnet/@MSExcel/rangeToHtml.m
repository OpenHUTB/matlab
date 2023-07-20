


function[html,targetFilePath]=rangeToHtml(this,label,hRange,richContent)



    if nargin<4
        richContent=false;
    end

    disableCaching=true;

    if richContent


        this.initPaths();

        targetFilePath=rmidotnet.getCacheFilePath(this.htmlFileDir,this.sName,label);


        if disableCaching||~rmidotnet.isCurrentCache(targetFilePath,this.dTimestamp)


            excelRangeToHtml(hRange,targetFilePath,label);

            html=slreq.import.html.processRawExport(targetFilePath,this.resourcePath,'EXCEL');

        elseif exist(targetFilePath,'file')==2

            fid=fopen(targetFilePath,'r');
            html=fread(fid,'*char')';
            fclose(fid);

        else
            html='';
        end

    else

        targetFilePath='';
        numCols=range.Columns.Count;
        numRows=range.Rows.Count;
        row=range.Row;
        col=range.Column;
        rowRange=row:row+numRows-1;
        colRange=col:col+numCols-1;
        html=this.cellsToHtml(rowRange,colRange);
    end
end

function excelRangeToHtml(hRange,targetFilePath,itemId)
    try

        hSheet=Microsoft.Office.Interop.Excel.Worksheet(hRange.Parent);
        hWorkbook=hSheet.Parent;
        wasSaved=hWorkbook.Saved;


        srcTypeRange=Microsoft.Office.Interop.Excel.XlSourceType.xlSourceRange;
        hPublisher=hWorkbook.PublishObjects.Add(srcTypeRange,targetFilePath,hSheet.Name,hRange.Address,0,...
        'RmiTarget','');
        hPublisher.Publish;

        legacy=false;



        if legacy&&exist(targetFilePath,'file')
            rmiref.cleanupExportedHtml(targetFilePath);
        end




        if wasSaved
            hWorkbook.Saved=1;
        end
    catch ME
        warning(['Failed to export ',itemId,': ',ME.message]);


    end
end
