classdef FilterExplorer<handle




    properties(SetObservable=true)

        dialogTitle=''
        explorer=[]
        resultsExplorer=[]
        imme=[]
        am=[]
        ed=[];
        listeners=[]
        filterTree=[]
        ctxType=''
        ctxId=''
        viewCmd=''
        outputDir=''
        filters=[]
        filterTagCount=0
        uuid=''
        activeCvdId=[]
        tempCvdFileName=''
        callbacks=[]
        topModelName=''
        outputCvhtmlFile=''
    end
    properties(Constant)
        tmpFilterFileNamePrefix='FilterNode'
    end
    methods(Static=true)

        feObj=instanceMap(uuid,instance)

        fe=launchForSTM(ctxInfo)

        function tabChangedCallback(dlg,~,idx)
            dlg.getSource.m_impl.activeTab=idx;
        end

        function filterTabChangedCallback(hDialog,~,tab_Index)
            if isa(hDialog.getSource,'SlCovResultsExplorer.Folder')
                src=hDialog.getSource;
                src.m_impl.isCodeFilterTab=tab_Index==1;
                hDialog.refresh();
            end
        end

        function treeExpandedCallback(node)


            if isa(node,'cvi.FilterExplorer.FilterNode')
                node.parentTree.setSelectedNode(node);
            end
        end

        function destroy(obj)
            if isvalid(obj)
                if~strcmpi(obj.ctxType,'RE')
                    delete(obj.explorer);
                end
                delete(obj);
            end
        end

        function closeModelCallback(modelName)

            allInstances=cvi.FilterExplorer.FilterExplorer.instanceMap();
            if isempty(allInstances)
                return;
            end
            modelName=get_param(modelName,'name');
            obj=allInstances({allInstances.topModelName}==string(modelName));

            if~isempty(obj)&&~strcmpi(obj.ctxType,'RE')
                if~isempty(obj.activeCvdId)&&cv('ishandle',obj.activeCvdId)
                    obj.tempCvdFileName=tempname(tempdir);
                    cvsave(obj.tempCvdFileName,cvdata(obj.activeCvdId));
                end
            end
        end


        function close(obj)
            if~isvalid(obj)
                return;
            end

            failure=obj.triggerCallbackNoException('endCallback',obj.ctxId,obj.getAllFilterFiles);
            cvi.FilterExplorer.FilterExplorer.instanceMap(obj.ctxId,[]);
            cvi.FilterExplorer.FilterExplorer.destroy(obj);

            if~isempty(failure)
                rethrow(failure);
            end
        end



        function filterExplorer=getFilterExplorer(ctxInfo)
            try
                filterExplorer=[];
                filterCtxId=ctxInfo.filterCtxId;
                if isempty(filterCtxId)||startsWith(filterCtxId,'RE#')
                    topModelName=ctxInfo.topModelName;

                    if~isempty(filterCtxId)
                        filterExplorer=cvi.FilterExplorer.FilterExplorer.instanceMap(filterCtxId);
                    end

                    if isempty(filterExplorer)
                        try
                            get_param(topModelName,'handle');
                        catch %#ok<CTCH>
                            try
                                open_system(topModelName);
                            catch %#ok<CTCH>
                                error(message('Slvnv:simcoverage:cvdisplay:LoadError',topModelName));
                            end
                        end


                        re=cvi.ResultsExplorer.ResultsExplorer.findExistingDlg(topModelName);
                        if isempty(re)
                            re=cvi.ResultsExplorer.ResultsExplorer.getInstance(topModelName,[]);
                            filterExplorer=re.filterExplorer;
                        else
                            filterExplorer=re.filterExplorer;
                        end

                    end
                    filterExplorer.setCtx(ctxInfo);

                else




                    filterExplorer=cvi.FilterExplorer.FilterExplorer.instanceMap(filterCtxId);
                    if~isempty(filterExplorer)
                        filterExplorer.setCtx(ctxInfo);
                    end
                    if isempty(filterExplorer)
                        ctxId=ctxInfo.filterCtxId;
                        callbacks.filterChangedCallback=[];
                        callbacks.startCallback=[];
                        callbacks.endCallback=[];
                        if~contains(ctxId,'#TEST')
                            callbacks.startCallback=@(ctxId)stm.internal.Coverage.filterEditStartCallback(ctxId);
                            callbacks.endCallback=@(ctxId,filterFiles)stm.internal.Coverage.filterEditEndCallback(ctxId,filterFiles);
                        end

                        filterExplorer=cvi.FilterExplorer.FilterExplorer(ctxId);
                        filterExplorer.callbacks=callbacks;
                        filterExplorer.initView();
                        filterExplorer.setCtx(ctxInfo);
                    end
                end
            catch MEx
                rethrow(MEx);
            end
        end

        function fn=fixFileExtension(fn)
            ext='.cvf';
            if~endsWith(fn,ext)
                fn=[fn,ext];
            end
        end


        filterExplorer=openFilterCallback(filterCtxUUID,filterUUID,cvdataId,viewCmd,topModelName,fileName,forCode)
        reportRuleCallback(filterCtxUUID,filterUUID,cvdataId,viewCmd,topModelName,filterFileName,action,ssid,codeCovInfo,idx,outcomeIdx,metricName,descr)
    end
    methods

        function obj=FilterExplorer(ctxId,ctxInstace)
            if nargin==2
                obj.resultsExplorer=ctxInstace;
                title=getString(message('Slvnv:simcoverage:cvresultsexplorer:AppliedFilters'));
                obj.filterTree=cvi.FilterExplorer.FilterTree(title,obj);
                obj.topModelName=ctxInstace.topModelName;
            end
            obj.ctxId=ctxId;
            guidStr=char(matlab.lang.internal.uuid);
            obj.uuid=guidStr;
            cvi.FilterExplorer.FilterExplorer.instanceMap(obj.ctxId,obj);

        end

        function res=triggerStartCallback(obj)
            res=false;
            if~obj.imme.isVisible()
                obj.triggerCallback('startCallback',obj.ctxId);
                res=true;
            end
        end


        function setCtx(obj,ctxInfo)
            obj.viewCmd=ctxInfo.filterReportViewCmd;


            if~strcmpi(obj.ctxType,'RE')
                obj.setActiveData(ctxInfo.cvdId);
            else

                if~isempty(ctxInfo.filterFileName)
                    filterFiles=split(ctxInfo.filterFileName,',');
                    obj.addFilterFiles(filterFiles)
                end
            end
            if isfield(ctxInfo,'outputCvhtmlFile')
                obj.outputCvhtmlFile=ctxInfo.outputCvhtmlFile;
            end


            if isfield(ctxInfo,'topModelName')&&~isempty(ctxInfo.topModelName)&&...
                ischar(obj.topModelName)&&strcmp(obj.topModelName,get_param(0,'name'))
                obj.topModelName=ctxInfo.topModelName;
            end
        end

        function uuid=getUUID(obj)
            uuid=obj.uuid;
        end


        function fns=getFilterFileName(obj,filterIds)
            fns=cell(1,numel(filterIds));
            for idx=1:numel(filterIds)
                filterRec=getFilterRec(obj,filterIds{idx});
                if~isempty(filterRec)
                    fns{idx}=filterRec.fileName;
                end
            end
            fns(cellfun(@isempty,fns))=[];
        end


        function filterObj=getSelectedFilter(obj)
            filterObj=[];
            node=obj.filterTree.getSelectedNode;
            if~isempty(node)&&isa(node,'cvi.FilterExplorer.FilterNode')
                filterObj=node.filterRec.filterObj;
            end
        end

        function show(obj)
            if~isempty(obj.explorer)
                obj.explorer.show;
                obj.filterTree.selectRoot;
            end
        end

        function res=getOutputDir(obj)
            res='';
            if~isempty(obj.resultsExplorer)
                res=obj.resultsExplorer.getOutputDir();
            end

        end

        function initView(obj)

            if~isempty(obj.resultsExplorer)
                obj.ctxType='RE';
                obj.explorer=obj.resultsExplorer.explorer;
                obj.imme=obj.resultsExplorer.imme;
                obj.am=obj.resultsExplorer.am;
                obj.ed=obj.resultsExplorer.ed;
            else
                title=getString(message('Slvnv:simcoverage:cvresultsexplorer:AppliedFilters'));
                obj.filterTree=cvi.FilterExplorer.FilterTree(title,obj);
                obj.ctxType='ST';
                obj.dialogTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterExplorer'));
                obj.initExplorer(obj.filterTree.interface);
            end

            if~isempty(obj.filters)
                for idx=1:numel(obj.filters)
                    obj.filterTree.addNewFilterNode(obj.filters(idx));
                end
            end

        end

        function hide(obj)
            if~isempty(obj.explorer)
                obj.explorer.hide
            end
        end

        function showFilter(obj,filterId,forCode)
            if nargin<2
                obj.show();
                return;
            end

            if nargin<3
                forCode=false;
            end
            obj.explorer.show;
            if~isempty(obj.filterTree)
                obj.filterTree.show(filterId,forCode);
            end
        end

        function showFilterRule(obj,filterId,ssid,idx,outcomeIdx,metricName,forCode)
            obj.explorer.show;
            obj.filterTree.showFilterRule(filterId,ssid,idx,outcomeIdx,metricName,forCode);
        end

        function err=filterChangedCallback(obj,event,filterId)
            err='';
            if~strcmpi(event,'new')&&...
                ~strcmpi(event,'load')&&...
                ~strcmpi(event,'remove')&&...
                ~strcmpi(event,'replace')
                err=obj.serializeFilter(filterId);
            end
            if~isempty(err)
                return;
            end
            if~isempty(obj.filterTree)
                obj.ed.broadcastEvent('HierarchyChangedEvent',obj.filterTree.root.interface);
            end
            if strcmpi(obj.ctxType,'RE')&&...
                isvalid(obj.resultsExplorer)

                obj.resultsExplorer.filterChangedCallback(event,filterId);
            elseif strcmpi(obj.ctxType,'ST')
                if~strcmpi(event,'new')&&~strcmpi(event,'replace')
                    obj.applyOnActiveData();
                    obj.triggerCallback('filterChangedCallback',event,filterId);
                end
            end

        end

        function setActiveData(obj,cvdataId)
            if isempty(cvdataId)
                return;
            end

            oldCvd=obj.getActiveData();

            if isempty(oldCvd)||...
                (oldCvd.id~=cvdataId)
                obj.activeCvdId=cvdataId;
                cvd=obj.getActiveData();
                filterFiles=cvd.filter;
                if~iscell(filterFiles)
                    filterFiles={filterFiles};
                end
                for idx=1:numel(filterFiles)
                    if~isempty(filterFiles{idx})
                        obj.addFilterFromFile(filterFiles{idx});
                    end
                end

                obj.topModelName=get_param(cvdata.findTopModelHandle(cvd),'name');
            end
        end

        function cvd=getActiveData(obj)
            cvd=[];
            if~isempty(obj.activeCvdId)
                if~cv('ishandle',obj.activeCvdId)
                    if~isempty(obj.tempCvdFileName)
                        if~bdIsLoaded(obj.topModelName)
                            load_system(obj.topModelName);
                        end
                        [~,cvd]=cvload(obj.tempCvdFileName);
                        cvd=cvd{1};
                        obj.activeCvdId=cvd.id;

                    else
                        obj.activeCvdId=[];
                    end
                else
                    cvd=cvdata(obj.activeCvdId);
                    if~valid(cvd)
                        cvd=[];
                    end
                end
            end
        end

        function applyOnActiveData(obj)
            cvd=obj.getActiveData();
            if~isempty(cvd)
                newFilterFiles=obj.getAllFilterFiles;
                if isempty(cvd.filter)&&isempty(newFilterFiles)
                    return;
                end
                cvd.filter=newFilterFiles;
                if~isempty(obj.topModelName)
                    cvhs=cvi.CvhtmlSettings(obj.topModelName);
                else
                    cvhs=cvi.CvhtmlSettings;
                end
                cvhs.setFilterCtxId(obj.ctxId,obj.viewCmd);

                if strcmpi(obj.viewCmd,'cvhtml')
                    if isempty(obj.outputCvhtmlFile)
                        outFile=tempname(tempdir);
                    else
                        outFile=obj.outputCvhtmlFile;
                    end
                    cvhtml(outFile,cvd,cvhs);
                elseif strcmpi(obj.viewCmd,'cvmodelview')
                    cvmodelview(cvd,cvhs);
                end
            end
        end


        initExplorer(this,root)


        function tf=isHierarchyReadonly(~,~)
            tf=false;
        end


        function fn=generateFilterFileName(~,filterName,~)
            fn=filterName;
        end

        function filterObj=findFilterFromReportCallback(obj,filterUUID,fileName)
            filterObj=[];
            filterRec=obj.getFilterRec(filterUUID);

            if isempty(filterRec)
                filterFiles=split(fileName,',');

                filterRec=obj.getFilterRecByFileName(filterFiles{1});
            end
            if~isempty(filterRec)
                filterObj=filterRec.filterObj;
            end
        end

        function checkFilterName(obj,filterObj)
            if isempty(filterObj.filterName)
                newTag=getNewFilterTag(obj);
                maxCnt=0;
                foundOne=false;
                for idx=1:numel(obj.filters)
                    cfn=obj.filters(idx).filterObj.filterName;
                    if contains(cfn,newTag)
                        foundOne=true;
                        if contains(cfn,'_')
                            maxCnt=max(maxCnt,str2double(cfn(numel(newTag)+2:end)));
                        end
                    end
                end
                if foundOne
                    filterObj.filterName=[newTag,'_',num2str(maxCnt+1)];
                else
                    filterObj.filterName=newTag;
                end
            end

        end


        function tag=getNewFilterTag(obj)


            tag=getString(message('Slvnv:simcoverage:cvresultsexplorer:UntitledFilterName'));
        end


        function newFilterRec=replaceFilterRec(obj,filterId,filterObj,fileName)

            filterObj.setUUID;
            newFilterRec=cvi.FilterExplorer.FilterRecord(filterObj,fileName);
            filterRecIdx=find({obj.filters.uuid}==string(filterId));
            oldFilterRec=obj.filters(filterRecIdx);
            obj.filters(filterRecIdx)=newFilterRec;
            obj.filterChangedCallback('replace',{oldFilterRec.uuid,newFilterRec.uuid});
        end


        function filterRec=getFilterRec(obj,filterId)
            filterRec=[];

            filterRecIdx=[];
            if~isempty(obj.filters)
                filterRecIdx=find({obj.filters.uuid}==string(filterId));
            end
            if~isempty(filterRecIdx)
                filterRec=obj.filters(filterRecIdx);
            end
        end

        function filterRec=getFilterRecByFileName(obj,fileName)
            filterRec=[];
            if~isempty(obj.filters)
                filterRec=obj.filters({obj.filters.fileName}==string(fileName));
            end
        end


        function idx=addNewFilterRec(obj,filter,fileName)
            if nargin<3
                fileName='';
            end
            if~isempty(fileName)
                fileName=cvi.FilterExplorer.FilterExplorer.fixFileExtension(fileName);
            end
            filterRec=cvi.FilterExplorer.FilterRecord(filter,fileName);
            if isempty(obj.filters)
                obj.filters=filterRec;
            else
                obj.filters(end+1)=filterRec;
            end
            idx=numel(obj.filters);
            obj.filterChangedCallback('new',filterRec.uuid);
        end

        function removeFilterRec(obj,filterId)
            filterRecIdx=[];
            if~isempty(obj.filters)
                filterRecIdx=find({obj.filters.uuid}==string(filterId));
            end
            if~isempty(filterRecIdx)
                filterIdToRemove=obj.filters(filterRecIdx).uuid;
                obj.filters(filterRecIdx)=[];
                obj.filterChangedCallback('remove',filterIdToRemove);
            end
        end


        function filterObj=newFilter(obj,filterName)
            if nargin<2
                filterName='';
            end
            filterObj=SlCov.FilterEditor.createFilter('');
            filterObj.filterName=filterName;
            filterObj.modelName=obj.topModelName;
            checkFilterName(obj,filterObj);
            idx=obj.addNewFilterRec(filterObj,'');
            if~isempty(obj.filterTree)
                filterRec=obj.filters(idx);
                obj.filterTree.addNewFilterNode(filterRec);
                obj.filterTree.show(filterRec.uuid)
            end
        end

        function filterObj=addFilterFromFile(obj,fileName)
            filterObj=[];
            foundFileName=SlCov.FilterEditor.findFile(fileName);
            if isempty(foundFileName)
                return;
            end
            filterObj=SlCov.FilterEditor.createFilter(fileName);
            filterObj.modelName=obj.topModelName;
            if~isempty(obj.filters)
                if~isempty(find({obj.filters.uuid}==string(filterObj.getUUID),1))
                    filterObj=[];
                    return;
                end
            end
            checkFilterName(obj,filterObj);
            idx=obj.addNewFilterRec(filterObj,fileName);
            if~isempty(obj.filterTree)
                obj.filterTree.addNewFilterNode(obj.filters(idx));
            end
        end

        function addFilterFiles(obj,filterFiles)
            for idx=1:numel(filterFiles)
                cfn=filterFiles{idx};
                if~isempty(cfn)&&isempty(obj.getFilterRecByFileName(cfn))
                    obj.addFilterFromFile(cfn);
                end
            end
            obj.filterTree.expandRoot();
        end

        function loadFilter(obj)
            fileFilterSpec={'*.cvf',getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageFilterFiles'));...
            '*.*',getString(message('Slvnv:simcoverage:cvresultsexplorer:AllFiles'))};
            title=getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadFilter'));
            [fileName,path,~]=uigetfile(fileFilterSpec,title);
            if fileName~=0
                fullFileName=fullfile(path,fileName);
                filterObj=obj.addFilterFromFile(fullFileName);
                if~isempty(filterObj)
                    [hasModel,hasCode]=filterObj.hasModelOrCodeRules();
                    obj.filterTree.show(filterObj.getUUID,~hasModel&&hasCode);
                    obj.filterChangedCallback('load',filterObj.getUUID);
                else
                    msg=getString(message('Slvnv:simcoverage:cvresultsexplorer:AlreadyLoaded',fullFileName));
                    warndlg(msg,getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadFilter')),'modal');
                end
            end
        end


        function saveFilter(obj,filterId)
            filterRec=getFilterRec(obj,filterId);

            if~isempty(filterRec.fileName)
                fileFilterSpec=filterRec.fileName;
            else
                if~isempty(obj.getOutputDir())
                    fileFilterSpec=[obj.getOutputDir(),filesep,filterRec.filterObj.filterName,'.cvf'];
                else
                    fileFilterSpec={'*.cvf',getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageFilterFiles'));...
                    '*.*',getString(message('Slvnv:simcoverage:cvresultsexplorer:AllFiles'))};
                end
            end

            title=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveFilter'));

            fullFileName=cvi.ResultsExplorer.ResultsExplorer.uiPutFile(fileFilterSpec,title);

            if~isempty(fullFileName)
                filterNode=obj.filterTree.getSelectedNode();

                if~isempty(filterRec.fileName)
                    filterRec=obj.replaceFilterRec(filterId,filterRec.filterObj,fullFileName);
                    filterNode.setFilterRec(filterRec);
                else
                    filterRec.fileName=fullFileName;
                end

                filterNode.apply();
            end
        end


        function removeFilter(obj,filterId)
            obj.removeFilterRec(filterId);
            if~isempty(obj.filterTree)
                obj.filterTree.removeFilterNode(filterId);
                obj.filterTree.selectRoot();
            end

        end

        function err=saveFilterObj(~,filterRec)
            err='';
            [dir,~]=fileparts(filterRec.fileName);
            if isempty(dir)
                fullFileName=fullfile(filterRec.fileDir,filterRec.fileName);
            else
                fullFileName=filterRec.fileName;
            end
            filterRec.filterObj.save(fullFileName);
        end

        function err=serializeFilter(obj,filterId)
            err='';
            filterRec=obj.getFilterRec(filterId);
            if isempty(filterRec.fileName)
                obj.saveFilter(filterRec.filterObj.getUUID);
            else
                err=obj.saveFilterObj(filterRec);
            end
        end


        function fileNames=getAllFilterFiles(obj)
            fileNames=[];
            if~isempty(obj.filters)
                fileNames={obj.filters.fileName};
            end
        end

        function res=hasFilters(obj)
            res=~isempty(obj.filters);
        end

        function filterObjs=getAllFilterObjs(obj)
            filterObjs=[];
            if~isempty(obj.filters)
                filterObjs=[obj.filters.filterObj];
            end
        end


        function failure=triggerCallbackNoException(this,callbackName,varargin)
            failure=[];
            if~isempty(this.callbacks)
                callbackFcn=this.callbacks.(callbackName);
                if~isempty(callbackFcn)
                    try
                        callbackFcn(varargin{:});
                    catch MEx
                        failure=MEx;
                    end
                end
            end
        end

        function triggerCallback(this,callbackName,varargin)
            failure=this.triggerCallbackNoException(callbackName,varargin{:});
            if~isempty(failure)
                rethrow(failure);
            end
        end


        [selectedFilter,isCancelled]=promptFilterSelection(this)
    end
end


