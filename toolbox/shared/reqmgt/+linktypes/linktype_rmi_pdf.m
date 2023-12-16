function linktype=linktype_rmi_pdf

    linktype=ReqMgr.LinkType;
    linktype.Registration=mfilename;
    linktype.Label=getString(message('Slvnv:reqmgt:linktype_rmi_pdf:PDFDocument'));


    linktype.IsFile=1;
    linktype.Extensions={'.pdf'};


    linktype.LocDelimiters='#@';
    linktype.Version='';


    linktype.NavigateFcn=@NavigateFcn;

    linktype.CreateURLFcn=@CreateURLFcn;
    linktype.UrlLabelFcn=@UrlLabelFcn;
end

function NavigateFcn(filename,id)%#ok<INUSD>
    if ispc
        try

            userChoice=reqmgt('regValue','HKEY_CURRENT_USER','Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice','ProgId');

            registryStr=[userChoice,'\Shell\Open\Command'];

            openCommand=reqmgt('regValue','HKEY_CLASSES_ROOT',registryStr,'');
            openCommand=[strrep(openCommand,'%1',filename),' &'];


            if~isempty(id)
                if id(1)=='#'

                    ACROBAT_EXE='Acrobat.exe';
                    ADOBE_READER_EXE='AcroRd32.exe';

                    if contains(openCommand,ACROBAT_EXE)||contains(openCommand,ADOBE_READER_EXE)
                        try
                            idNum=id(2:end);
                            pageNum=str2double(idNum);
                            if~isnan(pageNum)

                                gotoCmd=['/A "page=',idNum,'" '];
                                openCommand=insertBefore(openCommand,['"',filename],gotoCmd);
                            end
                        catch ex


                        end
                    end
                end
            end

            system(openCommand);
            return;
        catch ex %#ok<NASGU>
            rptgen.pdfmanage('open',filename);
        end
    else
        rptgen.pdfmanage('open',filename);
    end
end

function url=CreateURLFcn(doc,refSrc,locationStr)
    docPath=rmi.locateFile(doc,refSrc);
    if isempty(docPath)
        url='';
    else
        url=rmiut.filepathToUrl(docPath);
        if~isempty(locationStr)&&contains(url,'file://')

            switch locationStr(1)
            case '#'
                url=[url,'#page=',locationStr(2:end)];
            case '@'
                url=[url,'#namedest=',locationStr(2:end)];
            otherwise
                url=[url,'#',locationStr];
            end
        end
    end
end

function label=UrlLabelFcn(doc,docLabel,location)
    if~isempty(docLabel)
        doc=docLabel;
    else
        doc=RptgenRMI.shortPath(doc);
    end
    if length(location)>1
        if location(1)=='#'
            label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPage',...
            doc,location(2:end)));
        else
            label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPosition',...
            doc,location(2:end)));
        end
    else
        label=doc;
    end
end









































































































































