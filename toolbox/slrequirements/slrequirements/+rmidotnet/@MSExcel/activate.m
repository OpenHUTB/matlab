function hDoc=activate(docPath,doShow)



    if nargin<2
        doShow=true;
    end

    isOneDrive=rmidotnet.isOneDrivePath(docPath);
    shortName=slreq.uri.getShortNameExt(docPath);
    hDoc=[];
    hApp=rmidotnet.MSExcel.application();
    allDocs=hApp.Workbooks;
    for i=1:allDocs.Count
        oneDoc=allDocs.Item(i);
        docFullName=oneDoc.FullName.char;
        if strcmp(docFullName,docPath)
            hDoc=oneDoc;
            break;
        elseif isOneDrive
            docShortName=slreq.uri.getShortNameExt(docFullName);
            if strcmp(docShortName,shortName)
                hDoc=oneDoc;
                break;
            end
        end
    end
    if isempty(hDoc)
        if isOneDrive


            scratchFolder=fullfile(tempdir,'RMI','scratch');
            copyfile(docPath,scratchFolder,'f');
            docPath=fullfile(scratchFolder,slreq.uri.getShortNameExt(docPath));
            fileattrib(docPath,'+w');
            slreq.import.docToReqSetMap(docPath,'clear');
        end
        allDocs.Open(docPath,0,0);
        hDoc=hApp.ActiveWorkbook;








        if~hDoc.Saved
            fileattrib(docPath,'+w');
            hDoc.Save();
        end
    end
    hApp.Visible=1;
    if doShow

        if(strcmpi(hApp.WindowState.char,'xlMinimized'))
            hApp.WindowState=Microsoft.Office.Interop.Excel.XlWindowState.xlNormal;
        end
    end
    hDoc.Activate;
end

