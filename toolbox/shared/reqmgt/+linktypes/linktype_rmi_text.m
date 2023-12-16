function linktype=linktype_rmi_text

    linktype=ReqMgr.LinkType;
    linktype.Registration=mfilename;
    linktype.Label=getString(message('Slvnv:rmiml:LinkableDomainLegacy'));

    linktype.IsFile=1;
    linktype.Extensions={'.txt'};

    linktype.LocDelimiters='?>';
    linktype.Version='';

    linktype.NavigateFcn=@NavigateFcn;
    linktype.CreateURLFcn=@CreateURLFcn;
    linktype.UrlLabelFcn=@UrlLabelFcn;
end


function NavigateFcn(filename,locationStr)

    lineNum=0;

    if~isempty(locationStr)
        findId=0;
        switch(locationStr(1))
        case '>'
            lineNum=str2double(locationStr(2:end));

        case '?'
            locationStr=locationStr(2:end);
            findId=1;

        otherwise
            findId=1;

        end

        if findId==1
            fid=fopen(filename);
            i=1;
            while lineNum==0
                lineStr=fgetl(fid);
                if contains(lineStr,locationStr)
                    lineNum=i;
                end
                if~ischar(lineStr),break,end
                i=i+1;
            end
            fclose(fid);
        end
    end

    openTextFileToLine(filename,lineNum);
end


function openTextFileToLine(fileName,lineNum)

    if lineNum>0
        if matlab.desktop.editor.isEditorAvailable
            matlab.desktop.editor.openAndGoToLine(fileName,lineNum);
        end
    else
        edit(fileName);
    end
end


function url=CreateURLFcn(doc,refSrc,locationStr)%#ok<INUSD>  Anchors not supported for TXT URLs
    url='';
    docPath=rmi.locateFile(doc,refSrc);
    if~isempty(docPath)
        url=rmiut.filepathToUrl(docPath);
    end
end


function label=UrlLabelFcn(doc,docLabel,location)
    if~isempty(docLabel)
        doc=docLabel;
    else
        doc=RptgenRMI.shortPath(doc);
    end
    if length(location)>1
        if location(1)=='>'
            label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtLine',...
            doc,location(2:end)));
        else
            label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPosition',...
            doc,location(2:end)));
        end
    else
        label=doc;
    end
end


