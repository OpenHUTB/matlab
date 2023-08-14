function linkType=linktype_rmi_safetymanager

    linkType=ReqMgr.LinkType;
    linkType.Registration=mfilename;


    linkType.Label=getString(message('Slvnv:rmism:SafetyManager'));


    linkType.IsFile=0;
    linkType.Extensions={'.xlm'};


    linkType.LocDelimiters='@';
    linkType.Version='';


    linkType.NavigateFcn=@NavigateFcn;
    linkType.SelectionLinkFcn=@SelectionLinkFcn;
    linkType.BrowseFcn=@BrowseFcn;
    linkType.CreateURLFcn=@CreateURLFcn;
    linkType.DocDateFcn=@DocDateFcn;
    linkType.ItemIdFcn=@ItemIdFcn;
    linkType.SelectionLinkLabel=getString(message('Slvnv:rmism:LinkToCurrent'));
end


function NavigateFcn(document,location)
    rmism.navigate(document,location);
end

function req=SelectionLinkFcn(obj,make2way)
    oldRmiStruct=true;
    req=rmism.selectionLink(obj,make2way,oldRmiStruct);
end

function safetyManagerFile=BrowseFcn()
    extensions='*.xml;';
    [fileName,pathName]=uigetfile(...
    {extensions,getString(message('Slvnv:rmism:SafetyManagerExtensions',extensions));...
    '*.*',getString(message('Slvnv:rmism:AllFilesExtensions'))},...
    getString(message('Slvnv:rmism:SelectTargetSafetyManagerFile')));

    if isempty(fileName)||~ischar(fileName)
        safetyManagerFile='';
        return;
    end
    safetyManagerFile=fullfile(pathName,fileName);
    warndlg('browsFunc to Safety Manager to be implemented');
end

function url=CreateURLFcn(docPath,~,loc)
    navCmd=sprintf('rmism.navigate('' %s '','' %s'')',docPath,loc);
    url=rmiut.cmdToUrl(navCmd);
end

function dateString=DocDateFcn(doc)
    fileinfo=dir(doc);
    if~isempty(fileinfo)
        dateString=fileinfo.date;
    else
        dateString='';
    end
end

function out=ItemIdFcn(host,in,mode)
    out=rmism.itemID(host,in,mode);
end