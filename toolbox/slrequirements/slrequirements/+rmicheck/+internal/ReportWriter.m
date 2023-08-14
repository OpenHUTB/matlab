classdef ReportWriter<handle





    properties(Access=private)
srcDomain
srcName
destFile
rptTitle
itemTitle
checker
itemDispFcn
showInBrwsr
    end

    methods
        function this=ReportWriter(srcArtifactDomain,pathToSourceFile,reportSpec)
            this.srcDomain=srcArtifactDomain;
            this.srcName=pathToSourceFile;
            this.destFile=reportSpec.filepath;
            if rmisl.isSidString(pathToSourceFile)
                try
                    mlbH=Simulink.ID.getHandle(pathToSourceFile);
                    shortName=getfullname(mlbH);
                catch
                    shortName=pathToSourceFile;
                end
            else
                shortName=slreq.uri.getShortNameExt(pathToSourceFile);
            end
            this.rptTitle=getString(message(reportSpec.titleTemplateId,rmicheck.internal.ReportWriter.htmlTT(shortName)));
            this.itemTitle=getString(message(reportSpec.srcItemHeaderId));
            this.checker=reportSpec.checker;
            this.itemDispFcn=reportSpec.srcItemFormatter;
            this.showInBrwsr=reportSpec.doShow;
        end

    end

    methods

        function writeResultsToFile(this,check,faultCounters,stats)

            this.ensureDir(fileparts(this.destFile));
            fid=fopen(this.destFile,'w+');


            isAllInOne=strcmp(check,'all');
            rmicheck.internal.ReportWriter.htmlStart(fid,this.rptTitle,isAllInOne);

            if isAllInOne
                this.writeSummary(fid,faultCounters,stats);
            end


            if any(strcmp(check,{'doc','all'}))
                this.writeResultsDoc(fid,faultCounters,isAllInOne);
            end
            if any(strcmp(check,{'id','all'}))
                this.writeResultsId(fid,faultCounters,isAllInOne);
            end
            if any(strcmp(check,{'label','all'}))
                this.writeResultsLabel(fid,faultCounters,isAllInOne);
            end
            if any(strcmp(check,{'path','all'}))
                this.writeResultsPath(fid,faultCounters,isAllInOne);
            end
            if any(strcmp(check,{'doors','all'}))
                if is_doors_installed()&&rmidoors.isAppRunning('nodialog')
                    this.writeResultsDoors(fid,faultCounters,isAllInOne);
                end
            end

            rmicheck.internal.ReportWriter.htmlEnd(fid);
            fclose(fid);

            if this.showInBrwsr
                if exist(this.destFile,'file')==2
                    web(this.destFile);
                else
                    error(message('Slvnv:slreq_import:FileNotFound',this.destFile));
                end
            end
        end

    end

    methods(Access=private)

        function ensureDir(~,dirPath)
            if exist(dirPath,'dir')==7
                return;
            end
            if dirPath(end)~='/'
                dirPath(end+1)='/';
            end
            separators=strfind(dirPath,'/');
            if separators(1)==1
                start=2;
            elseif dirPath(2)==':'
                start=2;
            else
                start=1;
            end
            for i=start:length(separators)
                subdir=dirPath(1:separators(i)-1);
                if exist(subdir,'dir')~=7
                    mkdir(subdir);
                end
            end
        end

        function writeSummary(this,fid,faultCounters,stats)
            rerunCmd=['matlab:rmi(''check'',''',this.srcName,''');'];
            rerunShortcut=['&nbsp;&nbsp;[ ',rmicheck.internal.ReportWriter.htmlLink(rerunCmd,getString(message('Slvnv:consistency:RptRerun'))),' ]'];
            fprintf(fid,'%s %s <br/>\n',rmicheck.internal.ReportWriter.htmlItalic(getString(message('Slvnv:consistency:RptGeneratedOn',datestr(now)))),rerunShortcut);
            if ispc
                currentUser=getenv('USERNAME');
            else
                currentUser=getenv('USER');
            end
            fprintf(fid,'%s <br/>\n',rmicheck.internal.ReportWriter.htmlItalic(getString(message('Slvnv:consistency:RptGeneratedBy',currentUser))));
            rStatus=rmiml.getStatus(this.srcName);
            if any(rStatus=='.')
                rmicheck.internal.ReportWriter.htmlFontColorStart(fid,'#cc5500');
                fprintf(fid,[getString(message('Slvnv:consistency:RptHasUnsavedChanges')),'<br/>']);
                rmicheck.internal.ReportWriter.htmlFontColorEnd(fid);
            end
            fprintf(fid,'<blockquote>\n');
            rmicheck.internal.ReportWriter.htmlTableStart(fid);
            rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptSrcLocation')),this.srcName);
            fData=dir(this.srcName);
            rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptSrcLastSaved')),fData.date);
            rData=dir(rmimap.StorageMapper.getInstance.getStorageFor(this.srcName));
            rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptReqLastSaved')),rData.date);
            rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptTotalItems')),num2str(stats(1)));
            if stats(2)==stats(3)
                rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptTotalLinks')),num2str(stats(2)));
            else
                countersString=getString(message('Slvnv:consistency:RptTotalFiltered',num2str(stats(3)),num2str(stats(2))));
                rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptTotalLinks')),countersString);
            end
            link=this.linkedCount(faultCounters.docCount,'doc');
            rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptMissingDoc')),link);
            link=this.linkedCount(faultCounters.idCount,'id');
            rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptMissingId')),link);
            link=this.linkedCount(faultCounters.labelCount,'label');
            rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptMismatchedLabel')),link);
            link=this.linkedCount(faultCounters.pathCount,'path');
            rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptMismatchedPath')),link);
            if faultCounters.doorsCount>0
                link=this.linkedCount(faultCounters.doorsCount,'doors');
                rmicheck.internal.ReportWriter.htmlTableRow(fid,getString(message('Slvnv:consistency:RptMissingDoorsLink')),link);
            end
            rmicheck.internal.ReportWriter.htmlTableEnd(fid);
            fprintf(fid,'</blockquote>\n');
        end

        function link=linkedCount(~,count,anchor)
            if count==0
                link=getString(message('Slvnv:consistency:RptNoIssues'));
            elseif count==1
                label=getString(message('Slvnv:consistency:RptOneIssue'));
                url=['#',anchor];
                link=rmicheck.internal.ReportWriter.htmlLink(url,label);
            else
                label=getString(message('Slvnv:consistency:RptCountIssues',num2str(count)));
                url=['#',anchor];
                link=rmicheck.internal.ReportWriter.htmlLink(url,label);
            end
        end

        function result=getShortName(this)
            if rmisl.isSidString(this.srcName)
                obj=Simulink.ID.getHandle(this.srcName);
                if~isa(obj,'double')

                    result=[obj.Path,'/',obj.Name];
                else
                    result=getfullname(obj);
                end
            else
                [~,name,ext]=fileparts(this.srcName);
                result=[name,ext];
            end
        end

        function writeResultsDoc(this,fid,counts,isAllInOne)
            if isAllInOne
                rmicheck.internal.ReportWriter.htmlSeparator(fid,'doc');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptCheckDoc')),2);
            end

            myResults=this.checker.getResults('doc');
            docs=unique(myResults(:,4));
            for i=1:length(docs)
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:DocNotFound',...
                rmicheck.internal.ReportWriter.htmlTT(docs{i}))));
                rmicheck.internal.ReportWriter.htmlTableStart(fid,...
                this.itemTitle,...
                getString(message('Slvnv:consistency:Requirement')),'');
                docMatch=strcmp(myResults(:,4),docs{i});
                subSet=myResults(docMatch,[1,2,3,5]);


                [ids,idx]=unique(subSet(:,1));
                for j=1:length(ids)
                    id=ids{j};
                    linesString=this.itemDispFcn(subSet{idx(j),2});
                    selectionCmd=['rmi.navigate(''',this.srcDomain,''',''',this.srcName,''',''',id,''');'];
                    mcodeLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',selectionCmd],linesString);


                    idMatch=strcmp(subSet(:,1),id);
                    subSubSet=subSet(idMatch,3:4);
                    linkLinks='';
                    fixLinks='';
                    for k=1:size(subSubSet,1)
                        linkNo=subSubSet{k,1};

                        description=subSubSet{k,2};
                        editCmd=['slreq.internal.editLinksFrom(''',this.srcDomain,''',''',this.srcName,''',''',id,''',',num2str(linkNo),');'];
                        dialogLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',editCmd],description);
                        linkLinks=[linkLinks,'<br/>',dialogLink];%#ok<AGROW>

                        fixCmd=rmicheck.internal.ReportWriter.makeSetPropCommand('doc',this.srcDomain,this.srcName,id,linkNo);
                        fixLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',fixCmd],getString(message('Slvnv:consistency:fix')));
                        fixLinks=[fixLinks,'<br/>',fixLink];%#ok<AGROW>
                    end
                    trimFront=length('<br/>')+1;
                    rmicheck.internal.ReportWriter.htmlTableRow(fid,mcodeLink,linkLinks(trimFront:end),fixLinks(trimFront:end));
                end
                if size(subSet,1)>1

                    allIds=subSet(:,1);
                    allLinkNo=cell2mat(subSet(:,3));
                    fixAllCmd=rmicheck.internal.ReportWriter.makeSetPropCommand('doc',this.srcDomain,this.srcName,allIds',allLinkNo');
                    fixAllLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',fixAllCmd],getString(message('Slvnv:consistency:fixAll')));
                    rmicheck.internal.ReportWriter.htmlTableRow(fid,'&nbsp;','&nbsp;',fixAllLink);
                end
                rmicheck.internal.ReportWriter.htmlTableEnd(fid);
            end
            hasErrors=rmicheck.internal.ReportWriter.appendErrorInfoIfAny(fid,'doc',counts);
            if isAllInOne&&~hasErrors&&isempty(docs)
                rmicheck.internal.ReportWriter.htmlFontColorStart(fid,'#55cc00');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptNoIssues')));
                rmicheck.internal.ReportWriter.htmlFontColorEnd(fid);
            end
        end

        function writeResultsId(this,fid,counts,isAllInOne)
            if isAllInOne
                rmicheck.internal.ReportWriter.htmlSeparator(fid,'id');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptCheckId')),2);
            end
            myResults=this.checker.getResults('id');
            docs=unique(myResults(:,4));
            for i=1:length(docs)
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:IdNotFound',rmicheck.internal.ReportWriter.htmlTT(docs{i}))));
                rmicheck.internal.ReportWriter.htmlTableStart(fid,...
                this.itemTitle,...
                getString(message('Slvnv:consistency:Requirement')));
                docMatch=strcmp(myResults(:,4),docs{i});
                subSet=myResults(docMatch,[1,2,3,5,6]);

                [ids,idx]=unique(subSet(:,1));
                for j=1:length(ids)
                    id=ids{j};
                    linesString=this.itemDispFcn(subSet{idx(j),2});
                    selectionCmd=['rmi.navigate(''',this.srcDomain,''',''',this.srcName,''',''',id,''');'];
                    mcodeLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',selectionCmd],linesString);

                    idMatch=strcmp(subSet(:,1),id);
                    subSubSet=subSet(idMatch,3:5);
                    dlgLinks='';
                    for k=1:size(subSubSet,1)
                        linkNo=subSubSet{k,1};
                        description=subSubSet{k,2};
                        wrongId=subSubSet{k,3};
                        editCmd=['slreq.internal.editLinksFrom(''',this.srcDomain,''',''',this.srcName,''',''',id,''',',num2str(linkNo),');'];
                        dlgLink=[rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',editCmd],description),' (',wrongId,')'];
                        dlgLinks=[dlgLinks,'<br/>',dlgLink];%#ok<AGROW>
                    end
                    trimFront=length('<br/>')+1;
                    rmicheck.internal.ReportWriter.htmlTableRow(fid,mcodeLink,dlgLinks(trimFront:end));
                end
                rmicheck.internal.ReportWriter.htmlTableEnd(fid);
            end
            hasErrors=rmicheck.internal.ReportWriter.appendErrorInfoIfAny(fid,'id',counts);
            if isAllInOne&&~hasErrors&&isempty(docs)
                rmicheck.internal.ReportWriter.htmlFontColorStart(fid,'#55cc00');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptNoIssues')));
                rmicheck.internal.ReportWriter.htmlFontColorEnd(fid);
            end
        end

        function writeResultsLabel(this,fid,counts,isAllInOne)
            if isAllInOne
                rmicheck.internal.ReportWriter.htmlSeparator(fid,'label');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptCheckLabel')),2);
            end
            myResults=this.checker.getResults('label');
            if~isempty(myResults)


                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:LabelNoMatch')));
                rmicheck.internal.ReportWriter.htmlTableStart(fid,this.itemTitle,...
                getString(message('Slvnv:consistency:currentDescription')),...
                getString(message('Slvnv:consistency:externalDescription')),'&nbsp;');


                linkedItemInfo=myResults(:,2);
                sortByStrings=cell(size(linkedItemInfo));
                for i=1:length(linkedItemInfo)
                    sortByStrings{i}=this.itemDispFcn(linkedItemInfo{i});
                end
                [uniqueItems,idx,map]=unique(sortByStrings);
                for i=1:length(uniqueItems)
                    myId=myResults{idx(i),1};
                    linesString=sortByStrings{idx(i)};
                    selectionCmd=['rmi.navigate(''',this.srcDomain,''',''',this.srcName,''',''',myId,''');'];
                    mcodeLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',selectionCmd],linesString);

                    subSet=myResults(map==i,:);
                    dlgLinks='';
                    docLinks='';
                    updateLinks='';
                    for j=1:size(subSet,1)
                        myReqNo=subSet{j,3};

                        origDescription=subSet{j,5};
                        editCmd=['slreq.internal.editLinksFrom(''',this.srcDomain,''',''',this.srcName,''',''',myId,''',',num2str(myReqNo),');'];
                        dlgLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',editCmd],origDescription);
                        dlgLinks=[dlgLinks,'<br/>',dlgLink];%#ok<AGROW>

                        currentDescription=subSet{j,6};
                        navCmd=['slreq.internal.navigateLinkFrom(''',this.srcDomain,''',''',this.srcName,''',''',myId,''',',num2str(myReqNo),');'];
                        docLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',navCmd],currentDescription);
                        docLinks=[docLinks,'<br/>',docLink];%#ok<AGROW>

                        updateCmd=rmicheck.internal.ReportWriter.makeSetPropCommand('description',this.srcDomain,this.srcName,myId,myReqNo,currentDescription);
                        updateLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',updateCmd],getString(message('Slvnv:consistency:update')));
                        updateLinks=[updateLinks,'<br/>',updateLink];%#ok<AGROW>
                    end
                    trimFront=length('<br/>')+1;
                    rmicheck.internal.ReportWriter.htmlTableRow(fid,mcodeLink,dlgLinks(trimFront:end),docLinks(trimFront:end),updateLinks(trimFront:end));
                end
                rmicheck.internal.ReportWriter.htmlTableEnd(fid);
            end
            hasErrors=rmicheck.internal.ReportWriter.appendErrorInfoIfAny(fid,'label',counts);
            if isAllInOne&&~hasErrors&&isempty(myResults)
                rmicheck.internal.ReportWriter.htmlFontColorStart(fid,'#55cc00');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptNoIssues')));
                rmicheck.internal.ReportWriter.htmlFontColorEnd(fid);
            end
        end

        function writeResultsPath(this,fid,counts,isAllInOne)
            if isAllInOne
                rmicheck.internal.ReportWriter.htmlSeparator(fid,'path');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptCheckPath')),2);
            end

            myResults=this.checker.getResults('path');
            docs=unique(myResults(:,4));
            for i=1:length(docs)
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:PathInconsistent',rmicheck.internal.ReportWriter.htmlTT(docs{i}))));
                docMatch=strcmp(myResults(:,4),docs{i});
                subSet=myResults(docMatch,[1,2,3,5,6]);
                rmicheck.internal.ReportWriter.htmlBlock(fid,[rmicheck.internal.ReportWriter.htmlBoldPrefix([getString(message('Slvnv:consistency:currentPath')),':'],2),rmicheck.internal.ReportWriter.htmlTT(docs{i})]);
                betterPath=subSet{end,end};
                rmicheck.internal.ReportWriter.htmlBlock(fid,[rmicheck.internal.ReportWriter.htmlBoldPrefix([getString(message('Slvnv:consistency:validPath')),':'],6),rmicheck.internal.ReportWriter.htmlTT(betterPath)]);
                rmicheck.internal.ReportWriter.htmlTableStart(fid,...
                this.itemTitle,...
                getString(message('Slvnv:consistency:Requirement')),'&nbsp;');

                [ids,idx]=unique(subSet(:,1));
                for j=1:length(ids)
                    id=ids{j};
                    linesString=this.itemDispFcn(subSet{idx(j),2});
                    selectionCmd=['rmi.navigate(''',this.srcDomain,''',''',this.srcName,''',''',id,''');'];
                    mcodeLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',selectionCmd],linesString);

                    idMatch=strcmp(subSet(:,1),id);
                    subSubSet=subSet(idMatch,3:4);
                    linkLinks='';
                    fixLinks='';
                    for k=1:size(subSubSet,1)
                        linkNo=subSubSet{k,1};

                        description=subSubSet{k,2};
                        editCmd=['slreq.internal.editLinksFrom(''',this.srcDomain,''',''',this.srcName,''',''',id,''',',num2str(linkNo),');'];
                        dialogLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',editCmd],description);
                        linkLinks=[linkLinks,'<br/>',dialogLink];%#ok<AGROW>

                        fixCmd=rmicheck.internal.ReportWriter.makeSetPropCommand('doc',this.srcDomain,this.srcName,id,linkNo,betterPath);
                        fixLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',fixCmd],getString(message('Slvnv:consistency:fix')));
                        fixLinks=[fixLinks,'<br/>',fixLink];%#ok<AGROW>
                    end
                    trimFront=length('<br/>')+1;
                    rmicheck.internal.ReportWriter.htmlTableRow(fid,mcodeLink,linkLinks(trimFront:end),fixLinks(trimFront:end));
                end
                if size(subSet,1)>1

                    allIds=subSet(:,1);
                    allLinkNo=cell2mat(subSet(:,3));
                    fixAllCmd=rmicheck.internal.ReportWriter.makeSetPropCommand('doc',this.srcDomain,this.srcName,allIds',allLinkNo',betterPath);
                    fixAllLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',fixAllCmd],getString(message('Slvnv:consistency:fixAll')));
                    rmicheck.internal.ReportWriter.htmlTableRow(fid,'&nbsp;','&nbsp;',fixAllLink);
                end
                rmicheck.internal.ReportWriter.htmlTableEnd(fid);
            end
            hasErrors=rmicheck.internal.ReportWriter.appendErrorInfoIfAny(fid,'path',counts);
            if isAllInOne&&~hasErrors&&isempty(docs)
                rmicheck.internal.ReportWriter.htmlFontColorStart(fid,'#55cc00');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptNoIssues')));
                rmicheck.internal.ReportWriter.htmlFontColorEnd(fid);
            end
        end

        function writeResultsDoors(this,fid,counts,isAllInOne)
            if isAllInOne
                rmicheck.internal.ReportWriter.htmlSeparator(fid,'doors');
                rmicheck.internal.ReportWriter.htmlSection(fid,'Checking bidirectional links with IBM Rational DOORS',2);
            end
            myResults=this.checker.getResults('doors');
            if~isempty(myResults)


                titleString=getString(message('Slvnv:reqmgt:mdlAdvCheck:FollowingObjectsHaveNoLink'));
                rmicheck.internal.ReportWriter.htmlSection(fid,titleString);
                rmicheck.internal.ReportWriter.htmlTableStart(fid,this.itemTitle,...
                getString(message('Slvnv:reqmgt:mdlAdvCheck:LinkNumber')),...
                getString(message('Slvnv:reqmgt:mdlAdvCheck:TargetObjInDoors')),'&nbsp;');


                linkedItemInfo=myResults(:,2);
                sortByStrings=cell(size(linkedItemInfo));
                for i=1:length(linkedItemInfo)
                    sortByStrings{i}=this.itemDispFcn(linkedItemInfo{i});
                end
                [uniqueItems,idx,map]=unique(sortByStrings);
                for i=1:length(uniqueItems)
                    myId=myResults{idx(i),1};
                    linesString=sortByStrings{idx(i)};
                    selectionCmd=['rmi.navigate(''',this.srcDomain,''',''',this.srcName,''',''',myId,''');'];
                    mcodeLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',selectionCmd],linesString);

                    subSet=myResults(map==i,:);
                    dlgLinks='';
                    docLinks='';
                    for j=1:size(subSet,1)
                        myReqNo=subSet{j,3};

                        editCmd=['slreq.internal.editLinksFrom(''',this.srcDomain,''',''',this.srcName,''',''',myId,''',',num2str(myReqNo),');'];
                        dlgLabel=getString(message('Slvnv:reqmgt:mdlAdvCheck:LinkNumberN',num2str(myReqNo)));
                        dlgLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',editCmd],dlgLabel);
                        dlgLinks=[dlgLinks,'<br/>',dlgLink];%#ok<AGROW>

                        targetDescription=subSet{j,6};
                        navCmd=['slreq.internal.navigateLinkFrom(''',this.srcDomain,''',''',this.srcName,''',''',myId,''',',num2str(myReqNo),');'];
                        docLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',navCmd],targetDescription);
                        docLinks=[docLinks,'<br/>',docLink];%#ok<AGROW>
                    end
                    trimFront=length('<br/>')+1;
                    rmicheck.internal.ReportWriter.htmlTableRow(fid,mcodeLink,dlgLinks(trimFront:end),docLinks(trimFront:end),'&nbsp;');
                end

                fixCmd=['rmiml.checkLinks(''',this.srcName,''',''fixDoors'');'];

                fixLink=rmicheck.internal.ReportWriter.httpHyperlink(['matlab:',fixCmd],getString(message('Slvnv:reqmgt:mdlAdvCheck:FixAll')));
                rmicheck.internal.ReportWriter.htmlTableRow(fid,'&nbsp;','&nbsp;','&nbsp;',fixLink);
                rmicheck.internal.ReportWriter.htmlTableEnd(fid);
            end
            hasErrors=rmicheck.internal.ReportWriter.appendErrorInfoIfAny(fid,'doors',counts);
            if isAllInOne&&~hasErrors&&isempty(myResults)
                rmicheck.internal.ReportWriter.htmlFontColorStart(fid,'#55cc00');
                rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:RptNoIssues')));
                rmicheck.internal.ReportWriter.htmlFontColorEnd(fid);
            end
        end

    end

    methods(Static,Access=private)



        function hasErrors=appendErrorInfoIfAny(fid,check,counts)
            errorsField=[check,'Errors'];
            loggedErrors=counts.(errorsField);
            if~isempty(loggedErrors)
                rmicheck.internal.ReportWriter.appendErrorInfo(fid,loggedErrors);
                hasErrors=true;
            else
                hasErrors=false;
            end
        end

        function cmdStr=makeSetPropCommand(propName,sourceDomain,sourceName,itemId,linkNo,value)
            if length(linkNo)>1
                linkNo=sprintf('%d,',linkNo);
                itemId=sprintf('%s,',itemId{:});
            else
                linkNo=num2str(linkNo);
            end
            switch sourceDomain
            case 'linktype_rmi_matlab'
                setPropCmd='rmiml.setProp';
            case 'linktype_rmi_data'
                setPropCmd='rmide.setProp';
            otherwise
                error('"Fix/Update" action not supported for %s domain',sourceDomain);
            end
            if nargin==5
                cmdStr=sprintf('%s(''%s'',''%s'',''%s'',''%s'');',...
                setPropCmd,propName,sourceName,itemId,linkNo);
            else
                cmdStr=sprintf('%s(''%s'',''%s'',''%s'',''%s'',''%s'');',...
                setPropCmd,propName,sourceName,itemId,linkNo,value);
            end
        end




        function htmlStart(fid,title,isAllInOne)
            if isAllInOne
                headerLevel=1;
            else
                headerLevel=3;
            end
            fprintf(fid,'<html><body><h%d>%s</h%d><blockquote>',...
            headerLevel,title,headerLevel);
        end

        function appendErrorInfo(fid,errors)
            rmicheck.internal.ReportWriter.htmlFontColorStart(fid,'#cc5500');
            rmicheck.internal.ReportWriter.htmlSection(fid,getString(message('Slvnv:consistency:FailedToCheck')));
            rmicheck.internal.ReportWriter.htmlListStart(fid);
            for i=1:length(errors)
                rmicheck.internal.ReportWriter.htmlListItem(fid,errors{i});
            end
            rmicheck.internal.ReportWriter.htmlListEnd(fid);
            rmicheck.internal.ReportWriter.htmlFontColorEnd(fid);
        end

        function htmlEnd(fid)
            fprintf(fid,'</blockquote></body></html>');
        end

        function htmlSeparator(fid,anchor)
            if nargin>1
                fprintf(fid,'<a name="%s">\n',anchor);
            end
            fprintf(fid,'<hr/>\n');
        end

        function htmlSection(fid,title,level)
            if nargin==2
                level=4;
            end
            fprintf(fid,'<h%d>%s</h%d>',level,title,level);
        end

        function htmlTableStart(fid,varargin)
            if isempty(varargin)
                fprintf(fid,'<table cellpadding=10>\n');
            else
                fprintf(fid,'<table cellpadding=10><tr>');
                for i=1:length(varargin)
                    fprintf(fid,'<td><b>%s</b></td>',varargin{i});
                end
                fprintf(fid,'</tr>\n');
            end
        end

        function htmlTableRow(fid,varargin)
            fprintf(fid,'<tr>');
            for i=1:length(varargin)
                fprintf(fid,'<td>%s</td>',varargin{i});
            end
            fprintf(fid,'</tr>\n');
        end

        function htmlTableEnd(fid)
            fprintf(fid,'</table>\n');
        end

        function result=httpHyperlink(url,label)
            result=['<a href="',url,'">',label,'</a>'];
        end

        function result=htmlTT(str)
            result=['<tt>',str,'</tt>'];
        end

        function result=htmlItalic(str)
            result=['<i>',str,'</i>'];
        end

        function result=htmlBoldPrefix(str,space)
            spaceHtml='';
            for i=1:space
                spaceHtml=[spaceHtml,'&nbsp;'];%#ok<AGROW>
            end
            result=sprintf('<b>%s%s</b>',str,spaceHtml);
        end

        function link=htmlLink(url,label)
            link=['<a href="',url,'">',label,'</a>'];
        end

        function htmlBlock(fid,content)
            fprintf(fid,'<blockquote>%s</blockquote>\n',content);
        end

        function htmlFontColorStart(fid,color)
            fprintf(fid,'<font color="%s">',color);
        end

        function htmlFontColorEnd(fid)
            fprintf(fid,'</font>');
        end

        function htmlListStart(fid)
            fprintf(fid,'<ul>\n');
        end

        function htmlListEnd(fid)
            fprintf(fid,'</ul>\n');
        end

        function htmlListItem(fid,item)
            fprintf(fid,'<li> %s',item);
        end

    end
end
