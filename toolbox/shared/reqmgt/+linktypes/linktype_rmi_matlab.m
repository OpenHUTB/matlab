function linkType=linktype_rmi_matlab




    linkType=ReqMgr.LinkType;
    linkType.Registration=mfilename;


    linkType.Label=getString(message('Slvnv:rmiml:LinkableDomainLabel'));


    linkType.IsFile=0;
    linkType.Extensions={'.m'};


    linkType.LocDelimiters='@?';
    linkType.Version='';


    linkType.NavigateFcn=@NavigateFcn;
    linkType.SelectionLinkFcn=@SelectionLinkFcn;
    linkType.ResolveDocFcn=@ResolveDocFcn;
    linkType.CreateURLFcn=@CreateURLFcn;
    linkType.DocDateFcn=@DocDateFcn;
    linkType.BrowseFcn=@BrowseToMFile;
    linkType.ContentsFcn=@ContentsFcn;
    linkType.IsValidDocFcn=@IsValidDocFcn;
    linkType.IsValidIdFcn=@IsValidIdFcn;
    linkType.IsValidDescFcn=@IsValidDescFcn;
    linkType.ItemIdFcn=@ItemIdFcn;

    linkType.SelectionLinkLabel=getString(message('Slvnv:rmiml:LinkToCurrent'));
end

function NavigateFcn(mfile,locationStr)
    if length(locationStr)>1
        if locationStr(1)=='@'
            locationStr=locationStr(2:end);
        elseif locationStr(1)=='?'
            rmiml.findInFile(mfile,locationStr(2:end),true);
            return;
        end
    end
    rmicodenavigate(mfile,locationStr);
end

function req=SelectionLinkFcn(objH,make2way)
    req=[];

    try
        [targetFile,targetRange,selectedText]=rmiml.getSelection();
    catch ex %#ok<NASGU>

        errordlg(...
        getString(message('Slvnv:rmiml:NoFileIsOpen')),...
        getString(message('Slvnv:rmiml:RequirementsUseCurrent')));
        return;
    end
    if isempty(targetFile)
        errordlg(...
        getString(message('Slvnv:rmiml:NoFileIsOpen')),...
        getString(message('Slvnv:rmiml:RequirementsUseCurrent')));
    elseif targetRange(1)==targetRange(2)
        if length(targetFile)>50
            targetFile=['...',targetFile(end-50:end)];
        end
        errordlg(...
        getString(message('Slvnv:rmiml:NothingSelected',targetFile)),...
        getString(message('Slvnv:rmiml:RequirementsUseCurrent')));
    else

        if~rmiml.canLink(targetFile,true)
            return;
        end

        srcType=rmiut.resolveType(objH);


        if strcmp(srcType,'matlab')
            [isSame,srcFile,srcId]=isSameLocation(objH,targetFile,targetRange);
            if isSame
                conflictRangeTitle=getString(message('Slvnv:rmiml:RequirementsUseCurrent'));
                conflictRangeMsg=getString(message('Slvnv:rmiml:RequirementsUseCurrentConflict'));
                errordlg(conflictRangeMsg,conflictRangeTitle,'modal');
                return;
            end
        end


        if make2way&&~slreq.internal.isSlreqItem(objH)
            if strcmp(srcType,'matlab')

                retLink=rmiml.makeReq(srcFile,srcId);
            else
                retLink=rmi.makeReq(objH,targetFile,srcType);
            end
            if isempty(retLink)

                req=[];
                return;
            else
                if rmisl.isSidString(targetFile)&&rmisl.isComponentHarness(strtok(targetFile,':'))


                    rmiTarget=rmiml.harnessToModelRemap(targetFile);
                else
                    rmiTarget=targetFile;
                end
                rmiml.catReqs(retLink,rmiTarget,targetRange);
            end
        end


        req=rmiml.makeReq(targetFile,targetRange,selectedText);


        collapseRight=[targetRange(2),targetRange(2)];
        rmiut.RangeUtils.setSelection(targetFile,collapseRight);
    end

end


function[result,srcFile,srcId]=isSameLocation(source,targetFile,targetRange)
    [srcFile,remainder]=strtok(source,'|');
    if isempty(remainder)
        srcId='';
    else
        srcId=remainder(2:end);
    end
    if strcmp(srcFile,targetFile)


        if isempty(srcId)
            srcRange=targetRange;
        elseif any(srcId=='.')
            srcRange=slreq.idToRange(srcFile,srcId);
        else
            srcRange=sscanf(srcId,'%d-%d');
        end
        if srcRange(1)>targetRange(2)||srcRange(2)<targetRange(1)
            result=false;
        else
            result=true;
        end
    else
        result=false;
    end
end

function result=BrowseToMFile()
    extensions='*.m;';
    [fileName,pathName]=uigetfile(...
    {extensions,['MATLAB File (',extensions,')'];...
    '*.*','All Files (*.*)'},...
    getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectTargetMATLABFile')));

    if isempty(fileName)||~ischar(fileName)
        result='';
        return;
    else
        result=fullfile(pathName,fileName);

        edit(result);

        if ispc
            returnFocus(getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor','')));
        end
    end
end

function[labels,depths,locations]=ContentsFcn(mFileName)





    allData=mleditor.getAll(mFileName);
    totalBookmarks=size(allData,1);
    labels=cell(totalBookmarks,1);
    depths=ones(totalBookmarks,1);
    locations=cell(totalBookmarks,1);
    for i=1:totalBookmarks
        item=allData(i,:);
        locations{i}=item{1};
        label=rmiml.getText(mFileName,locations{i});
        if isempty(label)||strcmp(label,char(com.mathworks.toolbox.simulink.slvnv.RmiUtils.NO_LINKS_TAG))

            label=strrep(item{4},newline,', ');
        end
        if isempty(label)
            labels{i}=[locations{i},' <',getString(message('Slvnv:rmiml:NoLinksLabel')),'>'];
        elseif length(label)>40
            labels{i}=label(1:40);
        else
            labels{i}=label;
        end
    end


    fullText=rmiml.getText(mFileName);
    fTokens=regexp(fullText,'( *function [^\n]+)','tokens');
    totalFunctions=length(fTokens);
    if totalFunctions>1
        moreLabels=cell(totalFunctions,1);
        moreDepths=zeros(totalFunctions,1);
        moreLocations=cell(totalFunctions,1);
        for i=1:totalFunctions
            moreLabels{i}=strtrim(fTokens{i}{1});
            offset=strfind(fTokens{i}{1},'function ');
            moreDepths(i)=ceil(offset/4);
            location=strfind(fullText,moreLabels{i});
            moreLocations{i}=sprintf('%d-%d',location,location+length(moreLabels{i}));
        end
        labels=[...
        ['============= ',getString(message('Slvnv:rmiml:StoredNamedRanges')),'================='];...
        labels;...
        ['============= ',getString(message('Slvnv:rmiml:Functions')),'====================='];...
        moreLabels];
        depths=[0;depths;0;moreDepths];
        locations=[{''};locations;{''};moreLocations];
    end


    if ispc
        returnFocus(getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor','')));
    end
end

function returnFocus(windowTitlePrefix)
    pause(0.5);
    reqmgt('winFocus',['^',windowTitlePrefix]);
end

function[docPath,isRel]=ResolveDocFcn(doc,ref)


    docPath=rmiml.resolveDoc(doc,ref);
    if strcmp(docPath,doc)
        isRel=false;
    else
        isRel=true;
    end
end

function url=CreateURLFcn(docPath,refPath,locationStr)
    doc=rmiml.resolveDoc(docPath,refPath);
    command=sprintf('rmicodenavigate(''%s'',''%s'');',doc,locationStr);
    url=['matlab:',command];
end

function dateString=DocDateFcn(doc)

    [isSid,mdlName]=rmisl.isSidString(doc,false);
    if isSid
        try
            docPath=get_param(mdlName,'FileName');
        catch ex %#ok<NASGU> otherwise rely on which() and dir()
            docPath=which(mdlName);
        end
    else

        docPath=rmiml.resolveDoc(doc,pwd);
    end
    fileinfo=dir(docPath);
    if~isempty(fileinfo)
        dateString=fileinfo.date;
    else
        dateString='';
    end
end

function success=IsValidDocFcn(doc,ref)
    [docPath,isSid]=rmiml.resolveDoc(doc,ref);
    if isSid
        try
            blkH=Simulink.ID.getHandle(docPath);
            success=~isempty(blkH);
        catch ex %#ok<NASGU>

            mdlName=strtok(docPath,':');
            if exist(mdlName,'file')==4
                load_system(mdlName);
                try
                    blkH=Simulink.ID.getHandle(docPath);
                    success=~isempty(blkH);
                catch ex %#ok<NASGU>
                    success=false;
                end
            else
                success=false;
            end
        end
    else

        success=~isempty(docPath)&&exist(docPath,'file')==2;
    end
end

function success=IsValidIdFcn(doc,locationStr)
    if locationStr(1)=='@'
        locationStr(1)=[];
    elseif locationStr(1)=='?'
        success=rmiml.findInFile(doc,locationStr(2:end),false);
        return;
    end
    rmiData=slreq.utils.getRangesAndLabels(doc);
    success=~isempty(rmiData)&&any(strcmp(rmiData(:,1),locationStr));
end

function[success,docDescr]=IsValidDescFcn(doc,id,description)
    if id(1)=='@'
        id(1)=[];
    else

        success=true;
        docDescr='';
        return;
    end
    rmiData=slreq.utils.getRangesAndLabels(doc);
    if isempty(rmiData)
        error(message('Slvnv:reqmgt:linktype_rmi_doors:InvalidId',id,doc));
    end
    text=rmiml.getText(doc,id);
    text=rmiut.filterChars(text,false);
    dots=strfind(description,'...');
    if isempty(dots)
        compareLength=length(description);
    else
        compareLength=dots(1)-1;
    end
    if contains(text,description(1:compareLength))
        success=true;
        docDescr='';
    else
        success=false;
        docDescr=text;
    end
end

function out=ItemIdFcn(host,in,mode)



    out=in;

    if isempty(host)
        return;
    end

    if isempty(strtok(in))

        return;

    elseif in(1)=='?'

        return;

    elseif in(1)=='@'
        in=in(2:end);
    end

    mPath=rmiml.resolveDoc(host,pwd);
    if isempty(mPath)
        return;
    end

    if mode
        if~isempty(regexp(in,'^\d+\.\d+','once'))
            id=strtok(in);
        else
            [~,id]=rmiml.ensureBookmark(mPath,in);
        end
        out=['@',id];
    else
        if~isempty(regexp(in,'^\d[\d\.]+\d$','once'))
            if rmiut.RangeUtils.isOpenInEditor(mPath)
                range=slreq.idToRange(mPath,in);
                if isempty(range)
                    warning('linktype_rmi_matlab: failed to resolve %s in %s',in,host);
                    out=in;
                else
                    out=sprintf('%s (%d-%d)',in,range(1),range(2));
                end
            else


                return;
            end
        else
            out=in;
        end
        out=['@',out];
    end
end

