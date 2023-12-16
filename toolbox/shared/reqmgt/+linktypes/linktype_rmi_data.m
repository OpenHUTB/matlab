function linkType=linktype_rmi_data

    linkType=ReqMgr.LinkType;
    linkType.Registration=mfilename;
    linkType.Label=getString(message('Slvnv:rmide:LinkableDomainLabel'));

    linkType.IsFile=0;
    linkType.Extensions={'.sldd'};

    linkType.LocDelimiters='@';
    linkType.Version='';

    linkType.NavigateFcn=@NavigateFcn;
    linkType.SelectionLinkFcn=@SelectionLinkFcn;
    linkType.BrowseFcn=@BrowseObjects;
    linkType.ContentsFcn=@ContentsFcn;

    linkType.CreateURLFcn=@CreateURLFcn;

    linkType.DocDateFcn=@DocDateFcn;
    linkType.ResolveDocFcn=@ResolveDocFcn;
    linkType.ItemIdFcn=@ItemIdFcn;

    linkType.SelectionLinkLabel=getString(message('Slvnv:rmide:LinkToCurrent'));
end

function NavigateFcn(dictFile,entryKey)
    if length(entryKey)>1&&entryKey(1)=='@'
        entryKey=entryKey(2:end);
    end
    rmiobjnavigate(dictFile,entryKey);
end


function req=SelectionLinkFcn(objH,make2way)
    req=[];
    [dfile,dpath,label]=rmide.getSelection();

    if isempty(dpath)&&...
        (strncmp(class(dfile),'Simulink.',9)||strncmp(class(dfile),'Stateflow.',9))
        req=linkSlOrSfObject(objH,dfile,make2way);
        return;
    end

    if ispc
        reqmgt('winFocus',['^',getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',''))]);
    end

    if isempty(dfile)

        errordlg(...
        getString(message('Slvnv:rmide:NoEntrySelected')),...
        getString(message('Slvnv:rmide:RequirementsUseCurrent')),...
        'modal');
        return;
    end

    targetObj=[dfile,'|',dpath,'.',label];


    if ischar(objH)&&strcmp(objH,targetObj)
        errordlg(...
        getString(message('Slvnv:rmide:SourceAndDestinationSame')),...
        getString(message('Slvnv:rmide:RequirementsUseCurrent')),...
        'modal');
        return;
    end

    if make2way
        if~slreq.internal.isSlreqItem(objH)
            returnLink=rmi.makeReq(objH,targetObj);
            if isempty(returnLink)

                req=[];
                return;
            else
                rmi.catReqs(targetObj,returnLink);
            end
        end
    end


    req=rmide.makeReq(targetObj,objH);
end

function dictName=BrowseObjects()


    extensions='*.sldd;';
    [fileName,pathName]=uigetfile(...
    {extensions,['Data Dictionary (',extensions,')'];...
    '*.*','All Files (*.*)'},...
    getString(message('Slvnv:rmide:SelectLinkTargetDictionary')));

    if isempty(fileName)||~ischar(fileName)
        dictName='';
        return;
    else

        fullPath=fullfile(pathName,fileName);
        rmide.meOpen(fullPath,'');

        if ispc
            reqmgt('winFocus',['^',getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',''))]);
        end

        if strcmp(rmipref('DocumentPathReference'),'none')
            dictName=fileName;
        else
            dictName=fullPath;
        end
    end
end

function[labels,depths,locations]=ContentsFcn(dictName)
    dictPath=rmide.getFilePath(dictName);
    try
        allEntries=rmide.getLinkableEntries(dictPath);
    catch ex
        if any(strcmp(ex.identifier,...
            {'SLDD:sldd:DuplicateSymbol','SLDD:sldd:DuplicateSymbolConsistent'}))
            labels={getString(message('Slvnv:rmide:SameNameDataObject')),...
            ex.message};
            depths=[0,1];
            locations={'',''};
            return;
        else
            rethrow(ex);
        end
    end
    labels=allEntries(:,1);
    locations=allEntries(:,2);

    depths=zeros(size(locations));
    currentDepth=0;
    for i=1:length(depths)
        location=locations{i};
        if isempty(strtrim(location))
            depths(i)=length(location);
            currentDepth=depths(i)+1;
            locations{i}='';
        else
            depths(i)=currentDepth;
            locations{i}=['@',locations{i}];
        end
    end
end


function req=linkSlOrSfObject(srcH,destObj,make2way)
    if make2way
        if isa(destObj,'Stateflow.Object')
            destH=destObj.Id;
        else
            destH=destObj.Handle;
        end
        rmisl.intraLink(destH,srcH);
    end
    req=rmisl.makeReq(destObj);
end

function out=ItemIdFcn(host,in,mode)

    if isempty(strtok(in))
        if mode
            out='';
        else
            [~,out]=fileparts(host);
        end
        return;
    end

    if isempty(host)
        out=in;
        return;
    end

    if in(1)=='@'
        isNamedItem=true;
        in=in(2:end);
    else
        isNamedItem=false;
    end

    if mode

        if strncmp(in,'UUID_',length('UUID_'))
            out=in;
        else
            dictPath=rmide.getFilePath(host);
            if~any(in=='.')
                in=['Design.',in];
            end

            if strncmp(in,'Design.',length('Design.'))
                in=strrep(in,'Design.','Global.');
            end
            out=rmide.getGuid([dictPath,'|',in]);
        end
    else

        if strncmp(in,'UUID_',length('UUID_'))
            out=rmide.getEntryPath(host,in);
        elseif~any(in=='.')
            out=['Design.',in];
        else
            out=in;
        end
        if isNamedItem
            out=['@',out];
        end
    end
end


function url=CreateURLFcn(ddfile,~,dditem)
    if~isempty(dditem)&&dditem(1)=='@';
        dditem=dditem(2:end);
    end
    url=sprintf('matlab:rmide.navigate(''%s'', ''%s'')',ddfile,dditem);
end


function[docPath,isRel]=ResolveDocFcn(doc,ref)
    if isempty(strfind(doc,'.sldd'))
        doc=[doc,'.sldd'];
    end
    docPath=rmi.locateFile(doc,ref);
    isRel=(~isempty(docPath)&&~strcmp(docPath,doc));
end


function[docDate,docDateNum]=DocDateFcn(doc)


    fileinfo=dir(doc);
    if isempty(fileinfo)
        docDateNum=[];
        docDate=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:FileNotFound'));
    else
        docDateNum=fileinfo.datenum;
        docDate=datestr(fileinfo.datenum);
    end
end
