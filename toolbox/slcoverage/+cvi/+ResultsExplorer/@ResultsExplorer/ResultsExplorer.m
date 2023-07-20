
classdef ResultsExplorer<handle




    properties(SetObservable=true)
        explorer=[]
        imme=[]
        am=[]
        ed=[];
        root=[]
        topModelName=[]
        topModelHandle=[]
        outputDir=''
        inputDir=''
        dataFileName=''
        saveFileName=''
        aggregatedDataFileName=''
        aggregatedReportFileName=''
        filterEditor=[]
        tempFilterFileName=''
        dialogTag=''
        widgetTag=''
        dialogTitle=''
        testCount=1
        runTag=getString(message('Slvnv:simcoverage:cvresultsexplorer:Run'))
        maps=[]
        highlightedNode=[]
        listeners=[]
        synced=false
        incompatibleFiles={}
        htmlOptions=[]
        modelToSyncOptions=[]
        hierarchyChangedListener=[]
        lastActiveDataCount=0
        isClosing=false
        filterExplorer=[];
        uuid='';
        loadedfilterFileNames=[]
    end




    methods

        function obj=ResultsExplorer(topModelName,modelToSyncOptions)
            obj.uuid=['RE#',char(matlab.lang.internal.uuid)];

            obj.topModelName=topModelName;
            obj.topModelHandle=get_param(topModelName,'handle');
            if isempty(modelToSyncOptions)
                obj.modelToSyncOptions=topModelName;
            else
                obj.modelToSyncOptions=modelToSyncOptions;
            end
            obj.dialogTag=cvi.ResultsExplorer.ResultsExplorer.getDialogTag(obj.topModelName);
            obj.widgetTag=obj.dialogTag;
            obj.dialogTitle=[getString(message('Slvnv:simcoverage:cvresultsexplorer:WindowTitle')),': ',topModelName];

            obj.root=cvi.ResultsExplorer.Root.create(obj);

            createFilterEditor(obj);
            createMaps(obj);
            addListeners(obj);
        end

        function res=getOutputDir(obj)
            if isempty(obj.outputDir)
                options=getOptions(obj);
                obj.outputDir=cvi.TopModelCov.checkOutputDir(options.covOutputDir);
                if~isempty(obj.outputDir)
                    obj.dataFileName=options.covDataFileName;
                    obj.aggregatedDataFileName=[obj.dataFileName,'_cum'];
                    obj.aggregatedReportFileName=[obj.dataFileName,'_cum_report'];
                    obj.saveFileName=obj.topModelName;
                end
            end
            res=obj.outputDir;
        end


        function setInputDir(obj,inpDir)
            obj.inputDir=inpDir;
        end

        function res=getInputDir(obj)
            if isempty(obj.inputDir)
                obj.inputDir=obj.getOutputDir();
            end
            res=obj.inputDir;
        end


        function setRunTag(obj,tag)
            obj.runTag=tag;
        end

        activeModel=getActiveModel(obj)
        tag=getNextRunTag(obj)
        data=addData(obj,cvd,fileName,toCheckSDI)
        node=addToPassiveRoot(obj,data)
        data=addCvData(obj,cvd,fileName)
        addToActiveRoot(obj,data)
        save(obj)
        show(obj)
        checksum=getChecksum(obj)
        removeIncompatibleData=addChecksum(obj,modelName,cvd)
        res=compareChecksum(obj,cvd,modelName)
        [res,partial]=matchChecksum(obj,cvd)
        setChecksumFirstTime(obj,cvdatas)
        loadObj(obj)
        saveObj(obj)
        removeIncompatibleData(obj)
        deleteTreeNode(obj,node,permanently)
        node=findNode(obj,uuid)
        syncAllData(obj)
        loadAllData(obj)
        loadDataFromUI(obj,addToActiveTree)
        res=loadData(obj,selectedFileNames,addToActiveTree)
        addedNodes=initTrees(obj,usedIdMap)
        createMaps(obj)
        addDataToMaps(obj,data)
        removeDataFromMaps(obj,data)
        removeNodes(obj,nodes)
        removeInvalidData(obj)
        data=getDataByUniqueId(obj,uniqueId)
        res=isLoaded(obj,filename)
        res=isCvdLoaded(obj,cvd)
        tree=getNodeTree(~,node)
        tf=canAcceptDrop(obj,acceptNode,dropNode)
        tf=acceptDrop(obj,acceptNode,dropNode)
        refreshTreeView(obj)
        highlightCurrentData(obj)
        reportCurrentData(obj)
        highlightChange(obj,node,add)
        [status,id]=revertFilter(obj,dlg)
        saveFilterCallback(obj)
        loadFilterCallback(obj)
        filterChangedCallback(obj,event,filterId)
        makeCodeProverFilterCallback(obj,filterEditor)
        showFilterMetricRule(this,ssid,idx,outcomeIdx,metricName)
        showFilter(obj,forCode,filterId)
        createFilterEditor(obj)
        filterObj=getFilter(obj)
        loadFilter(obj,fullFileName)
        saveFilter(obj,fullFileName)
        copyFilter(obj,nodes)
        change=postApplyFilter(obj)
        addFilter(obj,cvd,isTmp,filterFileName)
        handleModelAttachedFilter(obj,node)
        dataChange(~,node)
        tf=isHierarchyReadonly(~,node)
        res=compareHtmlOptions(~,opt1,opt2)
        [options,res]=setOptions(obj,newOptions)
        [options,res]=getOptions(obj)
        resetLastReportLinks(obj)
        res=getCallbackString(obj,command,varargin)
        modelKey=genModelKey(obj,cvd,modelName)
        addListeners(obj)
    end



    methods(Static=true)


        function obj=create(topModelName,modelToSyncOptions,forceLoad)
            obj=cvi.ResultsExplorer.ResultsExplorer(topModelName,modelToSyncOptions);
            ri=obj.root.interface;

            obj.initExplorer(ri);
            if forceLoad
                getOutputDir(obj);
                obj.loadObj;
            end


            obj.filterExplorer.initView();
            obj.filterExplorer.addFilterFiles(obj.loadedfilterFileNames);
            obj.loadedfilterFileNames=[];

        end

        function obj=getInstance(topModelName,modelToSyncOptions,forceLoad)
            if nargin<3
                forceLoad=false;
            end
            if SlCov.CoverageAPI.checkCvLicense==0
                obj=[];
                return;
            end
            obj=cvi.ResultsExplorer.ResultsExplorer.findExistingDlg(topModelName);
            if isempty(obj)
                obj=cvi.ResultsExplorer.ResultsExplorer.create(topModelName,modelToSyncOptions,forceLoad);
            end
        end
        fullFileName=uiPutFile(fileFilter,title)
        aNode=activeNode(varargin)
        saveCumDataCallback(topModelName)
        saveDataCallback(topModelName)
        saveAllDataCallback(topModelName)
        loadCallback(topModelName)
        deleteCallback(topModelName,permanently)
        clearCallback(topModelName)
        addCallback(topModelName)
        addAllCallback(topModelName)
        gotoCallback(topModelName,isDst)
        showNodeCallback(topModelName,uuid)
        treeExpandedCallback(obj,tree)
        hierarchyChangedCallback(s,e,obj)
        tag=getDialogTag(topModelName)
        obj=findExistingDlg(topModelName)
        obj=hide(topModelName)
        close(topModelHandle)
        obj=setChecksum(topModelName,cvdIn)
        res=closeAll()
        status=makeFilter(filterObj,sldvDataFile)
        msg=checkLicense
        checkSDI(data,modelName)
        highlightRemoved(topModelName)
        makeFilterCallback(obj,topModelName,filterEditor)
        helpFcn(dialogTag)
    end

    methods(Static,Access=protected)
        function chkInfo=newChecksumInfo(key,checksum,modelName,dbVersion)
            if nargin<4
                dbVersion='';
            end
            if nargin<3
                modelName='';
            end
            if nargin<2
                checksum='';
            end
            if nargin<1
                key='';
            end
            chkInfo=struct('key',key,'checksum',checksum,'modelName',modelName,'dbVersion',dbVersion);
        end
    end
end


