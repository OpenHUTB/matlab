classdef Checker<handle





    properties(Access=private)
        srcName;
        domain;
        itemGetter;
resultsTable
    end

    methods
        function this=Checker(pathToSourceFile,sourceDomain,domainItemGetter)
            this.srcName=pathToSourceFile;
            this.domain=sourceDomain;
            this.itemGetter=domainItemGetter;




            this.resultsTable=cell(0,7);
        end

        function[faultCounters,stats]=checkSource(this,check,filters,faultCounters)

            if strcmp(check,'all')


                [hasWord,hasExcel]=rmicheck.internal.Checker.setup(this.srcName);
                faultCounters.docCount=0;
                faultCounters.idCount=0;
                faultCounters.labelCount=0;
                faultCounters.pathCount=0;
                faultCounters.doorsCount=0;
                faultCounters.docErrors={};
                faultCounters.idErrors={};
                faultCounters.labelErrors={};
                faultCounters.pathErrors={};
                faultCounters.doorsErrors={};
            else
                switch check
                case 'doc'
                    faultCounters.docCount=0;
                    faultCounters.docErrors={};
                case 'id'
                    faultCounters.idCount=0;
                    faultCounters.idErrors={};
                case 'label'
                    faultCounters.labelCount=0;
                    faultCounters.labelErrors={};
                case 'path'
                    faultCounters.pathCount=0;
                    faultCounters.pathErrors={};
                case 'doors'
                    faultCounters.doorsCount=0;
                    faultCounters.doorsErrors={};

                otherwise
                    error(message('Slvnv:rmiref:docCheckCallback:UnknownMethod',check));
                end
            end

            linkedItems=this.itemGetter(this.srcName);
            totalLinkedItems=size(linkedItems,1);
            totalLinks=0;
            totalChecked=0;



            if rmisl.isSidString(this.srcName)
                refObj=strtok(this.srcName,':');
            else
                refObj=this.srcName;
            end
            for i=1:totalLinkedItems
                linkedItemId=linkedItems{i,1};
                linkedItemInfo=linkedItems{i,3};
                reqInfoStruct=slreq.getReqs(this.srcName,linkedItemId,this.domain);
                if~isempty(filters)
                    [~,filterMatched]=rmi.filterTags(reqInfoStruct,filters.tagsRequire,filters.tagsExclude);
                else
                    filterMatched=true(size(reqInfoStruct));
                end
                for j=1:length(reqInfoStruct)
                    totalLinks=totalLinks+1;
                    if~filterMatched(j)
                        continue;
                    end
                    totalChecked=totalChecked+1;
                    oneReqInfo=reqInfoStruct(j);
                    skip=false;

                    if any(strcmp(check,{'doc','all'}))
                        try
                            success=rmicheck.checkDoc(oneReqInfo.reqsys,oneReqInfo.doc,refObj);
                        catch Mex
                            success=false;
                            this_error=rmiut.errorToHtml([this.srcName,'|',linkedItemId],oneReqInfo,Mex,'doc');
                            if isempty(this_error)
                                this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                            else
                                skip=true;
                            end
                            if~any(strcmp(faultCounters.docErrors,this_error))
                                faultCounters.docErrors{end+1}=this_error;
                            end
                        end
                        if~success
                            faultCounters.docCount=faultCounters.docCount+1;
                            if~skip
                                this.storeFailed('doc',linkedItemId,linkedItemInfo,j,oneReqInfo.doc,oneReqInfo.description,'');
                            else
                                continue;
                            end
                        end
                    end

                    if any(strcmp(check,{'path','all'}))
                        try
                            [success,newPath]=rmicheck.checkPath(oneReqInfo.reqsys,oneReqInfo.doc,refObj);
                        catch Mex
                            success=false;
                            newPath='';
                            this_error=rmiut.errorToHtml([this.srcName,'|',linkedItemId],oneReqInfo,Mex,'path');
                            if isempty(this_error)
                                this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                            else
                                skip=true;
                            end
                            if~any(strcmp(faultCounters.pathErrors,this_error))
                                faultCounters.pathErrors{end+1}=this_error;
                            end
                        end
                        if~success
                            faultCounters.pathCount=faultCounters.pathCount+1;
                            if~skip
                                if~isempty(newPath)
                                    this.storeFailed('path',linkedItemId,linkedItemInfo,j,oneReqInfo.doc,oneReqInfo.description,newPath);
                                end
                            else
                                skip=false;
                            end
                        end
                    end

                    if any(strcmp(check,{'id','all'}))
                        try
                            success=rmicheck.checkId(oneReqInfo.reqsys,oneReqInfo.doc,oneReqInfo.id,refObj);
                        catch Mex
                            success=false;
                            this_error=rmiut.errorToHtml([this.srcName,'|',linkedItemId],oneReqInfo,Mex,'id');
                            if isempty(this_error)
                                this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                            else
                                skip=true;
                            end
                            if~any(strcmp(faultCounters.idErrors,this_error))
                                faultCounters.idErrors{end+1}=this_error;
                            end
                        end
                        if~success
                            faultCounters.idCount=faultCounters.idCount+1;
                            if~skip
                                this.storeFailed('id',linkedItemId,linkedItemInfo,j,oneReqInfo.doc,oneReqInfo.description,oneReqInfo.id);
                            else
                                continue;
                            end
                        end
                    end

                    if any(strcmp(check,{'label','all'}))
                        try
                            [success,newLabel]=rmicheck.checkDesc(oneReqInfo,refObj);
                        catch Mex
                            success=false;
                            newLabel='';
                            this_error=rmiut.errorToHtml([this.srcName,'|',linkedItemId],oneReqInfo,Mex,'label');
                            if isempty(this_error)
                                this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                            else
                                skip=true;
                            end
                            if~any(strcmp(faultCounters.labelErrors,this_error))
                                faultCounters.labelErrors{end+1}=this_error;
                            end
                        end
                        if~success
                            faultCounters.labelCount=faultCounters.labelCount+1;
                            if~skip&&~isempty(newLabel)
                                this.storeFailed('label',linkedItemId,linkedItemInfo,j,oneReqInfo.doc,oneReqInfo.description,newLabel);
                            end
                        end
                    end

                    if any(strcmp(check,{'doors','all'}))
                        if~strcmp(oneReqInfo.reqsys,'linktype_rmi_doors')
                            continue;
                        end
                        try

                            if~reqmgt('findProc','doors.exe')
                                ME=MException(message('Slvnv:reqmgt:linktype_rmi_doors:IsValidDocFcn'));
                                throw(ME);
                            end
                            linkType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_doors');
                            [success,doorsInfo]=linkType.BacklinkCheckFcn(this.srcName,linkedItemId,strtok(oneReqInfo.doc),oneReqInfo.id);
                        catch Mex
                            success=false;
                            doorsInfo='';
                            this_error=rmiut.errorToHtml([this.srcName,'|',linkedItemId],oneReqInfo,Mex,'doc');
                            if isempty(this_error)
                                this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                            else
                                skip=true;
                            end
                            if~any(strcmp(faultCounters.doorsErrors,this_error))
                                faultCounters.doorsErrors{end+1}=this_error;
                            end
                        end
                        if~success
                            faultCounters.doorsCount=faultCounters.doorsCount+1;
                            if~skip&&~isempty(doorsInfo)
                                this.storeFailed('doors',linkedItemId,linkedItemInfo,j,oneReqInfo.doc,oneReqInfo.id,doorsInfo);
                            end
                        end
                    end
                end
            end


            if isfield(faultCounters,'doorsCount')&&faultCounters.doorsCount>0
                rmicheck.internal.Checker.doorsFixAll(this.srcName,this.getResults('doors'));
            end




            if strcmp(check,'all')
                rmicheck.internal.Checker.cleanup(hasWord,hasExcel);
            end

            faultCounters.(check)=now;
            stats=[totalLinkedItems,totalLinks,totalChecked];
        end

        function failures=getResults(this,check)
            match=strcmp(this.resultsTable(:,1),check);
            failures=this.resultsTable(match,2:end);
        end

        function storeFailed(this,varargin)
            this.resultsTable(end+1,:)=varargin;
        end
    end

    methods(Static)

        function out=cachedResults(key,in)
            persistent results;
            if~isa(results,'containers.Map')||isempty(key)
                results=containers.Map('KeyType','char','ValueType','any');
            end
            out=[];
            if isempty(key)
                return;
            end
            if isKey(results,key)
                out=results(key);
            end
            if nargin==2
                results(key)=in;
            end
        end

        function[errorCount,errors]=packErrors(check,data)
            switch check
            case 'doc'
                errorCount=data.docCount;
                errors=data.docErrors;
            case 'id'
                errorCount=data.idCount;
                errors=data.idErrors;
            case 'label'
                errorCount=data.labelCount;
                errors=data.labelErrors;
            case 'path'
                errorCount=data.pathCount;
                errors=data.pathErrors;
            case 'doors'
                errorCount=data.doorsCount;
                errors=data.doorsErrors;
            case 'all'
                errorCount=[data.docCount;data.idCount;data.labelCount;data.pathCount];
                errors={data.docErrors;data.idErrors;data.labelErrors;data.pathErrors};
            otherwise
                error(message('Slvnv:rmiref:docCheckCallback:UnknownMethod',check));
            end
        end

        function doorsFixAll(srcName,data)
            persistent doorsResults;

            if nargin==2

                if isempty(doorsResults)
                    doorsResults=containers.Map('KeyType','char','ValueType','any');
                end
                doorsResults(srcName)=data;

            elseif~isKey(doorsResults,srcName)
                errordlg(...
                getString(message('Slvnv:reqmgt:mdlAdvCheck:StaleMaReport')),...
                getString(message('Slvnv:reqmgt:mdlAdvCheck:DoorsFixAll')),'modal');

            else
                linkType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_doors');
                resultsTable=doorsResults(srcName);
                for i=1:size(resultsTable,1)
                    try
                        linkType.BacklinkInsertFcn(resultsTable{i,4},resultsTable{i,5},srcName,resultsTable{i,1});
                    catch Ex
                        errordlg({...
                        getString(message('Slvnv:reqmgt:mdlAdvCheck:FailedToInsertLink',strtok(resultsTable{i,2}))),...
                        Ex.message},...
                        getString(message('Slvnv:reqmgt:mdlAdvCheck:DoorsFixAll')));
                        break;
                    end
                end
            end
        end






        function[hasWord,hasExcel]=setup(linkSource)
            hasWord=false;
            hasExcel=false;
            [docs,~,reqsys]=rmiml.getLinkedItems(linkSource);
            for i=1:length(docs)
                linkType=rmi.getLinktype(reqsys{i},docs{i});
                switch linkType.Registration
                case 'linktype_rmi_word'
                    hasWord=true;
                case 'linktype_rmi_excel'
                    hasExcel=true;
                otherwise
                end
                if hasWord&&hasExcel
                    break;
                end
            end
            if hasWord
                ok=rmicom.wordRpt('setup');
                if~ok
                    warning(message('Slvnv:consistency:FailedToSetupMS','word'));
                    hasWord=false;
                end
            end
            if hasExcel
                ok=rmicom.excelRpt('setup');
                if~ok
                    warning(message('Slvnv:consistency:FailedToSetupMS','excel'));
                    hasExcel=false;
                end
            end
        end

        function cleanup(hasWord,hasExcel)
            if hasWord
                rmicom.wordRpt('destroy');
            end
            if hasExcel
                rmicom.excelRpt('destroy');
            end
        end

    end
end
