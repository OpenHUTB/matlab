function myDate=getDocDate(docName,srcDir,type)




    if ischar(type)
        if strcmp(type,'other')
            linktype=rmi.linktype_mgr('resolveByFileExt',docName);
        else
            linktype=rmi.linktype_mgr('resolveByRegName',type);
        end
    else
        linktype=type;
    end



    if linktype.isFile




        fullPath=rmiut.absolute_path(docName,srcDir);



        if exist(fullPath,'file')==0&&isempty(fileparts(docName))
            fullPath=which(docName);
        end
        myDate=getFileDate(fullPath);




    elseif strcmp(linktype.Registration,'linktype_rmi_matlab')

        myDate=getFileDate(rmiml.resolveDoc(docName,srcDir));

    elseif strcmp(linktype.Registration,'linktype_rmi_data')

        myDate=getFileDate(rmi.locateFile(docName,srcDir));


    elseif~isempty(linktype.DocDateFcn)

        myDate=linktype.DocDateFcn(docName);
    else

        myDate=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:NA'));
    end

end

function fileDate=getFileDate(docPath)
    if isempty(docPath)||exist(docPath,'file')~=2
        fileDate=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:SystemNotFound'));
    else
        finfo=dir(docPath);
        fileDate=finfo.date;
    end
end
