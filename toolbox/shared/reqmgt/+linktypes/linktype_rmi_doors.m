function linktype=linktype_rmi_doors





    linktype=ReqMgr.LinkType;
    linktype.Registration=mfilename;


    linktype.Label=getString(message('Slvnv:reqmgt:linktype_rmi_doors:LinkableDomainLabel'));


    linktype.IsFile=0;
    linktype.Extensions={};


    linktype.LocDelimiters='#';
    linktype.Version='';


    linktype.NavigateFcn=@NavigateFcn;
    linktype.BrowseFcn=@DoorsBrowse;
    linktype.ContentsFcn=@ContentsFcn;
    linktype.IsValidIdFcn=@IsValidIdFcn;
    linktype.IsValidDocFcn=@IsValidDocFcn;
    linktype.IsValidDescFcn=@IsValidDescFcn;
    linktype.CreateURLFcn=@CreateURLFcn;
    linktype.UrlLabelFcn=@UrlLabelFcn;
    linktype.DocDateFcn=@DocDateFcn;
    linktype.DetailsFcn=@DetailsFcn;
    linktype.HtmlViewFcn=@HtmlViewFcn;


    linktype.GetAttributeFcn=@GetAttributeFcn;
    linktype.TextViewFcn=@TextViewFcn;
    linktype.SummaryFcn=@SummaryFcn;
    linktype.ModificationInfoFcn=@ModificationInfoFcn;
    linktype.BeforeUpdateFcn=@BeforeUpdateFcn;
    linktype.BeforeImportFcn=@BeforeImportFcn;


    linktype.SelectionLinkLabel=getString(message('Slvnv:rmisl:menus_rmi_object:LinkToSelectionInDoors'));
    linktype.SelectionLinkFcn=@SelectionLinkFcn;


    linktype.BacklinkCheckFcn=@BacklinkCheckFcn;
    linktype.BacklinkInsertFcn=@BacklinkInsertFcn;
    linktype.BacklinkDeleteFcn=@BacklinkDeleteFcn;
    linktype.BacklinksCleanupFcn=@BacklinksCleanupFcn;
end

function NavigateFcn(docInfo,locationStr)

    if isstruct(docInfo)
        moduleIdStr=docInfo.doc;
        baselineStr=docInfo.version;
    else
        moduleIdStr=docInfo;
        baselineStr='';
    end

    moduleIdStr=strtok(moduleIdStr,' ');

    if~isempty(moduleIdStr)

        if isempty(locationStr)||isempty(moduleIdStr)
            objNum=[];
        else
            objNum=rmidoors.getNumericStr(locationStr,moduleIdStr);
        end

        if isempty(baselineStr)

            rmidoors.show(moduleIdStr,objNum,false);
        else

            rmidoors.show(moduleIdStr,objNum,baselineStr);
        end
    end
end

function modIdStr=DoorsBrowse()
    modIdStr=' ';

    if~rmidoors.isAppRunning()
        return;
    end

    hDoors=rmidoors.comApp();
    [fullPath,uniqueId]=rmidoors.selectModulePath(hDoors);

    if isempty(fullPath)||isempty(uniqueId)

        return;
    end

    modIdStr=[uniqueId,' (',fullPath,')'];
end

function[labels,depths,locations]=ContentsFcn(moduleIdStr,options)

    if nargin<2
        options=struct();
    end
    if~isfield(options,'isImporting')
        isImporting=false;
    else
        isImporting=options.isImporting;
    end
    if isfield(options,'isUI')
        isUI=options.isUI;
    else
        isUI=true;
    end

    moduleIdStr=strtok(moduleIdStr,' ');
    labels={};
    depths=[];
    locations={};

    if~rmidoors.isAppRunning()
        return;
    end

    hDoors=rmidoors.comApp();

    if isUI

        rmiut.progressBarFcn('set',0.05,...
        getString(message('Slvnv:reqmgt:linktype_rmi_doors:ProcessingPleaseWait')),...
        getString(message('Slvnv:rmiut:progressBar:GettingDocInfo')));
    end


    if isImporting&&reqmgt('rmiFeature','DoorsImportOpt')
        if isfield(options,'filter')
            [allIDs,depths]=rmidoors.getIdsAndDepths(moduleIdStr,options.filter);
        else
            [allIDs,depths]=rmidoors.getIdsAndDepths(moduleIdStr,{});
        end
        allIDsString=num2str(allIDs');
    else
        allIDs=rmidoors.getModuleAttribute(moduleIdStr,'objectids');
        allIDsString=num2str(allIDs);
    end
    totalItems=length(allIDs);
    allIDsStrings=regexp(allIDsString,'(\d+)','match');
    locations=strcat('#',allIDsStrings');














    if~isImporting

        depths=zeros(1,length(allIDs));

        labels=strcat(['DOORS item ',moduleIdStr],locations);
        labels=strcat(labels,getString(message('Slvnv:reqmgt:linktype_rmi_doors:clickForInfo')));



        currentItem=1;
        chunkSize=150;
        while currentItem<totalItems
            if isUI
                rmiut.progressBarFcn('set',0.05+0.9*currentItem/totalItems,getString(message('Slvnv:reqmgt:linktype_rmi_doors:ProcessingPleaseWait')));
            end
            cmdStr=sprintf('dmiModuleContents("%s", %d, %d)',moduleIdStr,currentItem,chunkSize);
            rmidoors.invoke(hDoors,cmdStr);
            cmdResultStr=hDoors.Result;
            cmdResultStr=rmiut.filterChars(cmdResultStr,false);
            if strncmp(cmdResultStr,'DMI Error:',10)
                errordlg(cmdResultStr,getString(message('Slvnv:reqmgt:linktype_rmi_doors:CommunicationError')));
                break;
            else
                chunkContents=eval(cmdResultStr);
                chunkNumbers=chunkContents(1:2:end);
                chunkLabels=chunkContents(2:2:end);
                chunkLast=currentItem+length(chunkNumbers)-1;
                labels(currentItem:chunkLast)=chunkLabels';
                if chunkLast<currentItem+chunkSize-1&&chunkLast~=totalItems
                    warning(message('Slvnv:reqmgt:dmiModuleContents:MismatchedNumber'));
                end
            end
            if rmiut.progressBarFcn('isCanceled')
                break;
            else
                currentItem=currentItem+chunkSize;
            end
        end

    else

        if reqmgt('rmiFeature','DoorsImportOpt')

        else

            if isUI
                rmiut.progressBarFcn('set',0.9,...
                getString(message('Slvnv:slreq_import:CheckingForParents')),...
                getString(message('Slvnv:rmiut:progressBar:GettingDocInfo')));
            end
            depths=getDepths(moduleIdStr,allIDs,isUI);
        end



        labels=repmat({''},size(locations));
    end





    if isUI
        rmiut.progressBarFcn('set',0.95,...
        getString(message('Slvnv:reqmgt:linktype_rmi_doors:ProcessingPleaseWait')),...
        getString(message('Slvnv:rmiut:progressBar:GettingDocInfo')));
    end
    rmidoors.getModulePrefix([]);
    prefix=rmidoors.getModulePrefix(moduleIdStr);
    if~isempty(prefix)
        locations=strcat({['#',prefix]},allIDsStrings');
    end

    if isUI
        rmiut.progressBarFcn('delete');
    end
end

function labels=getLabels(module,ids)
    totalItems=length(ids);
    labels=cell(totalItems,1);
    for i=1:totalItems
        if mod(i,20)==0
            progressValue=double(i)/totalItems;
            rmiut.progressBarFcn('set',progressValue,getString(message('Slvnv:reqmgt:linktype_rmi_doors:ProcessingPleaseWait')));
        end
        labels{i}=rmidoors.getObjAttribute(module,ids(i),'Object Heading');
        if isempty(labels{i})
            label=rmidoors.getObjAttribute(module,ids(i),'Object Text');
            if length(label)>100
                labels{i}=[label(1:66),'...'];
            else
                labels{i}=label;
            end
        end
        if isempty(labels{i})



            labels{i}=rmidoors.getObjAttribute(module,ids(i),'labelText');
        end
    end
end

function depths=getDepths(module,ids,isUI)
    totalItems=length(ids);

    knownDepths=containers.Map('KeyType','double','ValueType','uint32');
    for i=1:totalItems

        if isUI&&mod(i,25)==0
            if rmiut.progressBarFcn('isCanceled')
                return;
            else
                rmiut.progressBarFcn('set',0.9+0.1*i/totalItems,getString(message('Slvnv:reqmgt:linktype_rmi_doors:ProcessingPleaseWait')));
            end
        end

        if~isKey(knownDepths,ids(i))
            assignDepthsForChildren(ids(i));


        end
    end

    depths=zeros(totalItems,1);
    for i=1:totalItems
        if isKey(knownDepths,ids(i))
            depths(i)=knownDepths(ids(i));
        else
            rmiut.warnNoBacktrace(sprintf('depths not known for %d',ids(i)));
            depths(i)=0;
        end
    end

    function assignDepthsForChildren(id)
        if isKey(knownDepths,id)
            childDepths=knownDepths(id)+1;
        else
            knownDepths(id)=0;
            childDepths=1;
        end
        children=rmidoors.getObjAttribute(module,id,'ChildIds');
        for j=1:length(children)
            childId=children{j};
            if numel(childId)>1

                for m=1:size(childId,1)
                    for n=1:size(childId,2)
                        knownDepths(childId(m,n))=childDepths;
                    end
                end
            else
                knownDepths(childId)=childDepths;
                assignDepthsForChildren(childId);
            end
        end
    end
end

function status=IsValidDocFcn(moduleIdStr,~)
    moduleIdStr=strtok(moduleIdStr,' ');

    if~reqmgt('findProc','doors.exe')
        error(message('Slvnv:reqmgt:linktype_rmi_doors:IsValidDocFcn'));
    end

    try
        moduleActPath=rmidoors.getModuleAttribute(moduleIdStr,'FullName');%#ok<NASGU>
        status=true;
    catch Mex %#ok<NASGU>
        status=false;
    end
end

function status=IsValidIdFcn(moduleIdStr,locationStr)
    status=true;
    moduleIdStr=strtok(moduleIdStr,' ');

    if isempty(locationStr)||isempty(moduleIdStr)
        return;
    end

    if~reqmgt('findProc','doors.exe')
        error(message('Slvnv:reqmgt:linktype_rmi_doors:IsValidIdFcn'));
    end

    objNum=rmidoors.getNumericStr(locationStr,moduleIdStr);
    str=rmidoors.getObjAttribute(moduleIdStr,objNum,'isValid?');
    switch str
    case 'true'
        status=true;
    case 'false'
        status=false;
    otherwise
        ME=MException('Slvnv:reqmgt:DoorsObjValidationFailed','DOORS returned %s',str);
        throw(ME);
    end
end

function[status,labelStr]=IsValidDescFcn(moduleIdStr,locationStr,currDesc)
    status=false;
    labelStr='';
    moduleIdStr=strtok(moduleIdStr,' ');

    if isempty(locationStr)||isempty(moduleIdStr)
        return;
    end

    if~reqmgt('findProc','doors.exe')
        error(message('Slvnv:reqmgt:linktype_rmi_doors:IsValidDescFcn'));
    end


    if~IsValidIdFcn(moduleIdStr,locationStr)
        error(message('Slvnv:reqmgt:linktype_rmi_doors:InvalidId',locationStr,moduleIdStr));
    end

    objNum=rmidoors.getNumericStr(locationStr,moduleIdStr);

    labelStr=rmidoors.customLabel(moduleIdStr,objNum);
    if isempty(labelStr)

        labelStr=rmidoors.getObjAttribute(moduleIdStr,objNum,'labelText');
    end


    labelStr=rmiut.filterChars(labelStr,false);
    currDesc=rmiut.filterChars(currDesc,false);



    status=strcmp(currDesc,labelStr);
    if status
        labelStr='';
    else
        if(length(currDesc)>2&&(strncmp(currDesc,'->',2)&&strcmp(currDesc(3:end),labelStr))||...
            (strncmp(currDesc,'<-',2)&&strcmp(currDesc(3:end),labelStr)))
            status=true;
            labelStr='';
        end
    end
end

function url=CreateURLFcn(doc,~,locationStr)
    if rmipref('ReportLinkToObjects')


        navCmd=sprintf('rmi.navigate(''linktype_rmi_doors'',''%s'',''%s'',''%s'');',...
        strtok(doc),locationStr,'');
        url=rmiut.cmdToUrl(navCmd);

    elseif rmidoors.isAppRunning('nodialog')
        if isempty(locationStr)
            url=rmidoors.getModuleAttribute(strtok(doc),'URL');
        else
            url=rmidoors.getObjAttribute(strtok(doc),locationStr,'URL');
        end
    else

        url='';
    end
end

function urlLabel=UrlLabelFcn(doc,docLabel,locationStr)
    if~isempty(docLabel)
        docString=docLabel;
    else
        if~contains(doc,' (')
            if rmidoors.isAppRunning('nodialog')
                try
                    module_name=rmidoors.getModuleAttribute(doc,'FullName');
                    docString=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DOORSModule',doc,module_name));
                catch Mex %#ok<NASGU>
                    docString=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DOORSModule',doc,'unresolved'));
                end
            else
                docString=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DOORSModule',doc,...
                getString(message('Slvnv:reqmgt:is_doors_running:DOORSUnavailable'))));
            end
        else
            docString=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DOORSModule_1',doc));
        end
    end







    if isempty(locationStr)&&doc(1)=='#'

        if rmidoors.isAppRunning('nodialog')
            try
                prefix=rmidoors.getModulePrefix(docString);
            catch
                prefix='';
            end
        else
            prefix='';
        end
        if isempty(prefix)
            urlLabel=doc;
        elseif startsWith(doc(2:end),prefix)
            urlLabel=doc(2:end);
        else
            urlLabel=[prefix,doc(2:end)];
        end
        return;
    end

    if length(locationStr)>1&&locationStr(1)=='#'
        urlLabel=sprintf('%s%s %s',...
        docString,...
        getString(message('Slvnv:RptgenRMI:ReqTable:execute:ObjectID')),...
        locationStr(2:end));
    else
        urlLabel=docString;
    end
end

function dateString=DocDateFcn(doc)
    if rmidoors.isAppRunning('nodialog')
        try
            dateString=rmidoors.getModuleAttribute(strtok(doc),'Last Modified On');
        catch Mex
            dateString=Mex.message;
        end
    else
        dateString=getString(message('Slvnv:reqmgt:is_doors_running:DOORSUnavailable'));
    end
end

function[depths,items]=DetailsFcn(document,itemId,more)

    depths=[];
    items={};
    if~rmidoors.isAppRunning('nodialog')
        warning(message('Slvnv:reqmgt:is_doors_running:DOORSIsNotRunning'));
        return;
    end
    if isempty(itemId)
        return;
    end

    [depths,items]=rmiref.DoorsUtil.getObjAttributes(document,itemId);

    if more
        [depths,items]=appendChildItems(strtok(document),itemId,depths,items);
    end
end

function[depths,items]=appendChildItems(moduleId,itemId,depths,items,parentDepth)
    if nargin<5
        parentDepth=min(depths);
    end
    childIds=rmidoors.getObjAttribute(moduleId,itemId,'childIds');
    if~isempty(childIds)
        for i=1:length(childIds)
            childId=childIds{i};
            depths(end+1)=parentDepth+1;%#ok<AGROW>
            if length(childId)>1
                items{end+1}=rmiref.DoorsUtil.doorsTableIdsToStrings(moduleId,childId);%#ok<AGROW>
            else
                items{end+1}=rmidoors.getObjAttribute(moduleId,childId,'labelText');%#ok<AGROW>
                [depths,items]=appendChildItems(moduleId,childId,depths,items,depths(end));
            end
        end
    end
end


function reqstruct=SelectionLinkFcn(objH,make2way,varargin)
    reqstruct=[];

    if rmidoors.isAppRunning()




        rmidoors.getModulePrefix([]);



        if isempty(varargin)
            [moduleIdStr,objNum,descr]=rmidoors.getCurrentObj();
        else
            moduleIdStr=varargin{1};
            objNum=varargin{2};
            descr=rmiut.filterChars(varargin{3},false);
        end

        if isempty(objNum)||(isa(objNum,'double')&&objNum<0)
            if isempty(objH)

                allIDs=rmidoors.getModuleAttribute(moduleIdStr,'objectIDs');
                objNum=allIDs(1);
            else

                warndlg(...
                getString(message('Slvnv:reqmgt:linktype_rmi_doors:NoCurrentObject_content')),...
                getString(message('Slvnv:reqmgt:linktype_rmi_doors:NoCurrentObject_title')));
                return;
            end
        end


        modulePath=rmidoors.getModuleAttribute(moduleIdStr,'fullName');
        pastPaths=rmi.settings_mgr('get','doorsSelHist');
        pastIdx=find(strcmp(pastPaths,modulePath));
        if~isempty(pastIdx)
            pastPaths(pastIdx)=[];
        end
        pastPaths=[{modulePath},pastPaths];
        rmi.settings_mgr('set','doorsSelHist',pastPaths);


        reqstruct=rmi('createempty');
        reqstruct.linked=true;
        reqstruct.doc=[moduleIdStr,' (',modulePath,')'];
        if ischar(objNum)
            reqstruct.id=['#',objNum];
        else
            reqstruct.id=['#',num2str(objNum)];
        end
        reqstruct.description=descr;
        reqstruct.reqsys='linktype_rmi_doors';
        tag=rmi.settings_mgr('get','selectTag');
        if~isempty(tag)
            reqstruct.keywords=tag;
        end

        if make2way

            srcType=rmiut.resolveType(objH);


            if strcmp(srcType,'simulink')&&~ischar(objH)
                [source,canceled]=rmi.canlink2way(objH);
                if canceled||length(source)<length(objH)
                    reqstruct=[];
                    return;
                end
            end

            if isModuleOutlined(moduleIdStr)
                warndlg(...
                getString(message('Slvnv:reqmgt:linktype_rmi_doors:CannotAddToOutline')),...
                getString(message('Slvnv:reqmgt:linktype_rmi_doors:RequirementsLinkCreationFailed')));
                return;
            end


            referencePath=rmiut.srcToPath(objH);
            if isempty(referencePath)
                errordlg(...
                getString(message('Slvnv:reqmgt:linktype_rmi_doors:ModelMustBeSaved')),...
                getString(message('Slvnv:reqmgt:linktype_rmi_doors:RequirementsLinkCreationFailed')));
                reqstruct=[];
                return;
            end


            [navcmd,dispstr,iconPath]=rmiut.targetInfo(objH,srcType);
            switch srcType
            case 'simulink'
                labelStr=['[Simulink reference: ',dispstr,']'];
            case 'matlab'
                if rmisl.isSidString(strtok(objH,'|'))
                    labelStr=['[Simulink reference: ',dispstr,']'];
                else
                    labelStr=['[MATLAB reference: ',dispstr,']'];
                end
            case 'testmgr'
                labelStr=['[Test case: ',dispstr,']'];
            case 'data'
                labelStr=['[Data Dictionary reference: ',dispstr,']'];
            otherwise

            end

            if rmi.settings_mgr('get','linkSettings','useActiveX')

                if isempty(iconPath)
                    iconPath=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','slicon.bmp');
                end
            else

                iconPath='';
            end

            bareObjNum=rmidoors.getNumericStr(objNum,moduleIdStr);
            rmidoors.addLinkObj(moduleIdStr,bareObjNum,iconPath,labelStr,navcmd);
        end
    end
end

function out=isModuleOutlined(moduleIdStr)
    hDoors=rmidoors.comApp();
    cmdStr=['dmiUtilIsModuleOutlined_("',moduleIdStr,'")'];
    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;
    if strncmp(commandResult,'DMI Error:',10)
        error(message('Slvnv:reqmgt:DoorsApiError',commandResult));
    else
        out=eval(commandResult);
    end
end

function html=HtmlViewFcn(doc,id,includeAttributes)
    if nargin<3
        includeAttributes=true;
    end
    if isempty(id)
        html='';
        return;
    end
    if rmidoors.isAppRunning('nodialog')
        moduleId=strtok(doc);
        try
            if~includeAttributes




                html=rmidoors.getObjAttribute(moduleId,id,'textAsHtml');

                pictureHtml=rmiref.DoorsUtil.pictureObjToHtml(moduleId,id);
                if~isempty(pictureHtml)
                    html=[html,newline,pictureHtml];
                end



                if rmi.settings_mgr('get','doorsSettings','externalLinksHtml')
                    linksHtml=rmidoors.externalLinksToHtml(moduleId,id);
                    if~isempty(linksHtml)
                        html=[html,newline,linksHtml];
                    end
                end
            else





                html=rmiref.DoorsUtil.itemToHtml(moduleId,id,includeAttributes);
            end
        catch ex
            html=['<font color="red">',ex.identifier,'<br/>',ex.message,'</font>'];
        end
    else

        messageStr1=getString(message('Slvnv:rmiref:DocCheckDoors:DoorsNotRunning'));
        messageStr2=getString(message('Slvnv:rmiref:DocCheckDoors:PleaseRetryAfterStartingDoors'));
        html=['<font color="red">',messageStr1,'<br/>',messageStr2,'</font>'];
    end
end

function value=GetAttributeFcn(moduleId,itemId,attributeName)
    value=rmidoors.getObjAttribute(moduleId,itemId,attributeName);
end

function text=TextViewFcn(moduleId,itemId)
    text=rmidoors.getObjAttribute(moduleId,itemId,'Object Text');
end

function summary=SummaryFcn(moduleId,itemId)
    summary=rmidoors.getObjAttribute(moduleId,itemId,'Object Heading');
end

function modificationInfo=ModificationInfoFcn(moduleId,itemId)



    modificationInfo=rmidoors.getModificationInfo(moduleId,itemId);
end

function[tf,linkTargetInfo]=BacklinkCheckFcn(mwSourceArtifact,mwItemId,reqDoc,reqId)
    moduleId=strtok(reqDoc);
    [tf,linkTargetInfo]=rmidoors.checkIncomingLink(mwSourceArtifact,mwItemId,moduleId,reqId);
end

function[navcmd,dispstr]=BacklinkInsertFcn(reqDoc,reqId,mwSourceArtifact,mwItemId,mwDomain)
    doorsModuleId=strtok(reqDoc);
    bareObjNum=rmidoors.getNumericStr(reqId,doorsModuleId);
    if isnumeric(mwSourceArtifact)


        [navcmd,dispstr]=rmi.objinfo(mwSourceArtifact);
        labelStr=['[Simulink reference: ',dispstr,']'];
    else
        isTextRange=[];
        if nargin==3
            if isa(mwSourceArtifact,'slreq.data.SourceItem')

                mwDomain=mwSourceArtifact.domain;
                [mwSourceArtifact,mwItemId]=slreq.utils.getExternalLinkArgs(mwSourceArtifact);
                isTextRange=mwSourceArtifact.isTextRange();
            elseif ischar(mwSourceArtifact)


                [mwSourceArtifact,mwItemId]=slreq.utils.getExternalLinkArgs(mwSourceArtifact);




                mwDomain=slreq.utils.getDomainLabel(mwSourceArtifact);
            else

                error('unsupported usage of BacklinkInsertFcn() with 3rd arg of type %s',class(mwSourceArtifact));
            end
        else




            if nargin<5
                isTextRange=rmisl.isSidString(mwSourceArtifact);
                mwDomain=slreq.backlinks.getSrcDomainLabel(mwSourceArtifact);
            end
        end


        try
            [navcmd,dispstr]=slreq.backlinks.getBacklinkAttributes(mwSourceArtifact,mwItemId,mwDomain,isTextRange);
        catch Mex
            throwAsCaller(Mex);
        end

        if strcmp(mwDomain,'linktype_rmi_matlab')
            labelStr=['[MATLAB reference: ',dispstr,']'];
        else
            labelStr=['[Simulink reference: ',dispstr,']'];



        end
    end
    if~isempty(navcmd)
        rmidoors.addLinkObj(doorsModuleId,bareObjNum,'',labelStr,navcmd);
    end
end

function success=BacklinkDeleteFcn(reqDoc,reqId,mwSourceArtifact,mwItemId)
    if nargin<4

        [mwSourceArtifact,mwItemId]=slreq.utils.getExternalLinkArgs(mwSourceArtifact);
    end

    if rmidoors.checkIncomingLink(mwSourceArtifact,mwItemId,reqDoc,reqId)

        doorsModuleId=strtok(reqDoc);
        bareObjNum=rmidoors.getNumericStr(reqId,doorsModuleId);
        rmidoors.removeLink(doorsModuleId,bareObjNum,mwSourceArtifact,mwItemId);
        success=true;
    else
        success=false;
    end
end

function[countRemoved,countChecked]=BacklinksCleanupFcn(reqDoc,mwSourceArtifact,linksData,doSaveBeforeCleanup)
    moduleId=strtok(reqDoc);
    checker=slreq.backlinks.DoorsModuleChecker(moduleId);
    if nargin>3&&doSaveBeforeCleanup
        checker.initialize();
    end
    checker.registerMwLinks(mwSourceArtifact,linksData);
    [countUnmatched,countChecked]=checker.countUnmatchedLinks();
    if countUnmatched>0&&...
        slreq.backlinks.confirmCleanup(reqDoc,slreq.uri.getShortNameExt(mwSourceArtifact),countUnmatched)
        countRemoved=checker.deleteUnmatchedLinks();
        if countRemoved~=countUnmatched
            rmiut.warnNoBacktrace('Slvnv:slreq_backlinks:SomethingWentWrong',num2str(countUnmatched-countRemoved));
        end
    else
        countRemoved=0;
    end
end

function callerObj=BeforeUpdateFcn(callerObj)
    importOptions=callerObj.importOptions;


    if~isfield(importOptions,'filterString')||isempty(importOptions.filterString)
        return;
    end

    moduleId=strtok(importOptions.DocID);
    filterInDoors=rmidoors.getModuleAttribute(moduleId,'rowFilter');
    if strcmp(filterInDoors,importOptions.filterString)
        return;
    end
    response=questdlg({getString(message('Slvnv:reqmgt:linktype_rmi_doors:MismatchedFilterMessage')),...
    ['* ',getString(message('Slvnv:reqmgt:linktype_rmi_doors:MismatchedFilterStored',importOptions.filterString))],...
    ['* ',getString(message('Slvnv:reqmgt:linktype_rmi_doors:MismatchedFilterApplied',filterInDoors))],...
    getString(message('Slvnv:reqmgt:linktype_rmi_doors:MismatchedFilterChoice'))},...
    getString(message('Slvnv:reqmgt:linktype_rmi_doors:MismatchedFilterTitle')),...
    getString(message('Slvnv:reqmgt:linktype_rmi_doors:ApplyStoredFilterBtn')),...
    getString(message('Slvnv:reqmgt:linktype_rmi_doors:UpdateStoredFilterBtn')),...
    getString(message('Slvnv:slreq:Cancel')),getString(message('Slvnv:reqmgt:linktype_rmi_doors:ApplyStoredFilterBtn')));
    if isempty(response)||strcmp(response,getString(message('Slvnv:slreq:Cancel')))
        throwAsCaller(MException(message('Slvnv:rmiref:docCheckCallback:checkerCanceled')));
    elseif strcmp(response,getString(message('Slvnv:reqmgt:linktype_rmi_doors:ApplyStoredFilterBtn')))


        rmidoors.setRowFilter(moduleId,importOptions.filterString);
    elseif strcmp(response,getString(message('Slvnv:reqmgt:linktype_rmi_doors:UpdateStoredFilterBtn')))


        callerObj.importOptions.filterString=filterInDoors;
        callerObj.hasChanges=true;
    else

        error('invalid case in linktype_rmi_doors:BeforeUpdateFcn()');
    end
end

function BeforeImportFcn(callerObj)
    options=callerObj.importOptions;

    if isfield(options,'filterString')&&~isempty(options.filterString)
        moduleId=strtok(options.DocID);
        filterInDoors=rmidoors.getModuleAttribute(moduleId,'rowFilter');
        if~strcmp(filterInDoors,options.filterString)
            rmidoors.setRowFilter(moduleId,options.filterString);
        end
    end
end
