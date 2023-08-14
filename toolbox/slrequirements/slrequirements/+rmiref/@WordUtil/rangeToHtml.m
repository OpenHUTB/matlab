
function resultsFile=rangeToHtml(range,targetFilePath,utilObj)
    if nargin<3
        utilObj=[];
    end

    origSaved=range.Parent.Saved;
    try





        if range.Parent.ReadOnly
            exportRangeFromTempCopy();
        else
            exportInPlace();
        end
    catch ex
        reportException(ex.message);
    end

    if exist(targetFilePath,'file')==2
        resultsFile=targetFilePath;
    else
        resultsFile='';
    end

    function reportException(essageFromWord)


        failedText=range.Text;
        if length(failedText)>100
            failedText=[failedText(1:100),'...'];
        end
        disp(getString(message('Slvnv:rmiref:WordUtil:ErrorInWord',essageFromWord,failedText)));


        if origSaved&&~range.Parent.ReadOnly
            range.Parent.Save;
        end
    end

    function exportInPlace()

        range.ListFormat.ConvertNumbersToText();
        range.ExportFragment(targetFilePath,10);

        range.Parent.Undo();
        if origSaved&&~range.Parent.Saved
            if isempty(utilObj)
                range.Parent.Save;
            else
                utilObj.resave();
            end
        end

        rmiref.cleanupExportedHtml(targetFilePath);
    end

    function exportRangeFromTempCopy()
        persistent tempDocs
        if isempty(tempDocs)
            tempDocs=containers.Map('KeyType','char','ValueType','char');
            tempDocs('origPath')='tempPath';
        end
        origName=range.Parent.FullName;
        if isKey(tempDocs,origName)
            tempFileName=tempDocs(origName);
        else
            [~,~,wExt]=fileparts(origName);
            tempFileName=[tempname(),wExt];
        end
        if exist(tempFileName,'file')~=2
            copyfile(origName,tempFileName);
            fileattrib(tempFileName,'+w');
        end
        tempDocs(origName)=tempFileName;
        tempDoc=rmiref.WordUtil.activateDocument(tempFileName);
        tempRange=tempDoc.Paragraphs.Item(1).Range;
        tempRange.Start=range.Start;
        tempRange.End=range.End;


        try
            tempRange.ListFormat.ConvertNumbersToText();
            shouldUndo=true;
        catch
            shouldUndo=false;
        end
        tempRange.ExportFragment(targetFilePath,10);
        if shouldUndo
            tempDoc.Undo();
        end

        rmiref.cleanupExportedHtml(targetFilePath);
    end
end
